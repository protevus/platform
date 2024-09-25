/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// A custom exception class for reflection-related errors.
///
/// This class extends the base [Exception] class and provides a way to
/// create exceptions specific to reflection operations. It includes a
/// message that describes the nature of the exception.
///
/// Example usage:
/// ```dart
/// throw ReflectionException('Failed to reflect on class XYZ');
/// ```
class ReflectionException implements Exception {
  /// Creates a new instance of [ReflectionException] with the specified message.
  ///
  /// The [message] parameter should describe the nature of the reflection error.
  final String message;

  /// Creates a new instance of [ReflectionException] with the specified message.
  ///
  /// The [message] parameter should describe the nature of the reflection error.
  ReflectionException(this.message);

  // Override the toString method to provide a custom string representation of the exception.
  @override
  String toString() => message;
}
