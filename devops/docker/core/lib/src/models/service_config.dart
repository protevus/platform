import 'package:meta/meta.dart';

/// Represents a service configuration from dev-services.yaml
@immutable
class ServiceConfig {
  /// The name of the service
  final String name;

  /// The category this service belongs to (e.g., 'database', 'messaging')
  final String category;

  /// The version of the service to use
  final String version;

  /// Whether this service is enabled
  final bool enabled;

  /// Service-specific configuration options
  final Map<String, dynamic> config;

  /// Creates a new service configuration
  const ServiceConfig({
    required this.name,
    required this.category,
    required this.version,
    required this.enabled,
    required this.config,
  });

  /// Creates a service configuration from YAML data
  factory ServiceConfig.fromYaml(String name, Map<String, dynamic> yaml) {
    return ServiceConfig(
      name: name,
      category: yaml['category'] as String? ?? 'uncategorized',
      version: yaml['version'] as String? ?? 'latest',
      enabled: yaml['enabled'] as bool? ?? false,
      config: yaml['config'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Creates a copy of this config with the given fields replaced
  ServiceConfig copyWith({
    String? name,
    String? category,
    String? version,
    bool? enabled,
    Map<String, dynamic>? config,
  }) {
    return ServiceConfig(
      name: name ?? this.name,
      category: category ?? this.category,
      version: version ?? this.version,
      enabled: enabled ?? this.enabled,
      config: config ?? Map<String, dynamic>.from(this.config),
    );
  }

  /// Converts this config to a YAML-compatible map
  Map<String, dynamic> toYaml() {
    return {
      'category': category,
      'version': version,
      'enabled': enabled,
      'config': config,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceConfig &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          category == other.category &&
          version == other.version &&
          enabled == other.enabled &&
          _mapsEqual(config, other.config);

  @override
  int get hashCode =>
      name.hashCode ^
      category.hashCode ^
      version.hashCode ^
      enabled.hashCode ^
      config.hashCode;

  @override
  String toString() =>
      'ServiceConfig(name: $name, category: $category, version: $version, enabled: $enabled, config: $config)';

  /// Helper method to compare maps
  bool _mapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (identical(map1, map2)) return true;
    if (map1.length != map2.length) return false;
    return map1.entries.every((entry) =>
        map2.containsKey(entry.key) && map2[entry.key] == entry.value);
  }
}
