import 'dart:async';
import 'dart:io';
import 'dart:convert';

// import 'package:angel3_framework/angel3_framework.dart';
// import 'package:angel3_mq/mq.dart';
// import 'package:angel3_reactivex/angel3_reactivex.dart';
// import 'package:angel3_event_bus/event_bus.dart';
import 'package:logging/logging.dart';

class Angel3Process {
  final String _command;
  final List<String> _arguments;
  final String? _workingDirectory;
  final Map<String, String>? _environment;
  final Duration? _timeout;
  final bool _tty;
  final bool _enableReadError;
  final Logger _logger;

  late final StreamController<List<int>> _outputController;
  late final StreamController<List<int>> _errorController;
  late final Completer<String> _outputCompleter;
  late final Completer<String> _errorCompleter;
  final Completer<String> _errorOutputCompleter = Completer<String>();
  bool _isOutputComplete = false;
  bool _isErrorComplete = false;

  Process? _process;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isDisposed = false;

  Angel3Process(
    this._command,
    this._arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    Duration? timeout,
    bool tty = false,
    bool enableReadError = true,
    Logger? logger,
  })  : _workingDirectory = workingDirectory,
        _environment = environment,
        _timeout = timeout,
        _tty = tty,
        _enableReadError = enableReadError,
        _logger = logger ?? Logger('Angel3Process'),
        _outputController = StreamController<List<int>>.broadcast(),
        _errorController = StreamController<List<int>>.broadcast(),
        _outputCompleter = Completer<String>(),
        _errorCompleter = Completer<String>();

  // Add this public getter
  String get command => _command;
  int? get pid => _process?.pid;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  Stream<List<int>> get output => _outputController.stream;
  Stream<List<int>> get errorOutput => _errorController.stream;

  // Future<String> get outputAsString => _outputCompleter.future;
  // Future<String> get errorOutputAsString => _errorCompleter.future;

  Future<int> get exitCode => _process?.exitCode ?? Future.value(-1);
  bool get isRunning => _process != null && !_process!.kill();

  Future<Angel3Process> start() async {
    if (_isDisposed) {
      throw StateError('This process has been disposed and cannot be reused.');
    }
    _startTime = DateTime.now();

    try {
      _process = await Process.start(
        _command,
        _arguments,
        workingDirectory: _workingDirectory,
        environment: _environment,
        runInShell: _tty,
      );

      _process!.stdout.listen(
        (data) {
          _outputController.add(data);
        },
        onDone: () {
          if (!_isOutputComplete) {
            _isOutputComplete = true;
            _outputController.close();
          }
        },
        onError: (error) {
          _logger.severe('Error in stdout stream', error);
          _outputController.addError(error);
          if (!_isOutputComplete) {
            _isOutputComplete = true;
            _outputController.close();
          }
        },
      );

      var errorBuffer = StringBuffer();
      _process!.stderr.listen(
        (data) {
          _errorController.add(data);
          errorBuffer.write(utf8.decode(data));
        },
        onDone: () {
          if (!_isErrorComplete) {
            _isErrorComplete = true;
            _errorController.close();
            _errorOutputCompleter.complete(errorBuffer.toString());
          }
        },
        onError: (error) {
          _logger.severe('Error in stderr stream', error);
          _errorController.addError(error);
          if (!_isErrorComplete) {
            _isErrorComplete = true;
            _errorController.close();
            _errorOutputCompleter.completeError(error);
          }
        },
      );

      _logger.info('Process started: $_command ${_arguments.join(' ')}');
    } catch (e) {
      _logger.severe('Failed to start process', e);
      rethrow;
    }
    return this;
  }

  Future<ProcessResult> run() async {
    await start();
    if (_timeout != null) {
      return await runWithTimeout(_timeout!);
    }
    final exitCode = await this.exitCode;
    final output = await outputAsString;
    final errorOutput = await _errorOutputCompleter.future;
    _endTime = DateTime.now();
    return ProcessResult(pid!, exitCode, output, errorOutput);
  }

  Future<ProcessResult> runWithTimeout(Duration timeout) async {
    final exitCodeFuture = this.exitCode.timeout(timeout, onTimeout: () {
      kill();
      throw TimeoutException('Process timed out', timeout);
    });

    try {
      final exitCode = await exitCodeFuture;
      final output = await outputAsString;
      final errorOutput = await _errorOutputCompleter.future;
      _endTime = DateTime.now();
      return ProcessResult(pid!, exitCode, output, errorOutput);
    } catch (e) {
      if (e is TimeoutException) {
        throw e;
      }
      rethrow;
    }
  }

  Future<void> write(String input) async {
    if (_process != null) {
      _process!.stdin.write(input);
      await _process!.stdin.flush();
    } else {
      throw StateError('Process has not been started');
    }
  }

  Future<void> writeLines(List<String> lines) async {
    for (final line in lines) {
      await write('$line\n');
    }
  }

  Future<void> kill({ProcessSignal signal = ProcessSignal.sigterm}) async {
    if (_process != null) {
      _logger.info('Killing process with signal: ${signal.name}');
      final result = _process!.kill(signal);
      if (!result) {
        _logger.warning('Failed to kill process with signal: ${signal.name}');
      }
    }
  }

  bool sendSignal(ProcessSignal signal) {
    return _process?.kill(signal) ?? false;
  }

  Future<void> dispose() async {
    if (!_isDisposed) {
      _isDisposed = true;
      await _outputController.close();
      await _errorController.close();
      if (!_outputCompleter.isCompleted) {
        _outputCompleter.complete('');
      }
      if (!_errorCompleter.isCompleted) {
        _errorCompleter.complete('');
      }
      await kill();
      _logger.info('Process disposed: $_command ${_arguments.join(' ')}');
    }
  }

  Future<String> get outputAsString async {
    var buffer = await output.transform(utf8.decoder).join();
    return buffer;
  }

  Future<String> get errorOutputAsString => _errorOutputCompleter.future;
}

class ProcessResult {
  final int pid;
  final int exitCode;
  final String output;
  final String errorOutput;

  ProcessResult(this.pid, this.exitCode, this.output, this.errorOutput);

  @override
  String toString() {
    return 'ProcessResult(pid: $pid, exitCode: $exitCode, output: ${output.length} chars, errorOutput: ${errorOutput.length} chars)';
  }
}

class InvokedProcess {
  final Angel3Process process;
  final DateTime startTime;
  final DateTime endTime;
  final int exitCode;
  final String output;
  final String errorOutput;

  InvokedProcess(this.process, this.startTime, this.endTime, this.exitCode,
      this.output, this.errorOutput);

  @override
  String toString() {
    return 'InvokedProcess(command: ${process._command}, arguments: ${process._arguments}, startTime: $startTime, endTime: $endTime, exitCode: $exitCode)';
  }
}
