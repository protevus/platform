/// Base class for all reflection-related exceptions.
class ReflectionException implements Exception {
  /// The error message.
  final String message;

  /// Creates a new reflection exception.
  const ReflectionException(this.message);

  @override
  String toString() => 'ReflectionException: $message';
}

/// Exception thrown when attempting to reflect on a non-reflectable type.
class NotReflectableException extends ReflectionException {
  /// The type that was not reflectable.
  final Type type;

  /// Creates a new not reflectable exception.
  const NotReflectableException(this.type)
      : super('Type $type is not reflectable. '
            'Make sure it is annotated with @reflectable or registered manually.');
}

/// Exception thrown when invalid arguments are provided to a reflective operation.
class InvalidArgumentsException extends ReflectionException {
  /// The name of the member being invoked.
  final String memberName;

  /// The type the member belongs to.
  final Type type;

  /// Creates a new invalid arguments exception.
  const InvalidArgumentsException(this.memberName, this.type)
      : super('Invalid arguments for $memberName on type $type');
}

/// Exception thrown when a member is not found during reflection.
class MemberNotFoundException extends ReflectionException {
  /// The name of the member that was not found.
  final String memberName;

  /// The type the member was looked up on.
  final Type type;

  /// Creates a new member not found exception.
  const MemberNotFoundException(this.memberName, this.type)
      : super('Member $memberName not found on type $type');
}
