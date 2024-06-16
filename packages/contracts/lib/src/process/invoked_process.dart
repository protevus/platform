import 'process_result.dart';
abstract class InvokedProcess {
  /// Get the process ID if the process is still running.
  /// 
  /// Returns an integer or null.
  int? id();

  /// Send a signal to the process.
  /// 
  /// Takes an integer [signal] and returns the current instance.
  InvokedProcess signal(int signal);

  /// Determine if the process is still running.
  /// 
  /// Returns a boolean.
  bool running();

  /// Get the standard output for the process.
  /// 
  /// Returns a string.
  String output();

  /// Get the error output for the process.
  /// 
  /// Returns a string.
  String errorOutput();

  /// Get the latest standard output for the process.
  /// 
  /// Returns a string.
  String latestOutput();

  /// Get the latest error output for the process.
  /// 
  /// Returns a string.
  String latestErrorOutput();

  /// Wait for the process to finish.
  /// 
  /// Takes an optional [output] callback and returns a ProcessResult instance.
  Future<ProcessResult> wait([Future<void> Function()? output]);
}
