/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:illuminate_container/container.dart';

/// A static implementation of the [Reflector] class that performs simple [Map] lookups.
///
/// `package:platform_container_generator` uses this to create reflectors from analysis metadata.
class StaticReflector extends Reflector {
  /// A map that associates [Symbol] objects with their corresponding string names.
  ///
  /// This map is used to store and retrieve the string representations of symbols,
  /// which can be useful for reflection and debugging purposes.
  final Map<Symbol, String> names;

  /// A map that associates [Type] objects with their corresponding [ReflectedType] objects.
  ///
  /// This map is used to store and retrieve reflection information for different types,
  /// allowing for runtime introspection of type metadata and structure.
  final Map<Type, ReflectedType> types;

  /// A map that associates [Function] objects with their corresponding [ReflectedFunction] objects.
  ///
  /// This map is used to store and retrieve reflection information for functions,
  /// enabling runtime introspection of function metadata, parameters, and return types.
  final Map<Function, ReflectedFunction> functions;

  /// A map that associates [Object] instances with their corresponding [ReflectedInstance] objects.
  ///
  /// This map is used to store and retrieve reflection information for specific object instances,
  /// allowing for runtime introspection of object properties, methods, and metadata.
  final Map<Object, ReflectedInstance> instances;

  /// Creates a new [StaticReflector] instance with optional parameters.
  ///
  /// The [StaticReflector] constructor allows you to initialize the reflector
  /// with pre-populated maps for names, types, functions, and instances.
  ///
  /// Parameters:
  /// - [names]: A map of [Symbol] to [String] for symbol name lookups. Defaults to an empty map.
  /// - [types]: A map of [Type] to [ReflectedType] for type reflection. Defaults to an empty map.
  /// - [functions]: A map of [Function] to [ReflectedFunction] for function reflection. Defaults to an empty map.
  /// - [instances]: A map of [Object] to [ReflectedInstance] for instance reflection. Defaults to an empty map.
  ///
  /// All parameters are optional and default to empty constant maps if not provided.
  const StaticReflector(
      {this.names = const {},
      this.types = const {},
      this.functions = const {},
      this.instances = const {}});

  /// Returns the string name associated with the given [Symbol].
  ///
  /// This method looks up the string representation of the provided [symbol]
  /// in the [names] map. If the symbol is found, its corresponding string
  /// name is returned. If the symbol is not found in the map, an [ArgumentError]
  /// is thrown.
  ///
  /// Parameters:
  ///   - [symbol]: The [Symbol] for which to retrieve the string name.
  ///
  /// Returns:
  ///   The string name associated with the given [symbol], or null if not found.
  ///
  /// Throws:
  ///   - [ArgumentError]: If the provided [symbol] is not found in the [names] map.
  @override
  String? getName(Symbol symbol) {
    if (!names.containsKey(symbol)) {
      throw ArgumentError(
          'The value of $symbol is unknown - it was not generated.');
    }

    return names[symbol];
  }

  /// Reflects a class based on its [Type].
  ///
  /// This method attempts to reflect the given class [Type] by calling [reflectType]
  /// and casting the result to [ReflectedClass]. If the reflection is successful
  /// and the result is a [ReflectedClass], it is returned. Otherwise, null is returned.
  ///
  /// Parameters:
  ///   - [clazz]: The [Type] of the class to reflect.
  ///
  /// Returns:
  ///   A [ReflectedClass] instance if the reflection is successful and the result
  ///   is a [ReflectedClass], or null otherwise.
  @override
  ReflectedClass? reflectClass(Type clazz) =>
      reflectType(clazz) as ReflectedClass?;

  /// Reflects a function based on its [Function] object.
  ///
  /// This method attempts to retrieve reflection information for the given [function]
  /// from the [functions] map. If the function is found in the map, its corresponding
  /// [ReflectedFunction] object is returned. If the function is not found, an
  /// [ArgumentError] is thrown.
  ///
  /// Parameters:
  ///   - [function]: The [Function] object to reflect.
  ///
  /// Returns:
  ///   A [ReflectedFunction] object containing reflection information about the
  ///   given function, or null if not found.
  ///
  /// Throws:
  ///   - [ArgumentError]: If there is no reflection information available for
  ///     the given [function].
  @override
  ReflectedFunction? reflectFunction(Function function) {
    if (!functions.containsKey(function)) {
      throw ArgumentError(
          'There is no reflection information available about $function.');
    }

    return functions[function];
  }

  /// Reflects an object instance to retrieve its reflection information.
  ///
  /// This method attempts to retrieve reflection information for the given [object]
  /// from the [instances] map. If the object is found in the map, its corresponding
  /// [ReflectedInstance] object is returned. If the object is not found, an
  /// [ArgumentError] is thrown.
  ///
  /// Parameters:
  ///   - [object]: The object instance to reflect.
  ///
  /// Returns:
  ///   A [ReflectedInstance] object containing reflection information about the
  ///   given object instance, or null if not found.
  ///
  /// Throws:
  ///   - [ArgumentError]: If there is no reflection information available for
  ///     the given [object].
  @override
  ReflectedInstance? reflectInstance(Object object) {
    if (!instances.containsKey(object)) {
      throw ArgumentError(
          'There is no reflection information available about $object.');
    }

    return instances[object];
  }

  /// Reflects a type to retrieve its reflection information.
  ///
  /// This method attempts to retrieve reflection information for the given [type]
  /// from the [types] map. If the type is found in the map, its corresponding
  /// [ReflectedType] object is returned. If the type is not found, an
  /// [ArgumentError] is thrown.
  ///
  /// Parameters:
  ///   - [type]: The [Type] to reflect.
  ///
  /// Returns:
  ///   A [ReflectedType] object containing reflection information about the
  ///   given type, or null if not found.
  ///
  /// Throws:
  ///   - [ArgumentError]: If there is no reflection information available for
  ///     the given [type].
  @override
  ReflectedType? reflectType(Type type) {
    if (!types.containsKey(type)) {
      throw ArgumentError(
          'There is no reflection information available about $type.');
    }

    return types[type];
  }
}
