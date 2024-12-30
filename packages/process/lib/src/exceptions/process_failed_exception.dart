import '../contracts/process_result.dart';

/// Exception thrown when a process fails.
class ProcessFailedException implements Exception {
  /// The process result that caused this exception.
  final ProcessResult result;

  /// Create a new process failed exception instance.
  ProcessFailedException(this.result);

  @override
  String toString() {
    return '''
The process "${result.command()}" failed with exit code ${result.exitCode()}.

Output:
${result.output().isEmpty ? '(empty)' : result.output()}

Error Output:
${result.errorOutput().isEmpty ? '(empty)' : result.errorOutput()}
''';
  }
}

/// Exception thrown when a process times out.
class ProcessTimeoutException implements Exception {
  /// The process result that caused this exception.
  final ProcessResult result;

  /// The timeout duration that was exceeded.
  final Duration timeout;

  /// Create a new process timeout exception instance.
  ProcessTimeoutException(this.result, this.timeout);

  @override
  String toString() {
    return '''
The process "${result.command()}" timed out after ${timeout.inSeconds} seconds.

Output:
${result.output().isEmpty ? '(empty)' : result.output()}

Error Output:
${result.errorOutput().isEmpty ? '(empty)' : result.errorOutput()}
''';
  }
}
