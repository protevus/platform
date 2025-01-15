import 'package:yaml/yaml.dart';
import '../models/service_config.dart';
import '../models/service_manifest.dart';

/// Generates docker-compose configuration for services
class ComposeGenerator {
  /// The version of docker-compose file format to use
  final String composeVersion;

  /// Default network name for services
  final String defaultNetwork;

  ComposeGenerator({
    this.composeVersion = '3.8',
    this.defaultNetwork = 'dev_network',
  });

  /// Generates a docker-compose.yml content for the given services
  String generate({
    required Map<String, ServiceConfig> services,
    required Map<String, ServiceManifest> manifests,
    List<String>? specificServices,
  }) {
    final buffer = StringBuffer();
    final activeServices = _getActiveServices(services, specificServices);

    // Write header
    buffer.writeln('version: "$composeVersion"');
    buffer.writeln();

    // Write services section
    buffer.writeln('services:');
    for (final entry in activeServices.entries) {
      final config = entry.value;
      final manifest = manifests[config.name];

      if (manifest == null) continue;

      _writeService(
        buffer,
        config: config,
        manifest: manifest,
        indent: '  ',
      );
    }

    // Write networks section
    buffer.writeln();
    buffer.writeln('networks:');
    buffer.writeln('  $defaultNetwork:');
    buffer.writeln('    driver: bridge');

    // Write volumes section if any services define volumes
    final allVolumes = _collectVolumes(activeServices.values, manifests);
    if (allVolumes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('volumes:');
      for (final volume in allVolumes) {
        buffer.writeln('  $volume:');
        buffer.writeln('    driver: local');
      }
    }

    return buffer.toString();
  }

  /// Gets the list of services to include based on configuration and specific services requested
  Map<String, ServiceConfig> _getActiveServices(
    Map<String, ServiceConfig> services,
    List<String>? specificServices,
  ) {
    if (specificServices == null || specificServices.isEmpty) {
      return Map.fromEntries(
        services.entries.where((entry) => entry.value.enabled),
      );
    }
    return Map.fromEntries(
      services.entries.where((entry) => specificServices.contains(entry.key)),
    );
  }

  /// Writes a single service configuration
  void _writeService(
    StringBuffer buffer, {
    required ServiceConfig config,
    required ServiceManifest manifest,
    required String indent,
  }) {
    buffer.writeln('$indent${config.name}:');

    // Build context and args
    buffer.writeln('${indent}  build:');
    buffer.writeln('${indent}    context: ./${config.category}/${config.name}');
    buffer.writeln('${indent}    args:');
    buffer.writeln('${indent}      - VERSION=${config.version}');

    // Container name
    buffer.writeln('${indent}  container_name: ${config.name}');

    // Restart policy
    buffer.writeln('${indent}  restart: unless-stopped');

    // Environment variables
    if (manifest.environment.isNotEmpty) {
      buffer.writeln('${indent}  environment:');
      for (final env in manifest.environment) {
        buffer.writeln('${indent}    - $env');
      }
    }

    // Volumes
    if (manifest.volumes.isNotEmpty) {
      buffer.writeln('${indent}  volumes:');
      for (final volume in manifest.volumes) {
        buffer.writeln('${indent}    - $volume');
      }
    }

    // Ports
    if (config.config.containsKey('port')) {
      buffer.writeln('${indent}  ports:');
      buffer.writeln(
          '${indent}    - "${config.config['port']}:${config.config['port']}"');
    }

    // Health check
    buffer.writeln('${indent}  healthcheck:');
    buffer.writeln('${indent}    test: ${manifest.healthCheck.command}');
    buffer.writeln('${indent}    interval: ${manifest.healthCheck.interval}');
    buffer.writeln('${indent}    timeout: ${manifest.healthCheck.timeout}');
    buffer.writeln('${indent}    retries: ${manifest.healthCheck.retries}');

    // Networks
    buffer.writeln('${indent}  networks:');
    buffer.writeln('${indent}    - $defaultNetwork');

    // Service-specific configuration
    if (config.config.isNotEmpty) {
      buffer.writeln('${indent}  # Service-specific configuration');
      for (final entry in config.config.entries) {
        if (entry.key != 'port') {
          // Skip port as it's handled above
          buffer.writeln('${indent}  # ${entry.key}: ${entry.value}');
        }
      }
    }
  }

  /// Collects all unique volume names from services
  Set<String> _collectVolumes(
    Iterable<ServiceConfig> configs,
    Map<String, ServiceManifest> manifests,
  ) {
    final volumes = <String>{};
    for (final config in configs) {
      final manifest = manifests[config.name];
      if (manifest == null) continue;

      for (final volume in manifest.volumes) {
        // Extract volume name from volume mapping (e.g., "data:/var/lib/data" -> "data")
        final volumeName = volume.split(':').first;
        if (!volumeName.startsWith('/')) {
          volumes.add(volumeName);
        }
      }
    }
    return volumes;
  }
}
