import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/mirrors.dart';

/// A utility class for calling methods with dependency injection.
class BoundMethod {
  /// Call the given Closure / class@method and inject its dependencies.
  static dynamic call(ContainerContract container, dynamic callback,
      [List<dynamic> parameters = const []]) {
    if (callback is Function) {
      return callBoundMethod(container, callback, parameters);
    }

    return callClass(container, callback, parameters);
  }

  /// Call a string reference to a class@method with dependencies.
  static dynamic callClass(ContainerContract container, dynamic target,
      [List<dynamic> parameters = const []]) {
    target = normalizeMethod(target);

    // If the target is a string, we will assume it is a class name and attempt to resolve it
    if (target is String) {
      target = container.make(target);
    }

    return callBoundMethod(container, target[0], parameters,
        methodName: target[1]);
  }

  /// Call a method that has been bound in the container.
  static dynamic callBoundMethod(
      ContainerContract container, dynamic target, List<dynamic> parameters,
      {String? methodName}) {
    var callable = methodName != null ? [target, methodName] : target;

    var dependencies = getMethodDependencies(container, callable, parameters);

    var reflector = getCallReflector(callable);
    if (reflector is Function) {
      return Function.apply(reflector, dependencies);
    } else if (reflector is InstanceMirrorContract && callable is List) {
      return reflector.invoke(Symbol(callable[1]), dependencies).reflectee;
    }

    throw Exception('Unable to call the bound method');
  }

  /// Normalize the given callback or string into a Class@method String.
  static dynamic normalizeMethod(dynamic method) {
    if (method is String && isCallableWithAtSign(method)) {
      var parts = method.split('@');
      return parts.length > 1 ? parts : [parts[0], '__invoke'];
    }

    return method is String ? [method, '__invoke'] : method;
  }

  /// Get all dependencies for a given method.
  static List<dynamic> getMethodDependencies(
      ContainerContract container, dynamic callable, List<dynamic> parameters) {
    var dependencies = [];

    var reflector = getCallReflector(callable);
    MethodMirrorContract? methodMirror;

    if (reflector is InstanceMirrorContract && callable is List) {
      methodMirror = reflector.type.instanceMembers[Symbol(callable[1])];
    } else if (reflector is MethodMirrorContract) {
      methodMirror = reflector;
    }

    methodMirror?.parameters.forEach((parameter) {
      dependencies
          .add(addDependencyForCallParameter(container, parameter, parameters));
    });

    return dependencies;
  }

  /// Get the proper reflection instance for the given callback.
  static dynamic getCallReflector(dynamic callable) {
    if (callable is List) {
      return reflect(callable[0]);
    }

    return reflectClass(callable.runtimeType).declarations[Symbol('call')];
  }

  /// Get the dependency for the given call parameter.
  static dynamic addDependencyForCallParameter(ContainerContract container,
      ParameterMirrorContract parameter, List<dynamic> parameters) {
    if (parameters.isNotEmpty) {
      return parameters.removeAt(0);
    }

    if (parameter.isOptional && !parameter.hasDefaultValue) {
      return null;
    }

    return container.make(parameter.type.reflectedType.toString());
  }

  /// Determine if the given string is in Class@method syntax.
  static bool isCallableWithAtSign(String value) {
    return value.contains('@');
  }
}
