import 'dart:convert';
import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';

/// Command to configure a service
class ConfigureCommand extends Command {
  @override
  String get name => 'services:configure';

  @override
  String get description => 'Configure a service';

  @override
  String get signature =>
      'services:configure {name : Service name} {config : Configuration in key=value format}';

  @override
  Future<void> handle() async {
    try {
      final manager = ServiceManager(
        configPath: path.join('devops', 'docker', 'dev-services.yaml'),
        servicesPath: path.join('devops', 'docker', 'services'),
        workingDir: path.join('devops', 'docker'),
      );

      await manager.initialize();

      final name = argument<String>('name')!;
      final configStr = argument<String>('config')!;

      // Parse configuration string (key=value format)
      final config = Map<String, dynamic>.fromEntries(
        configStr.split(' ').map((pair) {
          final parts = pair.split('=');
          if (parts.length != 2) {
            throw ArgumentError(
                'Invalid configuration format. Use key=value format.');
          }
          return MapEntry(parts[0], _parseValue(parts[1]));
        }),
      );

      output.info('Configuring service: $name');
      output.info('Configuration:');
      output.write(const JsonEncoder.withIndent('  ').convert(config));
      output.newLine();

      await manager.configureService(name, config);
      output.success('Service configured successfully');
    } catch (e) {
      output.error('Failed to configure service: $e');
      rethrow;
    }
  }

  /// Parse configuration value into appropriate type
  dynamic _parseValue(String value) {
    // Try parsing as number
    final number = num.tryParse(value);
    if (number != null) {
      return number;
    }

    // Try parsing as boolean
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;

    // Try parsing as JSON
    try {
      return json.decode(value);
    } catch (_) {
      // Return as string if not valid JSON
      return value;
    }
  }
}
