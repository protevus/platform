import '../../metadata/parameter_metadata.dart';

/// Information about a constructor.
///
/// Contains metadata about a constructor including:
/// - The constructor's name
/// - Parameter types and metadata
class ConstructorInfo {
  /// The name of the constructor
  final String name;

  /// List of parameter types for this constructor
  final List<Type> parameterTypes;

  /// List of parameter metadata for this constructor
  final List<ParameterMetadata> parameters;

  /// Creates a new [ConstructorInfo] instance.
  ///
  /// All parameters are required:
  /// - [name]: The constructor's name
  /// - [parameterTypes]: List of parameter types
  /// - [parameters]: List of parameter metadata
  const ConstructorInfo({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    if (name.isNotEmpty) {
      buffer.write('$name(');
    } else {
      buffer.write('(');
    }
    buffer.write(parameters.join(', '));
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConstructorInfo &&
        other.name == name &&
        _listEquals(other.parameterTypes, parameterTypes) &&
        _listEquals(other.parameters, parameters);
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      Object.hashAll(parameterTypes),
      Object.hashAll(parameters),
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
