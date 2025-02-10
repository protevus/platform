/// Represents metadata about a type parameter.
class TypeParameterMetadata {
  /// The name of the type parameter (e.g., 'T', 'E').
  final String name;

  /// The type of the parameter.
  final Type type;

  /// The upper bound of the type parameter, if any.
  final Type? bound;

  /// Any attributes (annotations) on this type parameter.
  final List<Object> attributes;

  /// Creates a new type parameter metadata instance.
  const TypeParameterMetadata({
    required this.name,
    required this.type,
    this.bound,
    this.attributes = const [],
  });
}
