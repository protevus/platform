import 'package:illuminate_mirrors/mirrors.dart';

// Type aliases for cleaner code
typedef ContextualResolver = Function(Container);
typedef ContextualBindings = Map<Type, ContextualResolver>;

class Container {
  final Map<String, dynamic> _dependencies = <String, dynamic>{};
  final Map<String, dynamic> _singletonDependencies = <String, dynamic>{};

  // New features
  final Map<Type, ContextualBindings> _contextual = {};
  final Map<Type, List<Function(dynamic)>> _extenders = {};
  final Map<Type, List<Function(dynamic)>> _resolving = {};
  final Map<String, Set<Type>> _tags = {};

  /// register a request class in ioc container
  /// ```
  /// container.registerRequest('BlogRequest', () => BlogRequest());
  /// ```
  void registerRequest(String name, Function callback) {
    if (name != 'dynamic') {
      _dependencies[name] = () => callback();
    }
  }

  /// register a class in ioc container
  /// ```
  /// container.registerByName('name', (i) => Bar());
  /// container.registerByName('name', (i) => Foo(i.get<Bar>()));
  /// ```
  void registerByName(String name, Function(Container) callback) {
    if (name != 'dynamic') {
      _dependencies[name] = () => callback(this);
    }
  }

  /// register a class in ioc container
  /// ```
  /// container.register<Bar>((i) => Bar());
  ///
  /// container.register<Foo>((i) => Foo(i.get<Bar>()));
  /// ```
  void register<T>(Function(Container) callback) {
    if (T.toString() != 'dynamic') {
      _dependencies[T.toString()] = () => callback(this);
    }
  }

  /// register as singleton in ioc container
  /// ```
  /// container.registerSingleton<Bar>((i) => Bar());
  /// ```
  /// bar will create only once instance
  void registerSingleton<T>(Function(Container) callback) {
    if (T.toString() != 'dynamic') {
      _singletonDependencies[T.toString()] = callback(this);
    }
  }

  /// get class
  /// ```
  /// Foo foo = container.get<Foo>();
  /// ```
  T get<T>() {
    // Get instance from singleton or regular dependencies
    dynamic instance;
    if (_haveInSingleton(T.toString())) {
      instance = _singletonDependencies[T.toString()];
    } else {
      // Check contextual bindings first
      if (_contextual.containsKey(T)) {
        final bindings = _contextual[T]!;
        for (var entry in bindings.entries) {
          if (_dependencies.containsKey(entry.key.toString())) {
            // Store original dependency
            final originalDependency = _dependencies[entry.key.toString()];
            // Replace with contextual binding temporarily
            _dependencies[entry.key.toString()] = () => entry.value(this);
            // Get instance with contextual binding
            instance = _dependencies[T.toString()]();
            // Restore original dependency
            _dependencies[entry.key.toString()] = originalDependency;
            return _applyCallbacks<T>(instance);
          }
        }
      }
      // No contextual binding found, use regular dependency
      instance = _dependencies[T.toString()]();
    }

    // Apply resolving callbacks and extenders
    return _applyCallbacks<T>(instance);
  }

  /// Apply resolving callbacks and extenders to an instance
  T _applyCallbacks<T>(dynamic instance, [Type? explicitType]) {
    final type = explicitType ?? T;

    // Apply resolving callbacks
    if (_resolving.containsKey(type)) {
      for (var callback in _resolving[type]!) {
        callback(instance);
      }
    }

    // Apply extenders
    if (_extenders.containsKey(type)) {
      for (var extender in _extenders[type]!) {
        extender(instance);
      }
    }

    return instance as T;
  }

  /// get class
  /// ```
  /// Foo foo = container.get<Foo>();
  /// ```
  dynamic getByName(String name) {
    // Get instance from singleton or regular dependencies
    dynamic instance;
    if (_haveInSingleton(name)) {
      instance = _singletonDependencies[name];
    } else {
      instance = _dependencies[name] != null ? _dependencies[name]() : null;
    }

    if (instance == null) return null;

    // Get the actual type for callbacks
    final type = instance.runtimeType;

    // Apply resolving callbacks and extenders using dynamic type
    return _applyCallbacks<dynamic>(instance, type);
  }

  bool _haveInSingleton(String name) {
    return _singletonDependencies[name] != null;
  }

  /// Make an instance with optional parameters
  T make<T>([Map<String, dynamic>? parameters]) {
    if (T.toString() == 'dynamic') {
      throw Exception('Cannot make dynamic type');
    }

    if (parameters != null && parameters.isNotEmpty) {
      dynamic originalDependency;
      if (_dependencies.containsKey(T.toString())) {
        originalDependency = _dependencies[T.toString()];
      }

      register<T>((c) => _buildWithParameters<T>(parameters));

      final instance = get<T>();

      if (originalDependency != null) {
        _dependencies[T.toString()] = originalDependency;
      } else {
        _dependencies.remove(T.toString());
      }

      return instance;
    }

    return get<T>();
  }

  /// Register a contextual binding
  void registerFor<T, R>(Function(Container) callback) {
    if (T.toString() != 'dynamic') {
      _contextual[T] ??= {};
      _contextual[T]![R] = callback;
    }
  }

  /// Extend a type with additional functionality
  void extend<T>(Function(T) extender) {
    if (T.toString() != 'dynamic') {
      _extenders[T] ??= [];
      _extenders[T]!.add((obj) => extender(obj as T));
    }
  }

  /// Add resolving callback for a type
  void resolving<T>(Function(T) callback) {
    if (T.toString() != 'dynamic') {
      _resolving[T] ??= [];
      _resolving[T]!.add((obj) => callback(obj as T));
    }
  }

  /// Tag a type
  void tag<T>(String tag) {
    if (T.toString() != 'dynamic') {
      _tags[tag] ??= {};
      _tags[tag]!.add(T);
    }
  }

  /// Get instances by tag
  List<T> tagged<T>(String tag) {
    final types = _tags[tag] ?? {};
    final instances = <T>[];

    for (final type in types) {
      if (_dependencies.containsKey(type.toString())) {
        final instance = _dependencies[type.toString()]!();
        if (instance is T) {
          instances.add(instance);
        }
      }
    }

    return instances;
  }

  /// Build an instance with parameters
  T _buildWithParameters<T>(Map<String, dynamic> parameters) {
    final reflector = RuntimeReflector.instance;

    // Create instance using reflection
    return reflector.createInstance(
      T,
      namedArgs: parameters,
    ) as T;
  }
}
