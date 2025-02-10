/// Exception thrown when the application encryption key is missing.
class MissingAppKeyException implements Exception {
  /// The error message.
  final String message;

  /// Creates a new [MissingAppKeyException] instance.
  ///
  /// If no message is provided, a default message is used.
  MissingAppKeyException(
      [this.message = 'No application encryption key has been specified.']);

  @override
  String toString() => 'MissingAppKeyException: $message';
}
