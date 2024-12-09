import 'dart:collection';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/reflection.dart';
import 'package:platform_reflection/src/annotations.dart';

import 'bound_method.dart';
import 'contextual_binding_builder.dart';
import 'entry_not_found_exception.dart';
import 'rewindable_generator.dart';
import 'util.dart';

/// The IoC container implementation.
@reflectable
class Container implements ContainerContract {
  /// The current globally available container (if any).
  static Container? _instance;

  /// Keep track of registered types for lookup
  static final Set<Type> _registeredTypes = {};

  /// Keep track of primitive types that don't need reflection
  static final Set<Type> _primitiveTypes = {
    String,
    bool,
    int,
    double,
    num,
    Object,
    Function,
    Type,
    List,
    Map,
    Set,
    Iterable,
    Null,
  };

  Container() {
    // Register self and core types
    registerType(Container);
    registerType(ContainerContract);
    registerType(BindingResolutionException);
    registerType(CircularDependencyException);
    registerType(EntryNotFoundException);

    // Register primitive types
    _primitiveTypes.forEach(registerType);
  }

  /// Register a type for reflection
  static void registerType(Type type) {
    // Don't register primitive types, function types or List types
    if (!_primitiveTypes.contains(type) &&
        !(type.toString().startsWith('(') && type.toString().contains(')')) &&
        !type.toString().startsWith('List<')) {
      _registeredTypes.add(type);
      ReflectionRegistry.registerType(type);
    }
  }

  /// Register multiple types for reflection
  static void registerTypes(List<Type> types) {
    for (final type in types) {
      registerType(type);
    }
  }

  /// An array of the types that have been resolved.
  final _resolved = <String, bool>{};

  /// The container's bindings.
  final _bindings = <String, Map<String, dynamic>>{};

  /// The container's method bindings.
  final _methodBindings = <String, Function>{};

  /// The container's shared instances.
  final _instances = <String, dynamic>{};

  /// The container's scoped instances.
  final _scopedInstances = <String>[];

  /// The registered type aliases.
  final _aliases = <String, String>{};

  /// The registered aliases keyed by the abstract name.
  final _abstractAliases = <String, List<String>>{};

  /// The extension closures for services.
  final _extenders = <String, List<Function>>{};

  /// All of the registered tags.
  final _tags = <String, List<String>>{};

  /// The stack of concretions currently being built.
  final _buildStack = <String>[];

  /// The parameter override stack.
  final _with = <List<dynamic>>[];

  /// The contextual binding map.
  final contextual = <String, Map<String, dynamic>>{};

  /// The contextual attribute handlers.
  final contextualAttributes = <String, Function>{};

  /// All of the registered rebound callbacks.
  final _reboundCallbacks = <String, List<Function>>{};

  /// All of the global before resolving callbacks.
  final _globalBeforeResolvingCallbacks = <Function>[];

  /// All of the global resolving callbacks.
  final _globalResolvingCallbacks = <Function>[];

  /// All of the global after resolving callbacks.
  final _globalAfterResolvingCallbacks = <Function>[];

  /// All of the before resolving callbacks by class type.
  final _beforeResolvingCallbacks = <String, List<Function>>{};

  /// All of the resolving callbacks by class type.
  final _resolvingCallbacks = <String, List<Function>>{};

  /// All of the after resolving callbacks by class type.
  final _afterResolvingCallbacks = <String, List<Function>>{};

  /// All of the after resolving attribute callbacks by class type.
  final _afterResolvingAttributeCallbacks = <String, List<Function>>{};

  @override
  bool has(String id) => bound(id);

  @override
  dynamic get(String id) {
    try {
      return resolve(id);
    } catch (e) {
      if (has(id) || e is CircularDependencyException) {
        rethrow;
      }
      throw EntryNotFoundException(id);
    }
  }

  @override
  void bindMethod(dynamic method, Function callback) {
    _methodBindings[_parseBindMethod(method)] = callback;
  }

  /// Get the method to be bound in class@method format.
  String _parseBindMethod(dynamic method) {
    if (method is List) {
      return '${method[0]}@${method[1]}';
    }
    return method.toString();
  }

  /// Determine if the container has a method binding.
  bool hasMethodBinding(String method) {
    return _methodBindings.containsKey(method);
  }

  /// Get the method binding for the given method.
  dynamic callMethodBinding(String method, dynamic instance) {
    return Function.apply(
      _methodBindings[method]!,
      [instance, this],
    );
  }

  @override
  ContextualBindingBuilder when(dynamic concrete) {
    final aliases = <String>[];

    for (final c in Util.arrayWrap(concrete)) {
      aliases.add(getAlias(c.toString()));
    }

    return ContextualBindingBuilder(this, aliases);
  }

  @override
  void whenHasAttribute(String attribute, Function handler) {
    contextualAttributes[attribute] = handler;
  }

  @override
  bool bound(String abstract) {
    return _bindings.containsKey(abstract) ||
        _instances.containsKey(abstract) ||
        isAlias(abstract);
  }

  @override
  bool resolved(String abstract) {
    if (isAlias(abstract)) {
      abstract = getAlias(abstract);
    }

    return _resolved.containsKey(abstract) || _instances.containsKey(abstract);
  }

  @override
  void bind(String abstract, dynamic concrete, {bool shared = false}) {
    _dropStaleInstances(abstract);

    concrete ??= abstract;

    if (concrete is! Function) {
      if (concrete is! String) {
        throw TypeError();
      }
      concrete = _getClosure(abstract, concrete);
    }

    _bindings[abstract] = {'concrete': concrete, 'shared': shared};

    if (resolved(abstract)) {
      _rebound(abstract);
    }
  }

  @override
  void bindIf(String abstract, dynamic concrete, {bool shared = false}) {
    if (!bound(abstract)) {
      bind(abstract, concrete, shared: shared);
    }
  }

  @override
  void singleton(String abstract, [dynamic concrete]) {
    bind(abstract, concrete, shared: true);
  }

  @override
  void singletonIf(String abstract, [dynamic concrete]) {
    if (!bound(abstract)) {
      singleton(abstract, concrete);
    }
  }

  @override
  void scoped(String abstract, [dynamic concrete]) {
    _scopedInstances.add(abstract);
    singleton(abstract, concrete);
  }

  @override
  void scopedIf(String abstract, [dynamic concrete]) {
    if (!bound(abstract)) {
      scoped(abstract, concrete);
    }
  }

  @override
  T instance<T>(String abstract, T instance) {
    _removeAbstractAlias(abstract);

    final isBound = bound(abstract);

    _aliases.remove(abstract);

    _instances[abstract] = instance;

    if (isBound) {
      _rebound(abstract);
    }

    return instance;
  }

  @override
  void tag(dynamic abstracts, String tag,
      [List<String> additionalTags = const []]) {
    final tags = [tag, ...additionalTags];
    abstracts = Util.arrayWrap(abstracts);

    for (final tag in tags) {
      if (!_tags.containsKey(tag)) {
        _tags[tag] = [];
      }

      for (final abstract in abstracts) {
        _tags[tag]!.add(abstract.toString());
      }
    }
  }

  @override
  Iterable<dynamic> tagged(String tag) {
    if (!_tags.containsKey(tag)) {
      return [];
    }

    return RewindableGenerator(
      () sync* {
        for (final abstract in _tags[tag]!) {
          yield make(abstract);
        }
      },
      _tags[tag]!.length,
    );
  }

  @override
  void alias(String abstract, String alias) {
    if (alias == abstract) {
      throw Exception('[$abstract] is aliased to itself.');
    }

    _aliases[alias] = abstract;
    _abstractAliases.putIfAbsent(abstract, () => []).add(alias);
  }

  @override
  T make<T>(String abstract, [List<dynamic> parameters = const []]) {
    return resolve(abstract, parameters);
  }

  @override
  dynamic call(
    dynamic callback, [
    List<dynamic> parameters = const [],
    String? defaultMethod,
  ]) {
    return BoundMethod.call(this, callback, parameters, defaultMethod);
  }

  @override
  void addContextualBinding(
    String concrete,
    String abstract,
    dynamic implementation,
  ) {
    contextual[concrete] = {getAlias(abstract): implementation};
  }

  @override
  void beforeResolving(dynamic abstract, [Function? callback]) {
    if (abstract is String) {
      abstract = getAlias(abstract);
    }

    if (abstract is Function && callback == null) {
      _globalBeforeResolvingCallbacks.add(abstract);
    } else {
      _beforeResolvingCallbacks[abstract] = [
        ...(_beforeResolvingCallbacks[abstract] ?? []),
        callback!,
      ];
    }
  }

  @override
  void resolving(dynamic abstract, [Function? callback]) {
    if (abstract is String) {
      abstract = getAlias(abstract);
    }

    if (abstract is Function && callback == null) {
      _globalResolvingCallbacks.add(abstract);
    } else {
      _resolvingCallbacks[abstract] = [
        ...(_resolvingCallbacks[abstract] ?? []),
        callback!,
      ];
    }
  }

  @override
  void afterResolving(dynamic abstract, [Function? callback]) {
    if (abstract is String) {
      abstract = getAlias(abstract);
    }

    if (abstract is Function && callback == null) {
      _globalAfterResolvingCallbacks.add(abstract);
    } else {
      _afterResolvingCallbacks[abstract] = [
        ...(_afterResolvingCallbacks[abstract] ?? []),
        callback!,
      ];
    }
  }

  @override
  void extend(String abstract, Function(dynamic service) closure) {
    abstract = getAlias(abstract);

    if (_instances.containsKey(abstract)) {
      final instance = _instances[abstract];
      final extended = closure(instance);
      _instances[abstract] = extended;
      _rebound(abstract);
    } else {
      _extenders.putIfAbsent(abstract, () => []).add(closure);

      if (resolved(abstract)) {
        _rebound(abstract);
      }
    }
  }

  /// Bind a new callback to an abstract's rebind event.
  void rebinding(String abstract, Function(dynamic instance) callback) {
    _reboundCallbacks
        .putIfAbsent(abstract = getAlias(abstract), () => [])
        .add(callback);

    if (bound(abstract)) {
      make(abstract);
    }
  }

  /// Remove all of the extender callbacks for a given type.
  void forgetExtenders(String abstract) {
    _extenders.remove(getAlias(abstract));
  }

  @override
  Function factory(String abstract) {
    return () => make(abstract);
  }

  @override
  void flush() {
    _aliases.clear();
    _resolved.clear();
    _bindings.clear();
    _instances.clear();
    _abstractAliases.clear();
    _scopedInstances.clear();
  }

  /// Get the alias for an abstract if available.
  String getAlias(String abstract) {
    return _aliases.containsKey(abstract)
        ? getAlias(_aliases[abstract]!)
        : abstract;
  }

  /// Determine if a given string is an alias.
  bool isAlias(String name) {
    return _aliases.containsKey(name);
  }

  /// Get the container's bindings.
  Map<String, Map<String, dynamic>> getBindings() {
    return Map.unmodifiable(_bindings);
  }

  /// Drop all of the stale instances and aliases.
  void _dropStaleInstances(String abstract) {
    _instances.remove(abstract);
    _aliases.remove(abstract);
  }

  /// Remove an alias from the contextual binding alias cache.
  void _removeAbstractAlias(String searched) {
    if (!_aliases.containsKey(searched)) {
      return;
    }

    for (final abstract in _abstractAliases.keys) {
      _abstractAliases[abstract]?.removeWhere((alias) => alias == searched);
    }
  }

  /// Get the Closure to be used when building a type.
  Function _getClosure(String abstract, String concrete) {
    return (Container container, [List<dynamic> parameters = const []]) {
      if (abstract == concrete) {
        return container.build(concrete);
      }

      return container.resolve(concrete, parameters);
    };
  }

  /// Fire the "rebound" callbacks for the given abstract type.
  void _rebound(String abstract) {
    final instance = make(abstract);

    for (final callback in _getReboundCallbacks(abstract)) {
      callback(this, instance);
    }
  }

  /// Get the rebound callbacks for a given type.
  List<Function> _getReboundCallbacks(String abstract) {
    return _reboundCallbacks[abstract] ?? [];
  }

  /// Get the globally available instance of the container.
  static Container getInstance() {
    return _instance ??= Container();
  }

  /// Set the shared instance of the container.
  static Container setInstance([Container? container]) {
    return _instance = container ?? Container();
  }

  /// Resolve the given type from the container.
  T resolve<T>(String abstract, [List<dynamic> parameters = const []]) {
    abstract = getAlias(abstract);

    _fireBeforeResolvingCallbacks(abstract, parameters);

    final concrete = _getContextualConcrete(abstract);
    final needsContextualBuild = parameters.isNotEmpty || concrete != null;

    if (_instances.containsKey(abstract) && !needsContextualBuild) {
      return _instances[abstract] as T;
    }

    _with.add(parameters);

    final object = _isBuildable(concrete ?? _getConcrete(abstract), abstract)
        ? build(concrete ?? _getConcrete(abstract))
        : make(concrete ?? _getConcrete(abstract));

    for (final extender in _getExtenders(abstract)) {
      extender(object);
    }

    if (_isShared(abstract) && !needsContextualBuild) {
      _instances[abstract] = object;
    }

    _fireResolvingCallbacks(abstract, object);

    _resolved[abstract] = true;

    _with.removeLast();

    return object as T;
  }

  /// Build an instance of the given type.
  dynamic build(dynamic concrete) {
    // Handle function types
    if (concrete is Function) {
      final closure = concrete;
      final params = [this, _getLastParameterOverride()];

      try {
        return Function.apply(closure, params);
      } catch (e) {
        if (e is NoSuchMethodError) {
          try {
            return Function.apply(closure, [this]);
          } catch (e) {
            if (e is NoSuchMethodError) {
              return closure();
            }
            rethrow;
          }
        }
        rethrow;
      }
    }

    // Handle string types
    if (concrete is String) {
      for (final type in _registeredTypes) {
        if (type.toString() == concrete) {
          return build(type);
        }
      }
      throw BindingResolutionException('Target [$concrete] does not exist.');
    }

    // Handle primitive types and function types
    if (concrete.runtimeType.toString().startsWith('(') ||
        _primitiveTypes.contains(concrete.runtimeType)) {
      return concrete;
    }

    final reflector = RuntimeReflector.instance;
    try {
      final mirror = reflector.reflectClass(concrete.runtimeType);

      if (!mirror.hasReflectedType) {
        return _notInstantiable(concrete);
      }

      _buildStack.add(concrete.toString());

      // Get class metadata first
      final metadata = mirror.metadata;
      final attributes = <InstanceMirror>[];
      for (final meta in metadata) {
        if (meta.reflectee is ContextualAttribute) {
          attributes.add(meta);
        }
      }

      final constructor = mirror.declarations.values
          .whereType<MethodMirror>()
          .where((m) => m.isConstructor)
          .firstOrNull;

      if (constructor == null) {
        _buildStack.removeLast();
        final instance = reflector.createInstance(concrete.runtimeType);
        _fireAttributeCallbacks(attributes, instance);
        return instance;
      }

      final parameters = constructor.parameters;

      try {
        final instances = _resolveDependencies(parameters);
        _buildStack.removeLast();

        // Handle variadic parameters
        if (parameters
            .any((p) => p.isOptional && p.type.toString().startsWith('List'))) {
          final positionalArgs = <dynamic>[];
          final namedArgs = <String, dynamic>{};

          for (var i = 0; i < parameters.length; i++) {
            final param = parameters[i];
            if (param.isNamed) {
              namedArgs[param.simpleName.toString().replaceAll('"', '')] =
                  i < instances.length ? instances[i] : const [];
            } else {
              positionalArgs
                  .add(i < instances.length ? instances[i] : const []);
            }
          }

          final instance = reflector.createInstance(
            concrete.runtimeType,
            positionalArgs: positionalArgs,
            namedArgs: namedArgs,
          );
          _fireAttributeCallbacks(attributes, instance);
          return instance;
        }

        final instance = reflector.createInstance(
          concrete.runtimeType,
          positionalArgs: instances,
        );
        _fireAttributeCallbacks(attributes, instance);
        return instance;
      } catch (e) {
        _buildStack.removeLast();
        rethrow;
      }
    } catch (e) {
      throw BindingResolutionException(
        'Target [$concrete] does not exist.',
        originalError: e,
      );
    }
  }

  /// Fire attribute callbacks for an instance
  void _fireAttributeCallbacks(
      List<InstanceMirror> attributes, dynamic instance) {
    for (final attribute in attributes) {
      final handler =
          contextualAttributes[attribute.type.reflectedType.toString()];
      if (handler != null) {
        handler(attribute.reflectee, instance);
      }
    }
  }

  /// Get the concrete type for a given abstract.
  dynamic _getConcrete(String abstract) {
    if (_bindings.containsKey(abstract)) {
      return _bindings[abstract]!['concrete'];
    }

    return abstract;
  }

  /// Get the contextual concrete binding for the given abstract.
  dynamic _getContextualConcrete(String abstract) {
    if (_buildStack.isEmpty) return null;

    if (contextual.containsKey(_buildStack.last) &&
        contextual[_buildStack.last]!.containsKey(abstract)) {
      return contextual[_buildStack.last]![abstract];
    }

    if (_abstractAliases.isEmpty) return null;

    for (final alias in _abstractAliases[abstract] ?? []) {
      if (contextual.containsKey(_buildStack.last) &&
          contextual[_buildStack.last]!.containsKey(alias)) {
        return contextual[_buildStack.last]![alias];
      }
    }

    return null;
  }

  /// Determine if the given concrete is buildable.
  bool _isBuildable(dynamic concrete, String abstract) {
    return concrete == abstract || concrete is Function;
  }

  /// Determine if the given abstract type is shared.
  bool _isShared(String abstract) {
    return _instances.containsKey(abstract) ||
        (_bindings.containsKey(abstract) &&
            _bindings[abstract]!['shared'] == true);
  }

  /// Get the extenders callbacks for a given type.
  List<Function> _getExtenders(String abstract) {
    return _extenders[getAlias(abstract)] ?? [];
  }

  /// Get the last parameter override.
  List<dynamic> _getLastParameterOverride() {
    return _with.isEmpty ? [] : _with.last;
  }

  /// Fire all of the before resolving callbacks.
  void _fireBeforeResolvingCallbacks(
      String abstract, List<dynamic> parameters) {
    _fireBeforeCallbackArray(
        abstract, parameters, _globalBeforeResolvingCallbacks);

    for (final entry in _beforeResolvingCallbacks.entries) {
      if (entry.key == abstract) {
        _fireBeforeCallbackArray(abstract, parameters, entry.value);
      }
    }
  }

  /// Fire an array of callbacks with an object.
  void _fireBeforeCallbackArray(
    String abstract,
    List<dynamic> parameters,
    List<Function> callbacks,
  ) {
    for (final callback in callbacks) {
      callback(abstract, parameters, this);
    }
  }

  /// Fire all of the resolving callbacks.
  void _fireResolvingCallbacks(String abstract, dynamic object) {
    _fireCallbackArray(object, _globalResolvingCallbacks);

    _fireCallbackArray(
      object,
      _getCallbacksForType(abstract, object, _resolvingCallbacks),
    );

    _fireAfterResolvingCallbacks(abstract, object);
  }

  /// Fire all of the after resolving callbacks.
  void _fireAfterResolvingCallbacks(String abstract, dynamic object) {
    _fireCallbackArray(object, _globalAfterResolvingCallbacks);

    _fireCallbackArray(
      object,
      _getCallbacksForType(abstract, object, _afterResolvingCallbacks),
    );

    // Fire attribute callbacks
    for (final entry in _afterResolvingAttributeCallbacks.entries) {
      final attribute = Util.getAttributeFromType(entry.key, object);
      if (attribute != null) {
        for (final callback in entry.value) {
          callback(attribute, object, this);
        }
      }
    }
  }

  /// Register a callback to be run after resolving an attribute.
  void afterResolvingAttribute(String attributeType,
      Function(dynamic, dynamic, ContainerContract) callback) {
    _afterResolvingAttributeCallbacks
        .putIfAbsent(attributeType, () => [])
        .add(callback);
  }

  /// Get all callbacks for a given type.
  List<Function> _getCallbacksForType(
    String abstract,
    dynamic object,
    Map<String, List<Function>> callbacksPerType,
  ) {
    final results = <Function>[];

    for (final entry in callbacksPerType.entries) {
      if (entry.key == abstract || object.runtimeType.toString() == entry.key) {
        results.addAll(entry.value);
      }
    }

    return results;
  }

  /// Fire an array of callbacks with an object.
  void _fireCallbackArray(dynamic object, List<Function> callbacks) {
    for (final callback in callbacks) {
      callback(object, this);
    }
  }

  /// Resolve all of the dependencies from the ReflectionParameters.
  List<dynamic> _resolveDependencies(List<ParameterMirror> dependencies) {
    final results = <dynamic>[];

    for (final dependency in dependencies) {
      if (_hasParameterOverride(dependency)) {
        results.add(_getParameterOverride(dependency));
        continue;
      }

      dynamic result;

      final attribute = Util.getContextualAttributeFromDependency(dependency);
      if (attribute != null) {
        result = _resolveFromAttribute(attribute);
      }

      result ??= Util.getParameterClassName(dependency) == null
          ? _resolvePrimitive(dependency)
          : _resolveClass(dependency);

      if (dependency.isOptional && dependency.isNamed) {
        results.addAll(result is List ? result : [result]);
      } else {
        results.add(result);
      }
    }

    return results;
  }

  /// Determine if the given dependency has a parameter override.
  bool _hasParameterOverride(ParameterMirror dependency) {
    return _getLastParameterOverride().any((p) =>
        p.toString() == dependency.simpleName.toString().replaceAll('"', ''));
  }

  /// Get a parameter override for a dependency.
  dynamic _getParameterOverride(ParameterMirror dependency) {
    return _getLastParameterOverride().firstWhere(
      (p) =>
          p.toString() == dependency.simpleName.toString().replaceAll('"', ''),
    );
  }

  /// Resolve a non-class hinted primitive dependency.
  dynamic _resolvePrimitive(ParameterMirror parameter) {
    if (parameter.hasDefaultValue) {
      return (parameter as dynamic).defaultValue?.reflectee;
    }

    if (parameter.isOptional && parameter.isNamed) {
      return [];
    }

    throw BindingResolutionException(
      'Unresolvable dependency resolving [$parameter] in class ${parameter.owner}',
    );
  }

  /// Resolve a class based dependency from the container.
  dynamic _resolveClass(ParameterMirror parameter) {
    try {
      return parameter.isOptional && parameter.isNamed
          ? _resolveVariadicClass(parameter)
          : make(Util.getParameterClassName(parameter)!);
    } catch (e) {
      if (parameter.hasDefaultValue) {
        _with.removeLast();
        return (parameter as dynamic).defaultValue?.reflectee;
      }

      if (parameter.isOptional && parameter.isNamed) {
        _with.removeLast();
        return [];
      }

      rethrow;
    }
  }

  /// Resolve a class based variadic dependency from the container.
  dynamic _resolveVariadicClass(ParameterMirror parameter) {
    final className = Util.getParameterClassName(parameter)!;
    final abstract = getAlias(className);

    if (_getContextualConcrete(abstract) is! List) {
      return make(className);
    }

    return _getContextualConcrete(abstract).map((a) => resolve(a));
  }

  /// Resolve a dependency based on an attribute.
  dynamic _resolveFromAttribute(InstanceMirror attribute) {
    final handler =
        contextualAttributes[attribute.type.reflectedType.toString()];
    final instance = attribute.reflectee;

    if (handler == null && instance is Function) {
      return instance();
    }

    if (handler == null) {
      throw BindingResolutionException(
        'Contextual binding attribute [${attribute.type.reflectedType}] has no registered handler.',
      );
    }

    return handler(instance, this);
  }

  /// Throw an exception that the concrete is not instantiable.
  Never _notInstantiable(dynamic concrete) {
    if (_buildStack.isNotEmpty) {
      final previous = _buildStack.join(' ');
      throw BindingResolutionException(
        'Target [$concrete] is not instantiable while building [$previous].',
      );
    }

    throw BindingResolutionException('Target [$concrete] is not instantiable.');
  }
}
