import '../process_result.dart';

/// Exception thrown when a process fails.
class ProcessFailedException implements Exception {
  /// The process result.
  final ProcessResult _result;

  /// Create a new process failed exception instance.
  ProcessFailedException(this._result);

  /// Get the process result.
  ProcessResult get result => _result;

  /// Get the process exit code.
  int get exitCode => _result.exitCode;

  /// Get the process output.
  String get output => _result.output();

  /// Get the process error output.
  String get errorOutput => _result.errorOutput();

  @override
  String toString() {
    final buffer =
        StringBuffer('Process failed with exit code: ${_result.exitCode}');

    if (_result.output().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Output:');
      buffer.writeln(_result.output().trim());
    }

    if (_result.errorOutput().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Error Output:');
      buffer.writeln(_result.errorOutput().trim());
    }

    return buffer.toString();
  }
}
