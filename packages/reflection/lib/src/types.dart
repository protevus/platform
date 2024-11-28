/// Represents the void type in our reflection system.
class VoidType implements Type {
  const VoidType._();

  /// The singleton instance representing void.
  static const instance = VoidType._();

  @override
  String toString() => 'void';
}

/// The void type instance to use in our reflection system.
const voidType = VoidType.instance;

/// Extension to check if a Type is void.
extension TypeExtensions on Type {
  /// Whether this type represents void.
  bool get isVoid => this == voidType;
}
