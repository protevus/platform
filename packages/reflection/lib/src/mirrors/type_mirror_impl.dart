import 'dart:core';
import '../mirrors.dart';
import '../core/reflector.dart';
import '../metadata.dart';
import 'base_mirror.dart';
import 'special_types.dart';
import 'type_variable_mirror_impl.dart';

/// Implementation of [TypeMirror] that provides reflection on types.
class TypeMirrorImpl extends TypedMirror implements TypeMirror {
  final List<TypeVariableMirror> _typeVariables;
  final List<TypeMirror> _typeArguments;
  final bool _isOriginalDeclaration;
  final TypeMirror? _originalDeclaration;
  final bool _isGeneric;

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
        _isGeneric = typeVariables.isNotEmpty,
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

    // Validate generic type arguments
    if (_typeArguments.length > _typeVariables.length) {
      throw ArgumentError('Too many type arguments');
    }
  }

  /// Creates a TypeMirror from TypeMetadata.
  factory TypeMirrorImpl.fromMetadata(TypeMetadata typeMetadata,
      [DeclarationMirror? owner]) {
    // Get type variables from metadata
    final typeVariables = typeMetadata.typeParameters.map((param) {
      // Create upper bound type mirror
      final upperBound = TypeMirrorImpl(
        type: param.bound ?? Object,
        name: param.bound?.toString() ?? 'Object',
        owner: owner,
      );

      // Create type variable mirror
      return TypeVariableMirrorImpl(
        type: param.type,
        name: param.name,
        upperBound: upperBound,
        owner: owner,
      );
    }).toList();

    // Get type arguments from metadata
    final typeArguments = typeMetadata.typeArguments.map((arg) {
      return TypeMirrorImpl(
        type: arg.type,
        name: arg.name,
        owner: owner,
      );
    }).toList();

    return TypeMirrorImpl(
      type: typeMetadata.type,
      name: typeMetadata.name,
      owner: owner,
      typeVariables: typeVariables,
      typeArguments: typeArguments,
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

  /// Creates a new TypeMirror with the given type arguments.
  TypeMirror instantiateGeneric(List<TypeMirror> typeArguments) {
    if (!_isGeneric) {
      throw StateError('Type $name is not generic');
    }

    if (typeArguments.length != _typeVariables.length) {
      throw ArgumentError(
          'Wrong number of type arguments: expected ${_typeVariables.length}, got ${typeArguments.length}');
    }

    // Validate type arguments against bounds
    for (var i = 0; i < typeArguments.length; i++) {
      final argument = typeArguments[i];
      final variable = _typeVariables[i];
      if (!argument.isAssignableTo(variable.upperBound)) {
        throw ArgumentError(
            'Type argument ${argument.name} is not assignable to bound ${variable.upperBound.name}');
      }
    }

    return TypeMirrorImpl(
      type: type,
      name: name,
      owner: owner,
      typeVariables: _typeVariables,
      typeArguments: typeArguments,
      isOriginalDeclaration: false,
      originalDeclaration: this,
      metadata: metadata,
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

  /// Whether this type is generic (has type parameters)
  bool get isGeneric => _isGeneric;

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
    final metadata = Reflector.getTypeMetadata(type);
    if (metadata == null) return false;

    // Check supertype
    if (metadata.supertype != null) {
      final superMirror = TypeMirrorImpl.fromMetadata(metadata.supertype!);
      if (superMirror.isSubtypeOf(other)) return true;
    }

    // Check interfaces
    for (final interface in metadata.interfaces) {
      final interfaceMirror = TypeMirrorImpl.fromMetadata(interface);
      if (interfaceMirror.isSubtypeOf(other)) return true;
    }

    // Check mixins
    for (final mixin in metadata.mixins) {
      final mixinMirror = TypeMirrorImpl.fromMetadata(mixin);
      if (mixinMirror.isSubtypeOf(other)) return true;
    }

    // Handle generic type arguments
    if (!isOriginalDeclaration && other.isOriginalDeclaration) {
      return originalDeclaration.isSubtypeOf(other);
    }

    if (!isOriginalDeclaration && !other.isOriginalDeclaration) {
      if (originalDeclaration != other.originalDeclaration) {
        return false;
      }

      // Check type arguments are compatible
      for (var i = 0; i < _typeArguments.length; i++) {
        if (!_typeArguments[i].isSubtypeOf(other._typeArguments[i])) {
          return false;
        }
      }
      return true;
    }

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
