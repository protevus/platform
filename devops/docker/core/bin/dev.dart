import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:dev_service_manager/src/service_manager.dart';

/// Base class for service commands
abstract class ServiceCommand extends Command {
  late final ServiceManager manager;

  ServiceCommand() {
    manager = ServiceManager(
      configPath: path.join('devops', 'docker', 'dev-services.yaml'),
      servicesPath: path.join('devops', 'docker', 'services'),
      workingDir: path.join('devops', 'docker'),
    );
  }

  @override
  Future<void> run() async {
    try {
      await manager.initialize();
      await runCommand();
    } catch (e) {
      stderr.writeln('Error: $e');
      exit(1);
    }
  }

  Future<void> runCommand();
}

/// Command to start services
class StartCommand extends ServiceCommand {
  @override
  final name = 'up';
  @override
  final description = 'Start services';

  StartCommand() {
    argParser.addMultiOption(
      'services',
      abbr: 's',
      help: 'Specific services to start',
      splitCommas: true,
    );
  }

  @override
  Future<void> runCommand() async {
    final services = argResults?['services'] as List<String>?;
    await manager.startServices(services);
    print('Services started successfully');
  }
}

/// Command to stop services
class StopCommand extends ServiceCommand {
  @override
  final name = 'down';
  @override
  final description = 'Stop services';

  StopCommand() {
    argParser.addMultiOption(
      'services',
      abbr: 's',
      help: 'Specific services to stop',
      splitCommas: true,
    );
  }

  @override
  Future<void> runCommand() async {
    final services = argResults?['services'] as List<String>?;
    await manager.stopServices(services);
    print('Services stopped successfully');
  }
}

/// Command to show service status
class StatusCommand extends ServiceCommand {
  @override
  final name = 'status';
  @override
  final description = 'Show service status';

  StatusCommand() {
    argParser.addMultiOption(
      'services',
      abbr: 's',
      help: 'Specific services to show status for',
      splitCommas: true,
    );
  }

  @override
  Future<void> runCommand() async {
    final services = argResults?['services'] as List<String>?;
    final status = await manager.getServicesStatus(services);

    if (status.isEmpty) {
      print('No services found');
      return;
    }

    print('\nService Status:');
    print('==============');
    for (final entry in status.entries) {
      final info = entry.value;
      final statusStr = info.status.toString().split('.').last.toUpperCase();
      print('${entry.key}: $statusStr');

      if (info.stats.isNotEmpty) {
        print('  CPU: ${info.stats['cpu_usage']}');
        print('  Memory: ${info.stats['memory_usage']}');
      }
      print('');
    }
  }
}

/// Command to view service logs
class LogsCommand extends ServiceCommand {
  @override
  final name = 'logs';
  @override
  final description = 'View service logs';

  LogsCommand() {
    argParser
      ..addOption(
        'service',
        abbr: 's',
        help: 'Service to view logs for',
        mandatory: true,
      )
      ..addOption(
        'tail',
        abbr: 't',
        help: 'Number of lines to show',
        defaultsTo: '100',
      )
      ..addFlag(
        'follow',
        abbr: 'f',
        help: 'Follow log output',
        defaultsTo: false,
      );
  }

  @override
  Future<void> runCommand() async {
    final service = argResults!['service'] as String;
    final tail = int.tryParse(argResults!['tail'] as String);
    final follow = argResults!['follow'] as bool;

    final logs = await manager.getServiceLogs(
      service,
      tail: tail,
      follow: follow,
    );
    print(logs);
  }
}

/// Command to add a new service
class AddCommand extends ServiceCommand {
  @override
  final name = 'add';
  @override
  final description = 'Add a new service';

  AddCommand() {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Service name',
        mandatory: true,
      )
      ..addOption(
        'category',
        abbr: 'c',
        help: 'Service category',
        mandatory: true,
      );
  }

  @override
  Future<void> runCommand() async {
    final name = argResults!['name'] as String;
    final category = argResults!['category'] as String;

    await manager.addService(name, category);
    print('Service $name added successfully');
  }
}

/// Command to remove a service
class RemoveCommand extends ServiceCommand {
  @override
  final name = 'remove';
  @override
  final description = 'Remove a service';

  RemoveCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Service name',
      mandatory: true,
    );
  }

  @override
  Future<void> runCommand() async {
    final name = argResults!['name'] as String;
    await manager.removeService(name);
    print('Service $name removed successfully');
  }
}

/// Command to configure a service
class ConfigureCommand extends ServiceCommand {
  @override
  final name = 'configure';
  @override
  final description = 'Configure a service';

  ConfigureCommand() {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Service name',
        mandatory: true,
      )
      ..addOption(
        'config',
        abbr: 'c',
        help: 'Configuration in JSON format',
        mandatory: true,
      );
  }

  @override
  Future<void> runCommand() async {
    final name = argResults!['name'] as String;
    final configStr = argResults!['config'] as String;

    try {
      // Parse JSON configuration
      final config = Map<String, dynamic>.from(
        Uri.splitQueryString(configStr).map(
          (key, value) => MapEntry(key, _parseValue(value)),
        ),
      );

      await manager.configureService(name, config);
      print('Service $name configured successfully');
    } catch (e) {
      throw FormatException('Invalid configuration format: $e');
    }
  }

  dynamic _parseValue(String value) {
    // Try parsing as number
    final number = num.tryParse(value);
    if (number != null) return number;

    // Try parsing as boolean
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;

    // Return as string
    return value;
  }
}

/// Command to clean up service resources
class CleanupCommand extends ServiceCommand {
  @override
  final name = 'cleanup';
  @override
  final description = 'Clean up service resources';

  CleanupCommand() {
    argParser
      ..addFlag(
        'volumes',
        abbr: 'v',
        help: 'Remove volumes',
        defaultsTo: false,
      )
      ..addFlag(
        'images',
        abbr: 'i',
        help: 'Remove images',
        defaultsTo: false,
      )
      ..addMultiOption(
        'services',
        abbr: 's',
        help: 'Specific services to clean up',
        splitCommas: true,
      );
  }

  @override
  Future<void> runCommand() async {
    final removeVolumes = argResults!['volumes'] as bool;
    final removeImages = argResults!['images'] as bool;
    final services = argResults?['services'] as List<String>?;

    await manager.cleanup(
      removeVolumes: removeVolumes,
      removeImages: removeImages,
      services: services,
    );
    print('Cleanup completed successfully');
  }
}

void main(List<String> arguments) {
  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.message}');
  });

  // Create and configure command runner
  final runner = CommandRunner('dev', 'Development service management tool')
    ..addCommand(StartCommand())
    ..addCommand(StopCommand())
    ..addCommand(StatusCommand())
    ..addCommand(LogsCommand())
    ..addCommand(AddCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(ConfigureCommand())
    ..addCommand(CleanupCommand());

  // Run command
  runner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates command line usage error
  });
}
