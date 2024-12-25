/// Represents metadata about a parameter.
class ParameterMetadata {
  /// The name of the parameter.
  final String name;

  /// The type of the parameter.
  final Type type;

  /// Whether this parameter is required.
  final bool isRequired;

  /// Whether this parameter is named.
  final bool isNamed;

  /// The default value for this parameter, if any.
  final Object? defaultValue;

  /// Any attributes (annotations) on this parameter.
  final List<Object> attributes;

  /// Creates a new parameter metadata instance.
  const ParameterMetadata({
    required this.name,
    required this.type,
    required this.isRequired,
    this.isNamed = false,
    this.defaultValue,
    this.attributes = const [],
  });
}
