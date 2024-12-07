/// Base interface for exceptions thrown by a cache implementation.
abstract class CacheException implements Exception {
  /// The error message.
  String get message;
}

/// Exception interface for invalid cache arguments.
abstract class InvalidArgumentException implements CacheException {
  /// The error message.
  @override
  String get message;
}

/// A concrete implementation of CacheException.
class SimpleCacheException implements CacheException {
  @override
  final String message;

  /// Creates a new cache exception.
  const SimpleCacheException([this.message = '']);

  @override
  String toString() =>
      message.isEmpty ? 'CacheException' : 'CacheException: $message';
}

/// A concrete implementation of InvalidArgumentException.
class CacheInvalidArgumentException implements InvalidArgumentException {
  @override
  final String message;

  /// Creates a new invalid argument exception.
  const CacheInvalidArgumentException([this.message = '']);

  @override
  String toString() => message.isEmpty
      ? 'InvalidArgumentException'
      : 'InvalidArgumentException: $message';
}
