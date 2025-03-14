import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import '../../command.dart';

/// Command to discover available services and update configuration
class DiscoverCommand extends Command {
  @override
  String get name => 'services:discover';

  @override
  String get description =>
      'Discover available services and update configuration';

  @override
  String get signature =>
      'services:discover {--category=? : Only discover services in specific category} {--dry-run : Show changes without applying} {--force : Overwrite all configurations}';

  @override
  Future<void> handle() async {
    final category = option<String>('category')?.toLowerCase() == '?'
        ? null
        : option<String>('category');
    final dryRun = option<bool>('dry-run') ?? false;
    final force = option<bool>('force') ?? false;

    output.info('Discovering services...');

    try {
      final servicesPath = 'devops/docker/services';
      final configPath = path.join('devops', 'docker', 'dev-services.yaml');

      // Load existing configuration
      final existingConfig = await _loadExistingConfig(configPath);
      final discoveredServices =
          await _discoverServices(servicesPath, category);

      // Merge configurations
      final newConfig = await _mergeConfigurations(
        existing: existingConfig,
        discovered: discoveredServices,
        force: force,
      );

      if (dryRun) {
        _printChanges(existingConfig, newConfig);
      } else {
        await _saveConfiguration(configPath, newConfig);
        output.success('Configuration updated successfully');
      }
    } catch (e) {
      output.error('Failed to discover services: $e');
      rethrow;
    }
  }

  /// Load existing configuration from dev-services.yaml
  Future<Map<String, dynamic>> _loadExistingConfig(String configPath) async {
    try {
      final file = File(configPath);
      if (!await file.exists()) {
        return {'services': {}};
      }

      final content = await file.readAsString();
      final yaml = loadYaml(content) as Map;
      return _convertYamlToMap(yaml);
    } catch (e) {
      throw 'Failed to load existing configuration: $e';
    }
  }

  /// Discover services in the services directory
  Future<Map<String, Map<String, dynamic>>> _discoverServices(
    String servicesPath,
    String? category,
  ) async {
    final services = <String, Map<String, dynamic>>{};
    final dir = Directory(servicesPath);

    if (!await dir.exists()) {
      throw 'Services directory not found: $servicesPath';
    }

    output.info('Scanning directory: $servicesPath');
    output.info('Directory exists: ${await dir.exists()}');

    // Scan categories
    await for (final categoryDir in dir.list()) {
      output.info(
          'Found entry: ${categoryDir.path} (${categoryDir.runtimeType})');
      if (categoryDir is! Directory) {
        output.info('  Skipping: Not a directory');
        continue;
      }
      if (category != null) {
        output.info('  Filtering by category: $category');
        if (path.basename(categoryDir.path) != category) {
          output.info('  Skipping: Not matching category');
          continue;
        }
      }

      final categoryName = path.basename(categoryDir.path);
      output.info('Found category: $categoryName');

      // Scan services in category
      output.info('  Scanning category directory: ${categoryDir.path}');
      services[categoryName] ??= {};

      final categoryDirPath = categoryDir.path;
      output.info('  Listing contents of: $categoryDirPath');
      final categoryDirContents =
          await Directory(categoryDirPath).list().toList();
      output.info('  Found ${categoryDirContents.length} entries');

      await for (final serviceDir in Directory(categoryDirPath).list()) {
        output.info(
            '    Found entry: ${serviceDir.path} (${serviceDir.runtimeType})');
        if (serviceDir is! Directory) {
          output.info('      Skipping: Not a directory');
          continue;
        }

        final serviceName = path.basename(serviceDir.path);
        output.info('    Processing service: $serviceName');

        final manifestPath = path.join(serviceDir.path, 'manifest.yaml');
        final manifestFile = File(manifestPath);
        output.info('    Checking manifest: $manifestPath');

        if (!await manifestFile.exists()) {
          output.warning('      No manifest.yaml found');
          continue;
        }

        try {
          output.info('      Reading manifest.yaml');
          final content = await manifestFile.readAsString();
          output.info('      Manifest content length: ${content.length}');

          output.info('      Parsing YAML');
          final manifest = loadYaml(content) as Map;
          output.info('      Manifest keys: ${manifest.keys.join(', ')}');

          output.info('      Processing manifest');
          final serviceConfig = _processManifest(
            manifest,
            categoryName,
            serviceName,
          );
          output.info('      Service config: $serviceConfig');

          output.info('      Adding service to category');
          services[categoryName]![serviceName] = serviceConfig;
          output.info('      Service added successfully');
        } catch (e) {
          output.warning(
            'Failed to process manifest for $serviceName: $e',
          );
          continue;
        }
      }
    }

    return services;
  }

  /// Process a service manifest into configuration
  Map<String, dynamic> _processManifest(
    Map manifest,
    String category,
    String name,
  ) {
    return {
      'category': category,
      'version': manifest['default_version'] ??
          manifest['versions']?.first ??
          'latest',
      'enabled': false,
      'config': _processConfigSchema(manifest['config_schema'] ?? {}),
    };
  }

  /// Process config schema into default configuration
  Map<String, dynamic> _processConfigSchema(Map schema) {
    final config = <String, dynamic>{};
    for (final entry in schema.entries) {
      final field = entry.value as Map;
      if (field.containsKey('default')) {
        config[entry.key] = field['default'];
      }
    }
    return config;
  }

  /// Merge existing and discovered configurations
  Future<Map<String, dynamic>> _mergeConfigurations({
    required Map<String, dynamic> existing,
    required Map<String, Map<String, dynamic>> discovered,
    required bool force,
  }) async {
    final merged = {'services': <String, Map<String, dynamic>>{}};
    final services = merged['services'] as Map<String, Map<String, dynamic>>;

    // Add discovered services
    for (final category in discovered.entries) {
      final categoryServices = <String, Map<String, dynamic>>{};
      services[category.key] = categoryServices;

      for (final service in category.value.entries) {
        final existingServices = existing['services'] as Map<String, dynamic>?;
        final existingCategory =
            existingServices?[category.key] as Map<String, dynamic>?;
        final existingService =
            existingCategory?[service.key] as Map<String, dynamic>?;

        if (force) {
          categoryServices[service.key] = service.value;
          continue;
        }

        categoryServices[service.key] = {
          ...service.value,
          'enabled': existingService?['enabled'] ?? false,
          'config': {
            ...service.value['config'] as Map<String, dynamic>,
            ...(existingService?['config'] as Map<String, dynamic>? ?? {}),
          },
        };
      }
    }

    // Remove empty categories
    services.removeWhere((_, services) => services.isEmpty);

    return merged;
  }

  /// Print changes between configurations
  void _printChanges(
    Map<String, dynamic> existing,
    Map<String, dynamic> updated,
  ) {
    final existingServices = _flattenServices(existing);
    final updatedServices = _flattenServices(updated);

    // Find new services
    final newServices = updatedServices.keys
        .where((key) => !existingServices.containsKey(key))
        .toList();

    // Find updated services
    final updatedServicesList = updatedServices.keys
        .where((key) =>
            existingServices.containsKey(key) &&
            !_areServicesEqual(existingServices[key]!, updatedServices[key]!))
        .toList();

    // Find preserved services
    final preservedServices = updatedServices.keys
        .where((key) =>
            existingServices.containsKey(key) &&
            _areServicesEqual(existingServices[key]!, updatedServices[key]!))
        .toList();

    output.info('\nNew services detected:');
    for (final service in newServices) {
      output.info('  ✨ $service');
    }

    output.info('\nUpdated services:');
    for (final service in updatedServicesList) {
      output.info('  🔄 $service');
    }

    output.info('\nExisting services preserved:');
    for (final service in preservedServices) {
      output.info('  ✓ $service');
    }
  }

  /// Save configuration to file
  Future<void> _saveConfiguration(
    String configPath,
    Map<String, dynamic> config,
  ) async {
    final file = File(configPath);
    final content = StringBuffer();
    content.writeln('services:');

    final services = config['services'] as Map<String, dynamic>;
    final sortedCategories = services.keys.toList()..sort();

    for (final category in sortedCategories) {
      content.writeln('  $category:');
      final categoryServices = services[category] as Map<String, dynamic>;
      final sortedServices = categoryServices.keys.toList()..sort();

      for (final service in sortedServices) {
        final serviceConfig = categoryServices[service] as Map<String, dynamic>;
        content.writeln('    $service:');
        content.writeln('      category: ${serviceConfig['category']}');
        content.writeln(
            '      version: ${_formatYamlValue(serviceConfig['version'])}');
        content.writeln('      enabled: ${serviceConfig['enabled']}');

        final config = serviceConfig['config'] as Map<String, dynamic>?;
        if (config == null || config.isEmpty) {
          content.writeln('      config: null');
        } else {
          content.writeln('      config:');
          final sortedKeys = config.keys.toList()..sort();
          for (final key in sortedKeys) {
            content.writeln('        $key: ${_formatYamlValue(config[key])}');
          }
        }
      }
    }

    await file.writeAsString(content.toString());
  }

  /// Convert YAML to Map
  Map<String, dynamic> _convertYamlToMap(Map yaml) {
    return yaml.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _convertYamlToMap(value));
      }
      if (value is YamlList) {
        return MapEntry(
          key.toString(),
          value
              .map((item) => item is Map ? _convertYamlToMap(item) : item)
              .toList(),
        );
      }
      return MapEntry(key.toString(), value);
    });
  }

  /// Generate YAML string
  String _generateYaml(Map<String, dynamic> data, {String indent = ''}) {
    final yaml = StringBuffer();
    final sortedKeys = data.keys.toList()..sort();

    for (final key in sortedKeys) {
      final value = data[key];
      if (value is Map<String, dynamic>) {
        yaml.writeln('$indent$key:');
        if (value.isNotEmpty) {
          final nestedYaml = _generateYaml(value, indent: '$indent  ');
          yaml.write(nestedYaml);
        }
      } else if (value is List) {
        if (value.isEmpty) {
          yaml.writeln('$indent$key: []');
        } else {
          yaml.writeln('$indent$key:');
          for (final item in value) {
            yaml.writeln('$indent  - ${_formatYamlValue(item)}');
          }
        }
      } else {
        yaml.writeln('$indent$key: ${_formatYamlValue(value)}');
      }
    }

    return yaml.toString();
  }

  /// Format YAML value
  String _formatYamlValue(dynamic value) {
    if (value == null) {
      return 'null';
    }
    if (value is bool) {
      return value.toString();
    }
    if (value is num) {
      return value.toString();
    }
    if (value is String) {
      if (value.isEmpty) {
        return '""';
      }
      if (value.contains('\n')) {
        final lines = value.split('\n');
        return '|\n${lines.map((line) => '    $line').join('\n')}';
      }
      if (_needsQuoting(value)) {
        return "'${value.replaceAll("'", "''")}'";
      }
      return value;
    }
    return value.toString();
  }

  /// Check if a string needs quoting in YAML
  bool _needsQuoting(String value) {
    final specialChars = RegExp(r'[:#{}\[\]!%|",\s]');
    return specialChars.hasMatch(value) ||
        value == 'true' ||
        value == 'false' ||
        value == 'null' ||
        num.tryParse(value) != null;
  }

  /// Flatten services map for comparison
  Map<String, Map<String, dynamic>> _flattenServices(
      Map<String, dynamic> config) {
    final flattened = <String, Map<String, dynamic>>{};
    final services = config['services'] as Map<String, dynamic>?;
    if (services == null) return flattened;

    for (final category in services.entries) {
      for (final service in (category.value as Map<String, dynamic>).entries) {
        flattened['${category.key}/${service.key}'] = service.value;
      }
    }
    return flattened;
  }

  /// Compare two service configurations
  bool _areServicesEqual(
    Map<String, dynamic>? a,
    Map<String, dynamic>? b,
  ) {
    if (a == null || b == null) return false;
    return a['version'] == b['version'] &&
        a['enabled'] == b['enabled'] &&
        _areConfigsEqual(
          a['config'] as Map<String, dynamic>? ?? {},
          b['config'] as Map<String, dynamic>? ?? {},
        );
  }

  /// Compare two service configs
  bool _areConfigsEqual(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final aKeys = a.keys.toSet();
    final bKeys = b.keys.toSet();
    if (!aKeys.containsAll(bKeys) || !bKeys.containsAll(aKeys)) return false;
    return aKeys.every((key) => a[key] == b[key]);
  }
}
