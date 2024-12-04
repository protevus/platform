import 'package:platform_macroable/platform_macroable.dart';
import 'package:platform_reflection/reflection.dart';

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
      final mirror = _reflector.reflect(_target) as InstanceMirror;

      // Get method declarations
      final methods = mirror.type.declarations.values
          .whereType<MethodMirror>()
          .where((m) => m.simpleName == invocation.memberName);

      if (methods.isNotEmpty) {
        // Found matching method, invoke it
        mirror.invoke(
          invocation.memberName,
          invocation.positionalArguments,
          invocation.namedArguments,
        );
        return this;
      }

      // If we get here, method wasn't found
      throw NoSuchMethodError.withInvocation(_target, invocation);
    }
  }

  @override
  String toString() => 'HigherOrderTapProxy($_target)';
}
