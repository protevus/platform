import 'reflected_type.dart';

/// Interface for parameter reflection information.
abstract class ReflectedParameter {
  /// Get the name of the parameter.
  String get name;

  /// Get the type of the parameter.
  ReflectedType get type;

  /// Get all attributes applied to this parameter.
  List<dynamic> get attributes;

  /// Check if this parameter has a specific attribute.
  bool hasAttribute(Type attributeType);

  /// Get all attributes of a specific type.
  List<dynamic> getAttributes(Type attributeType);

  /// Determine if this parameter is optional.
  bool get isOptional;

  /// Determine if this parameter is named.
  bool get isNamed;

  /// Determine if this parameter is required.
  bool get isRequired;

  /// Get the default value of the parameter if it has one.
  dynamic get defaultValue;

  /// Get whether this parameter has a default value.
  bool get hasDefaultValue;

  /// Get the position of this parameter in the parameter list.
  int get position;

  /// Get whether this parameter is variadic (accepts variable number of arguments).
  bool get isVariadic;

  /// Get whether this parameter is nullable.
  bool get isNullable;

  /// Get the metadata annotations applied to this parameter.
  List<dynamic> get annotations;
}
