import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// Status of a Docker service
enum ServiceStatus {
  running,
  stopped,
  error,
  unknown,
}

/// Information about a running service
class ServiceInfo {
  final String name;
  final ServiceStatus status;
  final String? containerId;
  final Map<String, dynamic> stats;

  ServiceInfo({
    required this.name,
    required this.status,
    this.containerId,
    Map<String, dynamic>? stats,
  }) : stats = stats ?? {};

  @override
  String toString() =>
      'ServiceInfo(name: $name, status: $status, containerId: $containerId, stats: $stats)';
}

/// Exception thrown when a Docker operation fails
class DockerException implements Exception {
  final String message;
  final String? command;
  final int? exitCode;
  final String? stderr;

  DockerException(
    this.message, {
    this.command,
    this.exitCode,
    this.stderr,
  });

  @override
  String toString() {
    final buffer = StringBuffer('DockerException: $message');
    if (command != null) buffer.write('\nCommand: $command');
    if (exitCode != null) buffer.write('\nExit code: $exitCode');
    if (stderr != null && stderr!.isNotEmpty) {
      buffer.write('\nError output: $stderr');
    }
    return buffer.toString();
  }
}

/// Utilities for working with Docker
class DockerUtils {
  final Logger _logger = Logger('DockerUtils');
  final String _composeFile;
  final String _projectName;

  DockerUtils({
    required String composeFile,
    String? projectName,
  })  : _composeFile = composeFile,
        _projectName = projectName ?? path.basename(path.dirname(composeFile));

  /// Runs a docker-compose command
  Future<ProcessResult> _runComposeCmd(
    List<String> args, {
    bool throwOnError = true,
  }) async {
    final fullArgs = [
      '-f',
      _composeFile,
      '-p',
      _projectName,
      ...args,
    ];

    _logger.fine('Running docker-compose ${fullArgs.join(" ")}');

    final result = await Process.run('docker-compose', fullArgs);

    if (throwOnError && result.exitCode != 0) {
      throw DockerException(
        'docker-compose command failed',
        command: 'docker-compose ${fullArgs.join(" ")}',
        exitCode: result.exitCode,
        stderr: result.stderr.toString(),
      );
    }

    return result;
  }

  /// Starts services
  Future<void> startServices([List<String>? services]) async {
    final args = ['up', '-d', '--remove-orphans'];
    if (services != null && services.isNotEmpty) {
      args.addAll(services);
    }

    await _runComposeCmd(args);
  }

  /// Stops services
  Future<void> stopServices([List<String>? services]) async {
    final args = services != null && services.isNotEmpty
        ? ['stop', ...services]
        : ['down'];
    await _runComposeCmd(args);
  }

  /// Gets status of all services or specific services
  Future<Map<String, ServiceInfo>> getServicesStatus([
    List<String>? services,
  ]) async {
    final result = await _runComposeCmd(
      ['ps', '--format', 'json'],
      throwOnError: false,
    );

    if (result.exitCode != 0) {
      _logger.warning('Failed to get service status: ${result.stderr}');
      return {};
    }

    final output = result.stdout.toString().trim();
    if (output.isEmpty) return {};

    try {
      final List<dynamic> psOutput = json.decode(output);
      final Map<String, ServiceInfo> status = {};

      for (final container in psOutput) {
        final name = container['Service'] as String;
        if (services != null && !services.contains(name)) continue;

        final state = container['State'] as String;
        final containerId = container['ID'] as String?;

        // Get container stats if running
        Map<String, dynamic>? stats;
        if (state.toLowerCase() == 'running' && containerId != null) {
          stats = await _getContainerStats(containerId);
        }

        status[name] = ServiceInfo(
          name: name,
          status: _parseStatus(state),
          containerId: containerId,
          stats: stats,
        );
      }

      return status;
    } catch (e) {
      _logger.severe('Error parsing docker-compose ps output', e);
      return {};
    }
  }

  /// Gets detailed stats for a container
  Future<Map<String, dynamic>?> _getContainerStats(String containerId) async {
    try {
      final result = await Process.run(
        'docker',
        ['stats', '--no-stream', '--format', 'json', containerId],
      );

      if (result.exitCode != 0) return null;

      final output = result.stdout.toString().trim();
      if (output.isEmpty) return null;

      return json.decode(output);
    } catch (e) {
      _logger.warning('Failed to get container stats: $e');
      return null;
    }
  }

  /// Parses Docker status string into ServiceStatus enum
  ServiceStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return ServiceStatus.running;
      case 'exited':
      case 'stopped':
        return ServiceStatus.stopped;
      case 'error':
      case 'dead':
      case 'oom':
        return ServiceStatus.error;
      default:
        return ServiceStatus.unknown;
    }
  }

  /// Executes a command in a service container
  Future<ProcessResult> execInService(
    String service,
    List<String> command, {
    bool interactive = false,
  }) async {
    final args = [
      'exec',
      if (interactive) '-it',
      service,
      ...command,
    ];

    return _runComposeCmd(args);
  }

  /// Gets logs for a service
  Future<String> getLogs(
    String service, {
    int? tail,
    bool follow = false,
  }) async {
    final args = ['logs'];
    if (tail != null) args.add('--tail=$tail');
    if (follow) args.add('--follow');
    args.add(service);

    final result = await _runComposeCmd(args, throwOnError: false);
    return result.stdout.toString();
  }

  /// Checks if Docker daemon is running and accessible
  Future<bool> checkDockerAvailable() async {
    try {
      final result = await Process.run('docker', ['info']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Checks if docker-compose is installed and accessible
  Future<bool> checkComposeAvailable() async {
    try {
      final result = await Process.run('docker-compose', ['version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Pulls latest images for services
  Future<void> pullImages([List<String>? services]) async {
    final args = ['pull'];
    if (services != null && services.isNotEmpty) {
      args.addAll(services);
    }

    await _runComposeCmd(args);
  }

  /// Builds service images
  Future<void> buildImages([List<String>? services]) async {
    final args = ['build'];
    if (services != null && services.isNotEmpty) {
      args.addAll(services);
    }

    await _runComposeCmd(args);
  }

  /// Removes service containers, networks, and volumes
  Future<void> cleanup({
    bool removeVolumes = false,
    bool removeImages = false,
    List<String>? services,
  }) async {
    final args = ['down'];
    if (removeVolumes) args.add('-v');
    if (removeImages) args.add('--rmi=all');
    if (services != null && services.isNotEmpty) {
      args.addAll(services);
    }

    await _runComposeCmd(args);
  }
}
