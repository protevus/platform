/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony BadRequestException.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_http/foundation_exception.dart';

/// Exception thrown when a user sends a malformed request.
///
/// This exception is used to indicate that the client's request was invalid or
/// could not be served. It extends [UnexpectedValueException] and implements
/// [RequestExceptionInterface].
///
/// Example usage:
/// ```dart
/// throw BadRequestException('Invalid parameter: id must be a positive integer');
/// ```
class BadRequestException extends UnexpectedValueException implements RequestExceptionInterface {
  /// Creates a new [BadRequestException] with an optional error message.
  ///
  /// The [message] parameter is passed to the superclass constructor.
  /// If not provided, the exception will be created with an empty message.
  ///
  /// Example:
  /// ```dart
  /// throw BadRequestException('Invalid input');
  /// ```
  BadRequestException([super.message]);

  /// Returns a string representation of the [BadRequestException].
  ///
  /// If the exception message is empty, it returns 'BadRequestException'.
  /// Otherwise, it returns 'BadRequestException: ' followed by the exception message.
  ///
  /// Example:
  /// ```dart
  /// var exception = BadRequestException('Invalid input');
  /// print(exception.toString()); // Output: BadRequestException: Invalid input
  /// ```
  @override
  String toString() {
    return message.isEmpty ? 'BadRequestException' : 'BadRequestException: $message';
  }
}

