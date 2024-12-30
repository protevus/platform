import 'contracts/process_result.dart';
import 'exceptions/process_failed_exception.dart';

/// Represents the result of a process execution.
class ProcessResultImpl implements ProcessResult {
  /// The original command executed by the process.
  final String _command;

  /// The exit code of the process.
  final int? _exitCode;

  /// The standard output of the process.
  final String _output;

  /// The error output of the process.
  final String _errorOutput;

  /// Create a new process result instance.
  ProcessResultImpl({
    required String command,
    required int? exitCode,
    required String output,
    required String errorOutput,
  })  : _command = command,
        _exitCode = exitCode,
        _output = output,
        _errorOutput = errorOutput;

  @override
  String command() => _command;

  @override
  bool successful() => _exitCode == 0;

  @override
  bool failed() => !successful();

  @override
  int? exitCode() => _exitCode;

  @override
  String output() => _output;

  @override
  bool seeInOutput(String output) => _output.contains(output);

  @override
  String errorOutput() => _errorOutput;

  @override
  bool seeInErrorOutput(String output) => _errorOutput.contains(output);

  @override
  ProcessResult throwIfFailed(
      [void Function(ProcessResult, Exception)? callback]) {
    if (successful()) {
      return this;
    }

    final exception = ProcessFailedException(this);

    if (callback != null) {
      callback(this, exception);
    }

    throw exception;
  }

  @override
  ProcessResult throwIf(bool condition,
      [void Function(ProcessResult, Exception)? callback]) {
    if (condition) {
      return throwIfFailed(callback);
    }

    return this;
  }

  @override
  String toString() {
    return '''
ProcessResult:
  Command: $_command
  Exit Code: $_exitCode
  Output: ${_output.isEmpty ? '(empty)' : '\n$_output'}
  Error Output: ${_errorOutput.isEmpty ? '(empty)' : '\n$_errorOutput'}
''';
  }
}
