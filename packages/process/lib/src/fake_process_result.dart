import 'contracts/process_result.dart';
import 'exceptions/process_failed_exception.dart';

/// Represents a fake process result for testing.
class FakeProcessResult implements ProcessResult {
  /// The command that was executed.
  final String _command;

  /// The exit code of the process.
  final int _exitCode;

  /// The output of the process.
  final String _output;

  /// The error output of the process.
  final String _errorOutput;

  /// Create a new fake process result instance.
  FakeProcessResult({
    String command = '',
    int exitCode = 0,
    String output = '',
    String errorOutput = '',
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

  /// Create a copy of this result with a different command.
  FakeProcessResult withCommand(String command) {
    return FakeProcessResult(
      command: command,
      exitCode: _exitCode,
      output: _output,
      errorOutput: _errorOutput,
    );
  }

  /// Create a copy of this result with a different exit code.
  FakeProcessResult withExitCode(int exitCode) {
    return FakeProcessResult(
      command: _command,
      exitCode: exitCode,
      output: _output,
      errorOutput: _errorOutput,
    );
  }

  /// Create a copy of this result with different output.
  FakeProcessResult withOutput(String output) {
    return FakeProcessResult(
      command: _command,
      exitCode: _exitCode,
      output: output,
      errorOutput: _errorOutput,
    );
  }

  /// Create a copy of this result with different error output.
  FakeProcessResult withErrorOutput(String errorOutput) {
    return FakeProcessResult(
      command: _command,
      exitCode: _exitCode,
      output: _output,
      errorOutput: errorOutput,
    );
  }
}
