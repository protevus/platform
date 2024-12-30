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

  /// Create a new invoked process instance.
  InvokedProcess(this._process, this._command, [this._outputHandler]) {
    // Set up output handling
    _process.stdout.transform(utf8.decoder).listen((data) {
      _outputBuffer.write(data);
      _outputHandler?.call(data);
    });

    _process.stderr.transform(utf8.decoder).listen((data) {
      _errorBuffer.write(data);
      _outputHandler?.call(data);
    });
  }

  /// Get the process ID.
  int get pid => _process.pid;

  /// Kill the process.
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    return _process.kill(signal);
  }

  /// Get the process exit code.
  Future<int> get exitCode => _process.exitCode;

  /// Wait for the process to complete.
  Future<ProcessResult> wait() async {
    final exitCode = await _process.exitCode;

    return ProcessResultImpl(
      command: _command,
      exitCode: exitCode,
      output: _outputBuffer.toString(),
      errorOutput: _errorBuffer.toString(),
    );
  }

  /// Get the process stdout stream.
  Stream<List<int>> get stdout => _process.stdout;

  /// Get the process stderr stream.
  Stream<List<int>> get stderr => _process.stderr;

  /// Get the process stdin sink.
  IOSink get stdin => _process.stdin;

  /// Write data to the process stdin.
  Future<void> write(String input) async {
    _process.stdin.write(input);
    await _process.stdin.flush();
  }

  /// Write lines to the process stdin.
  Future<void> writeLines(List<String> lines) async {
    for (final line in lines) {
      await write('$line\n');
    }
  }
}
