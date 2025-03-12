import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';
import '../../services/manager/docker_utils.dart';

/// Command to show status of development services
class StatusCommand extends Command {
  @override
  String get name => 'services:status';

  @override
  String get description => 'Show status of development services';

  @override
  String get signature =>
      'services:status {--services=* : Specific services to show status for}';

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
        output.info('Getting status for services: ${services.join(', ')}');
      } else {
        output.info('Getting status for all services...');
      }

      // Check if there are any services
      if (manager.services.isEmpty) {
        output.info('No services found');
        return;
      }

      // Display service list without Docker status
      output.table(
        ['Service', 'Category', 'Version', 'Enabled'],
        manager.services.entries.map((entry) {
          final service = entry.value;
          return [
            service.name,
            service.category,
            service.version,
            service.enabled ? 'Yes' : 'No',
          ];
        }).toList(),
      );
    } catch (e) {
      output.error('Failed to get services status: $e');
      rethrow;
    }
  }

  /// Format status for display
  String _formatStatus(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.running:
        return '<fg=green>Running</>';
      case ServiceStatus.stopped:
        return '<fg=red>Stopped</>';
      case ServiceStatus.error:
        return '<fg=red>Error</>';
      default:
        return '<fg=yellow>Unknown</>';
    }
  }
}
