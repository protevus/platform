import 'package:path/path.dart' as path;

import '../../command.dart';
import '../../services/manager/service_manager.dart';

/// Command to view service logs
class LogsCommand extends Command {
  @override
  String get name => 'services:logs';

  @override
  String get description => 'View service logs';

  @override
  String get signature =>
      'services:logs {service : Service to view logs for} {--tail=100 : Number of lines to show} {--follow : Follow log output}';

  @override
  Future<void> handle() async {
    try {
      final manager = ServiceManager(
        configPath: path.join('devops', 'docker', 'dev-services.yaml'),
        servicesPath: path.join('devops', 'docker', 'services'),
        workingDir: path.join('devops', 'docker'),
      );

      await manager.initialize();

      final service = argument<String>('service')!;
      final tail = int.tryParse(option<String>('tail') ?? '100');
      final follow = option<bool>('follow') ?? false;

      output.info('Getting logs for service: $service');
      if (follow) {
        output.info('Following log output (Ctrl+C to stop)...');
      }

      final logs = await manager.getServiceLogs(
        service,
        tail: tail,
        follow: follow,
      );

      // Output is already formatted by Docker
      output.write(logs);
    } catch (e) {
      output.error('Failed to get service logs: $e');
      rethrow;
    }
  }
}
