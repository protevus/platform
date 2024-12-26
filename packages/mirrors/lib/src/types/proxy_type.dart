/// A proxy type used for representing user-defined types during reflection.
class ProxyType implements Type {
  /// The name of the type.
  final String name;

  /// Creates a new proxy type with the given name.
  const ProxyType(this.name);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProxyType && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
