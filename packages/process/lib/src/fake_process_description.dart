import 'dart:async';
import 'dart:io';

/// Describes how a fake process should behave.
class FakeProcessDescription {
  /// The process ID.
  final int pid = DateTime.now().millisecondsSinceEpoch;

  /// The predicted exit code.
  int _exitCode = 0;

  /// The predicted output.
  String _output = '';

  /// The predicted error output.
  String _errorOutput = '';

  /// The sequence of outputs.
  final List<String> _outputSequence = [];

  /// The delay between outputs.
  Duration _delay = const Duration(milliseconds: 100);

  /// The total run duration.
  Duration _runDuration = Duration.zero;

  /// Whether the process was killed.
  bool _wasKilled = false;

  /// Create a new fake process description instance.
  FakeProcessDescription();

  /// Get the predicted exit code.
  int get predictedExitCode => _wasKilled ? -1 : _exitCode;

  /// Get the predicted output.
  String get predictedOutput => _output;

  /// Get the predicted error output.
  String get predictedErrorOutput => _errorOutput;

  /// Get the output sequence.
  List<String> get outputSequence => List.unmodifiable(_outputSequence);

  /// Get the delay between outputs.
  Duration get delay => _delay;

  /// Get the total run duration.
  Duration get runDuration => _runDuration;

  /// Set the exit code.
  FakeProcessDescription withExitCode(int code) {
    _exitCode = code;
    return this;
  }

  /// Replace the output.
  FakeProcessDescription replaceOutput(String output) {
    _output = output;
    return this;
  }

  /// Replace the error output.
  FakeProcessDescription replaceErrorOutput(String output) {
    _errorOutput = output;
    return this;
  }

  /// Set the output sequence.
  FakeProcessDescription withOutputSequence(List<String> sequence) {
    _outputSequence.clear();
    _outputSequence.addAll(sequence);
    return this;
  }

  /// Set the delay between outputs.
  FakeProcessDescription withDelay(Duration delay) {
    _delay = delay;
    return this;
  }

  /// Configure how long the process should run.
  FakeProcessDescription runsFor({
    Duration? duration,
    int? iterations,
  }) {
    if (duration != null) {
      _runDuration = duration;
    } else if (iterations != null) {
      _runDuration = _delay * iterations;
    }
    return this;
  }

  /// Kill the process.
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    _wasKilled = true;
    return true;
  }

  /// Get the process exit code future.
  Future<int> get exitCodeFuture async {
    await Future.delayed(_runDuration);
    return predictedExitCode;
  }

  /// Create a process result from this description.
  ProcessResult toProcessResult(String command) {
    return ProcessResult(
      pid,
      predictedExitCode,
      predictedOutput,
      predictedErrorOutput,
    );
  }
}
