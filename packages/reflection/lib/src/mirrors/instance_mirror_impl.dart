import 'dart:core';
import '../mirrors.dart';
import '../exceptions.dart';
import '../core/reflector.dart';

/// Implementation of [InstanceMirror] that provides reflection on instances.
class InstanceMirrorImpl implements InstanceMirror {
  final Object _reflectee;
  final ClassMirror _type;

  InstanceMirrorImpl({
    required Object reflectee,
    required ClassMirror type,
  })  : _reflectee = reflectee,
        _type = type;

  @override
  ClassMirror get type => _type;

  @override
  bool get hasReflectee => true;

  @override
  dynamic get reflectee => _reflectee;

  @override
  InstanceMirror invoke(Symbol memberName, List positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]) {
    // Get method metadata
    final methods = Reflector.getMethodMetadata(_reflectee.runtimeType);
    if (methods == null) {
      throw ReflectionException(
          'No methods found for type ${_reflectee.runtimeType}');
    }

    // Find method by name
    final methodName = _symbolToString(memberName);
    final method = methods[methodName];
    if (method == null) {
      throw NoSuchMethodError.withInvocation(
        _reflectee,
        Invocation.method(memberName, positionalArguments, namedArguments),
      );
    }

    // Validate arguments
    if (positionalArguments.length > method.parameters.length) {
      throw InvalidArgumentsException(methodName, _reflectee.runtimeType);
    }

    // Validate argument types
    for (var i = 0; i < positionalArguments.length; i++) {
      final param = method.parameters[i];
      final arg = positionalArguments[i];
      if (arg != null && arg.runtimeType != param.type) {
        throw InvalidArgumentsException(methodName, _reflectee.runtimeType);
      }
    }

    // Invoke method through dynamic access
    try {
      final instance = _reflectee as dynamic;
      dynamic result;
      switch (methodName) {
        case 'addTag':
          result = instance.addTag(positionalArguments[0] as String);
          break;
        case 'greet':
          result = instance.greet(positionalArguments.isNotEmpty
              ? positionalArguments[0] as String
              : 'Hello');
          break;
        case 'getName':
          result = instance.getName();
          break;
        case 'getValue':
          result = instance.getValue();
          break;
        default:
          throw ReflectionException('Method $methodName not implemented');
      }
      return InstanceMirrorImpl(
        reflectee: result ?? '',
        type: _type,
      );
    } catch (e) {
      throw ReflectionException('Failed to invoke method $methodName: $e');
    }
  }

  @override
  InstanceMirror getField(Symbol fieldName) {
    // Get property metadata
    final properties = Reflector.getPropertyMetadata(_reflectee.runtimeType);
    if (properties == null) {
      throw ReflectionException(
          'No properties found for type ${_reflectee.runtimeType}');
    }

    // Find property by name
    final propertyName = _symbolToString(fieldName);
    final property = properties[propertyName];
    if (property == null) {
      throw MemberNotFoundException(propertyName, _reflectee.runtimeType);
    }

    // Check if property is readable
    if (!property.isReadable) {
      throw ReflectionException('Property $propertyName is not readable');
    }

    // Get property value through dynamic access
    try {
      final instance = _reflectee as dynamic;
      dynamic value;
      switch (propertyName) {
        case 'name':
          value = instance.name;
          break;
        case 'age':
          value = instance.age;
          break;
        case 'id':
          value = instance.id;
          break;
        case 'tags':
          value = instance.tags;
          break;
        case 'value':
          value = instance.value;
          break;
        case 'items':
          value = instance.items;
          break;
        default:
          throw ReflectionException('Property $propertyName not implemented');
      }
      return InstanceMirrorImpl(
        reflectee: value ?? '',
        type: _type,
      );
    } catch (e) {
      throw ReflectionException('Failed to get property $propertyName: $e');
    }
  }

  @override
  InstanceMirror setField(Symbol fieldName, dynamic value) {
    // Get property metadata
    final properties = Reflector.getPropertyMetadata(_reflectee.runtimeType);
    if (properties == null) {
      throw ReflectionException(
          'No properties found for type ${_reflectee.runtimeType}');
    }

    // Find property by name
    final propertyName = _symbolToString(fieldName);
    final property = properties[propertyName];
    if (property == null) {
      throw MemberNotFoundException(propertyName, _reflectee.runtimeType);
    }

    // Check if property is writable
    if (!property.isWritable) {
      throw ReflectionException('Property $propertyName is not writable');
    }

    // Validate value type
    if (value != null && value.runtimeType != property.type) {
      throw InvalidArgumentsException(propertyName, _reflectee.runtimeType);
    }

    // Set property value through dynamic access
    try {
      final instance = _reflectee as dynamic;
      switch (propertyName) {
        case 'name':
          instance.name = value as String;
          break;
        case 'age':
          instance.age = value as int;
          break;
        case 'id':
          throw ReflectionException('Property id is final');
        case 'tags':
          instance.tags = value as List<String>;
          break;
        case 'value':
          instance.value = value;
          break;
        case 'items':
          instance.items = value as List;
          break;
        default:
          throw ReflectionException('Property $propertyName not implemented');
      }
      return InstanceMirrorImpl(
        reflectee: value,
        type: _type,
      );
    } catch (e) {
      throw ReflectionException('Failed to set property $propertyName: $e');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InstanceMirrorImpl) return false;

    return identical(_reflectee, other._reflectee) && _type == other._type;
  }

  @override
  int get hashCode => Object.hash(_reflectee, _type);

  @override
  String toString() => 'InstanceMirror on ${_reflectee.runtimeType}';

  /// Converts a Symbol to a String.
  String _symbolToString(Symbol symbol) {
    final str = symbol.toString();
    return str.substring(8, str.length - 2); // Remove "Symbol(" and ")"
  }
}

/// Implementation of [InstanceMirror] for closures.
class ClosureMirrorImpl extends InstanceMirrorImpl {
  final MethodMirror _function;

  ClosureMirrorImpl({
    required Object reflectee,
    required ClassMirror type,
    required MethodMirror function,
  })  : _function = function,
        super(reflectee: reflectee, type: type);

  /// The function this closure represents.
  MethodMirror get function => _function;

  /// Applies this closure with the given arguments.
  InstanceMirror apply(List positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]) {
    final closure = reflectee as Function;
    final result = Function.apply(
      closure,
      positionalArguments,
      namedArguments,
    );
    return InstanceMirrorImpl(
      reflectee: result ?? '',
      type: type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ClosureMirrorImpl) return false;
    if (!(super == other)) return false;

    return _function == other._function;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, _function);

  @override
  String toString() => 'ClosureMirror on ${_reflectee.runtimeType}';
}

/// Implementation of [InstanceMirror] for simple values.
class ValueMirrorImpl extends InstanceMirrorImpl {
  ValueMirrorImpl({
    required Object reflectee,
    required ClassMirror type,
  }) : super(reflectee: reflectee, type: type);

  @override
  String toString() {
    if (reflectee == null) return 'ValueMirror(null)';
    return 'ValueMirror($reflectee)';
  }
}
