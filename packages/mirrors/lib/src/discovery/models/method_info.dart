import '../../metadata/parameter_metadata.dart';

/// Information about a method.
///
/// Contains metadata about a method including:
/// - The method's name
/// - Parameter types and metadata
/// - Return type information
/// - Whether it's static
class MethodInfo {
  /// The name of the method
  final String name;

  /// List of parameter types for this method
  final List<Type> parameterTypes;

  /// List of parameter metadata for this method
  final List<ParameterMetadata> parameters;

  /// Whether this method returns void
  final bool returnsVoid;

  /// The return type of this method
  final Type returnType;

  /// Whether this method is static
  final bool isStatic;

  /// Creates a new [MethodInfo] instance.
  ///
  /// All parameters are required:
  /// - [name]: The method's name
  /// - [parameterTypes]: List of parameter types
  /// - [parameters]: List of parameter metadata
  /// - [returnsVoid]: Whether the method returns void
  /// - [returnType]: The method's return type
  /// - [isStatic]: Whether the method is static
  const MethodInfo({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
    required this.returnsVoid,
    required this.returnType,
    required this.isStatic,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    if (isStatic) buffer.write('static ');
    buffer.write('$returnType $name(');
    buffer.write(parameters.join(', '));
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MethodInfo &&
        other.name == name &&
        _listEquals(other.parameterTypes, parameterTypes) &&
        _listEquals(other.parameters, parameters) &&
        other.returnsVoid == returnsVoid &&
        other.returnType == returnType &&
        other.isStatic == isStatic;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      Object.hashAll(parameterTypes),
      Object.hashAll(parameters),
      returnsVoid,
      returnType,
      isStatic,
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
