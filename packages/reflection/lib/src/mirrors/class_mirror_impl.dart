import 'dart:core';
import '../mirrors.dart';
import '../core/reflector.dart';
import '../metadata.dart';
import '../exceptions.dart';
import '../core/runtime_reflector.dart';
import 'base_mirror.dart';
import 'type_mirror_impl.dart';
import 'method_mirror_impl.dart';
import 'variable_mirror_impl.dart';
import 'parameter_mirror_impl.dart';
import 'instance_mirror_impl.dart';
import 'special_types.dart';

/// Implementation of [ClassMirror] that provides reflection on classes.
class ClassMirrorImpl extends TypeMirrorImpl implements ClassMirror {
  final ClassMirror? _superclass;
  final List<ClassMirror> _superinterfaces;
  final bool _isAbstract;
  final bool _isEnum;
  final Map<Symbol, DeclarationMirror> _declarations;
  final Map<Symbol, MethodMirror> _instanceMembers;
  final Map<Symbol, MethodMirror> _staticMembers;

  ClassMirrorImpl({
    required Type type,
    required String name,
    DeclarationMirror? owner,
    ClassMirror? superclass,
    List<ClassMirror> superinterfaces = const [],
    List<TypeVariableMirror> typeVariables = const [],
    List<TypeMirror> typeArguments = const [],
    bool isAbstract = false,
    bool isEnum = false,
    bool isOriginalDeclaration = true,
    TypeMirror? originalDeclaration,
    Map<Symbol, DeclarationMirror> declarations = const {},
    Map<Symbol, MethodMirror> instanceMembers = const {},
    Map<Symbol, MethodMirror> staticMembers = const {},
    List<InstanceMirror> metadata = const [],
  })  : _superclass = superclass,
        _superinterfaces = superinterfaces,
        _isAbstract = isAbstract,
        _isEnum = isEnum,
        _declarations = declarations,
        _instanceMembers = instanceMembers,
        _staticMembers = staticMembers,
        super(
          type: type,
          name: name,
          owner: owner,
          typeVariables: typeVariables,
          typeArguments: typeArguments,
          isOriginalDeclaration: isOriginalDeclaration,
          originalDeclaration: originalDeclaration,
          metadata: metadata,
        );

  @override
  bool get hasReflectedType => true;

  @override
  Type get reflectedType => type;

  @override
  Map<String, PropertyMetadata> get properties =>
      Reflector.getPropertyMetadata(type) ?? {};

  @override
  Map<String, MethodMetadata> get methods =>
      Reflector.getMethodMetadata(type) ?? {};

  @override
  List<ConstructorMetadata> get constructors =>
      Reflector.getConstructorMetadata(type) ?? [];

  @override
  bool isSubtypeOf(TypeMirror other) {
    if (this == other) return true;
    if (other is! TypeMirrorImpl) return false;

    // Check superclass chain
    ClassMirror? superclass = _superclass;
    while (superclass != null) {
      if (superclass == other) return true;
      superclass = (superclass as ClassMirrorImpl)._superclass;
    }

    // Check interfaces
    for (var interface in _superinterfaces) {
      if (interface == other || interface.isSubtypeOf(other)) return true;
    }

    return false;
  }

  @override
  bool isAssignableTo(TypeMirror other) {
    // A type T may be assigned to a type S if either:
    // 1. T is a subtype of S, or
    // 2. S is dynamic
    if (other is TypeMirrorImpl && other.type == dynamicType) return true;
    return isSubtypeOf(other);
  }

  @override
  ClassMirror? get superclass => _superclass;

  @override
  List<ClassMirror> get superinterfaces => List.unmodifiable(_superinterfaces);

  @override
  bool get isAbstract => _isAbstract;

  @override
  bool get isEnum => _isEnum;

  @override
  Map<Symbol, DeclarationMirror> get declarations =>
      Map.unmodifiable(_declarations);

  @override
  Map<Symbol, MethodMirror> get instanceMembers =>
      Map.unmodifiable(_instanceMembers);

  @override
  Map<Symbol, MethodMirror> get staticMembers =>
      Map.unmodifiable(_staticMembers);

  @override
  InstanceMirror newInstance(
    Symbol constructorName,
    List positionalArguments, [
    Map<Symbol, dynamic> namedArguments = const {},
  ]) {
    // Get constructor metadata
    final ctors = constructors;
    if (ctors.isEmpty) {
      throw ReflectionException('No constructors found for type $type');
    }

    // Find constructor by name
    final name = constructorName
        .toString()
        .substring(8, constructorName.toString().length - 2);
    final constructor = ctors.firstWhere(
      (c) => c.name == name,
      orElse: () => throw ReflectionException(
          'Constructor $name not found on type $type'),
    );

    // Validate arguments
    if (positionalArguments.length > constructor.parameters.length) {
      throw InvalidArgumentsException(name, type);
    }

    // Get constructor factory
    final factory = Reflector.getConstructor(type, name);
    if (factory == null) {
      throw ReflectionException('No factory found for constructor $name');
    }

    // Create instance
    try {
      final instance = Function.apply(
        factory,
        positionalArguments,
        namedArguments,
      );

      return InstanceMirrorImpl(
        reflectee: instance,
        type: this,
      );
    } catch (e) {
      throw ReflectionException('Failed to create instance: $e');
    }
  }

  @override
  bool isSubclassOf(ClassMirror other) {
    if (this == other) return true;
    if (other is! ClassMirrorImpl) return false;

    // Check superclass chain
    ClassMirror? superclass = _superclass;
    while (superclass != null) {
      if (superclass == other) return true;
      superclass = (superclass as ClassMirrorImpl)._superclass;
    }

    return false;
  }

  @override
  InstanceMirror invoke(Symbol memberName, List positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]) {
    final method = staticMembers[memberName];
    if (method == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.method(memberName, positionalArguments, namedArguments),
      );
    }

    // TODO: Implement static method invocation
    throw UnimplementedError();
  }

  @override
  InstanceMirror getField(Symbol fieldName) {
    // TODO: Implement static field access
    throw UnimplementedError();
  }

  @override
  InstanceMirror setField(Symbol fieldName, dynamic value) {
    // TODO: Implement static field modification
    throw UnimplementedError();
  }
}
