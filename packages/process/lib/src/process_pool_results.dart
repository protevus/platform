import 'contracts/process_result.dart';

/// Represents the results of a process pool execution.
class ProcessPoolResults {
  /// The results of the processes.
  final List<ProcessResult> _results;

  /// Create a new process pool results instance.
  ProcessPoolResults(this._results);

  /// Get all process results.
  List<ProcessResult> get results => List.unmodifiable(_results);

  /// Determine if all processes succeeded.
  bool successful() => _results.every((result) => result.successful());

  /// Determine if any process failed.
  bool failed() => _results.any((result) => result.failed());

  /// Get the number of successful processes.
  int get successCount =>
      _results.where((result) => result.successful()).length;

  /// Get the number of failed processes.
  int get failureCount => _results.where((result) => result.failed()).length;

  /// Get the total number of processes.
  int get total => _results.length;

  /// Get all successful results.
  List<ProcessResult> get successes =>
      _results.where((result) => result.successful()).toList();

  /// Get all failed results.
  List<ProcessResult> get failures =>
      _results.where((result) => result.failed()).toList();

  /// Throw if any process failed.
  ProcessPoolResults throwIfAnyFailed() {
    if (failed()) {
      throw Exception(
          'One or more processes in the pool failed:\n${_formatFailures()}');
    }
    return this;
  }

  /// Format failure messages for error reporting.
  String _formatFailures() {
    final buffer = StringBuffer();
    for (final result in failures) {
      buffer.writeln('- Command: ${result.command()}');
      buffer.writeln('  Exit Code: ${result.exitCode()}');
      if (result.output().isNotEmpty) {
        buffer.writeln('  Output: ${result.output()}');
      }
      if (result.errorOutput().isNotEmpty) {
        buffer.writeln('  Error Output: ${result.errorOutput()}');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Get a process result by index.
  ProcessResult operator [](int index) => _results[index];

  /// Get the number of results.
  int get length => _results.length;

  /// Check if there are no results.
  bool get isEmpty => _results.isEmpty;

  /// Check if there are any results.
  bool get isNotEmpty => _results.isNotEmpty;

  /// Get the first result.
  ProcessResult get first => _results.first;

  /// Get the last result.
  ProcessResult get last => _results.last;

  /// Iterate over the results.
  Iterator<ProcessResult> get iterator => _results.iterator;
}
