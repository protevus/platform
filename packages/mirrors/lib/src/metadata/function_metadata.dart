import 'package:illuminate_mirrors/mirrors.dart';

/// Represents metadata about a function.
class FunctionMetadata {
  /// The parameters of the function.
  final List<ParameterMetadata> parameters;

  /// Whether the function returns void.
  final bool returnsVoid;

  /// The return type of the function.
  final Type returnType;

  /// Type parameters for generic functions.
  final List<TypeParameterMetadata> typeParameters;

  /// Creates a new function metadata instance.
  const FunctionMetadata({
    required this.parameters,
    required this.returnsVoid,
    required this.returnType,
    this.typeParameters = const [],
  });

  /// Validates the given arguments against this function's parameters.
  bool validateArguments(List<Object?> arguments) {
    if (arguments.length != parameters.length) return false;

    for (var i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      if (arg != null && arg.runtimeType != parameters[i].type) {
        return false;
      }
    }

    return true;
  }
}
