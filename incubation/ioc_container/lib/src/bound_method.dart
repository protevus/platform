import 'dart:mirrors';
import 'package:ioc_container/src/container.dart';
import 'package:ioc_container/src/util.dart';
import 'package:platform_contracts/contracts.dart';

class BoundMethod {
  static dynamic call(Container container, dynamic callback,
      [List<dynamic> parameters = const [], String? defaultMethod]) {
    if (callback is String) {
      if (defaultMethod == null && _hasInvokeMethod(callback)) {
        defaultMethod = '__invoke';
      }
      return _callClass(container, callback, parameters, defaultMethod);
    }

    if (callback is List && callback.length == 2) {
      var instance = container.make(callback[0].toString());
      var method = callback[1].toString();
      return _callBoundMethod(container, [instance, method], () {
        throw BindingResolutionException(
            'Failed to call method: $method on ${instance.runtimeType}');
      }, parameters);
    }

    if (callback is Function) {
      return _callBoundMethod(container, callback, () {
        throw BindingResolutionException('Failed to call function');
      }, parameters);
    }

    if (_isCallableWithAtSign(callback)) {
      return _callClass(container, callback, parameters, defaultMethod);
    }

    throw ArgumentError('Invalid callback type: ${callback.runtimeType}');
  }

  static dynamic _callBoundMethod(
      Container container, dynamic callback, Function defaultCallback,
      [List<dynamic> parameters = const []]) {
    if (callback is List && callback.length == 2) {
      var instance = callback[0];
      var method = callback[1];
      if (instance is String) {
        instance = container.make(instance);
      }
      if (method is String) {
        if (instance is Function && method == '__invoke') {
          return Function.apply(instance, parameters);
        }
        if (instance is Map && instance.containsKey(method)) {
          // Handle the case where instance is a Map and method is a key
          var result = instance[method];
          return result is Function
              ? Function.apply(result, parameters)
              : result;
        }
        var instanceMirror = reflect(instance);
        var methodSymbol = Symbol(method);
        if (instanceMirror.type.instanceMembers.containsKey(methodSymbol)) {
          var dependencies =
              _getMethodDependencies(container, instance, method, parameters);
          var result = Function.apply(
              instanceMirror.getField(methodSymbol).reflectee, dependencies);
          return result is Function
              ? Function.apply(result, parameters)
              : result;
        } else if (method == '__invoke' && instance is Function) {
          return Function.apply(instance, parameters);
        } else if (instance is Type) {
          // Handle static methods
          var classMirror = reflectClass(instance);
          if (classMirror.staticMembers.containsKey(Symbol(method))) {
            var dependencies =
                _getMethodDependencies(container, instance, method, parameters);
            var result = Function.apply(
                classMirror.getField(Symbol(method)).reflectee, dependencies);
            return result is Function
                ? Function.apply(result, parameters)
                : result;
          }
        }
        // Try to find the method in the global scope
        var globalMethod = _findGlobalMethod(method);
        if (globalMethod != null) {
          var result = Function.apply(globalMethod, parameters);
          return result is Function
              ? Function.apply(result, parameters)
              : result;
        }
        throw BindingResolutionException(
            'Method $method not found on ${instance.runtimeType}');
      } else if (method is Function) {
        var result = Function.apply(method, [instance, ...parameters]);
        return result is Function ? Function.apply(result, parameters) : result;
      }
    } else if (callback is Function) {
      var result = Function.apply(callback, parameters);
      return result is Function ? Function.apply(result, parameters) : result;
    }
    return Util.unwrapIfClosure(defaultCallback);
  }

  static dynamic _callClass(Container container, String target,
      List<dynamic> parameters, String? defaultMethod) {
    var segments = target.split('@');

    var className = segments[0];
    var method = segments.length == 2 ? segments[1] : defaultMethod;

    method ??= '__invoke';

    var instance = container.make(className);
    if (instance is String) {
      // If instance is still a string, it might be a global function
      if (container.bound(instance)) {
        return container.make(instance);
      }
      // If it's not bound, treat it as a string value
      return instance;
    }
    if (instance is Function && method == '__invoke') {
      return Function.apply(instance, parameters);
    }
    return _callBoundMethod(container, [instance, method], () {
      throw BindingResolutionException(
          'Failed to call method: $method on $className');
    }, parameters);
  }

  static Function? _findGlobalMethod(String methodName) {
    var currentMirror = currentMirrorSystem();
    for (var library in currentMirror.libraries.values) {
      if (library.declarations.containsKey(Symbol(methodName))) {
        var declaration = library.declarations[Symbol(methodName)]!;
        if (declaration is MethodMirror && declaration.isTopLevel) {
          return library.getField(Symbol(methodName)).reflectee as Function;
        }
      }
    }
    return null;
  }

  static List _getMethodDependencies(Container container, dynamic instance,
      dynamic method, List<dynamic> parameters) {
    var dependencies = <dynamic>[];
    var reflector = _getCallReflector(instance, method);

    if (reflector != null) {
      for (var parameter in reflector.parameters) {
        _addDependencyForCallParameter(
            container, parameter, parameters, dependencies);
      }
    } else if (instance is Map &&
        method is String &&
        instance.containsKey(method)) {
      // If instance is a Map and method is a key, return the value
      return [instance[method]];
    } else {
      // If we couldn't get a reflector, just return the original parameters
      return parameters;
    }

    return dependencies;
  }

  static dynamic _resolveInstance(Container container, dynamic instance) {
    if (instance is String) {
      return container.make(instance);
    }
    return instance;
  }

  static bool _hasInvokeMethod(String className) {
    ClassMirror? classMirror = _getClassMirror(className);
    return classMirror?.declarations[Symbol('__invoke')] != null;
  }

  static String _normalizeMethod(List callback) {
    var className = callback[0] is String
        ? callback[0]
        : MirrorSystem.getName(
            reflectClass(callback[0].runtimeType).simpleName);
    return '$className@${callback[1]}';
  }

  static MethodMirror? _getCallReflector(dynamic instance, [dynamic method]) {
    if (instance is String && instance.contains('::')) {
      var parts = instance.split('::');
      instance = parts[0];
      method = parts[1];
    } else if (instance is! Function && instance is! List && method == null) {
      method = '__invoke';
    }

    if (instance is List && method == null) {
      instance = instance[0];
      method = instance[1];
    }

    if (method != null) {
      var classMirror =
          reflectClass(instance is Type ? instance : instance.runtimeType);
      var methodSymbol = Symbol(method);
      return classMirror.instanceMembers[methodSymbol] ??
          classMirror.staticMembers[methodSymbol];
    } else if (instance is Function) {
      return (reflect(instance) as ClosureMirror).function;
    }

    return null;
  }

  static void _addDependencyForCallParameter(Container container,
      ParameterMirror parameter, List<dynamic> parameters, List dependencies) {
    var pendingDependencies = <dynamic>[];
    var paramName = MirrorSystem.getName(parameter.simpleName);

    if (parameters.any((p) => p is Map && p.containsKey(paramName))) {
      var param =
          parameters.firstWhere((p) => p is Map && p.containsKey(paramName));
      pendingDependencies.add(param[paramName]);
      parameters.remove(param);
    } else if (parameter.type.reflectedType != dynamic) {
      var className = parameter.type.reflectedType.toString();
      if (parameters.any((p) => p is Map && p.containsKey(className))) {
        var param =
            parameters.firstWhere((p) => p is Map && p.containsKey(className));
        pendingDependencies.add(param[className]);
        parameters.remove(param);
      } else if (parameter.isNamed) {
        var variadicDependencies = container.make(className);
        pendingDependencies.addAll(variadicDependencies is List
            ? variadicDependencies
            : [variadicDependencies]);
      } else {
        pendingDependencies.add(container.make(className));
      }
    } else if (parameter.hasDefaultValue) {
      pendingDependencies.add(parameter.defaultValue?.reflectee);
    } else if (!parameter.isOptional &&
        !parameters.any((p) => p is Map && p.containsKey(paramName))) {
      throw Exception(
          "Unable to resolve dependency [$parameter] in class ${parameter.owner?.qualifiedName ?? 'Unknown'}");
    }

    dependencies.addAll(pendingDependencies);
  }

  static bool _isCallableWithAtSign(dynamic callback) {
    return callback is String && callback.contains('@');
  }

  static ClassMirror? _getClassMirror(String className) {
    try {
      return reflectClass(className as Type);
    } catch (_) {
      return null;
    }
  }
}
