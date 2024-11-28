/// Base class for all reflection-related exceptions.
class ReflectionException implements Exception {
  /// The error message.
  final String message;

  /// Creates a new reflection exception with the given [message].
  const ReflectionException(this.message);

  @override
  String toString() => 'ReflectionException: $message';
}

/// Thrown when attempting to reflect on a type that is not marked as [Reflectable].
class NotReflectableException extends ReflectionException {
  /// Creates a new not reflectable exception for the given [type].
  NotReflectableException(Type type)
      : super('Type "$type" is not marked as @reflectable');
}

/// Thrown when a property or method is not found during reflection.
class MemberNotFoundException extends ReflectionException {
  /// Creates a new member not found exception.
  MemberNotFoundException(String memberName, Type type)
      : super('Member "$memberName" not found on type "$type"');
}

/// Thrown when attempting to invoke a method with invalid arguments.
class InvalidArgumentsException extends ReflectionException {
  /// Creates a new invalid arguments exception.
  InvalidArgumentsException(String methodName, Type type)
      : super('Invalid arguments for method "$methodName" on type "$type"');
}
