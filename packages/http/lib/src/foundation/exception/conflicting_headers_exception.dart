import 'package:protevus_http/foundation_exception.dart';

/// Exception thrown when an HTTP request contains headers with conflicting information.
///
/// This exception is a subclass of [UnexpectedValueException] and implements
/// [RequestExceptionInterface]. It is used to indicate that the headers in an
/// HTTP request contain conflicting or inconsistent information.
///
/// Example usage:
/// ```dart
/// throw ConflictingHeadersException('Content-Type and Content-Encoding headers are incompatible');
/// ```
/// @author Magnus Nordlander <magnus@fervo.se>
class ConflictingHeadersException extends UnexpectedValueException
    implements RequestExceptionInterface {
  /// Creates a new instance of [ConflictingHeadersException].
  ConflictingHeadersException([super.message]);
}
