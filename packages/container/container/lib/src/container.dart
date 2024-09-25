/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'exception.dart';
import 'reflector.dart';

class Container {
  /// The [Reflector] instance used by this container for reflection-based operations.
  ///
  /// This reflector is used to instantiate objects and resolve dependencies
  /// when no explicit factory or singleton is registered for a given type.
  final Reflector reflector;

  /// A map that stores singleton instances, where the key is the Type and the value is the singleton object.
  ///
  /// This map is used internally by the Container to store and retrieve singleton objects
  /// that have been registered using the [registerSingleton] method.
  final Map<Type, dynamic> _singletons = {};

  /// A map that stores factory functions for creating instances of different types.
  ///
  /// The key is the Type for which the factory is registered, and the value is a function
  /// that takes a Container as an argument and returns an instance of that Type.
  ///
  /// This map is used internally by the Container to store and retrieve factory functions
  /// that have been registered using the [registerFactory] method.
  final Map<Type, dynamic Function(Container)> _factories = {};

  /// A map that stores named singleton instances, where the key is a String name and the value is the singleton object.
  ///
  /// This map is used internally by the Container to store and retrieve named singleton objects
  /// that have been registered using the [registerNamedSingleton] method. Named singletons allow
  /// for multiple instances of the same type to be stored in the container with different names.
  final Map<String, dynamic> _namedSingletons = {};

  /// The parent container of this container, if any.
  ///
  /// This property is used to create a hierarchy of containers, where child containers
  /// can access dependencies registered in their parent containers. If this container
  /// is a root container (i.e., it has no parent), this property will be null.
  ///
  /// The parent-child relationship allows for scoped dependency injection, where
  /// child containers can override or add to the dependencies defined in their parents.
  final Container? _parent;

  /// Creates a new root [Container] instance with the given [Reflector].
  ///
  /// This constructor initializes a new container without a parent, making it
  /// a root container in the dependency injection hierarchy. The provided
  /// [reflector] will be used for all reflection-based operations within this
  /// container and its child containers.
  ///
  /// Parameters:
  ///   - [reflector]: The [Reflector] instance to be used by this container
  ///     for reflection-based dependency resolution and object instantiation.
  ///
  /// The [_parent] is set to null, indicating that this is a root container.
  Container(this.reflector) : _parent = null;

  /// Creates a child [Container] instance with the given parent container.
  ///
  /// This constructor is used internally to create child containers in the
  /// dependency injection hierarchy. It initializes a new container with a
  /// reference to its parent container and uses the same [Reflector] instance
  /// as the parent.
  ///
  /// Parameters:
  ///   - [_parent]: The parent [Container] instance for this child container.
  ///
  /// The [reflector] is initialized with the parent container's reflector,
  /// ensuring consistency in reflection operations throughout the container
  /// hierarchy.
  Container._child(Container this._parent) : reflector = _parent.reflector;

  /// Checks if this container is a root container.
  ///
  /// Returns `true` if this container has no parent (i.e., it's a root container),
  /// and `false` otherwise.
  ///
  /// This property is useful for determining the position of a container in the
  /// dependency injection hierarchy. Root containers are typically used as the
  /// top-level containers in an application, while non-root containers are child
  /// containers that may have more specific or localized dependencies.
  bool get isRoot => _parent == null;

  /// Creates a child [Container] that can define its own singletons and factories.
  ///
  /// This method creates a new [Container] instance that is a child of the current container.
  /// The child container inherits access to all dependencies registered in its parent containers,
  /// but can also define its own singletons and factories that override or extend the parent's dependencies.
  ///
  /// Child containers are useful for creating scoped dependency injection contexts, such as
  /// for specific features, modules, or request-scoped dependencies in web applications.
  ///
  /// The child container uses the same [Reflector] instance as its parent.
  ///
  /// Returns:
  ///   A new [Container] instance that is a child of the current container.
  ///
  /// Example:
  /// ```dart
  /// var parentContainer = Container(MyReflector());
  /// var childContainer = parentContainer.createChild();
  /// ```
  Container createChild() {
    return Container._child(this);
  }

  /// Determines if the container or any of its parent containers has an injection of the given type.
  ///
  /// This method checks for both singleton and factory registrations of the specified type.
  ///
  /// Parameters:
  ///   - [T]: The type to check for. If [T] is dynamic, the [t] parameter must be provided.
  ///   - [t]: An optional Type parameter. If provided, it overrides the type specified by [T].
  ///
  /// Returns:
  ///   - `true` if an injection (singleton or factory) for the specified type is found in this
  ///     container or any of its parent containers.
  ///   - `false` if no injection is found for the specified type in the entire container hierarchy.
  ///
  /// Note:
  ///   - If [T] is dynamic and [t] is null, the method returns `false` immediately.
  ///   - The method searches the current container first, then moves up the parent hierarchy
  ///     until an injection is found or the root container is reached.
  bool has<T>([Type? t]) {
    var t2 = T;
    if (t != null) {
      t2 = t;
    } else if (T == dynamic && t == null) {
      return false;
    }

    Container? search = this;
    while (search != null) {
      if (search._singletons.containsKey(t2)) {
        return true;
      } else if (search._factories.containsKey(t2)) {
        return true;
      } else {
        search = search._parent;
      }
    }

    return false;
  }

  /// Determines if the container or any of its parent containers has a named singleton with the given [name].
  ///
  /// This method searches the current container and its parent hierarchy for a named singleton
  /// registered with the specified [name].
  ///
  /// Parameters:
  ///   - [name]: The name of the singleton to search for.
  ///
  /// Returns:
  ///   - `true` if a named singleton with the specified [name] is found in this container
  ///     or any of its parent containers.
  ///   - `false` if no named singleton with the specified [name] is found in the entire
  ///     container hierarchy.
  ///
  /// The method searches the current container first, then moves up the parent hierarchy
  /// until a named singleton is found or the root container is reached.
  bool hasNamed(String name) {
    Container? search = this;

    while (search != null) {
      if (search._namedSingletons.containsKey(name)) {
        return true;
      } else {
        search = search._parent;
      }
    }

    return false;
  }

  /// Asynchronously instantiates an instance of [T].
  ///
  /// This method attempts to resolve and return a [Future<T>] in the following order:
  /// 1. If an injection of type [T] is registered, it wraps it in a [Future] and returns it.
  /// 2. If an injection of type [Future<T>] is registered, it returns it directly.
  /// 3. If [T] is [dynamic] and a [Future] of the specified type is registered, it returns that.
  /// 4. If none of the above conditions are met, it throws a [ReflectionException].
  ///
  /// Parameters:
  ///   - [type]: An optional [Type] parameter that can be used to specify the type
  ///     when [T] is [dynamic] or when a different type than [T] needs to be used.
  ///
  /// Returns:
  ///   A [Future<T>] representing the asynchronously resolved instance.
  ///
  /// Throws:
  ///   - [ReflectionException] if no suitable injection is found.
  ///
  /// This method is useful when you need to resolve dependencies that may be
  /// registered as either synchronous ([T]) or asynchronous ([Future<T>]) types.
  Future<T> makeAsync<T>([Type? type]) {
    var t2 = T;
    if (type != null) {
      t2 = type;
    }

    Type? futureType; //.Future<T>.value(null).runtimeType;

    if (T == dynamic) {
      try {
        futureType = reflector.reflectFutureOf(t2).reflectedType;
      } on UnsupportedError {
        // Ignore this.
      }
    }

    if (has<T>(t2)) {
      return Future<T>.value(make(t2));
    } else if (has<Future<T>>()) {
      return make<Future<T>>();
    } else if (futureType != null) {
      return make(futureType);
    } else {
      throw ReflectionException(
          'No injection for Future<$t2> or $t2 was found.');
    }
  }

  /// Instantiates an instance of [T].
  ///
  /// This method attempts to resolve and return an instance of type [T] in the following order:
  /// 1. If a singleton of type [T] is registered in this container or any parent container, it returns that instance.
  /// 2. If a factory for type [T] is registered in this container or any parent container, it calls the factory and returns the result.
  /// 3. If no singleton or factory is found, it uses reflection to instantiate a new instance of [T].
  ///
  /// For reflection-based instantiation:
  /// - It looks for a default constructor or a constructor with an empty name.
  /// - It recursively resolves and injects dependencies for the constructor parameters.
  /// - It supports both positional and named parameters.
  ///
  /// Parameters:
  ///   - [type]: An optional [Type] parameter that can be used to specify the type
  ///     when [T] is [dynamic] or when a different type than [T] needs to be used.
  ///
  /// Returns:
  ///   An instance of type [T].
  ///
  /// Throws:
  ///   - [ReflectionException] if [T] is not a class or if it has no default constructor.
  ///   - Any exception that might occur during the instantiation process.
  ///
  /// This method is central to the dependency injection mechanism, allowing for
  /// flexible object creation and dependency resolution within the container hierarchy.
  T make<T>([Type? type]) {
    Type t2 = T;
    if (type != null) {
      t2 = type;
    }

    Container? search = this;

    while (search != null) {
      if (search._singletons.containsKey(t2)) {
        // Find a singleton, if any.
        return search._singletons[t2] as T;
      } else if (search._factories.containsKey(t2)) {
        // Find a factory, if any.
        return search._factories[t2]!(this) as T;
      } else {
        search = search._parent;
      }
    }

    var reflectedType = reflector.reflectType(t2);
    var positional = [];
    var named = <String, Object>{};

    if (reflectedType is ReflectedClass) {
      bool isDefault(String name) {
        return name.isEmpty || name == reflectedType.name;
      }

      var constructor = reflectedType.constructors.firstWhere(
          (c) => isDefault(c.name),
          orElse: (() => throw ReflectionException(
              '${reflectedType.name} has no default constructor, and therefore cannot be instantiated.')));

      for (var param in constructor.parameters) {
        var value = make(param.type.reflectedType);

        if (param.isNamed) {
          named[param.name] = value;
        } else {
          positional.add(value);
        }
      }

      return reflectedType.newInstance(
          isDefault(constructor.name) ? '' : constructor.name,
          positional,
          named, []).reflectee as T;
    } else {
      throw ReflectionException(
          '$t2 is not a class, and therefore cannot be instantiated.');
    }
  }

  /// Registers a lazy singleton factory.
  ///
  /// In many cases, you might prefer this to [registerFactory].
  ///
  /// Returns [f].
  T Function(Container) registerLazySingleton<T>(T Function(Container) f,
      {Type? as}) {
    return registerFactory<T>(
      (container) {
        var r = f(container);
        container.registerSingleton<T>(r, as: as);
        return r;
      },
      as: as,
    );
  }

  /// Registers a factory function for creating instances of type [T] in the container.
  ///
  /// Returns [f].
  T Function(Container) registerFactory<T>(T Function(Container) f,
      {Type? as}) {
    Type t2 = T;
    if (as != null) {
      t2 = as;
    }

    if (_factories.containsKey(t2)) {
      throw StateError('This container already has a factory for $t2.');
    }

    _factories[t2] = f;
    return f;
  }

  /// Registers a singleton object in the container.
  ///
  /// Returns [object].
  T registerSingleton<T>(T object, {Type? as}) {
    Type t2 = T;
    if (as != null) {
      t2 = as;
    } else if (T == dynamic) {
      t2 = as ?? object.runtimeType;
    }
    //as ??= T == dynamic ? as : T;

    if (_singletons.containsKey(t2)) {
      throw StateError('This container already has a singleton for $t2.');
    }

    _singletons[t2] = object;
    return object;
  }

  /// Retrieves a named singleton from the container or its parent containers.
  ///
  /// In general, prefer using [registerSingleton] and [registerFactory].
  ///
  /// [findByName] is best reserved for internal logic that end users of code should
  /// not see.
  T findByName<T>(String name) {
    if (_namedSingletons.containsKey(name)) {
      return _namedSingletons[name] as T;
    } else if (_parent != null) {
      return _parent.findByName<T>(name);
    } else {
      throw StateError(
          'This container does not have a singleton named "$name".');
    }
  }

  /// Registers a named singleton object in the container.
  ///
  /// Note that this is not related to type-based injections, and exists as a mechanism
  /// to enable injecting multiple instances of a type within the same container hierarchy.
  T registerNamedSingleton<T>(String name, T object) {
    if (_namedSingletons.containsKey(name)) {
      throw StateError('This container already has a singleton named "$name".');
    }

    _namedSingletons[name] = object;
    return object;
  }
}
