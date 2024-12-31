import '../process_result.dart';

/// Exception thrown when a process times out.
class ProcessTimedOutException implements Exception {
  /// The error message.
  final String message;

  /// The process result, if available.
  final ProcessResult? result;

  /// Create a new process timed out exception instance.
  ProcessTimedOutException(this.message, [this.result]);

  @override
  String toString() {
    final buffer = StringBuffer(message);

    if (result != null) {
      if (result!.output().isNotEmpty) {
        buffer.writeln();
        buffer.writeln();
        buffer.writeln('Output:');
        buffer.writeln('================');
        buffer.writeln(result!.output());
      }

      if (result!.errorOutput().isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Error Output:');
        buffer.writeln('================');
        buffer.writeln(result!.errorOutput());
      }
    }

    return buffer.toString();
  }
}
