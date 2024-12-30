import 'dart:async';
import 'dart:io';
import 'contracts/process_result.dart';
import 'process_result.dart';
import 'fake_process_description.dart';

/// Represents a fake invoked process for testing.
class FakeInvokedProcess {
  /// The command that was executed.
  final String command;

  /// The process description.
  final FakeProcessDescription description;

  /// The output handler.
  void Function(String)? _outputHandler;

  /// Create a new fake invoked process instance.
  FakeInvokedProcess(this.command, this.description);

  /// Set the output handler.
  FakeInvokedProcess withOutputHandler(void Function(String)? handler) {
    _outputHandler = handler;
    return this;
  }

  /// Get the process ID.
  int get pid => description.pid;

  /// Kill the process.
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    return description.kill(signal);
  }

  /// Get the process exit code.
  Future<int> get exitCode => description.exitCodeFuture;

  /// Get the predicted process result.
  ProcessResult predictProcessResult() {
    return ProcessResultImpl(
      command: command,
      exitCode: description.predictedExitCode,
      output: description.predictedOutput,
      errorOutput: description.predictedErrorOutput,
    );
  }

  /// Wait for the process to complete.
  Future<ProcessResult> wait() async {
    if (_outputHandler != null) {
      for (final output in description.outputSequence) {
        _outputHandler!(output);
        await description.delay;
      }
    }

    await description.runDuration;
    return predictProcessResult();
  }
}
