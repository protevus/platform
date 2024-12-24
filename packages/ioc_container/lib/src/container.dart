import 'dart:mirrors';
import 'package:platform_contracts/contracts.dart';
import 'package:ioc_container/src/bound_method.dart';
import 'package:ioc_container/src/contextual_binding_builder.dart';
import 'package:ioc_container/src/entry_not_found_exception.dart';
import 'package:ioc_container/src/util.dart';

class Container implements ContainerContract {
  static Container? _instance;

  final Map<String, bool> _resolved = {};
  final Map<String, Map<String, dynamic>> _bindings = {};

  final Map<String, Function> _methodBindings = {};

  final Map<String, Object> _instances = {};
  final List<String> _scopedInstances = [];
  final Map<String, String> _aliases = {};
  final Map<String, List<String>> _abstractAliases = {};
  final Map<String, List<Function>> _extenders = {};
  final Map<String, List<String>> _tags = {};
  final List<String> _buildStack = [];
  final List<Map<String, dynamic>> _with = [];
  final Map<String, Map<String, dynamic>> _contextual = {};
  final Map<String, Function> _contextualAttributes = {};
  final Map<String, List<Function>> _reboundCallbacks = {};
  final List<Function> _globalBeforeResolvingCallbacks = [];
  final List<Function> _globalResolvingCallbacks = [];
  final List<Function> _globalAfterResolvingCallbacks = [];
  final Map<String, List<Function>> _beforeResolvingCallbacks = {};
  final Map<String, List<Function>> _resolvingCallbacks = {};
  final Map<String, List<Function>> _afterResolvingCallbacks = {};
  final Map<String, List<Function>> _afterResolvingAttributeCallbacks = {};

  Container();

  static Container getInstance() {
    return _instance ??= Container();
  }

  static void setInstance(Container? container) {
    _instance = container;
  }

  Function wrap(Function callback, [List<dynamic> parameters = const []]) {
    return () => call(callback, parameters);
  }

  dynamic refresh(String abstract, dynamic target, String method) {
    return rebinding(abstract, (Container container, dynamic instance) {
      Function.apply(target[method], [instance]);
    });
  }

  dynamic rebinding(String abstract, Function callback) {
    abstract = getAlias(abstract);

    _reboundCallbacks[abstract] ??= [];
    _reboundCallbacks[abstract]!.add(callback);

    if (bound(abstract)) {
      return make(abstract);
    }

    return null;
  }

  @override
  void bindMethod(dynamic method, Function callback) {
    _methodBindings[_parseBindMethod(method)] = callback;
  }

  String _parseBindMethod(dynamic method) {
    if (method is List && method.length == 2) {
      return '${method[0]}@${method[1]}';
    }
    return method.toString();
  }

  bool hasMethodBinding(String method) {
    return _methodBindings.containsKey(method);
  }

  dynamic callMethodBinding(String method, dynamic instance) {
    if (!hasMethodBinding(method)) {
      throw Exception("Method binding not found for $method");
    }
    return _methodBindings[method]!(instance);
  }

  @override
  bool bound(String abstract) {
    return _bindings.containsKey(abstract) ||
        _instances.containsKey(abstract) ||
        isAlias(abstract);
  }

  @override
  void alias(String abstract, String alias) {
    if (alias == abstract) {
      throw ArgumentError("[$abstract] is aliased to itself.");
    }

    _aliases[alias] = abstract;

    _abstractAliases[abstract] ??= [];
    _abstractAliases[abstract]!.add(alias);
  }

  @override
  void tag(dynamic abstracts, String tag,
      [List<String> additionalTags = const []]) {
    var tags = [tag, ...additionalTags];
    var abstractList = abstracts is List ? abstracts : [abstracts];

    for (var tag in tags) {
      if (!_tags.containsKey(tag)) {
        _tags[tag] = [];
      }

      _tags[tag]!.addAll(abstractList.cast<String>());
    }

    void forgetExtenders(String abstract) {
      abstract = getAlias(abstract);
      _extenders.remove(abstract);
    }
  }

  @override
  Iterable<dynamic> tagged(String tag) {
    if (!_tags.containsKey(tag)) {
      return [];
    }

    return _tags[tag]!.map((abstract) => make(abstract));
  }

  @override
  void bind(String abstract, dynamic concrete, {bool shared = false}) {
    _dropStaleInstances(abstract);

    if (concrete == null) {
      concrete = abstract;
    }

    // If concrete is not a function and not null, we store it directly
    if (concrete is! Function && concrete != null) {
      _bindings[abstract] = {'concrete': concrete, 'shared': shared};
    } else {
      // For functions or null, we wrap it in a closure
      _bindings[abstract] = {
        'concrete': (Container container) =>
            concrete is Function ? concrete(container) : concrete,
        'shared': shared
      };
    }

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
    bind(abstract, concrete ?? abstract, shared: true);
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
  void extend(String abstract, Function(dynamic service) closure) {
    abstract = getAlias(abstract);

    if (_instances.containsKey(abstract)) {
      _instances[abstract] = closure(_instances[abstract]!);
      _rebound(abstract);
    } else {
      _extenders[abstract] ??= [];
      _extenders[abstract]!.add(closure);

      if (resolved(abstract)) {
        _rebound(abstract);
      }
    }
  }

  @override
  T instance<T>(String abstract, T instance) {
    _removeAbstractAlias(abstract);

    bool isBound = bound(abstract);

    _aliases.remove(abstract);

    _instances[abstract] = instance as Object;

    if (isBound) {
      _rebound(abstract);
    }

    return instance;
  }

  @override
  void addContextualBinding(
      String concrete, String abstract, dynamic implementation) {
    _contextual[concrete] ??= {};
    _contextual[concrete]![getAlias(abstract)] = implementation;
  }

  @override
  ContextualBindingBuilderContract when(dynamic concrete) {
    return ContextualBindingBuilder(
        this, Util.arrayWrap(concrete).map((c) => getAlias(c)).toList());
  }

  @override
  void whenHasAttribute(String attribute, Function handler) {
    _contextualAttributes[attribute] = handler;
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

  @override
  T make<T>(String abstract, [List<dynamic> parameters = const []]) {
    return resolve(abstract, parameters) as T;
  }

  @override
  dynamic call(dynamic callback,
      [List<dynamic> parameters = const [], String? defaultMethod]) {
    return BoundMethod.call(this, callback, parameters, defaultMethod);
  }

  @override
  bool resolved(String abstract) {
    if (isAlias(abstract)) {
      abstract = getAlias(abstract);
    }

    return _resolved.containsKey(abstract) || _instances.containsKey(abstract);
  }

  @override
  void beforeResolving(dynamic abstract, [Function? callback]) {
    if (abstract is String) {
      abstract = getAlias(abstract);
    }

    if (abstract is Function && callback == null) {
      _globalBeforeResolvingCallbacks.add(abstract);
    } else {
      _beforeResolvingCallbacks[abstract.toString()] ??= [];
      if (callback != null) {
        _beforeResolvingCallbacks[abstract.toString()]!.add(callback);
      }
    }
  }

  @override
  void resolving(dynamic abstract, [Function? callback]) {
    if (abstract is String) {
      abstract = getAlias(abstract);
    }

    if (callback == null && abstract is Function) {
      _globalResolvingCallbacks.add(abstract);
    } else {
      _resolvingCallbacks[abstract.toString()] ??= [];
      if (callback != null) {
        _resolvingCallbacks[abstract.toString()]!.add(callback);
      }
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
      _afterResolvingCallbacks[abstract.toString()] ??= [];
      if (callback != null) {
        _afterResolvingCallbacks[abstract.toString()]!.add(callback);
      }
    }
  }

  void afterResolvingAttribute(
      Type attributeType, Function(dynamic, dynamic, Container) callback) {
    var attributeName = attributeType.toString();
    _afterResolvingAttributeCallbacks[attributeName] ??= [];
    _afterResolvingAttributeCallbacks[attributeName]!.add(callback);

    // Ensure the attribute type is bound
    if (!bound(attributeName)) {
      bind(attributeName, (container) => attributeType);
    }
  }

  bool isShared(String abstract) {
    return _instances.containsKey(abstract) ||
        (_bindings.containsKey(abstract) &&
            _bindings[abstract]!['shared'] == true);
  }

  bool isAlias(String name) {
    return _aliases.containsKey(name);
  }

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
  bool has(String id) {
    return bound(id);
  }

  void _dropStaleInstances(String abstract) {
    _instances.remove(abstract);
    _aliases.remove(abstract);
  }

  void _removeAbstractAlias(String abstract) {
    if (!_aliases.containsKey(abstract)) return;

    for (var entry in _abstractAliases.entries) {
      entry.value.remove(abstract);
    }
  }

  void _rebound(String abstract) {
    var instance = make(abstract);

    for (var callback in _getReboundCallbacks(abstract)) {
      callback(this, instance);
    }
  }

  List<Function> _getReboundCallbacks(String abstract) {
    return _reboundCallbacks[abstract] ?? [];
  }

  dynamic resolve(String abstract,
      [List<dynamic> parameters = const [], bool raiseEvents = true]) {
    abstract = getAlias(abstract);

    if (_buildStack.contains(abstract)) {
      throw CircularDependencyException([..._buildStack, abstract]);
    }

    _buildStack.add(abstract);

    try {
      if (raiseEvents) {
        _fireBeforeResolvingCallbacks(abstract, parameters);
      }

      var concrete = _getContextualConcrete(abstract);

      var needsContextualBuild = parameters.isNotEmpty || concrete != null;

      if (_instances.containsKey(abstract) && !needsContextualBuild) {
        return _instances[abstract];
      }

      _with.add(Map<String, dynamic>.fromEntries(parameters
          .asMap()
          .entries
          .map((e) => MapEntry(e.key.toString(), e.value))));

      if (concrete == null) {
        concrete = _getConcrete(abstract);
      }

      var object;
      if (_isBuildable(concrete, abstract)) {
        object = build(concrete);
        // If the result is still a function, execute it
        if (object is Function) {
          object = object(this);
        }
      } else {
        object = make(concrete);
      }

      for (var extender in _getExtenders(abstract)) {
        object = extender(object);
      }

      if (isShared(abstract) && !needsContextualBuild) {
        _instances[abstract] = object;
      }

      if (raiseEvents) {
        _fireResolvingCallbacks(abstract, object);
      }

      if (!needsContextualBuild) {
        _resolved[abstract] = true;
      }

      _with.removeLast();

      return object;
    } finally {
      _buildStack.removeLast();
    }
  }

  dynamic _getConcrete(String abstract) {
    if (_bindings.containsKey(abstract)) {
      return _bindings[abstract]!['concrete'];
    }

    return abstract;
  }

  bool _isBuildable(dynamic concrete, String abstract) {
    return concrete == abstract || concrete is Function;
  }

  dynamic _resolveContextualAttribute(ContextualAttribute attribute) {
    var attributeType = attribute.runtimeType.toString();
    if (_contextualAttributes.containsKey(attributeType)) {
      return _contextualAttributes[attributeType]!(attribute, this);
    }
    // Try to find a handler based on superclasses
    for (var handler in _contextualAttributes.entries) {
      if (reflectClass(attribute.runtimeType)
          .isSubclassOf(reflectClass(handler.key as Type))) {
        return handler.value(attribute, this);
      }
    }
    throw BindingResolutionException(
        "No handler registered for ContextualAttribute: $attributeType");
  }

  void fireBeforeResolvingAttributeCallbacks(
      List<InstanceMirror> annotations, dynamic object) {
    for (var annotation in annotations) {
      if (annotation.reflectee is ContextualAttribute) {
        var instance = annotation.reflectee as ContextualAttribute;
        var attributeType = instance.runtimeType.toString();
        if (_beforeResolvingCallbacks.containsKey(attributeType)) {
          for (var callback in _beforeResolvingCallbacks[attributeType]!) {
            callback(instance, object, this);
          }
        }
      }
    }
  }

  void fireAfterResolvingAttributeCallbacks(
      List<InstanceMirror> annotations, dynamic object) {
    for (var annotation in annotations) {
      var instance = annotation.reflectee;
      var attributeType = instance.runtimeType.toString();
      if (_afterResolvingAttributeCallbacks.containsKey(attributeType)) {
        for (var callback
            in _afterResolvingAttributeCallbacks[attributeType]!) {
          callback(instance, object, this);
        }
      }
    }
  }

  void forgetInstance(String abstract) {
    _instances.remove(abstract);
  }

  void forgetInstances() {
    _instances.clear();
  }

  void forgetScopedInstances() {
    for (var scoped in _scopedInstances) {
      _instances.remove(scoped);
    }
  }

  void forgetExtenders(String abstract) {
    abstract = getAlias(abstract);
    _extenders.remove(abstract);
  }

  T makeScoped<T>(String abstract) {
    // This is similar to make, but ensures the instance is scoped
    var instance = make<T>(abstract);
    if (!_scopedInstances.contains(abstract)) {
      _scopedInstances.add(abstract);
    }
    return instance;
  }

  Map<String, Map<String, dynamic>> getBindings() {
    return Map.from(_bindings);
  }

  dynamic build(dynamic concrete) {
    if (concrete is Function) {
      _buildStack.add(concrete.toString());
      try {
        return concrete(this);
      } finally {
        _buildStack.removeLast();
      }
    }

    if (concrete is String) {
      // First, check if it's a simple value binding
      if (_bindings.containsKey(concrete) &&
          _bindings[concrete]!['concrete'] is! Function) {
        return _bindings[concrete]!['concrete'];
      }

      // If it's not a simple value, proceed with class resolution
      try {
        Symbol classSymbol = MirrorSystem.getSymbol(concrete)!;
        ClassMirror? classMirror;

        // Search for the class in all libraries
        for (var lib in currentMirrorSystem().libraries.values) {
          if (lib.declarations.containsKey(classSymbol)) {
            var declaration = lib.declarations[classSymbol]!;
            if (declaration is ClassMirror) {
              classMirror = declaration;
              break;
            }
          }
        }

        if (classMirror == null) {
          // If we can't find a class, return the string as is
          return concrete;
        }

        var classAttributes = classMirror.metadata;
        fireBeforeResolvingAttributeCallbacks(classAttributes, null);

        MethodMirror? constructor = classMirror.declarations.values
            .whereType<MethodMirror>()
            .firstWhere((d) => d.isConstructor,
                orElse: () => null as MethodMirror);

        if (constructor == null) {
          throw BindingResolutionException(
              "No constructor found for [$concrete]");
        }

        List parameters = _resolveDependencies(constructor.parameters);
        var instance =
            classMirror.newInstance(Symbol.empty, parameters).reflectee;

        // Apply attributes to the instance
        for (var attribute in classAttributes) {
          var attributeType = attribute.reflectee.runtimeType;
          var attributeTypeName = attributeType.toString();
          if (_afterResolvingAttributeCallbacks
              .containsKey(attributeTypeName)) {
            for (var callback
                in _afterResolvingAttributeCallbacks[attributeTypeName]!) {
              callback(attribute.reflectee, instance, this);
            }
          }
        }

        // Apply attributes to properties
        var instanceMirror = reflect(instance);
        for (var declaration in classMirror.declarations.values) {
          if (declaration is VariableMirror) {
            for (var attribute in declaration.metadata) {
              var attributeType = attribute.reflectee.runtimeType;
              var attributeTypeName = attributeType.toString();
              if (_afterResolvingAttributeCallbacks
                  .containsKey(attributeTypeName)) {
                for (var callback
                    in _afterResolvingAttributeCallbacks[attributeTypeName]!) {
                  var propertyValue =
                      instanceMirror.getField(declaration.simpleName).reflectee;
                  callback(attribute.reflectee, propertyValue, this);
                  instanceMirror.setField(
                      declaration.simpleName, propertyValue);
                }
              }
            }
          }
        }

        // Apply after resolving callbacks
        fireAfterResolvingAttributeCallbacks(classAttributes, instance);
        _fireAfterResolvingCallbacks(concrete, instance);

        // Apply after resolving callbacks
        fireAfterResolvingAttributeCallbacks(classAttributes, instance);
        _fireAfterResolvingCallbacks(concrete, instance);

        // Apply extenders after all callbacks
        for (var extender in _getExtenders(concrete)) {
          instance = extender(instance);
        }

        // Store the instance if it's shared
        if (isShared(concrete)) {
          _instances[concrete] = instance;
        }

        // Ensure the instance is stored before returning
        if (_instances.containsKey(concrete)) {
          return _instances[concrete];
        }

        return instance;
      } catch (e) {
        // If any error occurs during class instantiation, return the string as is
        return concrete;
      }
    }

    // If concrete is neither a Function nor a String, return it as is
    return concrete;
  }

  dynamic _getContextualConcrete(String abstract) {
    if (_buildStack.isNotEmpty) {
      var building = _buildStack.last;
      if (_contextual.containsKey(building) &&
          _contextual[building]!.containsKey(abstract)) {
        return _contextual[building]![abstract];
      }

      // Check for attribute-based contextual bindings
      try {
        var buildingType = MirrorSystem.getSymbol(building);
        var buildingMirror = currentMirrorSystem()
            .findLibrary(buildingType)
            ?.declarations[buildingType];
        if (buildingMirror is ClassMirror) {
          for (var attribute in buildingMirror.metadata) {
            if (attribute.reflectee is ContextualAttribute) {
              var contextualAttribute =
                  attribute.reflectee as ContextualAttribute;
              if (_contextualAttributes
                  .containsKey(contextualAttribute.runtimeType.toString())) {
                var handler = _contextualAttributes[
                    contextualAttribute.runtimeType.toString()]!;
                return handler(contextualAttribute, this);
              }
            }
          }
        }
      } catch (e) {
        // If we can't find the class, just continue
      }
    }

    if (_buildStack.isNotEmpty) {
      if (_contextual.containsKey(_buildStack.last) &&
          _contextual[_buildStack.last]!.containsKey(abstract)) {
        return _contextual[_buildStack.last]![abstract];
      }
    }

    if (_abstractAliases.containsKey(abstract)) {
      for (var alias in _abstractAliases[abstract]!) {
        if (_buildStack.isNotEmpty &&
            _contextual.containsKey(_buildStack.last) &&
            _contextual[_buildStack.last]!.containsKey(alias)) {
          return _contextual[_buildStack.last]![alias];
        }
      }
    }

    return null;
  }

  dynamic resolveFromAnnotation(InstanceMirror annotation) {
    var instance = annotation.reflectee;

    if (instance is ContextualAttribute) {
      // Handle ContextualAttribute
      return _resolveContextualAttribute(instance);
    }

    // Add more annotation handling as needed

    throw BindingResolutionException(
        "Unsupported annotation type: ${annotation.type}");
  }

  void fireAfterResolvingAnnotationCallbacks(
      List<InstanceMirror> annotations, dynamic object) {
    for (var annotation in annotations) {
      if (annotation.reflectee is ContextualAttribute) {
        var instance = annotation.reflectee as ContextualAttribute;
        if (_afterResolvingAttributeCallbacks
            .containsKey(instance.runtimeType.toString())) {
          for (var callback in _afterResolvingAttributeCallbacks[
              instance.runtimeType.toString()]!) {
            callback(instance, object, this);
          }
        }
      }
    }
  }

  List<dynamic> _resolveDependencies(List<ParameterMirror> parameters) {
    var results = <dynamic>[];
    for (var parameter in parameters) {
      var parameterName = MirrorSystem.getName(parameter.simpleName);
      if (_hasParameterOverride(parameterName)) {
        results.add(_getParameterOverride(parameterName));
      } else {
        var annotations = parameter.metadata;
        if (annotations.isNotEmpty) {
          results.add(resolveFromAnnotation(annotations.first));
        } else if (parameter.type.reflectedType != dynamic) {
          results.add(make(parameter.type.reflectedType.toString()));
        } else if (parameter.isOptional && parameter.defaultValue != null) {
          results.add(parameter.defaultValue!.reflectee);
        } else {
          throw BindingResolutionException(
              "Unable to resolve parameter $parameterName");
        }
      }
    }
    return results;
  }

  bool _hasParameterOverride(String parameterName) {
    return _getLastParameterOverride().containsKey(parameterName);
  }

  dynamic _getParameterOverride(String parameterName) {
    return _getLastParameterOverride()[parameterName];
  }

  List<Function> _getExtenders(String abstract) {
    return _extenders[getAlias(abstract)] ?? [];
  }

  Map<String, dynamic> _getLastParameterOverride() {
    return _with.isNotEmpty ? _with.last : {};
  }

  void _fireBeforeResolvingCallbacks(
      String abstract, List<dynamic> parameters) {
    _fireCallbackArray(abstract, parameters, _globalBeforeResolvingCallbacks);

    for (var entry in _beforeResolvingCallbacks.entries) {
      if (entry.key == abstract || isSubclassOf(abstract, entry.key)) {
        _fireCallbackArray(abstract, parameters, entry.value);
      }
    }
  }

  void _fireResolvingCallbacks(String abstract, dynamic object) {
    _fireCallbackArray(object, null, _globalResolvingCallbacks);

    var callbacks = _getCallbacksForType(abstract, object, _resolvingCallbacks);
    _fireCallbackArray(object, null, callbacks);

    _fireAfterResolvingCallbacks(abstract, object);
  }

  void _fireAfterResolvingCallbacks(String abstract, dynamic object) {
    _fireCallbackArray(object, null, _globalAfterResolvingCallbacks);

    var callbacks =
        _getCallbacksForType(abstract, object, _afterResolvingCallbacks);
    _fireCallbackArray(object, null, callbacks);
  }

  void _fireCallbackArray(
      dynamic argument, List<dynamic>? parameters, List<Function> callbacks) {
    for (var callback in callbacks) {
      if (parameters != null) {
        callback(argument, parameters, this);
      } else {
        callback(argument, this);
      }
    }
  }

  List<Function> _getCallbacksForType(String abstract, dynamic object,
      Map<String, List<Function>> callbacksPerType) {
    var results = <Function>[];

    for (var entry in callbacksPerType.entries) {
      if (entry.key == abstract || object.runtimeType.toString() == entry.key) {
        results.addAll(entry.value);
      }
    }

    return results;
  }

  bool isSubclassOf(String child, String parent) {
    ClassMirror? childClass = _getClassMirror(child);
    ClassMirror? parentClass = _getClassMirror(parent);

    if (childClass == null || parentClass == null) {
      return false;
    }

    if (childClass == parentClass) {
      return true;
    }

    ClassMirror? currentClass = childClass.superclass;
    while (currentClass != null) {
      if (currentClass == parentClass) {
        return true;
      }
      currentClass = currentClass.superclass;
    }

    return false;
  }

  ClassMirror? _getClassMirror(String className) {
    Symbol classSymbol = MirrorSystem.getSymbol(className)!;
    for (var lib in currentMirrorSystem().libraries.values) {
      if (lib.declarations.containsKey(classSymbol)) {
        var declaration = lib.declarations[classSymbol]!;
        if (declaration is ClassMirror) {
          return declaration;
        }
      }
    }
    return null;
  }

  String getAlias(String abstract) {
    if (!_aliases.containsKey(abstract)) {
      return abstract;
    }

    if (_aliases[abstract] == abstract) {
      throw Exception("[$abstract] is aliased to itself.");
    }

    return getAlias(_aliases[abstract]!);
  }

  // Implement ArrayAccess-like functionality
  dynamic operator [](String key) => make(key);
  void operator []=(String key, dynamic value) => bind(key, value);
}
