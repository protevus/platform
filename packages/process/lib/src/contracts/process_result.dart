//import 'package:platform_contracts/contracts.dart';

/// Contract for process execution results.
abstract class ProcessResult {
  /// Get the original command executed by the process.
  String command();

  /// Determine if the process was successful.
  bool successful();

  /// Determine if the process failed.
  bool failed();

  /// Get the exit code of the process.
  int? exitCode();

  /// Get the standard output of the process.
  String output();

  /// Determine if the output contains the given string.
  bool seeInOutput(String output);

  /// Get the error output of the process.
  String errorOutput();

  /// Determine if the error output contains the given string.
  bool seeInErrorOutput(String output);

  /// Throw an exception if the process failed.
  ///
  /// Returns this instance for method chaining.
  ProcessResult throwIfFailed(
      [void Function(ProcessResult, Exception)? callback]);

  /// Throw an exception if the process failed and the given condition is true.
  ///
  /// Returns this instance for method chaining.
  ProcessResult throwIf(bool condition,
      [void Function(ProcessResult, Exception)? callback]);
}