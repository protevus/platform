import 'parameter_metadata.dart';
import 'method_metadata.dart';

/// Extended metadata for methods that includes additional Dart-specific features.
class ExtendedMethodMetadata extends MethodMetadata {
  /// Whether this is an async method.
  @override
  final bool isAsync;

  /// Whether this is a generator method (sync* or async*).
  @override
  final bool isGenerator;

  /// Whether this is an external method.
  @override
  final bool isExternal;

  ExtendedMethodMetadata({
    required String name,
    required List<Type> parameterTypes,
    required List<ParameterMetadata> parameters,
    required bool returnsVoid,
    required Type returnType,
    bool isStatic = false,
    this.isAsync = false,
    this.isGenerator = false,
    this.isExternal = false,
  }) : super(
          name: name,
          parameterTypes: parameterTypes,
          parameters: parameters,
          returnsVoid: returnsVoid,
          returnType: returnType,
          isStatic: isStatic,
        );
}
