import 'dart:io';

import 'package:illuminate_container/container.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_session/session.dart';

void main() async {
  // Create application
  final app = Application();

  // Create session configuration
  final config = SessionConfig(
    driver: 'file',
    lifetime: 120, // 2 hours
    secure: true,
    httpOnly: true,
  );

  // Create session manager
  final manager = SessionManager(config, app.container);

  // Create session middleware
  sessionHandler(RequestContext req, ResponseContext res) {
    final request = req as HttpRequestContext;
    final response = res as HttpResponseContext;
    return session(manager, config)(request, response);
  }

  // Example usage in a route handler
  app.get('/profile', (RequestContext req, ResponseContext res) async {
    final request = req as HttpRequestContext;
    final response = res as HttpResponseContext;

    // Get session data
    final user = request.illuminateSession?['user'];
    if (user == null) {
      response.redirect('/login');
      return false;
    }

    // Use session data
    response.write('Welcome back, ${user['name']}!');

    // Store data in session
    request.illuminateSession?['last_visit'] = DateTime.now().toIso8601String();

    // Flash data for next request
    request.illuminateSession?['status'] = 'Profile viewed successfully';
    return true;
  }, middleware: [sessionHandler]);

  // Example login handler
  app.post('/login', (RequestContext req, ResponseContext res) async {
    final request = req as HttpRequestContext;
    final response = res as HttpResponseContext;

    // Store user data in session
    request.illuminateSession?['user'] = {
      'id': 1,
      'name': 'John Doe',
      'email': 'john@example.com',
    };

    response.redirect('/profile');
    return true;
  }, middleware: [sessionHandler]);

  // Example logout handler
  app.post('/logout', (RequestContext req, ResponseContext res) async {
    final request = req as HttpRequestContext;
    final response = res as HttpResponseContext;

    // Clear session data
    request.illuminateSession?.destroy();
    response.redirect('/login');
    return true;
  }, middleware: [sessionHandler]);

  // Start server
  final server = await HttpServer.bind('localhost', 3000);
  print('Server running at http://localhost:3000');

  await for (var request in server) {
    final httpRequest =
        await HttpRequestContext.from(request, app, request.uri.path);
    final httpResponse = HttpResponseContext(request.response, app);
    await app.executeHandler(app.optimizedRouter, httpRequest, httpResponse);
  }
}
