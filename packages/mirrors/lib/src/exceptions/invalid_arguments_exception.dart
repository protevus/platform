import 'package:illuminate_mirrors/mirrors.dart';

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
