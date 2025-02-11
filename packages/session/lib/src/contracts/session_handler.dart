import 'dart:async';
import 'package:illuminate_http/http.dart';

/// Contract for session handlers that manage session lifecycle during requests.
abstract class SessionHandler {
  /// Starts the session for the given request.
  /// Returns the session ID.
  Future<String> start(
      HttpRequestContext request, HttpResponseContext response);

  /// Gets the session ID from the request.
  String? getId(HttpRequestContext request);

  /// Validates that the session ID is in a valid format.
  bool isValidId(String? id);

  /// Sets the session ID on the response.
  Future<void> setId(
    HttpRequestContext request,
    HttpResponseContext response,
    String id,
  );

  /// Blocks access to the session.
  Future<void> block(HttpRequestContext request, HttpResponseContext response);

  /// Regenerates the session ID.
  Future<String> regenerate(
    HttpRequestContext request,
    HttpResponseContext response, {
    bool destroy = false,
  });
}
