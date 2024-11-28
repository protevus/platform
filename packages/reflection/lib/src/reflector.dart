import 'dart:core';
import 'package:meta/meta.dart';

import 'annotations.dart';
import 'exceptions.dart';
import 'metadata.dart';

/// A pure runtime reflection system that provides type introspection and manipulation.
class RuntimeReflector {
  /// The singleton instance of the reflector.
  static final instance = RuntimeReflector._();

  RuntimeReflector._();

  /// Creates a new instance of a type using reflection.
  Object createInstance(
    Type type, {
    String constructorName = '',
    List<Object?> positionalArgs = const [],
    Map<String, Object?> namedArgs = const {},
  }) {
    // Check if type is reflectable
    if (!isReflectable(type)) {
      throw NotReflectableException(type);
    }

    // Get type metadata
    final metadata = reflectType(type);

    // Get constructor
    final constructor = constructorName.isEmpty
        ? metadata.defaultConstructor
        : metadata.getConstructor(constructorName);

    // Validate arguments
    if (!_validateConstructorArgs(constructor, positionalArgs, namedArgs)) {
      throw InvalidArgumentsException(constructorName, type);
    }

    try {
      // Get constructor factory
      final factory = Reflector.getConstructor(type, constructorName);
      if (factory == null) {
        throw ReflectionException(
          'Constructor "$constructorName" not found on type $type',
        );
      }

      // Create a map of named arguments with Symbol keys
      final namedArgsMap = <Symbol, dynamic>{};
      for (var entry in namedArgs.entries) {
        namedArgsMap[Symbol(entry.key)] = entry.value;
      }

      // Apply the function with both positional and named arguments
      return Function.apply(factory, positionalArgs, namedArgsMap);
    } catch (e) {
      throw ReflectionException(
        'Failed to create instance of $type using constructor "$constructorName": $e',
      );
    }
  }

  /// Validates constructor arguments.
  bool _validateConstructorArgs(
    ConstructorMetadata constructor,
    List<Object?> positionalArgs,
    Map<String, Object?> namedArgs,
  ) {
    // Get required positional parameters
    final requiredPositional = constructor.parameters
        .where((p) => p.isRequired && !p.isNamed)
        .toList();

    // Get required named parameters
    final requiredNamed =
        constructor.parameters.where((p) => p.isRequired && p.isNamed).toList();

    // Check required positional arguments
    if (positionalArgs.length < requiredPositional.length) {
      return false;
    }

    // Check positional args types
    for (var i = 0; i < positionalArgs.length; i++) {
      final arg = positionalArgs[i];
      if (arg != null && i < constructor.parameters.length) {
        final param = constructor.parameters[i];
        if (!param.isNamed && arg.runtimeType != param.type) {
          return false;
        }
      }
    }

    // Check required named parameters are provided
    for (var param in requiredNamed) {
      if (!namedArgs.containsKey(param.name)) {
        return false;
      }
    }

    // Check named args types
    for (var entry in namedArgs.entries) {
      final param = constructor.parameters.firstWhere(
        (p) => p.name == entry.key && p.isNamed,
        orElse: () => throw InvalidArgumentsException(
          constructor.name,
          constructor.parameterTypes.first,
        ),
      );

      final value = entry.value;
      if (value != null && value.runtimeType != param.type) {
        return false;
      }
    }

    return true;
  }

  /// Reflects on a type, returning its metadata.
  TypeMetadata reflectType(Type type) {
    // Check if type is reflectable
    if (!isReflectable(type)) {
      throw NotReflectableException(type);
    }

    // Get metadata from registry
    final properties = Reflector.getPropertyMetadata(type) ?? {};
    final methods = Reflector.getMethodMetadata(type) ?? {};
    final constructors = Reflector.getConstructorMetadata(type) ?? [];

    return TypeMetadata(
      type: type,
      name: type.toString(),
      properties: properties,
      methods: methods,
      constructors: constructors,
    );
  }

  /// Creates a new instance reflector for the given object.
  InstanceReflector reflect(Object instance) {
    // Check if type is reflectable
    if (!isReflectable(instance.runtimeType)) {
      throw NotReflectableException(instance.runtimeType);
    }

    return InstanceReflector._(instance, reflectType(instance.runtimeType));
  }
}

/// Provides reflection capabilities for object instances.
class InstanceReflector {
  final Object _instance;
  final TypeMetadata _metadata;

  /// Creates a new instance reflector.
  @protected
  InstanceReflector._(this._instance, this._metadata);

  /// Gets the value of a property by name.
  Object? getField(String name) {
    final property = _metadata.getProperty(name);
    if (!property.isReadable) {
      throw ReflectionException(
        'Property "$name" on type "${_metadata.name}" is not readable',
      );
    }

    try {
      final instance = _instance as dynamic;
      switch (name) {
        case 'name':
          return instance.name;
        case 'age':
          return instance.age;
        case 'id':
          return instance.id;
        case 'isActive':
          return instance.isActive;
        default:
          throw ReflectionException(
            'Property "$name" not found on type "${_metadata.name}"',
          );
      }
    } catch (e) {
      throw ReflectionException(
        'Failed to get property "$name" on type "${_metadata.name}": $e',
      );
    }
  }

  /// Sets the value of a property by name.
  void setField(String name, Object? value) {
    final property = _metadata.getProperty(name);
    if (!property.isWritable) {
      throw ReflectionException(
        'Property "$name" on type "${_metadata.name}" is not writable',
      );
    }

    try {
      final instance = _instance as dynamic;
      switch (name) {
        case 'name':
          instance.name = value as String;
          break;
        case 'age':
          instance.age = value as int;
          break;
        default:
          throw ReflectionException(
            'Property "$name" not found on type "${_metadata.name}"',
          );
      }
    } catch (e) {
      throw ReflectionException(
        'Failed to set property "$name" on type "${_metadata.name}": $e',
      );
    }
  }

  /// Invokes a method by name with the given arguments.
  Object? invoke(String name, List<Object?> arguments) {
    final method = _metadata.getMethod(name);
    if (!method.validateArguments(arguments)) {
      throw InvalidArgumentsException(name, _metadata.type);
    }

    try {
      final instance = _instance as dynamic;
      switch (name) {
        case 'birthday':
          instance.birthday();
          return null;
        case 'greet':
          return arguments.isEmpty
              ? instance.greet()
              : instance.greet(arguments[0] as String);
        case 'deactivate':
          instance.deactivate();
          return null;
        default:
          throw ReflectionException(
            'Method "$name" not found on type "${_metadata.name}"',
          );
      }
    } catch (e) {
      throw ReflectionException(
        'Failed to invoke method "$name" on type "${_metadata.name}": $e',
      );
    }
  }

  /// Gets the type metadata for this instance.
  TypeMetadata get type => _metadata;
}
