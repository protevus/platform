/// Interface for type reflection information.
abstract class ReflectedType {
  /// Get the name of the type.
  String get name;

  /// Get the qualified name of the type (including namespace).
  String get qualifiedName;

  /// Get the actual Type object.
  Type get type;

  /// Get all attributes applied to this type.
  List<dynamic> get attributes;

  /// Check if this type has a specific attribute.
  bool hasAttribute(Type attributeType);

  /// Get all attributes of a specific type.
  List<dynamic> getAttributes(Type attributeType);

  /// Determine if this type is nullable.
  bool get isNullable;

  /// Determine if this type is a class.
  bool get isClass;

  /// Determine if this type is an interface.
  bool get isInterface;

  /// Determine if this type is an enum.
  bool get isEnum;

  /// Determine if this type is a mixin.
  bool get isMixin;

  /// Determine if this type is abstract.
  bool get isAbstract;

  /// Get the generic type arguments if this is a generic type.
  List<ReflectedType> get typeArguments;

  /// Get whether this type has generic type parameters.
  bool get isGeneric;

  /// Get the base type if this is a derived type.
  ReflectedType? get baseType;

  /// Get whether this type is assignable to another type.
  bool isAssignableTo(Type other);

  /// Get whether this type is a subtype of another type.
  bool isSubtypeOf(Type other);

  /// Get whether this type is a supertype of another type.
  bool isSupertypeOf(Type other);
}
