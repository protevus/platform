import 'dart:async';
import 'factory.dart';
import 'pending_process.dart';
import 'contracts/process_result.dart';

/// Represents a pool of processes that can be executed concurrently.
class Pool {
  /// The process factory instance.
  final Factory _factory;

  /// The callback that configures the pool.
  final void Function(Pool) _callback;

  /// The processes in the pool.
  final List<PendingProcess> _processes = [];

  /// Create a new process pool instance.
  Pool(this._factory, this._callback) {
    // Call the callback immediately to configure the pool
    _callback(this);
  }

  /// Add a process to the pool.
  Pool command(dynamic command) {
    if (command is PendingProcess) {
      _processes.add(command);
    } else {
      _processes.add(_factory.command(command));
    }
    return this;
  }

  /// Start the processes in the pool.
  Future<List<ProcessResult>> start([void Function(String)? output]) async {
    if (_processes.isEmpty) {
      return [];
    }
    return _factory.concurrently(_processes, onOutput: output);
  }
}

/// Represents the results of a process pool execution.
class ProcessPoolResults {
  /// The results of the processes.
  final List<ProcessResult> _results;

  /// Create a new process pool results instance.
  ProcessPoolResults(this._results);

  /// Get all of the process results.
  List<ProcessResult> get results => List.unmodifiable(_results);

  /// Determine if all the processes succeeded.
  bool successful() => _results.every((result) => result.successful());

  /// Determine if any of the processes failed.
  bool failed() => _results.any((result) => result.failed());

  /// Throw an exception if any of the processes failed.
  ProcessPoolResults throwIfAnyFailed() {
    if (failed()) {
      throw Exception('One or more processes failed.');
    }
    return this;
  }
}
