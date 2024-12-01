/// Exception thrown when broadcasting fails.
///
/// This exception is thrown when there is an error during broadcasting,
/// such as connection issues or invalid channel configurations.
class BroadcastException implements Exception {
  /// The message describing why broadcasting failed.
  final String message;

  /// Create a new broadcast exception.
  ///
  /// Example:
  /// ```dart
  /// throw BroadcastException('Failed to connect to broadcasting server');
  /// ```
  const BroadcastException(this.message);

  @override
  String toString() => 'BroadcastException: $message';
}
