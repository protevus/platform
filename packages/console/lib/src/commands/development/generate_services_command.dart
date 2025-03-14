import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';

/// Command to generate docker-compose file for services
class GenerateServicesCommand extends Command {
  @override
  String get name => 'generate:services';

  @override
  String get description => 'Generate docker-compose file for services';

  @override
  String get signature =>
      'generate:services {--services=* : Specific services to include} {--force : Force regeneration of compose file}';

  @override
  Future<void> handle() async {
    try {
      final services = option<List<String>>('services');
      final force = option<bool>('force') ?? false;

      // Initialize service manager
      final manager = ServiceManager(
        configPath: path.join('devops', 'docker', 'dev-services.yaml'),
        servicesPath: path.join('devops', 'docker', 'services'),
        workingDir: path.join('devops', 'docker'),
      );

      await manager.initialize();

      // Show what we're generating
      if (services != null && services.isNotEmpty) {
        output.info(
            'Generating compose file for services: ${services.join(', ')}');
      } else {
        output.info('Generating compose file for all enabled services...');
      }

      // Generate compose file
      await manager.generateComposeFile(services);
      output.success('Docker compose file generated successfully');
    } catch (e) {
      output.error('Failed to generate compose file: $e');
      rethrow;
    }
  }
}
