import 'parameter_metadata.dart';

/// Metadata about a class method.
class MethodMetadata {
  /// The name of the method.
  final String name;

  /// The parameter types of the method.
  final List<Type> parameterTypes;

  /// The parameters of the method.
  final List<ParameterMetadata> parameters;

  /// Whether the method returns void.
  final bool returnsVoid;

  /// The return type of the method.
  final Type returnType;

  /// Whether the method is static.
  final bool isStatic;

  /// Whether the method is async.
  final bool isAsync;

  /// Whether the method is a generator (sync* or async*).
  final bool isGenerator;

  /// Whether the method is external.
  final bool isExternal;

  MethodMetadata({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
    required this.returnsVoid,
    required this.returnType,
    this.isStatic = false,
    this.isAsync = false,
    this.isGenerator = false,
    this.isExternal = false,
  });
}
