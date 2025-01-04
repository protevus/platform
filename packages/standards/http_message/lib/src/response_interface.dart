import 'message_interface.dart';

/// Representation of an outgoing, server-side response.
abstract class ResponseInterface implements MessageInterface {
  /// Gets the response status code.
  ///
  /// Returns the status code.
  int getStatusCode();

  /// Return an instance with the specified status code and, optionally, reason phrase.
  ///
  /// [code] The 3-digit integer result code to set.
  /// [reasonPhrase] The reason phrase to use with the
  ///                provided status code; if none is provided, implementations MAY
  ///                use the defaults as suggested in the HTTP specification.
  ///
  /// Returns a new instance with the specified status code and, optionally, reason phrase.
  /// Throws ArgumentError for invalid status code arguments.
  ResponseInterface withStatus(int code, [String? reasonPhrase]);

  /// Gets the response reason phrase associated with the status code.
  ///
  /// Returns the reason phrase; must return an empty string if none present.
  String getReasonPhrase();
}
