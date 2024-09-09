/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_runtime/runtime.dart';

/// Contextual values used during runtime.
///
/// This abstract class defines the structure for runtime contexts in the Protevus Platform.
/// It provides access to runtime objects and coercion functionality.
abstract class RuntimeContext {
  /// The current [RuntimeContext] available to the executing application.
  ///
  /// This static property holds either a `MirrorContext` or a `GeneratedContext`,
  /// depending on the execution type.
  static final RuntimeContext current = instance;

  /// The runtimes available to the executing application.
  ///
  /// This property stores a collection of runtime objects that can be accessed
  /// during the application's execution.
  late RuntimeCollection runtimes;

  /// Gets a runtime object for the specified [type].
  ///
  /// Callers typically invoke this operator, passing their [runtimeType]
  /// to retrieve their runtime object.
  ///
  /// It is important to note that a runtime object must exist for every
  /// class that extends a class that has a runtime. Use `MirrorContext.getSubclassesOf` when compiling.
  ///
  /// In other words, if the type `Base` has a runtime and the type `Subclass` extends `Base`,
  /// `Subclass` must also have a runtime. The runtime objects for both `Subclass` and `Base`
  /// must be the same type.
  ///
  /// @param type The Type to retrieve the runtime object for.
  /// @return The runtime object associated with the specified type.
  dynamic operator [](Type type) => runtimes[type];

  /// Coerces the given [input] to the specified type [T].
  ///
  /// This method is used to convert or cast the input to the desired type.
  ///
  /// @param input The input value to be coerced.
  /// @return The coerced value of type [T].
  T coerce<T>(dynamic input);
}

/// A collection of runtime objects indexed by type names.
///
/// This class provides a way to store and retrieve runtime objects
/// associated with specific types.
class RuntimeCollection {
  /// Creates a new [RuntimeCollection] with the given [map].
  ///
  /// @param map A map where keys are type names and values are runtime objects.
  RuntimeCollection(this.map);

  /// The underlying map storing runtime objects.
  final Map<String, Object> map;

  /// Returns an iterable of all runtime objects in the collection.
  Iterable<Object> get iterable => map.values;

  /// Retrieves the runtime object for the specified type [t].
  ///
  /// This operator first attempts to find an exact match for the type name.
  /// If not found, it tries to match a generic type by removing type parameters.
  ///
  /// @param t The Type to retrieve the runtime object for.
  /// @return The runtime object associated with the specified type.
  /// @throws ArgumentError if no runtime object is found for the given type.
  Object operator [](Type t) {
    //todo: optimize by keeping a cache where keys are of type [Type] to avoid the
    // expensive indexOf and substring calls in this method
    final typeName = t.toString();
    final r = map[typeName];
    if (r != null) {
      return r;
    }

    final genericIndex = typeName.indexOf("<");
    if (genericIndex == -1) {
      throw ArgumentError("Runtime not found for type '$t'.");
    }

    final genericTypeName = typeName.substring(0, genericIndex);
    final out = map[genericTypeName];
    if (out == null) {
      throw ArgumentError("Runtime not found for type '$t'.");
    }

    return out;
  }
}

/// An annotation to prevent a type from being compiled when it otherwise would be.
///
/// Use this annotation on a type to exclude it from compilation.
class PreventCompilation {
  /// Creates a constant instance of [PreventCompilation].
  const PreventCompilation();
}
