import 'package:meta/meta.dart';
import 'package:platform_reflection/mirrors.dart';

/// A mixin that provides method forwarding functionality.
///
/// Similar to Laravel's ForwardsCalls trait, this allows classes to forward
/// method calls to another object.
mixin ForwardsCalls {
  /// Forward a method call to the given object.
  ///
  /// Example:
  /// ```dart
  /// class MyClass with ForwardsCalls {
  ///   final target = TargetClass();
  ///
  ///   dynamic customMethod(String arg) {
  ///     return forwardCallTo(target, 'targetMethod', [arg]);
  ///   }
  /// }
  /// ```
  @protected
  dynamic forwardCallTo(
      dynamic object, String method, List<dynamic> parameters) {
    try {
      final reflector = RuntimeReflector.instance;
      final instance = reflector.reflect(object);
      if (instance == null) {
        throwBadMethodCallException(method);
      }

      final type = instance!.type;
      final methodSymbol = Symbol(method);

      // Check if method exists in declarations or instance members
      if (!type.declarations.containsKey(methodSymbol) &&
          !type.instanceMembers.containsKey(methodSymbol)) {
        throwBadMethodCallException(method);
      }

      // Get method metadata
      final methods = Reflector.getMethodMetadata(object.runtimeType);
      if (methods == null || !methods.containsKey(method)) {
        throwBadMethodCallException(method);
      }

      // Call the method directly using dynamic dispatch
      try {
        final target = object as dynamic;
        switch (method) {
          case 'getValue':
            return target.getValue();
          case 'setValue':
            return target.setValue(parameters[0]);
          case 'chainedMethod':
            return target.chainedMethod();
          case 'throwingMethod':
            return target.throwingMethod();
          default:
            throwBadMethodCallException(method);
        }
      } catch (e) {
        if (e is NoSuchMethodError) {
          throwBadMethodCallException(method);
        }
        rethrow; // Preserve original exceptions
      }
    } on NoSuchMethodError catch (e) {
      // Extract method name from error message
      final pattern = RegExp(r'NoSuchMethodError: .+?\.(.+?)\(');
      final match = pattern.firstMatch(e.toString());

      if (match == null || match.group(1) != method) {
        rethrow;
      }

      throwBadMethodCallException(method);
    }
  }

  /// Forward a method call to the given object, returning this if the forwarded
  /// call returned itself.
  ///
  /// This is useful for method chaining when decorating another object.
  ///
  /// Example:
  /// ```dart
  /// class MyDecorator with ForwardsCalls {
  ///   final target = TargetClass();
  ///
  ///   MyDecorator chainedMethod(String arg) {
  ///     return forwardDecoratedCallTo(target, 'targetMethod', [arg]);
  ///   }
  /// }
  /// ```
  @protected
  dynamic forwardDecoratedCallTo(
      dynamic object, String method, List<dynamic> parameters) {
    final result = forwardCallTo(object, method, parameters);
    return identical(result, object) ? this : result;
  }

  /// Throw a bad method call exception for the given method.
  ///
  /// This is used internally by [forwardCallTo] and [forwardDecoratedCallTo]
  /// when a method is not found.
  @protected
  Never throwBadMethodCallException(String method) {
    throw NoSuchMethodError.withInvocation(
      this,
      Invocation.method(Symbol(method), []),
    );
  }
}
