import '../models/service_config.dart';
import '../models/service_manifest.dart';
import 'package:path/path.dart' as path;

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
    required String servicesPath,
    List<String>? specificServices,
  }) {
    final buffer = StringBuffer();
    final activeServices = _getActiveServices(services, specificServices);

    // Write services section
    buffer.writeln('services:');
    buffer.writeln();
    for (final entry in activeServices.entries) {
      final config = entry.value;
      final manifest = manifests[config.name];

      if (manifest == null) continue;

      _writeService(
        buffer,
        config: config,
        manifest: manifest,
        servicesPath: servicesPath,
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
    if (specificServices != null && specificServices.isNotEmpty) {
      return Map.fromEntries(
        services.entries.where((entry) => specificServices.contains(entry.key)),
      );
    }
    return Map.fromEntries(
      services.entries.where((entry) => entry.value.enabled),
    );
  }

  /// Writes a single service configuration
  void _writeService(
    StringBuffer buffer, {
    required ServiceConfig config,
    required ServiceManifest manifest,
    required String servicesPath,
    required String indent,
  }) {
    buffer.writeln('$indent${config.name}:');

    // Build context and args
    buffer.writeln('$indent  build:');
    buffer.writeln(
        '$indent    context: ./services/${config.category}/${config.name}');
    buffer.writeln('$indent    args:');
    buffer.writeln('$indent      VERSION: ${config.version}');

    // Container name
    buffer.writeln('$indent  container_name: ${config.name}');

    // Restart policy
    buffer.writeln('$indent  restart: unless-stopped');

    // Environment variables
    final envVars = <String>[];
    // Add manifest environment variables
    if (manifest.environment.isNotEmpty) {
      for (final env in manifest.environment) {
        if (config.config.containsKey('password') && env == 'REDIS_PASSWORD') {
          continue; // Skip REDIS_PASSWORD from manifest if we have it in config
        }
        envVars.add(env);
      }
    }
    // Add config-based environment variables
    if (config.config.containsKey('password')) {
      envVars.add('REDIS_PASSWORD=${config.config['password']}');
    }
    if (envVars.isNotEmpty) {
      buffer.writeln('$indent  environment:');
      for (final env in envVars) {
        buffer.writeln('$indent    - $env');
      }
    }

    // Volumes
    if (manifest.volumes.isNotEmpty) {
      buffer.writeln('$indent  volumes:');
      for (final volume in manifest.volumes) {
        buffer.writeln('$indent    - $volume');
      }
    }

    // Ports
    if (config.config.containsKey('port')) {
      buffer.writeln('$indent  ports:');
      buffer.writeln(
          '$indent    - "${config.config['port']}:${config.config['port']}"');
    }

    // Health check
    buffer.writeln('$indent  healthcheck:');
    buffer.writeln(
        '$indent    test: ["CMD-SHELL", "${manifest.healthCheck.command}"]');
    buffer.writeln('$indent    interval: ${manifest.healthCheck.interval}');
    buffer.writeln('$indent    timeout: ${manifest.healthCheck.timeout}');
    buffer.writeln('$indent    retries: ${manifest.healthCheck.retries}');

    // Networks
    buffer.writeln('$indent  networks:');
    buffer.writeln('$indent    - $defaultNetwork');

    // Service-specific configuration
    if (config.config.isNotEmpty) {
      buffer.writeln('$indent  # Service-specific configuration');
      for (final entry in config.config.entries) {
        if (entry.key != 'port') {
          // Skip port as it's handled above
          buffer.writeln('$indent  # ${entry.key}: ${entry.value}');
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
