import 'reflected_class.dart';
import 'reflected_function.dart';
import 'reflected_parameter.dart';
import 'reflected_type.dart';

/// Interface for instance reflection information.
abstract class ReflectedInstance {
  /// Get the actual instance being reflected.
  dynamic get instance;

  /// Get the class information for this instance.
  ReflectedClass get reflectedClass;

  /// Get the type information for this instance.
  ReflectedType get type;

  /// Get all attributes applied to this instance.
  List<dynamic> get attributes;

  /// Check if this instance has a specific attribute.
  bool hasAttribute(Type attributeType);

  /// Get all attributes of a specific type.
  List<dynamic> getAttributes(Type attributeType);

  /// Get the value of a property by name.
  dynamic getProperty(String name);

  /// Set the value of a property by name.
  void setProperty(String name, dynamic value);

  /// Invoke a method on this instance.
  dynamic invoke(String methodName, [Map<String, dynamic>? arguments]);

  /// Get all property values as a map.
  Map<String, dynamic> toMap();

  /// Get all methods that can be invoked on this instance.
  List<ReflectedFunction> get methods;

  /// Get all properties that can be accessed on this instance.
  List<ReflectedParameter> get properties;

  /// Get whether this instance has a specific property.
  bool hasProperty(String name);

  /// Get whether this instance has a specific method.
  bool hasMethod(String name);

  /// Get whether this instance is of a specific type.
  bool isInstanceOf(Type type);
}
