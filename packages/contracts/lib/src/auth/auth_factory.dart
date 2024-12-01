import 'guard.dart';
import 'stateful_guard.dart';

/// Interface for creating authentication guard instances.
///
/// This contract defines how authentication guards should be created and managed.
/// It provides methods for getting guard instances and setting the default guard.
abstract class AuthFactory {
  /// Get a guard instance by name.
  ///
  /// Example:
  /// ```dart
  /// // Get the default guard
  /// var guard = factory.guard();
  ///
  /// // Get a specific guard
  /// var apiGuard = factory.guard('api');
  /// ```
  dynamic guard([String? name]);

  /// Set the default guard the factory should serve.
  ///
  /// Example:
  /// ```dart
  /// factory.shouldUse('web');
  /// ```
  void shouldUse(String name);
}
