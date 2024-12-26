/// Metadata about a class property.
class PropertyMetadata {
  /// The name of the property.
  final String name;

  /// The type of the property.
  final Type type;

  /// Whether the property can be read.
  final bool isReadable;

  /// Whether the property can be written to.
  final bool isWritable;

  /// Whether the property is static.
  final bool isStatic;

  /// Whether the property is late.
  final bool isLate;

  /// Whether the property is nullable.
  final bool isNullable;

  /// Whether the property has an initializer.
  final bool hasInitializer;

  /// Any attributes (annotations) on this property.
  final List<Object> attributes;

  PropertyMetadata({
    required this.name,
    required this.type,
    this.isReadable = true,
    this.isWritable = true,
    this.isStatic = false,
    this.isLate = false,
    this.isNullable = false,
    this.attributes = const [],
    this.hasInitializer = false,
  });
}
