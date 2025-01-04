import 'package:dsr_http_message/http_message.dart';
import 'package:dsr_http_server_handler/http_server_handler.dart';

/// Interface for server-side middleware.
///
/// This interface defines a middleware component that participates in processing
/// an HTTP server request and producing a response.
abstract class MiddlewareInterface {
  /// Process an incoming server request.
  ///
  /// Processes an incoming server request in order to produce a response.
  /// If unable to produce the response itself, it may delegate to the provided
  /// request handler to do so.
  ///
  /// [request] The server request object.
  /// [handler] The request handler to delegate to if needed.
  ///
  /// Returns a response implementing ResponseInterface.
  ResponseInterface process(
    ServerRequestInterface request,
    RequestHandlerInterface handler,
  );
}
