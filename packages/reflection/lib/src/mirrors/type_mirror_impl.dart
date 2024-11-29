import 'dart:core';
import '../mirrors.dart';
import '../core/reflector.dart';
import '../metadata.dart';
import 'base_mirror.dart';
import 'special_types.dart';

/// Implementation of [TypeMirror] that provides reflection on types.
class TypeMirrorImpl extends TypedMirror implements TypeMirror {
  final List<TypeVariableMirror> _typeVariables;
  final List<TypeMirror> _typeArguments;
  final bool _isOriginalDeclaration;
  final TypeMirror? _originalDeclaration;

  TypeMirrorImpl({
    required Type type,
    required String name,
    DeclarationMirror? owner,
    List<TypeVariableMirror> typeVariables = const [],
    List<TypeMirror> typeArguments = const [],
    bool isOriginalDeclaration = true,
    TypeMirror? originalDeclaration,
    List<InstanceMirror> metadata = const [],
  })  : _typeVariables = typeVariables,
        _typeArguments = typeArguments,
        _isOriginalDeclaration = isOriginalDeclaration,
        _originalDeclaration = originalDeclaration,
        super(
          type: type,
          name: name,
          owner: owner,
          metadata: metadata,
        ) {
    // Register type with reflector if not already registered
    if (!Reflector.isReflectable(type)) {
      Reflector.registerType(type);
    }
  }

  /// Creates a TypeMirror from TypeMetadata.
  factory TypeMirrorImpl.fromMetadata(TypeMetadata typeMetadata,
      [DeclarationMirror? owner]) {
    return TypeMirrorImpl(
      type: typeMetadata.type,
      name: typeMetadata.name,
      owner: owner,
      // Convert interfaces to TypeMirrors
      typeVariables: [], // TODO: Add type variable support
      typeArguments: [], // TODO: Add type argument support
      metadata: [], // TODO: Add metadata support
    );
  }

  /// Creates a TypeMirror for void.
  factory TypeMirrorImpl.voidType([DeclarationMirror? owner]) {
    return TypeMirrorImpl(
      type: voidType,
      name: 'void',
      owner: owner,
      metadata: [],
    );
  }

  /// Creates a TypeMirror for dynamic.
  factory TypeMirrorImpl.dynamicType([DeclarationMirror? owner]) {
    return TypeMirrorImpl(
      type: dynamicType,
      name: 'dynamic',
      owner: owner,
      metadata: [],
    );
  }

  @override
  bool get hasReflectedType => true;

  @override
  Type get reflectedType => type;

  @override
  List<TypeVariableMirror> get typeVariables =>
      List.unmodifiable(_typeVariables);

  @override
  List<TypeMirror> get typeArguments => List.unmodifiable(_typeArguments);

  @override
  bool get isOriginalDeclaration => _isOriginalDeclaration;

  @override
  TypeMirror get originalDeclaration {
    if (isOriginalDeclaration) return this;
    return _originalDeclaration!;
  }

  /// Gets the properties defined on this type.
  Map<String, PropertyMetadata> get properties =>
      Reflector.getPropertyMetadata(type) ?? {};

  /// Gets the methods defined on this type.
  Map<String, MethodMetadata> get methods =>
      Reflector.getMethodMetadata(type) ?? {};

  /// Gets the constructors defined on this type.
  List<ConstructorMetadata> get constructors =>
      Reflector.getConstructorMetadata(type) ?? [];

  @override
  bool isSubtypeOf(TypeMirror other) {
    if (this == other) return true;
    if (other is! TypeMirrorImpl) return false;

    // Never is a subtype of all types
    if (type == Never) return true;

    // Dynamic is a supertype of all types except void
    if (other.type == dynamicType && type != voidType) return true;

    // void is only a subtype of itself
    if (type == voidType) return other.type == voidType;

    // Get type metadata
    final metadata = Reflector.getConstructorMetadata(type);
    if (metadata == null) return false;

    return false;
  }

  @override
  bool isAssignableTo(TypeMirror other) {
    // A type T may be assigned to a type S if either:
    // 1. T is a subtype of S, or
    // 2. S is dynamic (except for void)
    if (other is TypeMirrorImpl &&
        other.type == dynamicType &&
        type != voidType) {
      return true;
    }
    return isSubtypeOf(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TypeMirrorImpl) return false;

    return type == other.type &&
        name == other.name &&
        owner == other.owner &&
        _typeVariables == other._typeVariables &&
        _typeArguments == other._typeArguments &&
        _isOriginalDeclaration == other._isOriginalDeclaration &&
        _originalDeclaration == other._originalDeclaration;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      name,
      owner,
      Object.hashAll(_typeVariables),
      Object.hashAll(_typeArguments),
      _isOriginalDeclaration,
      _originalDeclaration,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('TypeMirror on $name');
    if (_typeArguments.isNotEmpty) {
      buffer.write('<');
      buffer.write(_typeArguments.join(', '));
      buffer.write('>');
    }
    return buffer.toString();
  }
}
