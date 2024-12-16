/// Exception thrown when a lock operation times out.
///
/// This exception is thrown when attempting to acquire a lock that could not
/// be obtained within the specified timeout period.
class LockTimeoutException implements Exception {
  /// The message describing why the lock operation timed out.
  final String message;

  /// Create a new lock timeout exception.
  ///
  /// Example:
  /// ```dart
  /// throw LockTimeoutException('Could not acquire lock "users" within 5 seconds');
  /// ```
  const LockTimeoutException(this.message);

  @override
  String toString() => 'LockTimeoutException: $message';
}
