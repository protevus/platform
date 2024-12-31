/// Represents the result of a process execution.
class ProcessResult {
  /// The process exit code.
  final int _exitCode;

  /// The process standard output.
  final String _output;

  /// The process error output.
  final String _errorOutput;

  /// Create a new process result instance.
  ProcessResult(this._exitCode, this._output, this._errorOutput);

  /// Get the process exit code.
  int get exitCode => _exitCode;

  /// Get the process output.
  String output() => _output;

  /// Get the process error output.
  String errorOutput() => _errorOutput;

  /// Check if the process was successful.
  bool successful() => _exitCode == 0;

  /// Check if the process failed.
  bool failed() => !successful();

  @override
  String toString() => _output;
}
