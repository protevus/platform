import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';

/// Command to start development services
class UpCommand extends Command {
  @override
  String get name => 'services:up';

  @override
  String get description => 'Start development services';

  @override
  String get signature =>
      'services:up {--services=* : Specific services to start}';

  @override
  Future<void> handle() async {
    try {
      final manager = ServiceManager(
        configPath: path.join('devops', 'docker', 'dev-services.yaml'),
        servicesPath: path.join('devops', 'docker', 'services'),
        workingDir: path.join('devops', 'docker'),
      );

      await manager.initialize();

      // Get specific services if provided
      final services = option<List<String>>('services');
      if (services != null && services.isNotEmpty) {
        output.info('Starting services: ${services.join(', ')}');
      } else {
        output.info('Starting all enabled services...');
      }

      await manager.startServices(services);
      output.success('Services started successfully');
    } catch (e) {
      output.error('Failed to start services: $e');
      rethrow;
    }
  }
}
