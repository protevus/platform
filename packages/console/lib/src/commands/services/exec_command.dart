import '../../command.dart';
import '../../services/manager/service_manager.dart';
import 'package:path/path.dart' as path;

/// Command to execute commands in service containers
class ExecCommand extends Command {
  @override
  String get name => 'services:exec';

  @override
  String get description => 'Execute a command in a service container';

  @override
  String get signature =>
      'services:exec {service : Service name} {cmd : Command to execute}';

  @override
  Future<void> handle() async {
    try {
      final service = argument<String>('service')!;
      final cmd = argument<String>('cmd')!;
      final command = ['/bin/sh', '-c', cmd];

      output.info('Executing command in service: $service');
      output.info('Command: $cmd');

      final manager = ServiceManager(
        configPath: path.join('devops', 'docker', 'dev-services.yaml'),
        servicesPath: path.join('devops', 'docker', 'services'),
        workingDir: path.join('devops', 'docker'),
      );

      await manager.initialize();
      await manager.execInService(service, command);
    } catch (e) {
      output.error('Failed to execute command: $e');
      rethrow;
    }
  }
}
