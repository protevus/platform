/// Information about a property.
///
/// Contains metadata about a property including:
/// - The property's name
/// - Type
/// - Whether it's final
class PropertyInfo {
  /// The name of the property
  final String name;

  /// The type of the property
  final Type type;

  /// Whether this property is final
  final bool isFinal;

  /// Creates a new [PropertyInfo] instance.
  ///
  /// All parameters are required:
  /// - [name]: The property's name
  /// - [type]: The property's type
  /// - [isFinal]: Whether the property is final
  const PropertyInfo({
    required this.name,
    required this.type,
    required this.isFinal,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    if (isFinal) buffer.write('final ');
    buffer.write('$type $name');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyInfo &&
        other.name == name &&
        other.type == type &&
        other.isFinal == isFinal;
  }

  @override
  int get hashCode => Object.hash(name, type, isFinal);
}
