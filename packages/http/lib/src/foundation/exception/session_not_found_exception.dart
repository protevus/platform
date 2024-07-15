import 'package:protevus_http/foundation_exception.dart';
import 'package:protevus_mime/mime_exception.dart';

/// Raised when a session does not exist. This happens in the following cases:
/// - the session is not enabled
/// - attempt to read a session outside a request context (i.e., CLI script).
class SessionNotFoundException extends LogicException
    implements RequestExceptionInterface {
  /// Creates a new [SessionNotFoundException] with the given [message], [code], and [previous] exception.
  SessionNotFoundException({
    String message = 'There is currently no session available.',
    int code = 0,
    Exception? previous,
  }) : super(message, code, previous);
}
