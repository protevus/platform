import 'package:illuminate_mirrors/mirrors.dart';

/// Represents metadata about a type's constructor.
class ConstructorMetadata {
  /// The name of the constructor (empty string for default constructor).
  final String name;

  /// The parameter types of the constructor in order.
  final List<Type> parameterTypes;

  /// The names of the parameters if they are named parameters.
  final List<String>? parameterNames;

  /// Detailed metadata about each parameter.
  final List<ParameterMetadata> parameters;

  /// Any attributes (annotations) on this constructor.
  final List<Object> attributes;

  /// Creates a new constructor metadata instance.
  const ConstructorMetadata({
    this.name = '',
    required this.parameterTypes,
    required this.parameters,
    this.parameterNames,
    this.attributes = const [],
  });

  /// Whether this constructor uses named parameters.
  bool get hasNamedParameters => parameterNames != null;

  /// Validates the given arguments against this constructor's parameter types.
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
