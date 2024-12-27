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

  /// The container's type aliases
  final Map<Type, Type> _aliases = {};

  /// The container's service extenders
  final Map<Type, List<dynamic Function(dynamic, Container)>> _extenders = {};

  /// The container's rebound callbacks
  final Map<Type, List<void Function(dynamic, Container)>> _reboundCallbacks =
      {};

  /// The container's refreshing instances
  final Set<Type> _refreshing = {};

  /// The container's parameter override stack
  final List<Map<String, dynamic>> _parameterStack = [];

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

    // Check if the type is aliased
    t2 = getAlias(t2);

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
    // Get the original type
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
                // Check for parameter override
                var override = getParameterOverride(param.name);
                if (override != null) {
                  if (param.isNamed) {
                    named[param.name] = override;
                  } else {
                    positional.add(override);
                  }
                  continue;
                }

                // No override, resolve normally
                var value = make(param.type.reflectedType);
                if (param.isNamed) {
                  named[param.name] = value;
                } else {
                  positional.add(value);
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
          instance = _applyExtenders(t2, instance);
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
          instance = _applyExtenders(t2, instance);
          var typedInstance = instance as T;
          _fireResolvingCallbacks(typedInstance);
          _fireAfterResolvingCallbacks(typedInstance);
          return typedInstance;
        }
      }

      // Check for singleton or factory, resolving aliases if no contextual binding was found
      Container? search = this;
      var resolvedType = contextualConcrete == null ? getAlias(t2) : t2;
      while (search != null) {
        if (search._singletons.containsKey(resolvedType)) {
          var instance = search._singletons[resolvedType];
          instance = _applyExtenders(resolvedType, instance);
          _fireResolvingCallbacks(instance);
          _fireAfterResolvingCallbacks(instance);
          return instance as T;
        } else if (search._factories.containsKey(resolvedType)) {
          // For factory bindings, wrap the factory call in withParameters
          var instance = withParameters(_parameterStack.lastOrNull ?? {}, () {
            return search!._factories[resolvedType]!(this);
          });
          instance = _applyExtenders(resolvedType, instance);
          _fireResolvingCallbacks(instance);
          _fireAfterResolvingCallbacks(instance);
          return instance as T;
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
            // Check for parameter override
            var override = getParameterOverride(param.name);
            if (override != null) {
              if (param.isNamed) {
                named[param.name] = override;
              } else {
                positional.add(override);
              }
              continue;
            }

            // No override, resolve normally
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
            named, []).reflectee;

        instance = _applyExtenders(t2, instance);
        _fireResolvingCallbacks(instance);
        _fireAfterResolvingCallbacks(instance);
        return instance as T;
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

    // Wrap factory in parameter override handler
    _factories[t2] = (container) {
      return container.withParameters(
          _parameterStack.lastOrNull ?? {}, () => f(container));
    };
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
  ///
  /// The [concrete] parameter can be either a single Type or a List<Type>.
  /// When a List<Type> is provided, the same binding will be applied to all types in the list.
  ContextualBindingBuilder when(dynamic concrete) {
    if (concrete is Type) {
      return ContextualBindingBuilder(this, [concrete]);
    } else if (concrete is List<Type>) {
      return ContextualBindingBuilder(this, concrete);
    }
    throw ArgumentError(
        'The concrete parameter must be either Type or List<Type>');
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
      if (contextMap != null) {
        // First try to find a binding for the original type
        if (contextMap.containsKey(abstract)) {
          return contextMap[abstract];
        }
        // Then try to find a binding for the aliased type
        var aliasedType = getAlias(abstract);
        if (aliasedType != abstract && contextMap.containsKey(aliasedType)) {
          return contextMap[aliasedType];
        }
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
      if (contextMap != null) {
        // First check for binding of original type
        if (contextMap.containsKey(type)) {
          return true;
        }
        // Then check for binding of aliased type
        var aliasedType = getAlias(type);
        if (aliasedType != type && contextMap.containsKey(aliasedType)) {
          return true;
        }
      }
      search = search._parent;
    }

    return false;
  }

  /// Register an alias for an abstract type.
  ///
  /// This allows you to alias an abstract type to a concrete implementation.
  /// For example, you might alias an interface to its default implementation:
  /// ```dart
  /// container.alias<Logger>(ConsoleLogger);
  /// ```
  void alias<T>(Type concrete) {
    _aliases[T] = concrete;
  }

  /// Get the concrete type that an abstract type is aliased to.
  ///
  /// If the type is not aliased in this container or any parent container,
  /// returns the type itself.
  Type getAlias(Type abstract) {
    Container? search = this;
    while (search != null) {
      if (search._aliases.containsKey(abstract)) {
        return search._aliases[abstract]!;
      }
      search = search._parent;
    }
    return abstract;
  }

  /// Check if a type is aliased to another type in this container or any parent container.
  bool isAlias(Type type) {
    Container? search = this;
    while (search != null) {
      if (search._aliases.containsKey(type)) {
        return true;
      }
      search = search._parent;
    }
    return false;
  }

  /// Extend a service after it is resolved.
  ///
  /// This allows you to modify a service after it has been resolved from the container.
  /// The callback receives the resolved instance and the container, and should return
  /// the modified instance.
  ///
  /// ```dart
  /// container.extend<Logger>((logger, container) {
  ///   logger.level = LogLevel.debug;
  ///   return logger;
  /// });
  /// ```
  void extend<T>(
      dynamic Function(dynamic instance, Container container) callback) {
    _extenders.putIfAbsent(T, () => []).add(callback);
  }

  /// Apply any registered extenders to an instance.
  dynamic _applyExtenders(Type type, dynamic instance) {
    // Collect all extenders from parent to child
    var extenders = <dynamic Function(dynamic, Container)>[];
    Container? search = this;
    while (search != null) {
      if (search._extenders.containsKey(type)) {
        extenders.insertAll(0, search._extenders[type]!);
      }
      search = search._parent;
    }

    // Apply extenders in order (parent to child)
    for (var extender in extenders) {
      instance = extender(instance, this);
    }
    return instance;
  }

  /// Register a callback to be run when a type is rebound.
  ///
  /// The callback will be invoked whenever the type's binding is replaced
  /// or when refresh() is called on the type.
  ///
  /// ```dart
  /// container.rebinding<Logger>((logger, container) {
  ///   print('Logger was rebound');
  /// });
  /// ```
  void rebinding<T>(
      void Function(dynamic instance, Container container) callback) {
    _reboundCallbacks.putIfAbsent(T, () => []).add(callback);
  }

  /// Refresh an instance in the container.
  ///
  /// This will create a new instance and trigger any rebound callbacks.
  /// If the instance is a singleton, it will be replaced in the container.
  ///
  /// ```dart
  /// container.refresh<Logger>();
  /// ```
  T refresh<T>() {
    if (_refreshing.contains(T)) {
      throw CircularDependencyException(
          'Circular dependency detected while refreshing $T');
    }

    _refreshing.add(T);
    try {
      // Create new instance
      var instance = make<T>();

      // If it's a singleton, replace it
      if (_singletons.containsKey(T)) {
        _singletons[T] = instance;
      }

      // Fire rebound callbacks
      _fireReboundCallbacks(T, instance);

      return instance;
    } finally {
      _refreshing.remove(T);
    }
  }

  /// Fire the rebound callbacks for a type.
  void _fireReboundCallbacks(Type type, dynamic instance) {
    Container? search = this;
    while (search != null) {
      if (search._reboundCallbacks.containsKey(type)) {
        for (var callback in search._reboundCallbacks[type]!) {
          callback(instance, this);
        }
      }
      search = search._parent;
    }
  }

  /// Push parameter overrides onto the stack.
  ///
  /// These parameters will be used when resolving dependencies until they are popped.
  /// ```dart
  /// container.withParameters({'filename': 'custom.log'}, () {
  ///   var logger = container.make<Logger>();
  /// });
  /// ```
  T withParameters<T>(Map<String, dynamic> parameters, T Function() callback) {
    _parameterStack.add(parameters);
    try {
      return callback();
    } finally {
      _parameterStack.removeLast();
    }
  }

  /// Get an override value for a parameter if one exists.
  ///
  /// This method is used internally by the container to resolve parameter overrides,
  /// but is also exposed for use in factory functions.
  dynamic getParameterOverride(String name) {
    for (var i = _parameterStack.length - 1; i >= 0; i--) {
      var parameters = _parameterStack[i];
      if (parameters.containsKey(name)) {
        return parameters[name];
      }
    }
    return null;
  }

  /// Operator overload for array-style access to container bindings.
  ///
  /// This allows you to get instances from the container using array syntax:
  /// ```dart
  /// var logger = container[Logger];
  /// ```
  dynamic operator [](Type type) => make(type);

  /// Operator overload for array-style binding registration.
  ///
  /// This allows you to register bindings using array syntax:
  /// ```dart
  /// container[Logger] = ConsoleLogger();
  /// ```
  void operator []=(Type type, dynamic value) {
    if (value is Function) {
      registerFactory(value as dynamic Function(Container), as: type);
    } else {
      registerSingleton(value, as: type);
    }
  }

  /// Call a method on a resolved instance using Class@method syntax.
  ///
  /// This allows you to resolve and call a method in one step:
  /// ```dart
  /// container.call('Logger@log', ['Hello world']);
  /// ```
  dynamic call(String target,
      [List<dynamic> parameters = const [],
      Map<Symbol, dynamic> namedParameters = const {}]) {
    var parts = target.split('@');
    if (parts.length != 2) {
      throw ArgumentError('Invalid Class@method syntax: $target');
    }

    var className = parts[0];
    var methodName = parts[1];

    // Find the type by name
    var type = reflector.findTypeByName(className);
    if (type == null) {
      throw ArgumentError('Class not found: $className');
    }

    // Resolve the instance
    var instance = make(type);

    // Find and call the method
    var method = reflector.findInstanceMethod(instance, methodName);

    // If method not found and it's __invoke, try 'call' instead
    if (method == null && methodName == '__invoke') {
      method = reflector.findInstanceMethod(instance, 'call');
    }

    if (method == null) {
      throw ArgumentError('Method not found: $methodName on $className');
    }

    // Get method parameters
    var methodParams = method.parameters;
    var resolvedParams = [];
    var paramIndex = 0;

    // Resolve each parameter
    for (var param in methodParams) {
      // Handle variadic parameters
      if (param.isVariadic) {
        // Collect all remaining parameters into a list
        var variadicArgs = parameters.skip(paramIndex).toList();
        resolvedParams.add(variadicArgs);
        break; // Variadic parameter must be last
      } else {
        // If a value was provided for this parameter position, use it
        if (paramIndex < parameters.length) {
          var value = parameters[paramIndex++];
          // If null was provided and we can resolve from container, do so
          if (value == null && has(param.type.reflectedType)) {
            resolvedParams.add(make(param.type.reflectedType));
          } else {
            resolvedParams.add(value);
          }
          continue;
        }
      }

      // Otherwise try to resolve from container
      var paramType = param.type.reflectedType;
      if (has(paramType)) {
        resolvedParams.add(make(paramType));
      } else if (param.isRequired) {
        throw BindingResolutionException(
            'No value provided for required parameter ${param.name} of type $paramType in $className@$methodName');
      }
    }

    // Call the method with resolved parameters
    return method
        .invoke(Invocation.method(
            Symbol(methodName), resolvedParams, namedParameters))
        .reflectee;
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
