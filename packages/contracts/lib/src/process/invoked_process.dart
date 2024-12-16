import 'process_result.dart';

/// Interface for running processes.
abstract class InvokedProcess {
  /// Get the process ID if the process is still running.
  int? id();

  /// Send a signal to the process.
  InvokedProcess signal(int signal);

  /// Determine if the process is still running.
  bool running();

  /// Get the standard output for the process.
  String output();

  /// Get the error output for the process.
  String errorOutput();

  /// Get the latest standard output for the process.
  String latestOutput();

  /// Get the latest error output for the process.
  String latestErrorOutput();

  /// Wait for the process to finish.
  ProcessResult wait([Function? output]);
}
