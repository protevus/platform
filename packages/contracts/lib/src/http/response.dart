/// Abstract representation of an HTTP response.
///
/// This class serves as a base contract for HTTP responses across the framework.
/// Concrete implementations will provide the actual response handling logic.
abstract class Response {
  /// Get the response status code.
  int get statusCode;

  /// Set the response status code.
  set statusCode(int value);

  /// Get all response headers.
  Map<String, List<String>> get headers;

  /// Get the response body.
  dynamic get body;

  /// Set the response body.
  set body(dynamic value);

  /// Set a response header.
  void header(String name, String value);

  /// Remove a response header.
  void removeHeader(String name);

  /// Set the content type header.
  void contentType(String value);

  /// Get a response header value.
  String? getHeader(String name);

  /// Determine if the response has a given header.
  bool hasHeader(String name);

  /// Set the response content.
  void setContent(dynamic content);

  /// Get the response content.
  dynamic getContent();

  /// Convert the response to bytes.
  List<int> toBytes();

  /// Convert the response to a string.
  @override
  String toString();
}
