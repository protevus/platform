import 'dart:async';
import 'package:illuminate_http/http.dart';

/// Contract for session handlers that manage session lifecycle during requests.
abstract class SessionHandler {
  /// Starts the session for the given request.
  /// Returns the session ID.
  Future<String> start(Request request, Response response);

  /// Gets the session ID from the request.
  String? getId(Request request);

  /// Validates that the session ID is in a valid format.
  bool isValidId(String? id);

  /// Sets the session ID on the response.
  Future<void> setId(
    Request request,
    Response response,
    String id,
  );

  /// Blocks access to the session.
  Future<void> block(Request request, Response response);

  /// Regenerates the session ID.
  Future<String> regenerate(
    Request request,
    Response response, {
    bool destroy = false,
  });
}
