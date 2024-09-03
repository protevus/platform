/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:core' as core;
import 'dart:core' hide Map, String, int;

/// Represents an exception thrown when a cast operation fails.
///
/// This class is used to provide detailed information about the context
/// and reason for a failed cast operation.
///
/// [context] represents the location or scope where the cast failed.
/// [key] is an optional identifier for the specific element that failed to cast.
/// [message] provides additional details about the failure.
class FailedCast implements core.Exception {
  dynamic context;
  dynamic key;
  core.String message;
  FailedCast(this.context, this.key, this.message);
  @override
  core.String toString() {
    if (key == null) {
      return "Failed cast at $context: $message";
    }
    return "Failed cast at $context $key: $message";
  }
}

/// An abstract class representing a type cast operation.
///
/// This class defines the structure for implementing type casting
/// from dynamic types to a specific type T.
///
/// The [cast] method is the public API for performing the cast,
/// while [safeCast] is the internal implementation that can be
/// overridden by subclasses to define specific casting behavior.
///
/// Usage:
/// ```dart
/// class MyCustomCast extends Cast<MyType> {
///   @override
///   MyType _cast(dynamic from, String context, dynamic key) {
///     // Custom casting logic here
///   }
/// }
/// ```
abstract class Cast<T> {
  /// Constructs a new [Cast] instance.
  ///
  /// This constructor is declared as `const` to allow for compile-time
  /// constant instances of [Cast] subclasses. This can be beneficial for
  /// performance and memory usage in certain scenarios.
  const Cast();

  /// Performs a safe cast operation from a dynamic type to type T.
  ///
  /// This method wraps the [safeCast] method with additional error handling:
  /// - If a [FailedCast] exception is thrown, it's rethrown as-is.
  /// - For any other exception, it's caught and wrapped in a new [FailedCast] exception.
  ///
  /// Parameters:
  ///   [from]: The value to be cast.
  ///   [context]: A string describing the context where the cast is performed.
  ///   [key]: An optional identifier for the specific element being cast.
  ///
  /// Returns:
  ///   The cast value of type T.
  ///
  /// Throws:
  ///   [FailedCast]: If the cast fails, either from [safeCast] or from wrapping another exception.
  T _safeCast(dynamic from, core.String context, dynamic key) {
    try {
      return safeCast(from, context, key);
    } on FailedCast {
      rethrow;
    } catch (e) {
      throw FailedCast(context, key, e.toString());
    }
  }

  /// Performs a safe cast operation from a dynamic type to type T.
  ///
  /// This method is a convenience wrapper around [_safeCast] that provides
  /// a default context of "toplevel" and a null key.
  ///
  /// Parameters:
  ///   [from]: The value to be cast.
  ///
  /// Returns:
  ///   The cast value of type T.
  ///
  /// Throws:
  ///   [FailedCast]: If the cast operation fails.
  T cast(dynamic from) => _safeCast(from, "toplevel", null);

  /// Performs a safe cast operation from a dynamic type to type T.
  ///
  /// This method should be implemented by subclasses to define the specific
  /// casting behavior for the type T.
  ///
  /// Parameters:
  ///   [from]: The value to be cast.
  ///   [context]: A string describing the context where the cast is performed.
  ///   [key]: An optional identifier for the specific element being cast.
  ///
  /// Returns:
  ///   The cast value of type T.
  ///
  /// Throws:
  ///   [FailedCast]: If the cast operation fails.
  T safeCast(dynamic from, core.String context, dynamic key);
}
