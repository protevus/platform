import 'dart:io';
import 'dart:async';
import 'process_result.dart';
import 'exceptions/process_failed_exception.dart';

/// Represents a process that has been started.
class InvokedProcess {
  /// The underlying process instance.
  final Process _process;

  /// The output handler callback.
  final void Function(String)? _onOutput;

  /// The collected stdout data.
  final List<int> _stdout = [];

  /// The collected stderr data.
  final List<int> _stderr = [];

  /// Whether the process has completed
  bool _completed = false;

  /// Whether the process was killed
  bool _killed = false;

  /// Completer for stdout stream
  final _stdoutCompleter = Completer<void>();

  /// Completer for stderr stream
  final _stderrCompleter = Completer<void>();

  /// Create a new invoked process instance.
  InvokedProcess(this._process, this._onOutput) {
    _process.stdout.listen(
      (data) {
        _stdout.addAll(data);
        if (_onOutput != null) {
          _onOutput!(String.fromCharCodes(data));
        }
      },
      onDone: () => _stdoutCompleter.complete(),
    );

    _process.stderr.listen(
      (data) {
        _stderr.addAll(data);
        if (_onOutput != null) {
          _onOutput!(String.fromCharCodes(data));
        }
      },
      onDone: () => _stderrCompleter.complete(),
    );

    // Track when the process completes
    _process.exitCode.then((_) => _completed = true);
  }

  /// Get the process ID.
  int get pid => _process.pid;

  /// Write data to the process stdin.
  void write(dynamic input) {
    if (input is String) {
      _process.stdin.write(input);
    } else if (input is List<int>) {
      _process.stdin.add(input);
    }
  }

  /// Signal the process.
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    _killed = true;
    return _process.kill(signal);
  }

  /// Check if the process is still running.
  bool running() {
    return !_completed;
  }

  /// Wait for the process to complete and get its result.
  Future<ProcessResult> wait() async {
    // Wait for all streams to complete
    await Future.wait([
      _stdoutCompleter.future,
      _stderrCompleter.future,
    ]);

    final exitCode = await _process.exitCode;
    final result = ProcessResult(
      exitCode,
      String.fromCharCodes(_stdout),
      String.fromCharCodes(_stderr),
    );

    // Don't throw if the process was killed
    if (!_killed && exitCode != 0) {
      throw ProcessFailedException(result);
    }

    return result;
  }

  /// Get the latest output from the process.
  String latestOutput() {
    return String.fromCharCodes(_stdout);
  }

  /// Get the latest error output from the process.
  String latestErrorOutput() {
    return String.fromCharCodes(_stderr);
  }

  /// Get all output from the process.
  String output() {
    return String.fromCharCodes(_stdout);
  }

  /// Get all error output from the process.
  String errorOutput() {
    return String.fromCharCodes(_stderr);
  }
}
