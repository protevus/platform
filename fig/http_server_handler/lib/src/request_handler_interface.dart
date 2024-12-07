import 'package:dsr_http_message/http_message.dart';

/// Interface for request handlers.
///
/// A request handler processes an HTTP request and produces an HTTP response.
/// This interface defines the methods required to use the request handler.
abstract class RequestHandlerInterface {
  /// Handles a request and produces a response.
  ///
  /// [request] The server request object.
  ///
  /// Returns a response implementing ResponseInterface.
  /// May throw any throwable as needed.
  ResponseInterface handle(ServerRequestInterface request);
}
