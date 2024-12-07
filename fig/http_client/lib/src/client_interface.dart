import 'exceptions.dart';

/// Interface for sending HTTP requests.
///
/// Implementations MUST NOT take HTTP method, URI, headers, or body as parameters.
/// Instead, they MUST take a single Request object implementing PSR-7's RequestInterface.
abstract class ClientInterface {
  /// Sends a PSR-7 request and returns a PSR-7 response.
  ///
  /// [request] The request object implementing PSR-7's RequestInterface.
  ///
  /// Returns a response object implementing PSR-7's ResponseInterface.
  ///
  /// Throws [ClientExceptionInterface] If an error happens while processing the request.
  /// Throws [NetworkExceptionInterface] If the request cannot be sent due to a network error.
  /// Throws [RequestExceptionInterface] If the request is not a well-formed HTTP request or cannot be sent.
  dynamic sendRequest(dynamic request);

  /// Sends multiple PSR-7 requests concurrently.
  ///
  /// [requests] An iterable of request objects implementing PSR-7's RequestInterface.
  ///
  /// Returns a map of responses where the key is the request and the value is either:
  /// - A response object implementing PSR-7's ResponseInterface
  /// - A ClientExceptionInterface if the request failed
  ///
  /// This method is optional and implementations may throw
  /// [UnsupportedError] if they don't support concurrent requests.
  Map<dynamic, dynamic> sendConcurrentRequests(Iterable<dynamic> requests) {
    throw UnsupportedError(
        'Concurrent requests are not supported by this client');
  }
}
