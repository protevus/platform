/// Exception thrown when a broadcasting operation fails.
class BroadcastException implements Exception {
  /// The error message describing what went wrong.
  final String message;

  /// Optional error that caused this exception.
  final Object? error;

  /// Optional stack trace from the causing error.
  final StackTrace? stackTrace;

  /// Creates a new broadcast exception.
  ///
  /// Parameters:
  /// - [message]: Description of what went wrong
  /// - [error]: Optional error that caused this exception
  /// - [stackTrace]: Optional stack trace from the causing error
  const BroadcastException(
    this.message, {
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('BroadcastException: $message');
    if (error != null) {
      buffer.write('\nCaused by: $error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    return buffer.toString();
  }
}
