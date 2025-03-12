import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';

/// Command to remove a service module
class RemoveCommand extends Command {
  @override
  String get name => 'services:remove';

  @override
  String get description => 'Remove a service module';

  @override
  String get signature =>
      'services:remove {name : Name of the service to remove}';

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

      // Confirm removal
      output.warning('This will remove the service module and all its files.');
      if (!await prompt.confirm('Remove service "$name"?')) {
        output.info('Operation cancelled');
        return;
      }

      output.info('Removing service module: $name');
      await manager.removeService(name);
      output.success('Service module removed successfully');
    } catch (e) {
      output.error('Failed to remove service module: $e');
      rethrow;
    }
  }
}
