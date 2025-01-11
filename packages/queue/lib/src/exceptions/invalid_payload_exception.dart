/// Exception thrown when a queue payload cannot be created.
class InvalidPayloadException implements Exception {
  /// The error message.
  final String message;

  /// The payload that caused the error.
  final Map<String, dynamic> payload;

  /// Create a new invalid payload exception.
  InvalidPayloadException(this.message, this.payload);

  @override
  String toString() => 'InvalidPayloadException: $message';
}
