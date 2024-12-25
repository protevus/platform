/// Base class for all reflection-related exceptions.
class ReflectionException implements Exception {
  /// The error message.
  final String message;

  /// Creates a new reflection exception.
  const ReflectionException(this.message);

  @override
  String toString() => 'ReflectionException: $message';
}
