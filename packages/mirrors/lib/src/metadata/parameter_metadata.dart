/// Metadata about a method or constructor parameter.
class ParameterMetadata {
  /// The name of the parameter.
  final String name;

  /// The type of the parameter.
  final Type type;

  /// Whether the parameter is required.
  final bool isRequired;

  /// Whether the parameter is named.
  final bool isNamed;

  /// Whether the parameter is nullable.
  final bool isNullable;

  /// The default value of the parameter, if any.
  final dynamic defaultValue;

  ParameterMetadata({
    required this.name,
    required this.type,
    this.isRequired = true,
    this.isNamed = false,
    this.isNullable = false,
    this.defaultValue,
  });
}
