import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/mirrors.dart';

/// Implementation of [ClassMirrorContract].
class ClassMirror extends TypeMirror implements ClassMirrorContract {
  @override
  final Map<Symbol, DeclarationMirrorContract> declarations;

  @override
  final Map<Symbol, MethodMirrorContract> instanceMembers;

  @override
  final Map<Symbol, MethodMirrorContract> staticMembers;

  @override
  final bool isAbstract;

  @override
  final bool isEnum;

  @override
  final ClassMirrorContract? superclass;

  @override
  final List<ClassMirrorContract> superinterfaces;

  ClassMirror({
    required Type type,
    required String name,
    required DeclarationMirrorContract? owner,
    required this.declarations,
    required this.instanceMembers,
    required this.staticMembers,
    required List<InstanceMirrorContract> metadata,
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
  bool isSubclassOf(ClassMirrorContract other) {
    var current = this;
    while (current.superclass != null) {
      if (current.superclass == other) {
        return true;
      }
      current = current.superclass as ClassMirror;
    }
    return false;
  }

  @override
  InstanceMirrorContract newInstance(
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

      return InstanceMirror(
        reflectee: instance,
        type: this,
      );
    } catch (e) {
      throw ReflectionException('Failed to create instance: $e');
    }
  }

  @override
  InstanceMirrorContract invoke(
      Symbol memberName, List<dynamic> positionalArguments,
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

      return InstanceMirror(
        reflectee: result,
        type: this,
      );
    } catch (e) {
      throw ReflectionException('Failed to invoke method $memberName: $e');
    }
  }

  @override
  InstanceMirrorContract getField(Symbol fieldName) {
    final declaration = declarations[fieldName];
    if (declaration == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.getter(fieldName),
      );
    }

    try {
      final value = (type as dynamic)[_symbolToString(fieldName)];
      return InstanceMirror(
        reflectee: value,
        type: this,
      );
    } catch (e) {
      throw ReflectionException('Failed to get field: $e');
    }
  }

  @override
  InstanceMirrorContract setField(Symbol fieldName, dynamic value) {
    final declaration = declarations[fieldName];
    if (declaration == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.setter(fieldName, [value]),
      );
    }

    try {
      (type as dynamic)[_symbolToString(fieldName)] = value;
      return InstanceMirror(
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
      other is ClassMirror &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ClassMirror on $name';
}
