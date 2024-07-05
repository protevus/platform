/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony UnexpectedValueException.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:core';

/// Exception thrown if a value does not match with a set of values.
///
/// Typically this happens when a function calls another function and expects
/// the return value to be of a certain type or value not including arithmetic
/// or buffer related errors.
class UnexpectedValueException implements Exception {
  /// The error message associated with this exception.
  ///
  /// This is a final String that stores the descriptive message for the
  /// UnexpectedValueException. It provides details about why the exception
  /// was thrown and can be used for logging or displaying error information.
  final String message;

  /// Constructor for UnexpectedValueException.
  ///
  /// Creates a new instance of UnexpectedValueException with an optional error message.
  ///
  /// @param message The error message for this exception. Defaults to an empty string.
  UnexpectedValueException([this.message = '']);

  /// Returns a string representation of the UnexpectedValueException.
  ///
  /// This method overrides the default toString() method to provide a more
  /// descriptive string representation of the exception. If the exception
  /// message is empty, it returns just the exception name. Otherwise, it
  /// returns the exception name followed by a colon and the error message.
  ///
  /// @return A string representation of the UnexpectedValueException.
  @override
  String toString() => message.isEmpty ? 'UnexpectedValueException' : 'UnexpectedValueException: $message';
}
