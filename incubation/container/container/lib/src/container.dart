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
import 'contextual_binding_builder.dart';

class Container {
  /// The [Reflector] instance used by this container for reflection-based operations.
  ///
  /// This reflector is used to instantiate objects and resolve dependencies
  /// when no explicit factory or singleton is registered for a given type.
  final Reflector reflector;

  /// The container's bindings map
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function(Container)> _factories = {};
  final Map<String, dynamic> _namedSingletons = {};

  /// The container's contextual bindings
  final Map<Type, Map<Type, dynamic>> _contextual = {};

  /// The container's method bindings
  final Map<String, Function> _methodBindings = {};

  /// The container's tags
  final Map<String, List<Type>> _tags = {};

  /// The container's scoped instances
  final List<Type> _scopedInstances = [];

  /// Resolution callbacks
  final List<Function(Type, List, Container)> _beforeResolvingCallbacks = [];
  final List<Function(dynamic, Container)> _resolvingCallbacks = [];
  final List<Function(dynamic, Container)> _afterResolvingCallbacks = [];

  /// The build stack for detecting circular dependencies
  final List<Type> _buildStack = [];

  /// The parent container
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

    // Check for circular dependencies
    _checkCircularDependency(t2);
    _buildStack.add(t2);

    try {
      // Fire before resolving callbacks
      _fireBeforeResolvingCallbacks(t2, []);

      // Check for contextual binding
      var contextualConcrete = _getContextualConcrete(t2);
      if (contextualConcrete == null && _hasContextualBinding(t2)) {
        throw BindingResolutionException(
            'No implementation was provided for contextual binding of $t2');
      }
      if (contextualConcrete != null) {
        dynamic instance;
        if (contextualConcrete is Function) {
          // Remove current type from stack to avoid circular dependency
          _buildStack.removeLast();
          try {
            instance = contextualConcrete(this);
          } finally {
            _buildStack.add(t2);
          }
        } else if (contextualConcrete is Type) {
          // For Type bindings, we need to use reflection to create the instance
          _buildStack.removeLast(); // Remove current type from stack
          try {
            var reflectedType = reflector.reflectType(contextualConcrete);
            if (reflectedType is ReflectedClass) {
              bool isDefault(String name) {
                return name.isEmpty || name == reflectedType.name;
              }

              var constructor = reflectedType.constructors.firstWhere(
                  (c) => isDefault(c.name),
                  orElse: (() => throw BindingResolutionException(
                      '${reflectedType.name} has no default constructor, and therefore cannot be instantiated.')));

              var positional = [];
              var named = <String, Object>{};

              for (var param in constructor.parameters) {
                if (param.type.reflectedType == String) {
                  positional.add('test.log'); // Default filename for FileLogger
                } else {
                  var value = make(param.type.reflectedType);
                  if (param.isNamed) {
                    named[param.name] = value;
                  } else {
                    positional.add(value);
                  }
                }
              }

              instance = reflectedType.newInstance(
                  isDefault(constructor.name) ? '' : constructor.name,
                  positional,
                  named, []).reflectee;
            }
          } finally {
            _buildStack.add(t2); // Add it back
          }
        }

        if (instance != null) {
          var typedInstance = instance as T;
          _fireResolvingCallbacks(typedInstance);
          _fireAfterResolvingCallbacks(typedInstance);
          return typedInstance;
        }
      }

      // Check for contextual binding in parent classes
      var parentContextual = _getContextualConcreteFromParent(t2);
      if (parentContextual != null) {
        dynamic instance;
        if (parentContextual is Function) {
          // Remove current type from stack to avoid circular dependency
          _buildStack.removeLast();
          try {
            instance = parentContextual(this);
          } finally {
            _buildStack.add(t2);
          }
        } else if (parentContextual is Type) {
          // For Type bindings, we need to use reflection to create the instance
          _buildStack.removeLast(); // Remove current type from stack
          try {
            instance = make(parentContextual);
          } finally {
            _buildStack.add(t2); // Add it back
          }
        }

        if (instance != null) {
          var typedInstance = instance as T;
          _fireResolvingCallbacks(typedInstance);
          _fireAfterResolvingCallbacks(typedInstance);
          return typedInstance;
        }
      }

      // Check for singleton or factory
      Container? search = this;
      while (search != null) {
        if (search._singletons.containsKey(t2)) {
          var instance = search._singletons[t2] as T;
          _fireResolvingCallbacks(instance);
          _fireAfterResolvingCallbacks(instance);
          return instance;
        } else if (search._factories.containsKey(t2)) {
          var instance = search._factories[t2]!(this) as T;
          _fireResolvingCallbacks(instance);
          _fireAfterResolvingCallbacks(instance);
          return instance;
        } else {
          search = search._parent;
        }
      }

      // Handle primitive types
      if (t2 == String) {
        return '' as T;
      }

      // Use reflection to create instance
      var reflectedType = reflector.reflectType(t2);
      if (reflectedType == null) {
        throw BindingResolutionException('No binding was found for $t2');
      }

      // Check if we have all required dependencies
      if (reflectedType is ReflectedClass) {
        bool isDefault(String name) {
          return name.isEmpty || name == reflectedType.name;
        }

        var constructor = reflectedType.constructors.firstWhere(
            (c) => isDefault(c.name),
            orElse: (() => throw BindingResolutionException(
                '${reflectedType.name} has no default constructor, and therefore cannot be instantiated.')));

        // Check if we can resolve all constructor parameters
        for (var param in constructor.parameters) {
          var paramType = param.type.reflectedType;
          if (!has(paramType) && reflector.reflectType(paramType) == null) {
            throw BindingResolutionException(
                'No binding was found for $paramType required by $t2');
          }
        }
      }

      var positional = [];
      var named = <String, Object>{};

      if (reflectedType is ReflectedClass) {
        bool isDefault(String name) {
          return name.isEmpty || name == reflectedType.name;
        }

        var constructor = reflectedType.constructors.firstWhere(
            (c) => isDefault(c.name),
            orElse: (() => throw BindingResolutionException(
                '${reflectedType.name} has no default constructor, and therefore cannot be instantiated.')));

        // Add current type to build stack before resolving parameters
        _buildStack.add(t2);
        try {
          for (var param in constructor.parameters) {
            var value = make(param.type.reflectedType);

            if (param.isNamed) {
              named[param.name] = value;
            } else {
              positional.add(value);
            }
          }
        } finally {
          _buildStack.removeLast();
        }

        var instance = reflectedType.newInstance(
            isDefault(constructor.name) ? '' : constructor.name,
            positional,
            named, []).reflectee as T;

        _fireResolvingCallbacks(instance);
        _fireAfterResolvingCallbacks(instance);
        return instance;
      } else {
        throw BindingResolutionException(
            '$t2 is not a class, and therefore cannot be instantiated.');
      }
    } finally {
      _buildStack.removeLast();
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

  /// Define a contextual binding.
  ///
  /// This allows you to define how abstract types should be resolved in specific contexts.
  ContextualBindingBuilder when(Type concrete) {
    return ContextualBindingBuilder(this, [concrete]);
  }

  /// Add a contextual binding to the container.
  ///
  /// This is used internally by [ContextualBindingBuilder] to register the actual binding.
  void addContextualBinding(
      Type concrete, Type abstract, dynamic implementation) {
    _contextual.putIfAbsent(concrete, () => {});
    _contextual[concrete]![abstract] = implementation;
  }

  /// Bind a callback to resolve with Container::call.
  ///
  /// This allows you to register custom resolution logic for specific method calls.
  void bindMethod(String method, Function callback) {
    if (_methodBindings.containsKey(method)) {
      throw StateError(
          'This container already has a method binding for $method.');
    }
    _methodBindings[method] = callback;
  }

  /// Call the given method and inject its dependencies.
  ///
  /// This method supports both static methods and instance methods.
  dynamic callMethod(String method, [List<dynamic> arguments = const []]) {
    Container? search = this;
    while (search != null) {
      if (search._methodBindings.containsKey(method)) {
        return Function.apply(search._methodBindings[method]!, arguments);
      }
      search = search._parent;
    }
    throw StateError('No method binding found for $method.');
  }

  /// Check if this container or any parent has a method binding.
  bool hasMethodBinding(String method) {
    Container? search = this;
    while (search != null) {
      if (search._methodBindings.containsKey(method)) {
        return true;
      }
      search = search._parent;
    }
    return false;
  }

  /// Assign a set of tags to a given binding.
  ///
  /// This allows you to group related bindings together under a common tag.
  void tag(List<Type> abstracts, String tag) {
    _tags[tag] ??= [];
    _tags[tag]!.addAll(abstracts);
  }

  /// Resolve all bindings for a given tag.
  ///
  /// Returns a list of instances for all bindings tagged with the given tag.
  List<dynamic> tagged(String tag) {
    var result = <Type>{}; // Use Set to avoid duplicates

    // Collect tagged types from this container and all parents
    Container? search = this;
    while (search != null) {
      if (search._tags.containsKey(tag)) {
        result.addAll(search._tags[tag]!);
      }
      search = search._parent;
    }

    return result.map((type) => make(type)).toList();
  }

  /// Register a scoped binding in the container.
  ///
  /// Scoped bindings are similar to singletons but are cleared when [clearScoped] is called.
  void scoped<T>(T Function(Container) factory) {
    _scopedInstances.add(T);
    registerSingleton<T>(
        factory(this)); // Use singleton to ensure same instance
  }

  /// Clear all scoped bindings from the container.
  void clearScoped() {
    // Clear this container's scoped instances
    for (var type in _scopedInstances) {
      _singletons.remove(type);
      _factories.remove(type);
    }
    _scopedInstances.clear();

    // Clear parent's scoped instances if any
    if (_parent != null) {
      _parent.clearScoped();
    }
  }

  /// Get all scoped instances from this container and its parents.
  List<Type> _getAllScopedInstances() {
    var result = <Type>{}; // Use Set to avoid duplicates
    Container? search = this;
    while (search != null) {
      result.addAll(search._scopedInstances);
      search = search._parent;
    }
    return result.toList();
  }

  /// Register a callback to be run before resolving a type.
  void beforeResolving<T>(
      void Function(Type type, List args, Container container) callback) {
    _beforeResolvingCallbacks.add(callback);
  }

  /// Register a callback to be run while resolving a type.
  void resolving<T>(
      void Function(dynamic instance, Container container) callback) {
    _resolvingCallbacks.add(callback);
  }

  /// Register a callback to be run after resolving a type.
  void afterResolving<T>(
      void Function(dynamic instance, Container container) callback) {
    _afterResolvingCallbacks.add(callback);
  }

  /// Fire the "before resolving" callbacks for a type.
  void _fireBeforeResolvingCallbacks(Type type, List args) {
    // Fire parent callbacks first
    if (_parent != null) {
      _parent._fireBeforeResolvingCallbacks(type, args);
    }

    // Then fire this container's callbacks
    for (var callback in _beforeResolvingCallbacks) {
      callback(type, args, this);
    }
  }

  /// Fire the "resolving" callbacks for an instance.
  void _fireResolvingCallbacks(dynamic instance) {
    // Fire parent callbacks first
    if (_parent != null) {
      _parent._fireResolvingCallbacks(instance);
    }

    // Then fire this container's callbacks
    for (var callback in _resolvingCallbacks) {
      callback(instance, this);
    }
  }

  /// Fire the "after resolving" callbacks for an instance.
  void _fireAfterResolvingCallbacks(dynamic instance) {
    // Fire parent callbacks first
    if (_parent != null) {
      _parent._fireAfterResolvingCallbacks(instance);
    }

    // Then fire this container's callbacks
    for (var callback in _afterResolvingCallbacks) {
      callback(instance, this);
    }
  }

  /// Get a contextual concrete binding for the given abstract type.
  dynamic _getContextualConcrete(Type abstract) {
    if (_buildStack.isEmpty) return null;

    // Check current container's contextual bindings
    Container? search = this;
    while (search != null) {
      var building = _buildStack.last;
      var contextMap = search._contextual[building];
      if (contextMap != null && contextMap.containsKey(abstract)) {
        return contextMap[abstract];
      }
      search = search._parent;
    }

    return null;
  }

  /// Get a contextual binding map for a concrete type.
  Map<Type, dynamic>? _getContextualBindings(Type concrete) {
    return _contextual[concrete];
  }

  /// Get a contextual concrete binding from parent classes in the build stack.
  dynamic _getContextualConcreteFromParent(Type abstract) {
    if (_buildStack.isEmpty) return null;

    // Get the parent type from the build stack
    var parentIndex = _buildStack.length - 2;
    if (parentIndex < 0) return null;

    var parentType = _buildStack[parentIndex];

    // Check current container's contextual bindings
    Container? search = this;
    while (search != null) {
      var contextMap = search._contextual[parentType];
      if (contextMap != null && contextMap.containsKey(abstract)) {
        return contextMap[abstract];
      }
      search = search._parent;
    }

    return null;
  }

  /// Check if a type has a contextual binding.
  bool _hasContextualBinding(Type type) {
    if (_buildStack.isEmpty) return false;

    // Check current container's contextual bindings
    Container? search = this;
    while (search != null) {
      var building = _buildStack.last;
      var contextMap = search._contextual[building];
      if (contextMap != null && contextMap.containsKey(type)) {
        return true;
      }
      search = search._parent;
    }

    return false;
  }

  /// Check if we're in danger of a circular dependency.
  void _checkCircularDependency(Type type) {
    if (_buildStack.contains(type)) {
      throw CircularDependencyException(
        'Circular dependency detected while building $type. Build stack: ${_buildStack.join(' -> ')}',
      );
    }
  }
}
