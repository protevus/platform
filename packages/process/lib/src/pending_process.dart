import 'dart:io';
import 'dart:async';

import 'factory.dart';
import 'process_result.dart';
import 'invoked_process.dart';
import 'exceptions/process_timed_out_exception.dart';
import 'exceptions/process_failed_exception.dart';

/// A class that represents a process that is ready to be started.
class PendingProcess {
  /// The process factory instance.
  final Factory _factory;

  /// The command to invoke the process.
  dynamic command;

  /// The working directory of the process.
  String? workingDirectory;

  /// The maximum number of seconds the process may run.
  int? timeout = 60;

  /// The maximum number of seconds the process may go without returning output.
  int? idleTimeout;

  /// The additional environment variables for the process.
  Map<String, String> environment = {};

  /// The standard input data that should be piped into the command.
  dynamic input;

  /// Indicates whether output should be disabled for the process.
  bool quietly = false;

  /// Indicates if TTY mode should be enabled.
  bool tty = false;

  /// Create a new pending process instance.
  PendingProcess(this._factory);

  /// Format the command for display.
  String _formatCommand() {
    if (command is List) {
      return (command as List).join(' ');
    }
    return command.toString();
  }

  /// Specify the command that will invoke the process.
  PendingProcess withCommand(dynamic command) {
    this.command = command;
    return this;
  }

  /// Specify the working directory of the process.
  PendingProcess withWorkingDirectory(String directory) {
    workingDirectory = directory;
    return this;
  }

  /// Specify the maximum number of seconds the process may run.
  PendingProcess withTimeout(int seconds) {
    timeout = seconds;
    return this;
  }

  /// Specify the maximum number of seconds a process may go without returning output.
  PendingProcess withIdleTimeout(int seconds) {
    idleTimeout = seconds;
    return this;
  }

  /// Indicate that the process may run forever without timing out.
  PendingProcess forever() {
    timeout = null;
    return this;
  }

  /// Set the additional environment variables for the process.
  PendingProcess withEnvironment(Map<String, String> env) {
    environment = env;
    return this;
  }

  /// Set the standard input that should be provided when invoking the process.
  PendingProcess withInput(dynamic input) {
    this.input = input;
    return this;
  }

  /// Disable output for the process.
  PendingProcess withoutOutput() {
    quietly = true;
    return this;
  }

  /// Enable TTY mode for the process.
  PendingProcess withTty([bool enabled = true]) {
    tty = enabled;
    return this;
  }

  /// Run the process synchronously.
  Future<ProcessResult> run(
      [dynamic command, void Function(String)? onOutput]) async {
    this.command = command ?? this.command;

    if (this.command == null) {
      throw ArgumentError('No command specified');
    }

    // Handle immediate timeout
    if (timeout == 0) {
      throw ProcessTimedOutException(
        'The process "${_formatCommand()}" exceeded the timeout of $timeout seconds.',
      );
    }

    try {
      final process = await _createProcess();
      Timer? timeoutTimer;
      Timer? idleTimer;
      DateTime lastOutputTime = DateTime.now();
      bool timedOut = false;
      String? timeoutMessage;

      if (timeout != null) {
        timeoutTimer = Timer(Duration(seconds: timeout!), () {
          timedOut = true;
          timeoutMessage =
              'The process "${_formatCommand()}" exceeded the timeout of $timeout seconds.';
          process.kill();
        });
      }

      if (idleTimeout != null) {
        idleTimer = Timer.periodic(Duration(seconds: 1), (_) {
          final idleSeconds =
              DateTime.now().difference(lastOutputTime).inSeconds;
          if (idleSeconds >= idleTimeout!) {
            timedOut = true;
            timeoutMessage =
                'The process "${_formatCommand()}" exceeded the idle timeout of $idleTimeout seconds.';
            process.kill();
            idleTimer?.cancel();
          }
        });
      }

      try {
        final result = await _runProcess(process, (output) {
          lastOutputTime = DateTime.now();
          onOutput?.call(output);
        });

        if (timedOut) {
          throw ProcessTimedOutException(timeoutMessage!);
        }

        if (result.exitCode != 0) {
          throw ProcessFailedException(result);
        }

        return result;
      } finally {
        timeoutTimer?.cancel();
        idleTimer?.cancel();
      }
    } on ProcessException catch (e) {
      final result = ProcessResult(1, '', e.message);
      throw ProcessFailedException(result);
    }
  }

  /// Start the process asynchronously.
  Future<InvokedProcess> start([void Function(String)? onOutput]) async {
    if (command == null) {
      throw ArgumentError('No command specified');
    }

    try {
      final process = await _createProcess();

      if (input != null) {
        if (input is String) {
          process.stdin.write(input);
        } else if (input is List<int>) {
          process.stdin.add(input);
        }
        await process.stdin.close();
      }

      return InvokedProcess(process, onOutput);
    } on ProcessException catch (e) {
      final result = ProcessResult(1, '', e.message);
      throw ProcessFailedException(result);
    }
  }

  Future<Process> _createProcess() async {
    if (command is List) {
      final List<String> args =
          (command as List).map((e) => e.toString()).toList();
      return Process.start(
        args[0],
        args.skip(1).toList(),
        workingDirectory: workingDirectory ?? Directory.current.path,
        environment: environment,
        includeParentEnvironment: true,
        runInShell: false,
        mode: tty ? ProcessStartMode.inheritStdio : ProcessStartMode.normal,
      );
    } else {
      // For string commands, use shell to handle pipes, redirects, etc.
      final shell = Platform.isWindows ? 'cmd' : '/bin/sh';
      final shellArg = Platform.isWindows ? '/c' : '-c';
      return Process.start(
        shell,
        [shellArg, command.toString()],
        workingDirectory: workingDirectory ?? Directory.current.path,
        environment: environment,
        includeParentEnvironment: true,
        runInShell: true,
        mode: tty ? ProcessStartMode.inheritStdio : ProcessStartMode.normal,
      );
    }
  }

  Future<ProcessResult> _runProcess(
      Process process, void Function(String)? onOutput) async {
    final stdout = <int>[];
    final stderr = <int>[];
    final stdoutCompleter = Completer<void>();
    final stderrCompleter = Completer<void>();

    if (!quietly) {
      process.stdout.listen(
        (data) {
          stdout.addAll(data);
          if (onOutput != null) {
            onOutput(String.fromCharCodes(data));
          }
        },
        onDone: () => stdoutCompleter.complete(),
      );

      process.stderr.listen(
        (data) {
          stderr.addAll(data);
          if (onOutput != null) {
            onOutput(String.fromCharCodes(data));
          }
        },
        onDone: () => stderrCompleter.complete(),
      );
    } else {
      stdoutCompleter.complete();
      stderrCompleter.complete();
    }

    if (input != null) {
      if (input is String) {
        process.stdin.write(input);
      } else if (input is List<int>) {
        process.stdin.add(input);
      }
      await process.stdin.close();
    }

    // Wait for all streams to complete
    await Future.wait([
      stdoutCompleter.future,
      stderrCompleter.future,
    ]);

    final exitCode = await process.exitCode;

    return ProcessResult(
      exitCode,
      String.fromCharCodes(stdout),
      String.fromCharCodes(stderr),
    );
  }
}
