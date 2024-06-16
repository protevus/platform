abstract class ProcessResult {
  /// Get the original command executed by the process.
  ///
  /// @return String
  String command();

  /// Determine if the process was successful.
  ///
  /// @return bool
  bool successful();

  /// Determine if the process failed.
  ///
  /// @return bool
  bool failed();

  /// Get the exit code of the process.
  ///
  /// @return int|null
  int? exitCode();

  /// Get the standard output of the process.
  ///
  /// @return String
  String output();

  /// Determine if the output contains the given string.
  ///
  /// @param String output
  /// @return bool
  bool seeInOutput(String output);

  /// Get the error output of the process.
  ///
  /// @return String
  String errorOutput();

  /// Determine if the error output contains the given string.
  ///
  /// @param String output
  /// @return bool
  bool seeInErrorOutput(String output);

  /// Throw an exception if the process failed.
  ///
  /// @param Function? callback
  /// @return ProcessResult
  ProcessResult throwException([Function? callback]);

  /// Throw an exception if the process failed and the given condition is true.
  ///
  /// @param bool condition
  /// @param Function? callback
  /// @return ProcessResult
  ProcessResult throwIf(bool condition, [Function? callback]);
}
