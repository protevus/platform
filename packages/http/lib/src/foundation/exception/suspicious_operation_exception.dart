import 'package:protevus_http/foundation_exception.dart';

/// Exception thrown when a suspicious operation is detected during an HTTP request.
///
/// This exception is a subclass of [UnexpectedValueException] and implements
/// [RequestExceptionInterface]. It is used to indicate that a potentially
/// unsafe or unexpected operation has been attempted or detected during
/// the processing of an HTTP request.
///
/// Example usage:
/// ```dart
/// throw SuspiciousOperationException('Attempted to access restricted resource');
/// ```
/// @author Magnus Nordlander <magnus@fervo.se>
class SuspiciousOperationException extends UnexpectedValueException
    implements RequestExceptionInterface {
  /// Creates a new instance of [ConflictingHeadersException].
  SuspiciousOperationException([super.message]);
}
