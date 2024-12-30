import 'dart:async';
import 'traits/macroable.dart';
import 'pending_process.dart';
import 'contracts/process_result.dart';
import 'process_result.dart';
import 'pool.dart';
import 'pipe.dart';

/// Factory for creating and managing processes.
class Factory with Macroable {
  /// Indicates if the process factory is recording processes.
  bool _recording = false;

  /// All of the recorded processes.
  final List<List<dynamic>> _recorded = [];

  /// The registered fake handler callbacks.
  final Map<String, Function> _fakeHandlers = {};

  /// Indicates that an exception should be thrown if any process is not faked.
  bool _preventStrayProcesses = false;

  /// Create a new pending process instance.
  PendingProcess newPendingProcess() {
    return PendingProcess();
  }

  /// Create a new process instance and configure it.
  PendingProcess command(dynamic command) {
    return newPendingProcess().command(command);
  }

  /// Start defining a pool of processes.
  Pool pool(void Function(Pool) callback) {
    return Pool(this, callback);
  }

  /// Start defining a series of piped processes.
  Pipe pipeThrough(void Function(Pipe) callback) {
    return Pipe(this, callback);
  }

  /// Run a pool of processes concurrently.
  Future<List<ProcessResult>> concurrently(
    List<PendingProcess> processes, {
    void Function(String)? onOutput,
  }) async {
    // Run all processes concurrently and wait for all to complete
    final futures = processes.map((process) async {
      final result = await process.run(onOutput);
      if (onOutput != null) {
        final output = result.output().trim();
        if (output.isNotEmpty) {
          onOutput(output);
        }
      }
      return result;
    });
    return Future.wait(futures);
  }

  /// Run a series of processes in sequence.
  Future<ProcessResult> pipe(
    List<PendingProcess> processes, {
    void Function(String)? onOutput,
  }) async {
    if (processes.isEmpty) {
      return ProcessResultImpl(
        command: '',
        exitCode: 0,
        output: '',
        errorOutput: '',
      );
    }

    ProcessResult? result;
    for (final process in processes) {
      result = await process.run(onOutput);
      if (result.failed()) {
        return result;
      }
    }
    return result!;
  }

  /// Indicate that the process factory should fake processes.
  Factory fake([Map<String, dynamic>? fakes]) {
    _recording = true;

    if (fakes != null) {
      for (final entry in fakes.entries) {
        if (entry.value is Function) {
          _fakeHandlers[entry.key] = entry.value as Function;
        } else {
          _fakeHandlers[entry.key] = (_) => entry.value;
        }
      }
    }

    return this;
  }

  /// Record the given process if processes should be recorded.
  void recordIfRecording(PendingProcess process, ProcessResult result) {
    if (_recording) {
      _recorded.add([process, result]);
    }
  }

  /// Indicate that an exception should be thrown if any process is not faked.
  Factory preventStrayProcesses([bool prevent = true]) {
    _preventStrayProcesses = prevent;
    return this;
  }

  /// Determine if stray processes are being prevented.
  bool preventingStrayProcesses() => _preventStrayProcesses;

  /// Determine if the factory is recording processes.
  bool isRecording() => _recording;

  /// Get the fake handler for the given command.
  Function? fakeFor(String command) {
    for (final entry in _fakeHandlers.entries) {
      if (entry.key == '*' || command.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Run a pool of processes and wait for them to finish executing.
  Future<ProcessPoolResults> runPool(void Function(Pool) callback,
      {void Function(String)? output}) async {
    return ProcessPoolResults(await pool(callback).start(output));
  }

  /// Run a series of piped processes and wait for them to finish executing.
  Future<ProcessResult> runPipe(void Function(Pipe) callback,
      {void Function(String)? output}) async {
    return pipeThrough(callback).run(output: output);
  }

  /// Dynamically handle method calls.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) {
      return newPendingProcess().noSuchMethod(invocation);
    }
    return super.noSuchMethod(invocation);
  }
}
