import 'package:meta/meta.dart';

/// A mixin that provides conditional execution with a fluent interface.
///
/// This mixin allows for conditional method chaining similar to Laravel's
/// Conditionable trait.
mixin Conditionable {
  /// Executes the callback if the given value is truthy.
  ///
  /// The value can be either a direct value or a closure that returns a value.
  /// If a callback is provided and the condition is true, it will be executed
  /// with the current instance and value as parameters.
  ///
  /// ```dart
  /// instance.when(condition, (self, value) {
  ///   // Execute when condition is true
  /// });
  /// ```
  dynamic when(
    dynamic value,
    dynamic Function(dynamic self, dynamic value)? callback, {
    dynamic Function(dynamic self, dynamic value)? orElse,
  }) {
    // Evaluate the condition
    final condition = value is Function ? value() : value;

    if (condition == true) {
      // Execute callback if condition is true
      return callback?.call(this, condition) ?? this;
    } else if (orElse != null) {
      // Execute orElse callback if provided
      return orElse(this, condition);
    }

    return this;
  }

  /// Executes the callback if the given value is falsy.
  ///
  /// The value can be either a direct value or a closure that returns a value.
  /// If a callback is provided and the condition is false, it will be executed
  /// with the current instance and value as parameters.
  ///
  /// ```dart
  /// instance.unless(condition, (self, value) {
  ///   // Execute when condition is false
  /// });
  /// ```
  dynamic unless(
    dynamic value,
    dynamic Function(dynamic self, dynamic value)? callback, {
    dynamic Function(dynamic self, dynamic value)? orElse,
  }) {
    // Evaluate the condition
    final condition = value is Function ? value() : value;

    if (condition != true) {
      // Execute callback if condition is false
      return callback?.call(this, condition) ?? this;
    } else if (orElse != null) {
      // Execute orElse callback if provided
      return orElse(this, condition);
    }

    return this;
  }

  /// Creates a conditional chain that can be used with method cascades.
  ///
  /// ```dart
  /// instance
  ///   ..whenThen(condition, () {
  ///     // Execute when condition is true
  ///   })
  ///   ..unlessThen(otherCondition, () {
  ///     // Execute when otherCondition is false
  ///   });
  /// ```
  @useResult
  void whenThen(
    dynamic value,
    void Function() callback, {
    void Function()? orElse,
  }) {
    final condition = value is Function ? value() : value;

    if (condition == true) {
      callback();
    } else if (orElse != null) {
      orElse();
    }
  }

  /// Creates a negative conditional chain that can be used with method cascades.
  ///
  /// ```dart
  /// instance
  ///   ..unlessThen(condition, () {
  ///     // Execute when condition is false
  ///   })
  ///   ..whenThen(otherCondition, () {
  ///     // Execute when otherCondition is true
  ///   });
  /// ```
  @useResult
  void unlessThen(
    dynamic value,
    void Function() callback, {
    void Function()? orElse,
  }) {
    final condition = value is Function ? value() : value;

    if (condition != true) {
      callback();
    } else if (orElse != null) {
      orElse();
    }
  }
}
