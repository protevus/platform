import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';

/// Command to stop development services
class DownCommand extends Command {
  @override
  String get name => 'services:down';

  @override
  String get description => 'Stop development services';

  @override
  String get signature =>
      'services:down {--services=* : Specific services to stop}';

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
        output.info('Stopping services: ${services.join(', ')}');
      } else {
        output.info('Stopping all services...');
      }

      await manager.stopServices(services);
      output.success('Services stopped successfully');
    } catch (e) {
      output.error('Failed to stop services: $e');
      rethrow;
    }
  }
}
