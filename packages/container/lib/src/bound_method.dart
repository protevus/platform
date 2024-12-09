import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/reflection.dart';

/// Utility for calling methods with dependency injection.
class BoundMethod {
  /// Call the given callback / class@method and inject its dependencies.
  ///
  /// @param container The container instance
  /// @param callback The callback to call
  /// @param parameters Parameters to pass to the callback
  /// @param defaultMethod Default method to call if not specified
  /// @return The result of the callback
  static dynamic call(
    dynamic container,
    dynamic callback, [
    List<dynamic> parameters = const [],
    String? defaultMethod,
  ]) {
    if (callback is String &&
        defaultMethod == null &&
        hasMethod(callback, '__invoke')) {
      defaultMethod = '__invoke';
    }

    if (isCallableWithAtSign(callback) || defaultMethod != null) {
      return callClass(container, callback, parameters, defaultMethod);
    }

    return callBoundMethod(container, callback, () {
      final deps = getMethodDependencies(container, callback, parameters);
      return Function.apply(callback, deps);
    });
  }

  /// Call a string reference to a class using Class@method syntax.
  static dynamic callClass(
    dynamic container,
    String target, [
    List<dynamic> parameters = const [],
    String? defaultMethod,
  ]) {
    final segments = target.split('@');

    // We will assume an @ sign is used to delimit the class name from the method
    // name. We will split on this @ sign and then build a callable array that
    // we can pass right back into the "call" method for dependency binding.
    final method = segments.length == 2 ? segments[1] : defaultMethod;

    if (method == null) {
      throw ArgumentError('Method not provided.');
    }

    return call(
      container,
      [container.make(segments[0]), method],
      parameters,
    );
  }

  /// Call a method that has been bound to the container.
  static dynamic callBoundMethod(
    dynamic container,
    dynamic callback,
    dynamic Function() default_,
  ) {
    if (callback is! List) {
      return unwrapIfClosure(default_);
    }

    // Here we need to turn the array callable into a Class@method string we can use to
    // examine the container and see if there are any method bindings for this given
    // method. If there are we can call this method binding callback immediately.
    final method = normalizeMethod(callback);

    if (container.hasMethodBinding(method)) {
      return container.callMethodBinding(method, callback[0]);
    }

    return unwrapIfClosure(default_);
  }

  /// Normalize the given callback into a Class@method string.
  static String normalizeMethod(List callback) {
    final className = callback[0] is String
        ? callback[0]
        : callback[0].runtimeType.toString();

    return '$className@${callback[1]}';
  }

  /// Get all dependencies for a given method.
  static List<dynamic> getMethodDependencies(
    dynamic container,
    dynamic callback, [
    List<dynamic> parameters = const [],
  ]) {
    final dependencies = <dynamic>[];
    final params = Map<String, dynamic>.fromIterable(
      parameters,
      key: (p) => p.toString(),
      value: (p) => p,
    );

    final method = getCallReflector(callback);

    for (final parameter in method.parameters) {
      addDependencyForCallParameter(
        container,
        parameter,
        params,
        dependencies,
      );
    }

    // Merge dependencies with remaining parameters, maintaining order
    return [...dependencies, ...params.values];
  }

  /// Get the proper reflection instance for the given callback.
  static MethodMirror getCallReflector(dynamic callback) {
    final reflector = RuntimeReflector.instance;

    if (callback is String && callback.contains('::')) {
      callback = callback.split('::');
    } else if (callback is! Function && callback is Object) {
      callback = [callback, '__invoke'];
    }

    if (callback is List) {
      final classMirror = reflector.reflectClass(callback[0].runtimeType);
      return classMirror.declarations[Symbol(callback[1])] as MethodMirror;
    }

    final mirror = reflector.reflect(callback);
    return mirror.type.declarations[Symbol('call')] as MethodMirror;
  }

  /// Add a dependency for the given call parameter.
  static void addDependencyForCallParameter(
    dynamic container,
    ParameterMirror parameter,
    Map<String, dynamic> parameters,
    List<dynamic> dependencies,
  ) {
    final paramName = parameter.simpleName.toString().replaceAll('"', '');
    final type = parameter.type;
    final className = type is ClassMirror
        ? type.simpleName.toString().replaceAll('"', '')
        : null;

    if (parameters.containsKey(paramName)) {
      dependencies.add(parameters[paramName]);
      parameters.remove(paramName);
    } else if (className != null) {
      if (parameters.containsKey(className)) {
        dependencies.add(parameters[className]);
        parameters.remove(className);
      } else if (type is ClassMirror && type.reflectedType == List) {
        // Handle variadic parameters (represented as List in Dart)
        final variadicDependencies = container.make(className);
        if (variadicDependencies is List) {
          dependencies.addAll(variadicDependencies);
        } else {
          dependencies.add(variadicDependencies);
        }
      } else {
        dependencies.add(container.make(className));
      }
    } else if (parameter.hasDefaultValue) {
      dependencies.add((parameter as dynamic).defaultValue?.reflectee);
    } else if (!parameter.isOptional && !parameters.containsKey(paramName)) {
      final declaringClass = parameter.owner is ClassMirror
          ? (parameter.owner as ClassMirror)
              .simpleName
              .toString()
              .replaceAll('"', '')
          : 'unknown';
      throw BindingResolutionException(
        'Unable to resolve dependency [${parameter.type.reflectedType} \$${parameter.simpleName}] in class $declaringClass',
      );
    }
  }

  /// Determine if the given string is in Class@method syntax.
  static bool isCallableWithAtSign(dynamic callback) {
    return callback is String && callback.contains('@');
  }

  /// Check if an object has a specific method.
  static bool hasMethod(dynamic object, String method) {
    try {
      final reflector = RuntimeReflector.instance;
      final mirror = reflector.reflectClass(object.runtimeType);
      return mirror.declarations[Symbol(method)] is MethodMirror;
    } catch (_) {
      return false;
    }
  }

  /// Unwrap a closure if needed.
  static dynamic unwrapIfClosure(dynamic value) {
    return value is Function ? value() : value;
  }
}
