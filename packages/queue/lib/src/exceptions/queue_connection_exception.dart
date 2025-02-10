/// Exception thrown when there is an error with a queue connection.
class QueueConnectionException implements Exception {
  /// The error message.
  final String message;

  /// Create a new queue connection exception.
  QueueConnectionException(this.message);

  @override
  String toString() => 'QueueConnectionException: $message';
}
