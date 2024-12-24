import 'dart:mirrors';
import 'package:ioc_container/src/container.dart';
import 'package:ioc_container/src/util.dart';

class BoundMethod {
  static dynamic call(Container container, dynamic callback,
      [List<dynamic> parameters = const [], String? defaultMethod]) {
    if (callback is String &&
        defaultMethod == null &&
        _hasInvokeMethod(callback)) {
      defaultMethod = '__invoke';
    }

    if (_isCallableWithAtSign(callback) || defaultMethod != null) {
      return _callClass(container, callback, parameters, defaultMethod);
    }

    return _callBoundMethod(container, callback, () {
      var dependencies =
          _getMethodDependencies(container, callback, parameters);
      return Function.apply(callback, dependencies);
    });
  }

  static bool _hasInvokeMethod(String className) {
    ClassMirror? classMirror = _getClassMirror(className);
    return classMirror?.declarations[Symbol('__invoke')] != null;
  }

  static dynamic _callClass(Container container, String target,
      List<dynamic> parameters, String? defaultMethod) {
    var segments = target.split('@');

    var method = segments.length == 2 ? segments[1] : defaultMethod;

    if (method == null) {
      throw ArgumentError('Method not provided.');
    }

    var instance = container.make(segments[0]);
    return call(container, [instance, method], parameters);
  }

  static dynamic _callBoundMethod(
      Container container, dynamic callback, Function defaultCallback) {
    if (callback is! List) {
      return Util.unwrapIfClosure(defaultCallback);
    }

    var method = _normalizeMethod(callback);

    // Note: We need to add these methods to the Container class
    if (container.hasMethodBinding(method)) {
      return container.callMethodBinding(method, callback[0]);
    }

    return Util.unwrapIfClosure(defaultCallback);
  }

  static String _normalizeMethod(List callback) {
    var className = callback[0] is String
        ? callback[0]
        : MirrorSystem.getName(
            reflectClass(callback[0].runtimeType).simpleName);
    return '$className@${callback[1]}';
  }

  static List _getMethodDependencies(
      Container container, dynamic callback, List<dynamic> parameters) {
    var dependencies = <dynamic>[];
    var reflector = _getCallReflector(callback);

    for (var parameter in reflector.parameters) {
      _addDependencyForCallParameter(
          container, parameter, parameters, dependencies);
    }

    return [...dependencies, ...parameters];
  }

  static MethodMirror _getCallReflector(dynamic callback) {
    if (callback is String && callback.contains('::')) {
      callback = callback.split('::');
    } else if (callback is! Function && callback is! List) {
      callback = [callback, '__invoke'];
    }

    if (callback is List) {
      return (reflectClass(callback[0].runtimeType)
          .declarations[Symbol(callback[1])] as MethodMirror);
    } else {
      return (reflect(callback) as ClosureMirror).function;
    }
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
