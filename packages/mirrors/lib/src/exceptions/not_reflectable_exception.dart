import 'package:platform_mirrors/mirrors.dart';

/// Exception thrown when attempting to reflect on a non-reflectable type.
class NotReflectableException extends ReflectionException {
  /// The type that was not reflectable.
  final Type type;

  /// Creates a new not reflectable exception.
  const NotReflectableException(this.type)
      : super('Type $type is not reflectable. '
            'Make sure it is annotated with @reflectable or registered manually.');
}
