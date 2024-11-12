import 'dart:async';
import 'package:logging/logging.dart';
import 'process.dart';

class ProcessPool {
  final int concurrency;
  final List<Function> _queue = [];
  int _running = 0;
  final Logger _logger = Logger('ProcessPool');

  ProcessPool({this.concurrency = 5});

  Future<List<InvokedProcess>> run(List<Angel3Process> processes) async {
    final results = <InvokedProcess>[];
    final completer = Completer<List<InvokedProcess>>();

    _logger.info('Starting process pool with ${processes.length} processes');

    for (final process in processes) {
      _queue.add(() async {
        try {
          final result = await _runProcess(process);
          results.add(result);
        } catch (e) {
          _logger.severe('Error running process in pool', e);
        } finally {
          _running--;
          _processQueue();
          if (_running == 0 && _queue.isEmpty) {
            completer.complete(results);
          }
        }
      });
    }

    _processQueue();

    return completer.future;
  }

  void _processQueue() {
    while (_running < concurrency && _queue.isNotEmpty) {
      _running++;
      _queue.removeAt(0)();
    }
  }

  Future<InvokedProcess> _runProcess(Angel3Process process) async {
    _logger.info('Running process: ${process.command}');
    final result = await process.run();
    _logger.info(
        'Process completed: ${process.command} with exit code ${result.exitCode}');
    return InvokedProcess(
      process,
      process.startTime!,
      process.endTime!,
      result.exitCode,
      result.output,
      result.errorOutput,
    );
  }
}
