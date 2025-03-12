import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';

/// Command to clean up service resources
class CleanupCommand extends Command {
  @override
  String get name => 'services:cleanup';

  @override
  String get description => 'Clean up service resources';

  @override
  String get signature =>
      'services:cleanup {--services=* : Specific services to clean up} {--volumes : Remove volumes} {--images : Remove images}';

  @override
  Future<void> handle() async {
    try {
      final manager = ServiceManager(
        configPath: path.join('devops', 'docker', 'dev-services.yaml'),
        servicesPath: path.join('devops', 'docker', 'services'),
        workingDir: path.join('devops', 'docker'),
      );

      await manager.initialize();

      final services = option<List<String>>('services');
      final removeVolumes = option<bool>('volumes') ?? false;
      final removeImages = option<bool>('images') ?? false;

      // Show what will be cleaned up
      if (services != null && services.isNotEmpty) {
        output.info('Cleaning up services: ${services.join(', ')}');
      } else {
        output.info('Cleaning up all services');
      }

      if (removeVolumes) {
        output.info('Volumes will be removed');
      }
      if (removeImages) {
        output.info('Images will be removed');
      }

      await manager.cleanup(
        removeVolumes: removeVolumes,
        removeImages: removeImages,
        services: services,
      );

      output.success('Cleanup completed successfully');
    } catch (e) {
      output.error('Failed to clean up services: $e');
      rethrow;
    }
  }
}
