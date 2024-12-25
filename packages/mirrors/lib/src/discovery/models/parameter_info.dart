import 'type_info.dart';

/// Information about a function parameter.
///
/// Contains metadata about a parameter including:
/// - The parameter's name
/// - Type
/// - Whether it's required, named, or optional
/// - Default value
/// - Any annotations applied to the parameter
class ParameterInfo {
  /// The name of the parameter
  final String name;

  /// The type of the parameter
  final TypeInfo type;

  /// Whether this parameter is required
  final bool isRequired;

  /// Whether this parameter is named
  final bool isNamed;

  /// Whether this parameter is optional
  final bool isOptional;

  /// The default value for this parameter, if any
  final Object? defaultValue;

  /// List of annotations applied to this parameter
  final List<Object> annotations;

  /// Creates a new [ParameterInfo] instance.
  ///
  /// Required parameters:
  /// - [name]: The parameter's name
  /// - [type]: The parameter's type
  /// - [isRequired]: Whether the parameter is required
  /// - [isNamed]: Whether the parameter is named
  /// - [isOptional]: Whether the parameter is optional
  /// - [annotations]: List of annotations on the parameter
  ///
  /// Optional parameters:
  /// - [defaultValue]: The default value for this parameter
  const ParameterInfo({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.isNamed,
    required this.isOptional,
    required this.annotations,
    this.defaultValue,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    if (isNamed) buffer.write(isRequired ? 'required ' : '');
    buffer.write('$type $name');
    if (defaultValue != null) {
      buffer.write(' = $defaultValue');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParameterInfo &&
        other.name == name &&
        other.type == type &&
        other.isRequired == isRequired &&
        other.isNamed == isNamed &&
        other.isOptional == isOptional &&
        other.defaultValue == defaultValue &&
        _listEquals(other.annotations, annotations);
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      type,
      isRequired,
      isNamed,
      isOptional,
      defaultValue,
      Object.hashAll(annotations),
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
