import 'package:platform_macroable/platform_macroable.dart';
import 'package:platform_mirrors/mirrors.dart';

/// Provides higher-order tap functionality with macro support.
///
/// This class enables method chaining while allowing side effects,
/// similar to Laravel's HigherOrderTapProxy.
class HigherOrderTapProxy<T extends Object> with Macroable {
  final T _target;
  final RuntimeReflector _reflector;

  /// Creates a new higher-order tap proxy instance.
  ///
  /// Example:
  /// ```dart
  /// final proxy = HigherOrderTapProxy(someObject)
  ///   ..someMethod() // Calls method on target
  ///   ..anotherMethod(); // Method chaining
  /// ```
  HigherOrderTapProxy(this._target) : _reflector = RuntimeReflector.instance;

  /// Gets the target object.
  T get target => _target;

  /// Invokes method on target and returns self for chaining.
  ///
  /// This allows calling methods on the target object while maintaining
  /// the fluent interface pattern.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // First try to handle as a macro
    try {
      return super.noSuchMethod(invocation);
    } catch (_) {
      // If not a macro, forward to target
      final methods = ReflectionRegistry.getMethodMetadata(_target.runtimeType);
      if (methods == null) {
        throw NoSuchMethodError.withInvocation(_target, invocation);
      }

      final methodName = _symbolToString(invocation.memberName);
      if (!methods.containsKey(methodName)) {
        throw NoSuchMethodError.withInvocation(_target, invocation);
      }

      // Get method metadata
      final method = methods[methodName]!;

      // Forward invocation to target
      try {
        final result = Function.apply(
          (_target as dynamic).noSuchMethod,
          [invocation],
        );

        // If method returns target or void, return proxy for chaining
        if (identical(result, _target) || method.returnsVoid) {
          return this;
        }

        // Otherwise return actual result
        return result;
      } catch (e) {
        if (e is NoSuchMethodError) {
          throw NoSuchMethodError.withInvocation(_target, invocation);
        }
        rethrow;
      }
    }
  }

  /// Converts a Symbol to its string name.
  String _symbolToString(Symbol symbol) {
    final str = symbol.toString();
    return str.substring(8, str.length - 2); // Remove "Symbol(" and ")"
  }

  @override
  String toString() => 'HigherOrderTapProxy($_target)';
}
