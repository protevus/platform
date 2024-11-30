import '../metadata.dart';
import '../mirrors.dart';
import '../exceptions.dart';
import '../core/reflector.dart';
import 'base_mirror.dart';
import 'instance_mirror_impl.dart';
import 'method_mirror_impl.dart';
import 'mirror_system_impl.dart';
import 'type_mirror_impl.dart';

/// Implementation of [ClassMirror].
class ClassMirrorImpl extends TypeMirrorImpl implements ClassMirror {
  @override
  final Map<Symbol, DeclarationMirror> declarations;

  @override
  final Map<Symbol, MethodMirror> instanceMembers;

  @override
  final Map<Symbol, MethodMirror> staticMembers;

  @override
  final bool isAbstract;

  @override
  final bool isEnum;

  @override
  final ClassMirror? superclass;

  @override
  final List<ClassMirror> superinterfaces;

  ClassMirrorImpl({
    required Type type,
    required String name,
    required DeclarationMirror? owner,
    required this.declarations,
    required this.instanceMembers,
    required this.staticMembers,
    required List<InstanceMirror> metadata,
    this.isAbstract = false,
    this.isEnum = false,
    this.superclass,
    this.superinterfaces = const [],
  }) : super(
          type: type,
          name: name,
          owner: owner,
          metadata: metadata,
        );

  /// Converts a Symbol to its string name
  String _symbolToString(Symbol symbol) {
    final str = symbol.toString();
    return str.substring(8, str.length - 2); // Remove "Symbol(" and ")"
  }

  @override
  bool isSubclassOf(ClassMirror other) {
    var current = this;
    while (current.superclass != null) {
      if (current.superclass == other) {
        return true;
      }
      current = current.superclass as ClassMirrorImpl;
    }
    return false;
  }

  @override
  InstanceMirror newInstance(
    Symbol constructorName,
    List<dynamic> positionalArguments, [
    Map<Symbol, dynamic>? namedArguments,
  ]) {
    try {
      // Get constructor metadata
      final constructors = Reflector.getConstructorMetadata(type);
      if (constructors == null || constructors.isEmpty) {
        throw ReflectionException('No constructors found for type $type');
      }

      // Find matching constructor
      final constructorStr = _symbolToString(constructorName);
      final constructor = constructors.firstWhere(
        (c) => c.name == constructorStr,
        orElse: () => throw ReflectionException(
            'Constructor $constructorStr not found on type $type'),
      );

      // Validate arguments
      final positionalParams =
          constructor.parameters.where((p) => !p.isNamed).toList();
      if (positionalArguments.length <
          positionalParams.where((p) => p.isRequired).length) {
        throw InvalidArgumentsException(constructor.name, type);
      }

      final requiredNamedParams = constructor.parameters
          .where((p) => p.isRequired && p.isNamed)
          .map((p) => p.name)
          .toSet();
      if (requiredNamedParams.isNotEmpty &&
          !requiredNamedParams.every(
              (param) => namedArguments?.containsKey(Symbol(param)) ?? false)) {
        throw InvalidArgumentsException(constructor.name, type);
      }

      // Get instance creator
      final creator = Reflector.getInstanceCreator(type, constructorStr);
      if (creator == null) {
        throw ReflectionException(
            'No instance creator found for constructor $constructorStr');
      }

      // Create instance
      final instance = Function.apply(
        creator,
        positionalArguments,
        namedArguments,
      );

      if (instance == null) {
        throw ReflectionException(
            'Failed to create instance: creator returned null');
      }

      return InstanceMirrorImpl(
        reflectee: instance,
        type: this,
      );
    } catch (e) {
      throw ReflectionException('Failed to create instance: $e');
    }
  }

  @override
  InstanceMirror invoke(Symbol memberName, List<dynamic> positionalArguments,
      [Map<Symbol, dynamic>? namedArguments]) {
    try {
      // Get method metadata
      final methods = Reflector.getMethodMetadata(type);
      if (methods == null ||
          !methods.containsKey(_symbolToString(memberName))) {
        throw ReflectionException('Method $memberName not found');
      }

      // Get method
      final method = methods[_symbolToString(memberName)]!;

      // Validate arguments
      final positionalParams =
          method.parameters.where((p) => !p.isNamed).toList();
      if (positionalArguments.length <
          positionalParams.where((p) => p.isRequired).length) {
        throw InvalidArgumentsException(method.name, type);
      }

      final requiredNamedParams = method.parameters
          .where((p) => p.isRequired && p.isNamed)
          .map((p) => p.name)
          .toSet();
      if (requiredNamedParams.isNotEmpty &&
          !requiredNamedParams.every(
              (param) => namedArguments?.containsKey(Symbol(param)) ?? false)) {
        throw InvalidArgumentsException(method.name, type);
      }

      // Call method
      final result = Function.apply(
        (type as dynamic)[_symbolToString(memberName)],
        positionalArguments,
        namedArguments,
      );

      return InstanceMirrorImpl(
        reflectee: result,
        type: this,
      );
    } catch (e) {
      throw ReflectionException('Failed to invoke method $memberName: $e');
    }
  }

  @override
  InstanceMirror getField(Symbol fieldName) {
    final declaration = declarations[fieldName];
    if (declaration == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.getter(fieldName),
      );
    }

    try {
      final value = (type as dynamic)[_symbolToString(fieldName)];
      return InstanceMirrorImpl(
        reflectee: value,
        type: this,
      );
    } catch (e) {
      throw ReflectionException('Failed to get field: $e');
    }
  }

  @override
  InstanceMirror setField(Symbol fieldName, dynamic value) {
    final declaration = declarations[fieldName];
    if (declaration == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.setter(fieldName, [value]),
      );
    }

    try {
      (type as dynamic)[_symbolToString(fieldName)] = value;
      return InstanceMirrorImpl(
        reflectee: value,
        type: this,
      );
    } catch (e) {
      throw ReflectionException('Failed to set field: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassMirrorImpl &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ClassMirror on $name';
}
