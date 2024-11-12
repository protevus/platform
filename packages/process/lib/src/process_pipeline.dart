import 'dart:async';
import 'package:logging/logging.dart';
import 'process.dart';

class ProcessPipeline {
  final List<Angel3Process> _processes;
  final Logger _logger = Logger('ProcessPipeline');

  ProcessPipeline(this._processes);

  Future<InvokedProcess> run() async {
    String input = '';
    DateTime startTime = DateTime.now();
    DateTime endTime;
    int lastExitCode = 0;

    _logger
        .info('Starting process pipeline with ${_processes.length} processes');

    for (final process in _processes) {
      _logger.info('Running process: ${process.command}');
      if (input.isNotEmpty) {
        await process.write(input);
      }
      final result = await process.run();
      input = result.output;
      lastExitCode = result.exitCode;
      _logger.info(
          'Process completed: ${process.command} with exit code $lastExitCode');
      if (lastExitCode != 0) {
        _logger.warning(
            'Pipeline stopped due to non-zero exit code: $lastExitCode');
        break;
      }
    }

    endTime = DateTime.now();
    _logger.info(
        'Pipeline completed. Total duration: ${endTime.difference(startTime)}');

    return InvokedProcess(
      _processes.last,
      startTime,
      endTime,
      lastExitCode,
      input,
      '',
    );
  }
}
