/* import 'package:angel3_framework/angel3_framework.dart';
import 'package:logging/logging.dart';
import 'process_manager.dart';

class ProcessServiceProvider extends Provider {
  final Logger _logger = Logger('ProcessServiceProvider');

  @override
  void registers() {
    container.singleton<ProcessManager>((_) => ProcessManager());
    _logger.info('Registered ProcessManager');
  }

  @override
  void boots(Angel app) {
    app.shutdownHooks.add((_) async {
      _logger.info('Shutting down ProcessManager');
      final processManager = app.container.make<ProcessManager>();
      await processManager.killAll();
      processManager.dispose();
    });
    _logger.info('Added ProcessManager shutdown hook');
  }
} */
