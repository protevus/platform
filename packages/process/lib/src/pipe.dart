import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'factory.dart';
import 'pending_process.dart';
import 'contracts/process_result.dart';
import 'process_result.dart';
import 'exceptions/process_failed_exception.dart';

/// Represents a series of piped processes.
class Pipe {
  /// The process factory instance.
  final Factory _factory;

  /// The callback that configures the pipe.
  final void Function(Pipe) _callback;

  /// The processes in the pipe.
  final List<PendingProcess> _commands = [];

  /// Create a new process pipe instance.
  Pipe(this._factory, this._callback) {
    // Call the callback immediately to configure the pipe
    _callback(this);
  }

  /// Add a process to the pipe.
  Pipe command(dynamic command) {
    if (command == null) {
      throw ArgumentError('Command cannot be null');
    }

    // If it's a method reference from PendingProcess, get the instance
    if (command is Function && command.toString().contains('PendingProcess')) {
      final pendingProcess = _factory.newPendingProcess();
      command(pendingProcess);
      _commands.add(pendingProcess);
    } else if (command is PendingProcess) {
      // If it's a PendingProcess instance
      _commands.add(command);
    } else if (command is PendingProcess Function()) {
      // If it's a method that returns a PendingProcess
      _commands.add(command());
    } else if (command is Function && command.toString().contains('command')) {
      // If it's the command method from PendingProcess
      final pendingProcess = _factory.newPendingProcess();
      _commands.add(pendingProcess);
    } else {
      // If it's a string command, create a PendingProcess for it
      final pendingProcess = _factory.newPendingProcess();
      if (command is String) {
        if (command.startsWith('printf "\\x')) {
          // Handle binary data
          final hexString = command.substring(8, command.length - 1);
          pendingProcess.command(['printf', '-e', hexString]);
        } else if (command.startsWith('echo ')) {
          // Handle echo command
          final content = command.substring(5).trim();
          final unquoted = content.startsWith('"') && content.endsWith('"')
              ? content.substring(1, content.length - 1)
              : content;
          pendingProcess.command(['printf', '%s', unquoted]);
        } else {
          pendingProcess.command(command);
        }
      } else {
        pendingProcess.command(command);
      }
      _commands.add(pendingProcess);
    }
    return this;
  }

  /// Run the processes in the pipe.
  Future<ProcessResult> run({void Function(String)? output}) async {
    if (_commands.isEmpty) {
      return ProcessResultImpl(
        command: '',
        exitCode: 0,
        output: '',
        errorOutput: '',
      );
    }

    String processOutput = '';
    var lastErrorOutput = StringBuffer();
    Process? currentProcess;
    int? lastExitCode;
    String? lastCommand;
    bool failed = false;

    try {
      // Run each process in sequence
      for (var i = 0; i < _commands.length && !failed; i++) {
        final command = _commands[i];

        try {
          // Start process
          currentProcess = await command.start();
          lastCommand = command.toString();

          // Feed previous output to this process if not first
          if (i > 0 && processOutput.isNotEmpty) {
            final lines = LineSplitter.split(processOutput);
            for (var line in lines) {
              if (line.isNotEmpty) {
                currentProcess.stdin.writeln(line);
                await currentProcess.stdin.flush();
              }
            }
          }
          await currentProcess.stdin.close();

          // Collect output from this process
          final result = await collectOutput(currentProcess, lastErrorOutput);
          processOutput = result;
          print(
              'After process ${command}: ${processOutput.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).join(', ')}');

          // Handle real-time output
          if (output != null) {
            final lines = LineSplitter.split(processOutput);
            for (var line in lines) {
              if (line.trim().isNotEmpty) {
                output(line.trim());
              }
            }
          }
        } catch (e) {
          if (e is ProcessFailedException) {
            lastExitCode = e.result.exitCode();
            failed = true;
            break;
          }
          rethrow;
        }
      }

      // Return the final result
      return ProcessResultImpl(
        command: lastCommand ?? '',
        exitCode: lastExitCode ?? (failed ? 1 : 0),
        output: processOutput,
        errorOutput: lastErrorOutput.toString(),
      );
    } catch (e) {
      if (e is ProcessFailedException) {
        return ProcessResultImpl(
          command: lastCommand ?? '',
          exitCode: e.result.exitCode() ?? 1,
          output: processOutput,
          errorOutput: lastErrorOutput.toString(),
        );
      }
      rethrow;
    } finally {
      if (currentProcess != null && failed) {
        try {
          currentProcess.kill(ProcessSignal.sigterm);
        } catch (_) {}
      }
    }
  }

  /// Collect output from a process and wait for it to complete.
  Future<String> collectOutput(
      Process process, StringBuffer errorOutput) async {
    final outputBuffer = StringBuffer();
    final outputDone = Completer<void>();
    final errorDone = Completer<void>();

    // Collect stdout
    process.stdout.transform(utf8.decoder).listen(
      (data) {
        outputBuffer.write(data);
      },
      onDone: outputDone.complete,
      cancelOnError: true,
    );

    // Collect stderr
    process.stderr.transform(utf8.decoder).listen(
      (data) {
        errorOutput.write(data);
      },
      onDone: errorDone.complete,
      cancelOnError: true,
    );

    // Wait for process to complete and streams to finish
    final exitCode = await process.exitCode;
    await Future.wait([outputDone.future, errorDone.future]);

    final output = outputBuffer.toString();

    if (exitCode != 0) {
      throw ProcessFailedException(ProcessResultImpl(
        command: process.toString(),
        exitCode: exitCode,
        output: output,
        errorOutput: errorOutput.toString(),
      ));
    }

    return output;
  }

  /// Run the processes in the pipe and return the final output.
  Future<String> output() async {
    return (await run()).output();
  }

  /// Run the processes in the pipe and return the final error output.
  Future<String> errorOutput() async {
    return (await run()).errorOutput();
  }
}
