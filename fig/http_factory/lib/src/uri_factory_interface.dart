/// Factory interface for creating PSR-7 Uri instances.
abstract class UriFactoryInterface {
  /// Creates a new PSR-7 Uri instance.
  ///
  /// [uri] The URI to parse.
  ///
  /// Returns a new PSR-7 Uri instance.
  /// Implementations MUST support URIs as specified in RFC 3986.
  ///
  /// If the [uri] string is malformed, implementations MUST throw
  /// an exception that implements Throwable.
  dynamic createUri(String uri);
}
