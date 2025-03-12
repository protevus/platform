import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Exception thrown when Docker operations fail
class DockerException implements Exception {
  final String message;
  final Object? cause;

  DockerException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'DockerException: $message\nCaused by: $cause';
    }
    return 'DockerException: $message';
  }
}

/// Status of a service container
enum ServiceStatus {
  running,
  stopped,
  error,
  unknown,
}

/// Information about a service container
class ServiceInfo {
  /// Current status of the service
  final ServiceStatus status;

  /// Container statistics (CPU, memory, etc)
  final Map<String, String> stats;

  ServiceInfo({
    required this.status,
    this.stats = const {},
  });
}

/// Utilities for Docker operations
class DockerUtils {
  /// Project name for docker-compose
  final String projectName;

  /// Path to docker-compose file
  final String composePath;

  DockerUtils({
    required this.projectName,
    required this.composePath,
  });

  /// Check if Docker is available
  Future<bool> checkDockerAvailable() async {
    try {
      final result = await Process.run('docker', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Check if Docker Compose is available
  Future<bool> checkComposeAvailable() async {
    try {
      final result = await Process.run('docker', ['compose', 'version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Start services
  Future<void> startServices([List<String>? services]) async {
    final args = [
      'compose',
      '-f',
      composePath,
      '-p',
      projectName,
      'up',
      '-d',
      '--remove-orphans',
      '--build',
    ];

    if (services != null && services.isNotEmpty) {
      args.addAll(services);
    }

    final result = await Process.run('docker', args);
    if (result.exitCode != 0) {
      throw DockerException(
        'Failed to start services: ${result.stderr}',
      );
    }
  }

  /// Stop services
  Future<void> stopServices([List<String>? services]) async {
    final args = [
      'compose',
      '-f',
      composePath,
      '-p',
      projectName,
      'down',
    ];

    if (services != null && services.isNotEmpty) {
      args.addAll(services);
    }

    final result = await Process.run('docker', args);
    if (result.exitCode != 0) {
      throw DockerException(
        'Failed to stop services: ${result.stderr}',
      );
    }
  }

  /// Get status of services
  Future<Map<String, ServiceInfo>> getServicesStatus([
    List<String>? services,
  ]) async {
    final status = <String, ServiceInfo>{};

    // Get container IDs
    final psResult = await Process.run(
      'docker',
      [
        'compose',
        '-f',
        composePath,
        '-p',
        projectName,
        'ps',
        '-q',
        if (services != null && services.isNotEmpty) ...services,
      ],
    );

    if (psResult.exitCode != 0) {
      throw DockerException(
        'Failed to get service status: ${psResult.stderr}',
      );
    }

    final containerIds = LineSplitter.split(psResult.stdout.toString())
        .where((id) => id.isNotEmpty)
        .toList();

    // Get container details
    for (final id in containerIds) {
      final inspectResult = await Process.run(
        'docker',
        ['inspect', id],
      );

      if (inspectResult.exitCode != 0) continue;

      try {
        final data = json.decode(inspectResult.stdout.toString()) as List;
        if (data.isEmpty) continue;

        final container = data.first as Map<String, dynamic>;
        final name = container['Name'] as String;
        final serviceName = name.split('_').last.replaceAll('-', '');
        final state = container['State'] as Map<String, dynamic>;

        // Get status
        ServiceStatus serviceStatus;
        if (state['Running'] as bool) {
          if (state['Health'] != null) {
            final health = state['Health'] as Map<String, dynamic>;
            serviceStatus = health['Status'] == 'healthy'
                ? ServiceStatus.running
                : ServiceStatus.error;
          } else {
            serviceStatus = ServiceStatus.running;
          }
        } else {
          serviceStatus = ServiceStatus.stopped;
        }

        // Get stats if running
        final stats = <String, String>{};
        if (serviceStatus == ServiceStatus.running) {
          final statsResult = await Process.run(
            'docker',
            [
              'stats',
              '--no-stream',
              '--format',
              '{{.CPUPerc}},{{.MemUsage}}',
              id
            ],
          );

          if (statsResult.exitCode == 0) {
            final parts = statsResult.stdout.toString().trim().split(',');
            if (parts.length == 2) {
              stats['cpu_usage'] = parts[0];
              stats['memory_usage'] = parts[1];
            }
          }
        }

        status[serviceName] = ServiceInfo(
          status: serviceStatus,
          stats: stats,
        );
      } catch (e) {
        // Skip containers that can't be inspected
        continue;
      }
    }

    return status;
  }

  /// Get logs for a service
  Future<String> getLogs(
    String service, {
    int? tail,
    bool follow = false,
  }) async {
    final args = [
      'compose',
      '-f',
      composePath,
      '-p',
      projectName,
      'logs',
      if (follow) '--follow',
      if (tail != null) '--tail=$tail',
      service,
    ];

    final result = await Process.run('docker', args);
    if (result.exitCode != 0) {
      throw DockerException(
        'Failed to get logs: ${result.stderr}',
      );
    }

    return result.stdout.toString();
  }

  /// Execute command in a service container
  Future<ProcessResult> execInService(
    String service,
    List<String> command, {
    bool interactive = false,
  }) async {
    // Get container ID
    final psResult = await Process.run(
      'docker',
      [
        'compose',
        '-f',
        composePath,
        '-p',
        projectName,
        'ps',
        '-q',
        service,
      ],
    );

    if (psResult.exitCode != 0) {
      throw DockerException(
        'Failed to get container ID: ${psResult.stderr}',
      );
    }

    final containerId = psResult.stdout.toString().trim();
    if (containerId.isEmpty) {
      throw DockerException('Service container not found: $service');
    }

    // Execute command
    final args = [
      'exec',
      if (interactive) '-it',
      containerId,
      ...command,
    ];

    final result = await Process.run('docker', args);
    if (result.exitCode != 0) {
      throw DockerException(
        'Command execution failed: ${result.stderr}',
      );
    }

    return result;
  }

  /// Clean up service resources
  Future<void> cleanup({
    bool removeVolumes = false,
    bool removeImages = false,
    List<String>? services,
  }) async {
    // Stop services
    await stopServices(services);

    // Remove volumes if requested
    if (removeVolumes) {
      final args = [
        'compose',
        '-f',
        composePath,
        '-p',
        projectName,
        'down',
        '-v',
      ];

      if (services != null && services.isNotEmpty) {
        args.addAll(services);
      }

      final result = await Process.run('docker', args);
      if (result.exitCode != 0) {
        throw DockerException(
          'Failed to remove volumes: ${result.stderr}',
        );
      }
    }

    // Remove images if requested
    if (removeImages) {
      final args = [
        'compose',
        '-f',
        composePath,
        '-p',
        projectName,
        'down',
        '--rmi',
        'all',
      ];

      if (services != null && services.isNotEmpty) {
        args.addAll(services);
      }

      final result = await Process.run('docker', args);
      if (result.exitCode != 0) {
        throw DockerException(
          'Failed to remove images: ${result.stderr}',
        );
      }
    }
  }
}
