/// Abstract representation of an HTTP request.
///
/// This class serves as a base contract for HTTP requests across the framework.
/// Concrete implementations will provide the actual request handling logic.
abstract class Request {
  /// Get the request method.
  String get method;

  /// Get the request URI.
  Uri get uri;

  /// Get all request headers.
  Map<String, List<String>> get headers;

  /// Get the request body.
  dynamic get body;

  /// Get a request header value.
  String? header(String name);

  /// Get a query parameter value.
  String? query(String name);

  /// Get all query parameters.
  Map<String, String> get queryParameters;

  /// Determine if the request is AJAX.
  bool get isAjax;

  /// Determine if the request expects JSON.
  bool get expectsJson;
}
