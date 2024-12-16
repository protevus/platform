/// Special type representation for void.
class VoidType implements Type {
  const VoidType._();
  static const instance = VoidType._();
  @override
  String toString() => 'void';
}

/// Special type representation for dynamic.
class DynamicType implements Type {
  const DynamicType._();
  static const instance = DynamicType._();
  @override
  String toString() => 'dynamic';
}

/// Special type representation for Never.
class NeverType implements Type {
  const NeverType._();
  static const instance = NeverType._();
  @override
  String toString() => 'Never';
}

/// Gets the runtime type for void.
Type get voidType => VoidType.instance;

/// Gets the runtime type for dynamic.
Type get dynamicType => DynamicType.instance;

/// Gets the runtime type for Never.
Type get neverType => NeverType.instance;

/// Extension to check special types.
extension TypeExtensions on Type {
  /// Whether this type represents void.
  bool get isVoid => this == voidType;

  /// Whether this type represents dynamic.
  bool get isDynamic => this == dynamicType;

  /// Whether this type represents Never.
  bool get isNever => this == neverType;
}
