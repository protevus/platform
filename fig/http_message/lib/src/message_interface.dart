import 'stream_interface.dart';

/// Base HTTP message interface.
///
/// This interface represents both HTTP requests and responses, providing
/// the methods that are common to both types of messages.
abstract class MessageInterface {
  /// Retrieves the HTTP protocol version as a string.
  ///
  /// Returns the HTTP protocol version (e.g., "1.0", "1.1", "2.0").
  String getProtocolVersion();

  /// Return an instance with the specified HTTP protocol version.
  ///
  /// [version] HTTP protocol version.
  ///
  /// Returns a new instance with the specified version.
  MessageInterface withProtocolVersion(String version);

  /// Retrieves all message header values.
  ///
  /// Returns an associative array of header names to their values.
  Map<String, List<String>> getHeaders();

  /// Checks if a header exists by the given case-insensitive name.
  ///
  /// [name] Case-insensitive header field name.
  ///
  /// Returns true if any header names match the given name using a
  /// case-insensitive string comparison. Returns false otherwise.
  bool hasHeader(String name);

  /// Retrieves a message header value by the given case-insensitive name.
  ///
  /// [name] Case-insensitive header field name.
  ///
  /// Returns a list of string values as provided for the header.
  /// Returns an empty list if the header does not exist.
  List<String> getHeader(String name);

  /// Return an instance with the provided value replacing the specified header.
  ///
  /// [name] Case-insensitive header field name.
  /// [value] Header value(s).
  ///
  /// Returns a new instance with the specified header.
  MessageInterface withHeader(String name, dynamic value);

  /// Return an instance with the specified header appended with the given value.
  ///
  /// [name] Case-insensitive header field name.
  /// [value] Header value(s).
  ///
  /// Returns a new instance with the appended header values.
  MessageInterface withAddedHeader(String name, dynamic value);

  /// Return an instance without the specified header.
  ///
  /// [name] Case-insensitive header field name.
  ///
  /// Returns a new instance without the specified header.
  MessageInterface withoutHeader(String name);

  /// Gets the body of the message.
  ///
  /// Returns the body as a stream.
  StreamInterface getBody();

  /// Return an instance with the specified message body.
  ///
  /// [body] The new message body.
  ///
  /// Returns a new instance with the specified body.
  MessageInterface withBody(StreamInterface body);
}
