import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

import 'models/service_config.dart';
import 'models/service_manifest.dart';
import 'utils/compose_generator.dart';
import 'utils/docker_utils.dart';

/// Exception thrown when service operations fail
class ServiceException implements Exception {
  final String message;
  final Object? cause;

  ServiceException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'ServiceException: $message\nCaused by: $cause';
    }
    return 'ServiceException: $message';
  }
}

/// Manages development services
class ServiceManager {
  final Logger _logger = Logger('ServiceManager');
  final String configPath;
  final String servicesPath;
  final String workingDir;

  late final ComposeGenerator _composeGenerator;
  late final DockerUtils _dockerUtils;

  Map<String, ServiceConfig> _services = {};
  Map<String, ServiceManifest> _manifests = {};

  ServiceManager({
    required this.configPath,
    required this.servicesPath,
    required this.workingDir,
  }) {
    _composeGenerator = ComposeGenerator();
    _dockerUtils = DockerUtils(
      composeFile: path.join(workingDir, 'docker-compose.generated.yml'),
      projectName: 'dev_services',
    );
  }

  /// Initialize the service manager
  Future<void> initialize() async {
    await _validateEnvironment();
    await _loadConfig();
    await _discoverServices();
  }

  /// Validate Docker environment
  Future<void> _validateEnvironment() async {
    if (!await _dockerUtils.checkDockerAvailable()) {
      throw ServiceException('Docker is not available');
    }
    if (!await _dockerUtils.checkComposeAvailable()) {
      throw ServiceException('Docker Compose is not available');
    }
  }

  /// Load service configurations
  Future<void> _loadConfig() async {
    final file = File(configPath);
    if (!await file.exists()) {
      throw ServiceException('Configuration file not found: $configPath');
    }

    try {
      final yamlString = await file.readAsString();
      final yaml = loadYaml(yamlString) as Map;

      _services = {};
      final services = yaml['services'] as Map? ?? {};

      for (final category in services.keys) {
        final categoryServices = services[category] as Map? ?? {};
        for (final serviceName in categoryServices.keys) {
          _services[serviceName as String] = ServiceConfig.fromYaml(
            serviceName,
            categoryServices[serviceName] as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      throw ServiceException('Failed to load configuration', e);
    }
  }

  /// Discover available service modules
  Future<void> _discoverServices() async {
    final dir = Directory(servicesPath);
    if (!await dir.exists()) {
      throw ServiceException('Services directory not found: $servicesPath');
    }

    try {
      _manifests = {};
      await for (final category in dir.list()) {
        if (category is Directory) {
          await for (final service in category.list()) {
            if (service is Directory) {
              final manifestFile =
                  File(path.join(service.path, 'manifest.yaml'));
              if (await manifestFile.exists()) {
                final yaml = loadYaml(await manifestFile.readAsString()) as Map;
                final manifest = ServiceManifest.fromYaml(
                  yaml as Map<String, dynamic>,
                );
                _manifests[manifest.name] = manifest;
              }
            }
          }
        }
      }
    } catch (e) {
      throw ServiceException('Failed to discover services', e);
    }
  }

  /// Start services
  Future<void> startServices([List<String>? services]) async {
    try {
      // Generate docker-compose file
      final composeContent = _composeGenerator.generate(
        services: _services,
        manifests: _manifests,
        specificServices: services,
      );

      // Write docker-compose file
      final composeFile =
          File(path.join(workingDir, 'docker-compose.generated.yml'));
      await composeFile.writeAsString(composeContent);

      // Start services
      await _dockerUtils.startServices(services);
    } catch (e) {
      throw ServiceException('Failed to start services', e);
    }
  }

  /// Stop services
  Future<void> stopServices([List<String>? services]) async {
    try {
      await _dockerUtils.stopServices(services);
    } catch (e) {
      throw ServiceException('Failed to stop services', e);
    }
  }

  /// Get status of services
  Future<Map<String, ServiceInfo>> getServicesStatus([
    List<String>? services,
  ]) async {
    try {
      return await _dockerUtils.getServicesStatus(services);
    } catch (e) {
      throw ServiceException('Failed to get service status', e);
    }
  }

  /// Add a new service
  Future<void> addService(String name, String category) async {
    final serviceDir = Directory(path.join(servicesPath, category, name));
    if (await serviceDir.exists()) {
      throw ServiceException('Service already exists: $name');
    }

    try {
      // Create service directory structure
      await serviceDir.create(recursive: true);

      // Create manifest file
      final manifestFile = File(path.join(serviceDir.path, 'manifest.yaml'));
      await manifestFile.writeAsString('''
name: $name
category: $category
versions:
  - "latest"
default_version: "latest"
config_schema: {}
volumes: []
environment: []
health_check:
  command: "exit 0"
  interval: "30s"
  timeout: "5s"
  retries: 3
''');

      // Create Dockerfile
      final dockerFile = File(path.join(serviceDir.path, 'Dockerfile'));
      await dockerFile.writeAsString('''
ARG VERSION
FROM ${name}:\${VERSION}

LABEL maintainer="DevOps Team"
''');

      // Update configuration
      await _updateConfig(name, category);
    } catch (e) {
      // Cleanup on failure
      if (await serviceDir.exists()) {
        await serviceDir.delete(recursive: true);
      }
      throw ServiceException('Failed to add service', e);
    }
  }

  /// Remove a service
  Future<void> removeService(String name) async {
    final service = _services[name];
    if (service == null) {
      throw ServiceException('Service not found: $name');
    }

    try {
      // Stop service if running
      await stopServices([name]);

      // Remove service directory
      final serviceDir =
          Directory(path.join(servicesPath, service.category, name));
      if (await serviceDir.exists()) {
        await serviceDir.delete(recursive: true);
      }

      // Update configuration
      _services.remove(name);
      await _saveConfig();
    } catch (e) {
      throw ServiceException('Failed to remove service', e);
    }
  }

  /// Configure a service
  Future<void> configureService(
    String name,
    Map<String, dynamic> config,
  ) async {
    final service = _services[name];
    if (service == null) {
      throw ServiceException('Service not found: $name');
    }

    final manifest = _manifests[name];
    if (manifest == null) {
      throw ServiceException('Service manifest not found: $name');
    }

    // Validate configuration
    final errors = manifest.validateConfig(config);
    if (errors.isNotEmpty) {
      throw ServiceException(
        'Invalid configuration:\n${errors.join('\n')}',
      );
    }

    try {
      // Update service configuration
      _services[name] = service.copyWith(config: config);
      await _saveConfig();
    } catch (e) {
      throw ServiceException('Failed to configure service', e);
    }
  }

  /// Update configuration file with new service
  Future<void> _updateConfig(String name, String category) async {
    _services[name] = ServiceConfig(
      name: name,
      category: category,
      version: 'latest',
      enabled: false,
      config: {},
    );
    await _saveConfig();
  }

  /// Save current configuration to file
  Future<void> _saveConfig() async {
    final config = {
      'services': _groupServicesByCategory(),
    };

    try {
      final file = File(configPath);
      await file.writeAsString(json2yaml(config));
    } catch (e) {
      throw ServiceException('Failed to save configuration', e);
    }
  }

  /// Group services by category for configuration file
  Map<String, Map<String, dynamic>> _groupServicesByCategory() {
    final grouped = <String, Map<String, dynamic>>{};

    for (final service in _services.values) {
      grouped.putIfAbsent(service.category, () => {});
      grouped[service.category]![service.name] = service.toYaml();
    }

    return grouped;
  }

  /// Get logs for a service
  Future<String> getServiceLogs(
    String name, {
    int? tail,
    bool follow = false,
  }) async {
    if (!_services.containsKey(name)) {
      throw ServiceException('Service not found: $name');
    }

    try {
      return await _dockerUtils.getLogs(name, tail: tail, follow: follow);
    } catch (e) {
      throw ServiceException('Failed to get service logs', e);
    }
  }

  /// Execute command in a service container
  Future<ProcessResult> execInService(
    String name,
    List<String> command, {
    bool interactive = false,
  }) async {
    if (!_services.containsKey(name)) {
      throw ServiceException('Service not found: $name');
    }

    try {
      return await _dockerUtils.execInService(
        name,
        command,
        interactive: interactive,
      );
    } catch (e) {
      throw ServiceException('Failed to execute command in service', e);
    }
  }

  /// Clean up service resources
  Future<void> cleanup({
    bool removeVolumes = false,
    bool removeImages = false,
    List<String>? services,
  }) async {
    try {
      await _dockerUtils.cleanup(
        removeVolumes: removeVolumes,
        removeImages: removeImages,
        services: services,
      );
    } catch (e) {
      throw ServiceException('Failed to clean up services', e);
    }
  }
}

/// Convert a Map to YAML string
String json2yaml(Map<String, dynamic> json) {
  final buffer = StringBuffer();
  _writeYaml(json, buffer);
  return buffer.toString();
}

/// Helper function to write YAML with proper formatting
void _writeYaml(dynamic data, StringBuffer buffer, {String indent = ''}) {
  if (data is Map) {
    for (final entry in data.entries) {
      buffer.write('$indent${entry.key}:');
      if (entry.value is Map || entry.value is List) {
        buffer.writeln();
        _writeYaml(entry.value, buffer, indent: '$indent  ');
      } else {
        buffer.write(' ${_formatValue(entry.value)}\n');
      }
    }
  } else if (data is List) {
    if (data.isEmpty) {
      buffer.writeln(' []');
    } else {
      buffer.writeln();
      for (final item in data) {
        buffer.write('$indent- ');
        if (item is Map || item is List) {
          _writeYaml(item, buffer, indent: '$indent  ');
        } else {
          buffer.writeln(_formatValue(item));
        }
      }
    }
  }
}

/// Format YAML values properly
String _formatValue(dynamic value) {
  if (value == null) return 'null';
  if (value is String) {
    if (value.contains('\n') || value.contains('"')) {
      return "|\n    ${value.replaceAll('\n', '\n    ')}";
    }
    if (value.contains(' ') || value.isEmpty) {
      return '"$value"';
    }
    return value;
  }
  return value.toString();
}
