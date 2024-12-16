/// Factory interface for creating PSR-7 Request instances.
abstract class RequestFactoryInterface {
  /// Creates a new PSR-7 Request instance.
  ///
  /// [method] The HTTP method associated with the request.
  /// [uri] The URI associated with the request, as a string or UriInterface.
  ///
  /// Returns a new PSR-7 Request instance.
  dynamic createRequest(String method, dynamic uri);
}

/// Factory interface for creating PSR-7 ServerRequest instances.
abstract class ServerRequestFactoryInterface {
  /// Creates a new PSR-7 ServerRequest instance.
  ///
  /// [method] The HTTP method associated with the request.
  /// [uri] The URI associated with the request, as a string or UriInterface.
  /// [serverParams] Array of SAPI parameters.
  ///
  /// Returns a new PSR-7 ServerRequest instance.
  dynamic createServerRequest(
    String method,
    dynamic uri, [
    Map<String, dynamic> serverParams = const {},
  ]);
}

/// Factory interface for creating PSR-7 Response instances.
abstract class ResponseFactoryInterface {
  /// Creates a new PSR-7 Response instance.
  ///
  /// [code] The HTTP status code. The value MUST be between 100 and 599.
  /// [reasonPhrase] The reason phrase to associate with the status code.
  ///                If none is provided, implementations MAY use the defaults.
  ///
  /// Returns a new PSR-7 Response instance.
  dynamic createResponse([int code = 200, String? reasonPhrase]);
}
