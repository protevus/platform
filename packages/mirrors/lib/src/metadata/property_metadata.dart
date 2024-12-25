/// Represents metadata about a type's property.
class PropertyMetadata {
  /// The name of the property.
  final String name;

  /// The type of the property.
  final Type type;

  /// Whether the property can be read.
  final bool isReadable;

  /// Whether the property can be written to.
  final bool isWritable;

  /// Any attributes (annotations) on this property.
  final List<Object> attributes;

  /// Creates a new property metadata instance.
  const PropertyMetadata({
    required this.name,
    required this.type,
    this.isReadable = true,
    this.isWritable = true,
    this.attributes = const [],
  });
}
