import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'contracts/process_result.dart';
import 'process_result.dart';

/// Represents a running process.
class InvokedProcess {
  /// The underlying process instance.
  final Process _process;

  /// The command that was executed.
  final String _command;

  /// The output handler.
  final void Function(String)? _outputHandler;

  /// The output buffer.
  final StringBuffer _outputBuffer = StringBuffer();

  /// The error output buffer.
  final StringBuffer _errorBuffer = StringBuffer();

  /// The stdout stream controller.
  final StreamController<List<int>> _stdoutController;

  /// The stderr stream controller.
  final StreamController<List<int>> _stderrController;

  /// The stdout subscription.
  late final StreamSubscription<List<int>> _stdoutSubscription;

  /// The stderr subscription.
  late final StreamSubscription<List<int>> _stderrSubscription;

  /// Create a new invoked process instance.
  InvokedProcess(Process process, this._command, [this._outputHandler])
      : _process = process,
        _stdoutController = StreamController<List<int>>.broadcast(),
        _stderrController = StreamController<List<int>>.broadcast() {
    // Set up output handling
    _stdoutSubscription = _process.stdout.listen(
      (data) {
        _stdoutController.add(data);
        _handleOutput(data, _outputBuffer);
      },
      onDone: _stdoutController.close,
      cancelOnError: false,
    );

    _stderrSubscription = _process.stderr.listen(
      (data) {
        _stderrController.add(data);
        _handleOutput(data, _errorBuffer);
      },
      onDone: _stderrController.close,
      cancelOnError: false,
    );
  }

  /// Handle output data.
  void _handleOutput(List<int> data, StringBuffer buffer) {
    final text = utf8.decode(data);
    buffer.write(text);

    if (_outputHandler != null) {
      final lines = text.split('\n');
      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          _outputHandler!(trimmed);
        }
      }
    }
  }

  /// Get the process ID.
  int get pid => _process.pid;

  /// Kill the process.
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    closeStdin();
    _process.kill(signal);
    return true;
  }

  /// Get the process exit code.
  Future<int> get exitCode => _process.exitCode;

  /// Wait for the process to complete.
  Future<ProcessResult> wait() async {
    try {
      // Wait for process to complete first
      final exitCode = await _process.exitCode;

      // Give streams a chance to complete
      await Future.delayed(Duration(milliseconds: 10));

      // Cancel stream subscriptions
      await _stdoutSubscription.cancel();
      await _stderrSubscription.cancel();

      return ProcessResultImpl(
        command: _command,
        exitCode: exitCode,
        output: _outputBuffer.toString(),
        errorOutput: _errorBuffer.toString(),
      );
    } finally {
      // Ensure stdin is closed
      try {
        _process.stdin.close();
      } catch (_) {}
    }
  }

  /// Get the process stdout stream.
  Stream<List<int>> get stdout => _stdoutController.stream;

  /// Get the process stderr stream.
  Stream<List<int>> get stderr => _stderrController.stream;

  /// Get the process stdin sink.
  IOSink get stdin => _process.stdin;

  /// Write data to the process stdin.
  Future<void> write(String input) async {
    try {
      _process.stdin.write(input);
      await _process.stdin.flush();
      if (input.endsWith('\n')) {
        await _process.stdin.close();
        await Future.delayed(Duration(milliseconds: 10));
      }
    } catch (_) {}
  }

  /// Write lines to the process stdin.
  Future<void> writeLines(List<String> lines) async {
    try {
      for (final line in lines) {
        _process.stdin.write('$line\n');
        await _process.stdin.flush();
      }
      await _process.stdin.close();
      await Future.delayed(Duration(milliseconds: 10));
    } catch (_) {}
  }

  /// Close stdin.
  Future<void> closeStdin() async {
    try {
      await _process.stdin.close();
      await Future.delayed(Duration(milliseconds: 10));
    } catch (_) {}
  }
}
