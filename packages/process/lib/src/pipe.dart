import 'dart:async';
import 'factory.dart';
import 'pending_process.dart';
import 'contracts/process_result.dart';

/// Represents a series of piped processes.
class Pipe {
  /// The process factory instance.
  final Factory _factory;

  /// The callback that configures the pipe.
  final void Function(Pipe) _callback;

  /// The processes in the pipe.
  final List<PendingProcess> _processes = [];

  /// Create a new process pipe instance.
  Pipe(this._factory, this._callback);

  /// Add a process to the pipe.
  Pipe command(dynamic command) {
    _processes.add(_factory.command(command));
    return this;
  }

  /// Run the processes in the pipe.
  Future<ProcessResult> run({void Function(String)? output}) async {
    _callback(this);
    return _factory.pipe(_processes, onOutput: output);
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
