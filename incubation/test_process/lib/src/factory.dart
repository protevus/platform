import 'pending_process.dart';
import 'process_result.dart';
import 'invoked_process.dart';

/// A factory for creating process instances.
class Factory {
  /// Create a new process factory instance.
  Factory();

  /// Begin preparing a new process.
  PendingProcess command(dynamic command) {
    return PendingProcess(this).withCommand(command);
  }

  /// Begin preparing a new process with the given working directory.
  PendingProcess path(String path) {
    return PendingProcess(this).withWorkingDirectory(path);
  }

  /// Run a command synchronously.
  Future<ProcessResult> run(dynamic command) {
    return PendingProcess(this).withCommand(command).run();
  }

  /// Start a command asynchronously.
  Future<InvokedProcess> start(dynamic command,
      [void Function(String)? onOutput]) {
    return PendingProcess(this).withCommand(command).start(onOutput);
  }

  /// Run a command with a specific working directory.
  Future<ProcessResult> runInPath(String path, dynamic command) {
    return PendingProcess(this)
        .withWorkingDirectory(path)
        .withCommand(command)
        .run();
  }

  /// Run a command with environment variables.
  Future<ProcessResult> runWithEnvironment(
    dynamic command,
    Map<String, String> environment,
  ) {
    return PendingProcess(this)
        .withCommand(command)
        .withEnvironment(environment)
        .run();
  }

  /// Run a command with a timeout.
  Future<ProcessResult> runWithTimeout(
    dynamic command,
    int seconds,
  ) {
    return PendingProcess(this).withCommand(command).withTimeout(seconds).run();
  }

  /// Run a command with input.
  Future<ProcessResult> runWithInput(
    dynamic command,
    dynamic input,
  ) {
    return PendingProcess(this).withCommand(command).withInput(input).run();
  }
}
