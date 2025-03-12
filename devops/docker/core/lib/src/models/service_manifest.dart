import 'package:meta/meta.dart';

/// Represents a health check configuration for a service
@immutable
class HealthCheck {
  /// The command to run for health checking
  final String command;

  /// The interval between health checks
  final String interval;

  /// The timeout for health check
  final String timeout;

  /// Number of retries before marking unhealthy
  final int retries;

  const HealthCheck({
    required this.command,
    required this.interval,
    required this.timeout,
    required this.retries,
  });

  factory HealthCheck.fromYaml(Map<String, dynamic> yaml) {
    return HealthCheck(
      command: yaml['command'] as String,
      interval: yaml['interval'] as String? ?? '30s',
      timeout: yaml['timeout'] as String? ?? '5s',
      retries: yaml['retries'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'command': command,
      'interval': interval,
      'timeout': timeout,
      'retries': retries,
    };
  }
}

/// Represents configuration schema for a service parameter
@immutable
class ConfigSchema {
  /// The type of the configuration value
  final String type;

  /// The default value if not specified
  final dynamic defaultValue;

  /// Whether this configuration is required
  final bool required;

  /// Description of what this configuration does
  final String? description;

  const ConfigSchema({
    required this.type,
    this.defaultValue,
    this.required = false,
    this.description,
  });

  factory ConfigSchema.fromYaml(Map<String, dynamic> yaml) {
    return ConfigSchema(
      type: yaml['type'] as String,
      defaultValue: yaml['default'],
      required: yaml['required'] as bool? ?? false,
      description: yaml['description'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'type': type,
      if (defaultValue != null) 'default': defaultValue,
      'required': required,
      if (description != null) 'description': description,
    };
  }
}

/// Represents a service module's manifest
@immutable
class ServiceManifest {
  /// The name of the service
  final String name;

  /// The category this service belongs to
  final String category;

  /// List of supported versions
  final List<String> supportedVersions;

  /// The default version to use
  final String defaultVersion;

  /// Schema for configuration options
  final Map<String, ConfigSchema> configSchema;

  /// List of volume mappings
  final List<String> volumes;

  /// List of required environment variables
  final List<String> environment;

  /// Health check configuration
  final HealthCheck healthCheck;

  /// Optional description of the service
  final String? description;

  const ServiceManifest({
    required this.name,
    required this.category,
    required this.supportedVersions,
    required this.defaultVersion,
    required this.configSchema,
    required this.volumes,
    required this.environment,
    required this.healthCheck,
    this.description,
  });

  factory ServiceManifest.fromYaml(Map<String, dynamic> yaml) {
    final configSchemaYaml =
        yaml['config_schema'] as Map<String, dynamic>? ?? {};
    final configSchema = configSchemaYaml.map(
      (key, value) => MapEntry(
        key,
        ConfigSchema.fromYaml(value as Map<String, dynamic>),
      ),
    );

    return ServiceManifest(
      name: yaml['name'] as String,
      category: yaml['category'] as String,
      supportedVersions: (yaml['versions'] as List<dynamic>).cast<String>(),
      defaultVersion: yaml['default_version'] as String,
      configSchema: configSchema,
      volumes: (yaml['volumes'] as List<dynamic>?)?.cast<String>() ?? [],
      environment:
          (yaml['environment'] as List<dynamic>?)?.cast<String>() ?? [],
      healthCheck: HealthCheck.fromYaml(
          yaml['health_check'] as Map<String, dynamic>? ?? {}),
      description: yaml['description'] as String?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'name': name,
      'category': category,
      'versions': supportedVersions,
      'default_version': defaultVersion,
      'config_schema': configSchema.map(
        (key, value) => MapEntry(key, value.toYaml()),
      ),
      'volumes': volumes,
      'environment': environment,
      'health_check': healthCheck.toYaml(),
      if (description != null) 'description': description,
    };
  }

  /// Validates a configuration against this manifest's schema
  List<String> validateConfig(Map<String, dynamic> config) {
    final errors = <String>[];

    // Check for required fields
    for (final entry in configSchema.entries) {
      if (entry.value.required && !config.containsKey(entry.key)) {
        errors.add('Missing required configuration: ${entry.key}');
      }
    }

    // Validate types and values
    for (final entry in config.entries) {
      final schema = configSchema[entry.key];
      if (schema == null) {
        errors.add('Unknown configuration option: ${entry.key}');
        continue;
      }

      // Type validation
      switch (schema.type) {
        case 'string':
          if (entry.value is! String) {
            errors.add(
                '${entry.key} must be a string, got ${entry.value.runtimeType}');
          }
          break;
        case 'integer':
          if (entry.value is! int) {
            errors.add(
                '${entry.key} must be an integer, got ${entry.value.runtimeType}');
          }
          break;
        case 'number':
          if (entry.value is! num) {
            errors.add(
                '${entry.key} must be a number, got ${entry.value.runtimeType}');
          }
          break;
        case 'boolean':
          if (entry.value is! bool) {
            errors.add(
                '${entry.key} must be a boolean, got ${entry.value.runtimeType}');
          }
          break;
      }
    }

    return errors;
  }

  /// Validates if a version is supported
  bool isVersionSupported(String version) {
    return supportedVersions.contains(version);
  }
}
