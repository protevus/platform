import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';

/// Command to add a new service module
class AddCommand extends Command {
  @override
  String get name => 'services:add';

  @override
  String get description => 'Add a new service module';

  @override
  String get signature =>
      'services:add {name : Service name} {category : Service category (e.g., databases, caching)}';

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
      final category = argument<String>('category')!;

      output.info('Adding new service module:');
      output.info('  Name: $name');
      output.info('  Category: $category');

      await manager.addService(name, category);
      output.success('Service module created successfully');
      output.info(
          'Service files created in devops/docker/services/$category/$name');
      output.info('Edit manifest.yaml and Dockerfile to configure the service');
    } catch (e) {
      output.error('Failed to add service module: $e');
      rethrow;
    }
  }
}
