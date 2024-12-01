import 'reflected_class.dart';
import 'reflected_function.dart';
import 'reflected_instance.dart';
import 'reflected_parameter.dart';
import 'reflected_type.dart';

/// Interface for reflection operations.
///
/// This contract defines the core reflection capabilities needed by the framework,
/// particularly for dependency injection and service container functionality.
abstract class Reflector {
  /// Get reflection information for a class.
  ReflectedClass reflectClass(Type type);

  /// Get reflection information for a function.
  ReflectedFunction reflectFunction(Function function);

  /// Get reflection information for an instance.
  ReflectedInstance reflectInstance(dynamic instance);

  /// Get reflection information for a type.
  ReflectedType reflectType(Type type);

  /// Get reflection information for a parameter.
  ReflectedParameter reflectParameter(dynamic parameter);

  /// Determine if a type has a given attribute.
  bool hasAttribute(Type type, Type attributeType);

  /// Get all attributes of a given type from a type.
  List<dynamic> getAttributes(Type type, Type attributeType);
}
