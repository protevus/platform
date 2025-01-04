import 'message_interface.dart';
import 'uri_interface.dart';

/// Representation of an outgoing, client-side request.
abstract class RequestInterface implements MessageInterface {
  /// Retrieves the message's request target.
  ///
  /// Returns the message's request target.
  String getRequestTarget();

  /// Return an instance with the specific request-target.
  ///
  /// [requestTarget] The request target.
  ///
  /// Returns a new instance with the specified request target.
  RequestInterface withRequestTarget(String requestTarget);

  /// Retrieves the HTTP method of the request.
  ///
  /// Returns the HTTP method.
  String getMethod();

  /// Return an instance with the provided HTTP method.
  ///
  /// [method] Case-sensitive method.
  ///
  /// Returns a new instance with the specified method.
  RequestInterface withMethod(String method);

  /// Retrieves the URI instance.
  ///
  /// Returns a UriInterface instance representing the URI of the request.
  UriInterface getUri();

  /// Returns an instance with the provided URI.
  ///
  /// [uri] New request URI.
  /// [preserveHost] Preserve the original state of the Host header.
  ///
  /// Returns a new instance with the specified URI.
  RequestInterface withUri(UriInterface uri, [bool preserveHost = false]);
}

/// Representation of an incoming, server-side HTTP request.
///
/// Per the HTTP specification, this interface includes properties for
/// each of the following:
/// - Protocol version
/// - HTTP method
/// - URI
/// - Headers
/// - Message body
///
/// Additionally, it encapsulates all data as it has arrived to the
/// application from the CGI and/or PHP environment, including:
/// - The values represented in $_SERVER.
/// - Any cookies provided (generally via $_COOKIE)
/// - Query string arguments (generally via $_GET, or as parsed via parse_str())
/// - Upload files, if any (as represented by $_FILES)
/// - Deserialized body parameters (generally from $_POST)
abstract class ServerRequestInterface implements RequestInterface {
  /// Retrieve server parameters.
  ///
  /// Returns a map of server parameters.
  Map<String, String> getServerParams();

  /// Retrieve cookies.
  ///
  /// Returns a map of cookie name/value pairs.
  Map<String, String> getCookieParams();

  /// Return an instance with the specified cookies.
  ///
  /// [cookies] The map of cookie name/value pairs.
  ///
  /// Returns a new instance with the specified cookies.
  ServerRequestInterface withCookieParams(Map<String, String> cookies);

  /// Retrieve query string arguments.
  ///
  /// Returns a map of query string arguments.
  Map<String, dynamic> getQueryParams();

  /// Return an instance with the specified query string arguments.
  ///
  /// [query] The map of query string arguments.
  ///
  /// Returns a new instance with the specified query string arguments.
  ServerRequestInterface withQueryParams(Map<String, dynamic> query);

  /// Retrieve normalized file upload data.
  ///
  /// Returns a normalized tree of file upload data.
  Map<String, dynamic> getUploadedFiles();

  /// Create a new instance with the specified uploaded files.
  ///
  /// [uploadedFiles] A normalized tree of uploaded file data.
  ///
  /// Returns a new instance with the specified uploaded files.
  ServerRequestInterface withUploadedFiles(Map<String, dynamic> uploadedFiles);

  /// Retrieve any parameters provided in the request body.
  ///
  /// Returns the deserialized body parameters, if any.
  dynamic getParsedBody();

  /// Return an instance with the specified body parameters.
  ///
  /// [data] The deserialized body data.
  ///
  /// Returns a new instance with the specified body parameters.
  ServerRequestInterface withParsedBody(dynamic data);

  /// Retrieve attributes derived from the request.
  ///
  /// Returns a map of attributes.
  Map<String, dynamic> getAttributes();

  /// Retrieve a single derived request attribute.
  ///
  /// [name] The attribute name.
  /// [defaultValue] Default value to return if the attribute does not exist.
  ///
  /// Returns the attribute value or default value.
  dynamic getAttribute(String name, [dynamic defaultValue]);

  /// Return an instance with the specified derived request attribute.
  ///
  /// [name] The attribute name.
  /// [value] The value of the attribute.
  ///
  /// Returns a new instance with the specified attribute.
  ServerRequestInterface withAttribute(String name, dynamic value);

  /// Return an instance without the specified derived request attribute.
  ///
  /// [name] The attribute name.
  ///
  /// Returns a new instance without the specified attribute.
  ServerRequestInterface withoutAttribute(String name);
}
