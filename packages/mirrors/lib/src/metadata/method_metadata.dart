import 'package:platform_mirrors/mirrors.dart';

/// Represents metadata about a type's method.
class MethodMetadata {
  /// The name of the method.
  final String name;

  /// The parameter types of the method in order.
  final List<Type> parameterTypes;

  /// Detailed metadata about each parameter.
  final List<ParameterMetadata> parameters;

  /// Whether the method is static.
  final bool isStatic;

  /// Whether the method returns void.
  final bool returnsVoid;

  /// The return type of the method.
  final Type returnType;

  /// Any attributes (annotations) on this method.
  final List<Object> attributes;

  /// Type parameters for generic methods.
  final List<TypeParameterMetadata> typeParameters;

  /// Creates a new method metadata instance.
  const MethodMetadata({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
    required this.returnsVoid,
    required this.returnType,
    this.isStatic = false,
    this.attributes = const [],
    this.typeParameters = const [],
  });

  /// Validates the given arguments against this method's parameter types.
  bool validateArguments(List<Object?> arguments) {
    if (arguments.length != parameterTypes.length) return false;

    for (var i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      if (arg != null && arg.runtimeType != parameterTypes[i]) {
        return false;
      }
    }

    return true;
  }
}
