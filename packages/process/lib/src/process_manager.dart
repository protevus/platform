import 'dart:async';
import 'dart:io';

// import 'package:angel3_framework/angel3_framework.dart';
// import 'package:angel3_mq/mq.dart';
// import 'package:angel3_reactivex/angel3_reactivex.dart';
import 'package:angel3_event_bus/event_bus.dart';
import 'package:logging/logging.dart';

import 'process.dart';
import 'process_pool.dart';
import 'process_pipeline.dart';

class ProcessManager {
  final Map<String, Angel3Process> _processes = {};
  final EventBus _eventBus = EventBus();
  final List<StreamSubscription> _subscriptions = [];
  final Logger _logger = Logger('ProcessManager');

  Future<Angel3Process> start(
    String id,
    String command,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    Duration? timeout,
    bool tty = false,
    bool enableReadError = true,
  }) async {
    if (_processes.containsKey(id)) {
      throw Exception('Process with id $id already exists');
    }

    final process = Angel3Process(
      command,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      timeout: timeout,
      tty: tty,
      enableReadError: enableReadError,
      logger: Logger('Angel3Process:$id'),
    );

    try {
      await process.start();
      _processes[id] = process;

      _eventBus.fire(ProcessStartedEvent(id, process) as AppEvent);

      process.exitCode.then((exitCode) {
        _eventBus.fire(ProcessExitedEvent(id, exitCode) as AppEvent);
        _processes.remove(id);
      });

      _logger.info('Started process with id: $id');
      return process;
    } catch (e) {
      _logger.severe('Failed to start process with id: $id', e);
      rethrow;
    }
  }

  Angel3Process? get(String id) => _processes[id];

  Future<void> kill(String id,
      {ProcessSignal signal = ProcessSignal.sigterm}) async {
    final process = _processes[id];
    if (process != null) {
      await process.kill(signal: signal);
      _processes.remove(id);
      _logger.info('Killed process with id: $id');
    } else {
      _logger.warning('Attempted to kill non-existent process with id: $id');
    }
  }

  Future<void> killAll({ProcessSignal signal = ProcessSignal.sigterm}) async {
    _logger.info('Killing all processes');
    await Future.wait(
        _processes.values.map((process) => process.kill(signal: signal)));
    _processes.clear();
  }

  Stream<ProcessEvent> get events => _eventBus.on<ProcessEvent>();

  Future<List<InvokedProcess>> pool(List<Angel3Process> processes,
      {int concurrency = 5}) async {
    _logger.info('Running process pool with concurrency: $concurrency');
    final pool = ProcessPool(concurrency: concurrency);
    return await pool.run(processes);
  }

  Future<InvokedProcess> pipeline(List<Angel3Process> processes) async {
    _logger.info('Running process pipeline');
    final pipeline = ProcessPipeline(processes);
    return await pipeline.run();
  }

  void dispose() {
    _logger.info('Disposing ProcessManager');

    // Cancel all event subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Dispose all processes
    for (var process in _processes.values) {
      process.dispose();
    }
    _processes.clear();

    _logger.info('ProcessManager disposed');
  }
}

abstract class ProcessEvent extends AppEvent {}

class ProcessStartedEvent extends ProcessEvent {
  final String id;
  final Angel3Process process;

  ProcessStartedEvent(this.id, this.process);

  @override
  String toString() =>
      'ProcessStartedEvent(id: $id, command: ${process.command})';

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class ProcessExitedEvent extends ProcessEvent {
  final String id;
  final int exitCode;

  ProcessExitedEvent(this.id, this.exitCode);

  @override
  String toString() => 'ProcessExitedEvent(id: $id, exitCode: $exitCode)';

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
