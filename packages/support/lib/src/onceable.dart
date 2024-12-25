import 'once.dart';
import 'package:platform_mirrors/mirrors.dart';

/// A class that provides functionality to ensure methods are only executed once.
///
/// This class allows caching method results and ensuring they are only
/// executed once, similar to Laravel's once functionality.
class Onceable {
  /// Cache for once instances.
  final Map<String, Once> _once = {};

  /// Execute a callback only once and return the result.
  ///
  /// Example:
  /// ```dart
  /// final onceable = Onceable();
  /// final result = onceable.once('operation', () {
  ///   // This will only execute once
  ///   return computeExpensiveResult();
  /// });
  /// ```
  T once<T>(String key, T Function() callback) {
    // Create or get Once instance
    _once[key] ??= Once();

    // If not executed yet, register the callback type
    if (!_once[key]!.executed &&
        !ReflectionRegistry.isReflectable(callback.runtimeType)) {
      ReflectionRegistry.register(callback.runtimeType);
      ReflectionRegistry.registerMethod(
        callback.runtimeType,
        'call',
        const <Type>[],
        T == Null,
        parameterNames: const <String>[],
        isRequired: const <bool>[],
        isNamed: const <bool>[],
      );
    }

    // Execute with caching
    return _once[key]!.call(callback);
  }

  /// Reset the execution state for a specific key.
  ///
  /// Example:
  /// ```dart
  /// final onceable = Onceable();
  /// onceable.resetOnce('operation');
  /// ```
  void resetOnce(String key) {
    _once[key]?.reset();
  }

  /// Reset all execution states.
  ///
  /// Example:
  /// ```dart
  /// final onceable = Onceable();
  /// onceable.resetAllOnce();
  /// ```
  void resetAllOnce() {
    _once.clear();
  }

  /// Check if a callback has been executed.
  ///
  /// Example:
  /// ```dart
  /// final onceable = Onceable();
  /// final executed = onceable.hasExecutedOnce('operation');
  /// ```
  bool hasExecutedOnce(String key) {
    return _once[key]?.executed ?? false;
  }

  /// Get all registered once keys.
  ///
  /// Example:
  /// ```dart
  /// final onceable = Onceable();
  /// final keys = onceable.keys;
  /// ```
  Set<String> get keys => _once.keys.toSet();

  /// Get the number of registered once instances.
  ///
  /// Example:
  /// ```dart
  /// final onceable = Onceable();
  /// final count = onceable.count;
  /// ```
  int get count => _once.length;
}
