import 'reflected_parameter.dart';
import 'reflected_type.dart';

/// Interface for function reflection information.
abstract class ReflectedFunction {
  /// Get the name of the function.
  String get name;

  /// Get the qualified name of the function (including class name if a method).
  String get qualifiedName;

  /// Get the return type of the function.
  ReflectedType get returnType;

  /// Get the parameters of the function.
  List<ReflectedParameter> get parameters;

  /// Get all attributes applied to this function.
  List<dynamic> get attributes;

  /// Check if this function has a specific attribute.
  bool hasAttribute(Type attributeType);

  /// Get all attributes of a specific type.
  List<dynamic> getAttributes(Type attributeType);

  /// Invoke the function with the given arguments.
  ///
  /// The [target] parameter is required for instance methods.
  /// The [arguments] map contains the arguments to pass to the function.
  dynamic invoke([dynamic target, Map<String, dynamic>? arguments]);

  /// Determine if this function is static.
  bool get isStatic;

  /// Determine if this function is a constructor.
  bool get isConstructor;

  /// Determine if this function is abstract.
  bool get isAbstract;

  /// Get the number of required parameters.
  int get requiredParameterCount;

  /// Get the number of optional parameters.
  int get optionalParameterCount;

  /// Get whether this function has named parameters.
  bool get hasNamedParameters;

  /// Get whether this function is async.
  bool get isAsync;

  /// Get whether this function is a generator.
  bool get isGenerator;
}
