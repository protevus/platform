/// Base exception interface for cache exceptions.
class CacheException implements Exception {
  /// The error message.
  final String message;

  /// Creates a new cache exception.
  const CacheException([this.message = '']);

  @override
  String toString() =>
      message.isEmpty ? 'CacheException' : 'CacheException: $message';
}

/// Exception interface for invalid cache arguments.
class InvalidArgumentException extends CacheException {
  /// Creates a new invalid argument exception.
  const InvalidArgumentException([String message = '']) : super(message);

  @override
  String toString() => message.isEmpty
      ? 'InvalidArgumentException'
      : 'InvalidArgumentException: $message';
}
