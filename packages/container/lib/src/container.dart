import 'package:platform_contracts/contracts.dart';

/// Laravel-style container implementation.
class IlluminateContainer implements ContainerContract {
  final ReflectorContract _reflector;
  final Map<Type, dynamic Function(ContainerContract)> _bindings = {};
  final Map<Type, dynamic> _instances = {};
  final Map<String, dynamic> _namedInstances = {};
  final Map<String, List<Type>> _tags = {};
  final Map<Type, Map<Type, dynamic>> _contextualBindings = {};
  final Map<String, Function> _methodBindings = {};
  final Map<Type, Type> _aliases = {};
  final Map<Type, List<Function>> _extenders = {};
  final Map<Type, List<Function>> _reboundCallbacks = {};
  final Map<Type, dynamic> _scopedInstances = {};
  final IlluminateContainer? _parent;

  final List<Function> _beforeResolvingCallbacks = [];
  final List<Function> _resolvingCallbacks = [];
  final List<Function> _afterResolvingCallbacks = [];

  IlluminateContainer(this._reflector) : _parent = null;

  IlluminateContainer._child(this._parent, this._reflector);

  @override
  ReflectorContract get reflector => _reflector;

  @override
  bool get isRoot => _parent == null;

  @override
  ContainerContract createChild() {
    return IlluminateContainer._child(this, _reflector);
  }

  @override
  bool bound(String abstract) {
    return has(Type);
  }

  @override
  void bind<T>(T Function(ContainerContract) concrete, {bool shared = false}) {
    if (shared) {
      singleton<T>(concrete);
    } else {
      registerFactory<T>(concrete);
    }
  }

  @override
  void bindIf<T>(T Function(ContainerContract) concrete,
      {bool shared = false}) {
    if (!has<T>()) {
      bind<T>(concrete, shared: shared);
    }
  }

  @override
  void singleton<T>(T Function(ContainerContract) concrete) {
    registerLazySingleton<T>(concrete);
  }

  @override
  void singletonIf<T>(T Function(ContainerContract) concrete) {
    if (!has<T>()) {
      singleton<T>(concrete);
    }
  }

  @override
  void scoped<T>(T Function(ContainerContract) concrete) {
    final type = T;
    T Function(ContainerContract) wrapper = (container) {
      if (!_scopedInstances.containsKey(type)) {
        _scopedInstances[type] = concrete(container);
      }
      return _scopedInstances[type] as T;
    };
    _bindings[type] = wrapper;
  }

  @override
  void scopedIf<T>(T Function(ContainerContract) concrete) {
    if (!has<T>()) {
      scoped<T>(concrete);
    }
  }

  @override
  T instance<T>(T instance) {
    return registerSingleton<T>(instance);
  }

  @override
  void bindMethod(String method, Function callback) {
    _methodBindings[method] = callback;
  }

  @override
  dynamic call(Function callback, [List<dynamic> parameters = const []]) {
    final reflected = _reflector.reflect(callback);
    if (reflected == null) {
      return Function.apply(callback, parameters);
    }

    final method = reflected.type.instanceMembers.values.firstWhere(
      (m) => m.isRegularMethod && m.name == 'call',
      orElse: () => throw StateError('Could not find call method'),
    );

    final injectedParams = method.parameters.map((param) {
      if (parameters.isNotEmpty) {
        return parameters.removeAt(0);
      }
      return make(param.type.reflectedType);
    }).toList();

    final result = Function.apply(callback, injectedParams);
    return result ?? null;
  }

  @override
  Function wrap(Function callback, [List<dynamic> parameters = const []]) {
    return () => call(callback, parameters);
  }

  @override
  ContextualBindingBuilder when(Type concrete) {
    return _ContextualBindingBuilder(this, concrete);
  }

  @override
  void addContextualBinding(
      Type concrete, Type abstract, dynamic implementation) {
    _contextualBindings.putIfAbsent(concrete, () => {})[abstract] =
        implementation;
  }

  @override
  void beforeResolving<T>(
      void Function(ContainerContract, T instance) callback) {
    _beforeResolvingCallbacks.add(callback);
  }

  @override
  void resolving<T>(void Function(ContainerContract, T instance) callback) {
    _resolvingCallbacks.add(callback);
  }

  @override
  void afterResolving<T>(
      void Function(ContainerContract, T instance) callback) {
    _afterResolvingCallbacks.add(callback);
  }

  @override
  bool has<T>([Type? t]) {
    final type = t ?? T;
    return _bindings.containsKey(type) ||
        _instances.containsKey(type) ||
        (_parent?.has<T>(t) ?? false);
  }

  @override
  bool hasNamed(String name) {
    return _namedInstances.containsKey(name) ||
        (_parent?.hasNamed(name) ?? false);
  }

  @override
  T make<T>([Type? type]) {
    final resolveType = type ?? T;
    final concrete = _aliases[resolveType] ?? resolveType;

    // Fire before resolving callbacks
    _fireBeforeResolvingCallbacks<T>(null);

    // Check for singleton instance
    if (_instances.containsKey(concrete)) {
      final instance = _instances[concrete];
      // Apply extenders to singleton instance
      final extenders = getExtenders(concrete);
      for (var extender in extenders) {
        extender(instance);
      }
      _fireResolvingCallbacks<T>(instance as T);
      return instance as T;
    }

    // Check for contextual binding
    if (_contextualBindings.containsKey(concrete)) {
      final bindings = _contextualBindings[concrete]!;
      if (bindings.containsKey(T)) {
        final binding = bindings[T];
        if (binding is Function) {
          final instance = binding(this) as T;
          // Apply extenders to contextual binding instance
          final extenders = getExtenders(concrete);
          for (var extender in extenders) {
            extender(instance);
          }
          _fireResolvingCallbacks<T>(instance);
          return instance;
        }
        _fireResolvingCallbacks<T>(binding as T);
        return binding as T;
      }
    }

    // Check for binding
    if (_bindings.containsKey(concrete)) {
      final instance = _bindings[concrete]!(this);
      // Apply extenders to factory instance
      final extenders = getExtenders(concrete);
      for (var extender in extenders) {
        extender(instance);
      }
      _fireResolvingCallbacks<T>(instance as T);
      return instance as T;
    }

    // Check parent container
    if (_parent != null && _parent!.has<T>(type)) {
      return _parent!.make<T>(type);
    }

    // Try to create instance via reflection
    final reflected = _reflector.reflectClass(concrete);
    if (reflected == null) {
      throw StateError('Could not reflect type $concrete');
    }

    try {
      final instance = reflected.newInstance(Symbol.empty, []).reflectee as T;
      // Apply extenders to reflected instance
      final extenders = getExtenders(concrete);
      for (var extender in extenders) {
        extender(instance);
      }
      _fireResolvingCallbacks<T>(instance);
      return instance;
    } catch (e) {
      throw StateError(
          'Failed to create instance of $concrete: ${e.toString()}');
    }
  }

  void _fireBeforeResolvingCallbacks<T>(T? instance) {
    for (var callback in _beforeResolvingCallbacks) {
      callback(this, instance);
    }
  }

  void _fireResolvingCallbacks<T>(T instance) {
    for (var callback in _resolvingCallbacks) {
      callback(this, instance);
    }
    for (var callback in _afterResolvingCallbacks) {
      callback(this, instance);
    }
  }

  @override
  Future<T> makeAsync<T>([Type? type]) async {
    try {
      final instance = make<T>(type);
      if (instance is Future<T>) {
        return instance;
      }
      return Future<T>.value(instance);
    } catch (e) {
      // Create a Future<T> instance
      final futureClass = _reflector.reflectClass(Future);
      if (futureClass == null) {
        throw StateError('Could not reflect Future type');
      }

      final instance =
          futureClass.newInstance(Symbol.empty, []).reflectee as Future<T>;
      return instance;
    }
  }

  @override
  T registerSingleton<T>(T object, {Type? as}) {
    final type = as ?? T;
    if (_instances.containsKey(type)) {
      throw StateError('Singleton already registered for type $type');
    }
    _instances[type] = object;
    return object;
  }

  @override
  T Function(ContainerContract) registerFactory<T>(
      T Function(ContainerContract) factory,
      {Type? as}) {
    final type = as ?? T;
    _bindings[type] = factory;
    return factory;
  }

  @override
  T Function(ContainerContract) registerLazySingleton<T>(
      T Function(ContainerContract) factory,
      {Type? as}) {
    final type = as ?? T;
    T Function(ContainerContract) wrapper = (container) {
      if (!_instances.containsKey(type)) {
        _instances[type] = factory(container);
      }
      return _instances[type] as T;
    };
    _bindings[type] = wrapper;
    return wrapper;
  }

  @override
  T findByName<T>(String name) {
    if (_namedInstances.containsKey(name)) {
      return _namedInstances[name] as T;
    }
    if (_parent != null) {
      return _parent!.findByName<T>(name);
    }
    throw StateError('No singleton registered with name "$name"');
  }

  @override
  T registerNamedSingleton<T>(String name, T object) {
    if (_namedInstances.containsKey(name)) {
      throw StateError('Singleton already registered with name "$name"');
    }
    _namedInstances[name] = object;
    return object;
  }

  @override
  void tag(List<Type> abstracts, String tag) {
    _tags.putIfAbsent(tag, () => []).addAll(abstracts);
  }

  @override
  List<T> tagged<T>(String tag) {
    final types = _tags[tag] ?? [];
    if (types.isEmpty) {
      throw StateError('No types registered for tag "$tag"');
    }

    final instances = <T>[];
    for (final type in types) {
      if (_bindings.containsKey(type)) {
        final instance = _bindings[type]!(this) as T;
        instances.add(instance);
      } else if (_parent != null && _parent!.has(type)) {
        final instance = _parent!.make(type) as T;
        instances.add(instance);
      } else {
        throw StateError('Could not resolve type $type');
      }
    }
    return instances;
  }

  @override
  void alias(Type abstract, Type alias) {
    if (abstract == alias) {
      throw StateError('$abstract is aliased to itself.');
    }
    _aliases[alias] = abstract;
  }

  @override
  bool isAlias(String name) {
    return _aliases.keys.any((type) => type.toString() == name);
  }

  @override
  Type getAlias(Type abstract) {
    return _aliases[abstract] ?? abstract;
  }

  @override
  void extend(Type abstract, Function(dynamic instance) extension) {
    _extenders.putIfAbsent(abstract, () => []).add(extension);
  }

  @override
  List<Function> getExtenders(Type abstract) {
    return _extenders[abstract] ?? [];
  }

  @override
  void forgetExtenders(Type abstract) {
    _extenders.remove(abstract);
  }

  @override
  void forgetInstance(Type abstract) {
    _instances.remove(abstract);
  }

  @override
  void forgetInstances() {
    _instances.clear();
  }

  @override
  void forgetScopedInstances() {
    _scopedInstances.clear();
  }

  @override
  void flush() {
    _bindings.clear();
    _instances.clear();
    _namedInstances.clear();
    _tags.clear();
    _contextualBindings.clear();
    _methodBindings.clear();
    _aliases.clear();
    _extenders.clear();
    _reboundCallbacks.clear();
    _scopedInstances.clear();
    _beforeResolvingCallbacks.clear();
    _resolvingCallbacks.clear();
    _afterResolvingCallbacks.clear();
  }

  @override
  void rebinding(Type abstract, Function(ContainerContract, dynamic) callback) {
    _reboundCallbacks.putIfAbsent(abstract, () => []).add(callback);
  }

  @override
  void refresh(Type abstract, dynamic target, String method) {
    final instance = make(abstract);

    for (var callback in _reboundCallbacks[abstract] ?? []) {
      callback(this, instance);
    }

    Function.apply(target[method], [instance]);
  }
}

class _ContextualBindingBuilder implements ContextualBindingBuilder {
  final IlluminateContainer _container;
  final Type _concrete;
  Type? _needsType;

  _ContextualBindingBuilder(this._container, this._concrete);

  @override
  ContextualBindingBuilder needs<T>() {
    _needsType = T;
    return this;
  }

  @override
  void give(dynamic implementation) {
    if (_needsType == null) {
      throw StateError('Must call needs() before give()');
    }
    _container.addContextualBinding(_concrete, _needsType!, implementation);
  }
}
