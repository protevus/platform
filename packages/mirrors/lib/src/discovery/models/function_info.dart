import '../../metadata/parameter_metadata.dart';

/// Information about a top-level function.
///
/// Contains metadata about a function including:
/// - The function's name
/// - Parameter types and metadata
/// - Return type information
/// - Privacy status
class FunctionInfo {
  /// The name of the function
  final String name;

  /// List of parameter types for this function
  final List<Type> parameterTypes;

  /// List of parameter metadata for this function
  final List<ParameterMetadata> parameters;

  /// Whether this function returns void
  final bool returnsVoid;

  /// The return type of this function
  final Type returnType;

  /// Whether this function is private
  final bool isPrivate;

  /// Creates a new [FunctionInfo] instance.
  ///
  /// All parameters are required:
  /// - [name]: The function's name
  /// - [parameterTypes]: List of parameter types
  /// - [parameters]: List of parameter metadata
  /// - [returnsVoid]: Whether the function returns void
  /// - [returnType]: The function's return type
  /// - [isPrivate]: Whether the function is private
  const FunctionInfo({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
    required this.returnsVoid,
    required this.returnType,
    required this.isPrivate,
  });

  @override
  String toString() => 'FunctionInfo(name: $name, returnType: $returnType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FunctionInfo &&
        other.name == name &&
        _listEquals(other.parameterTypes, parameterTypes) &&
        _listEquals(other.parameters, parameters) &&
        other.returnsVoid == returnsVoid &&
        other.returnType == returnType &&
        other.isPrivate == isPrivate;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      Object.hashAll(parameterTypes),
      Object.hashAll(parameters),
      returnsVoid,
      returnType,
      isPrivate,
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
