/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Exception thrown when type coercion fails.
///
/// This exception is used to indicate that an attempt to convert a value
/// from one type to another has failed. It provides information about
/// the expected type and the actual type of the value.
class TypeCoercionException implements Exception {
  /// Creates a new [TypeCoercionException].
  ///
  /// [expectedType] is the type that was expected for the conversion.
  /// [actualType] is the actual type of the value that couldn't be converted.
  ///
  /// Example:
  /// ```dart
  /// throw TypeCoercionException(String, int);
  /// ```
  TypeCoercionException(this.expectedType, this.actualType);

  /// The type that was expected for the conversion.
  final Type expectedType;

  /// The actual type of the value that couldn't be converted.
  final Type actualType;

  @override

  /// Returns a string representation of the exception.
  ///
  /// The returned string includes both the expected type and the actual type
  /// to provide clear information about the nature of the coercion failure.
  ///
  /// Returns:
  ///   A string describing the type coercion exception.
  String toString() {
    return "input is not expected type '$expectedType' (input is '$actualType')";
  }
}
