import 'dart:async';
import 'contracts/process_result.dart';
import 'invoked_process.dart';
import 'process_pool_results.dart';

/// Represents a pool of running processes.
class InvokedProcessPool {
  /// The processes in the pool.
  final List<InvokedProcess> _processes;

  /// Create a new invoked process pool instance.
  InvokedProcessPool(this._processes);

  /// Get the list of processes.
  List<InvokedProcess> get processes => List.unmodifiable(_processes);

  /// Wait for all processes to complete.
  Future<ProcessPoolResults> wait() async {
    final results = <ProcessResult>[];
    for (final process in _processes) {
      results.add(await process.wait());
    }
    return ProcessPoolResults(results);
  }

  /// Kill all processes.
  void kill() {
    for (final process in _processes) {
      process.kill();
    }
  }

  /// Get the process IDs.
  List<int> get pids => _processes.map((p) => p.pid).toList();

  /// Get the number of processes.
  int get length => _processes.length;

  /// Check if the pool is empty.
  bool get isEmpty => _processes.isEmpty;

  /// Check if the pool is not empty.
  bool get isNotEmpty => _processes.isNotEmpty;

  /// Get a process by index.
  InvokedProcess operator [](int index) => _processes[index];

  /// Iterate over the processes.
  Iterator<InvokedProcess> get iterator => _processes.iterator;

  /// Get the first process.
  InvokedProcess get first => _processes.first;

  /// Get the last process.
  InvokedProcess get last => _processes.last;

  /// Add a process to the pool.
  void add(InvokedProcess process) {
    _processes.add(process);
  }

  /// Remove a process from the pool.
  bool remove(InvokedProcess process) {
    return _processes.remove(process);
  }

  /// Clear all processes from the pool.
  void clear() {
    _processes.clear();
  }
}
