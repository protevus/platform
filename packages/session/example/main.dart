import 'dart:io';

import 'package:illuminate_container/container.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_routing/routing.dart';
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
  sessionHandler(Request req, Response res) {
    return session(manager, config)(req, res);
  }

  // Example usage in a route handler
  Route.middleware([sessionHandler], () {
    Route.get('/profile', (Request req, Response res) async {
      // Get session data
      final session = req.platformSession;
      final user = session?['user'];
      if (user == null) {
        res.statusCode(302).header(HttpHeaders.locationHeader, '/login');
        return false;
      }

      // Use session data
      res.content('Welcome back, ${(user as Map)['name']}!');

      // Store data in session
      session?['last_visit'] = DateTime.now().toIso8601String();

      // Flash data for next request
      session?['status'] = 'Profile viewed successfully';
      return true;
    });

    // Example login handler
    Route.post('/login', (Request req, Response res) async {
      // Store user data in session
      req.platformSession?['user'] = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
      };

      res.statusCode(302).header(HttpHeaders.locationHeader, '/profile');
      return true;
    });

    // Example logout handler
    Route.post('/logout', (Request req, Response res) async {
      // Clear session data
      req.platformSession?.destroy();
      res.statusCode(302).header(HttpHeaders.locationHeader, '/login');
      return true;
    });
  });

  // Start server
  final server = await HttpServer.bind('localhost', 3000);
  print('Server running at http://localhost:3000');

  // Start handling requests
  await for (final request in server) {
    try {
      final route = Route().routes.firstWhere(
            (r) =>
                r.path == request.uri.path &&
                r.method == request.method.toUpperCase(),
            orElse: () => throw Exception('Route not found'),
          );
      try {
        final req = Request(
          route: route,
          uri: request.uri,
          body: {},
          httpHeaders: request.headers,
          httpRequest: request,
        );
        final res = Response(null);
        for (final controller in route.controllers) {
          if (controller is Function) {
            await controller(req, res);
          }
        }
      } catch (e) {
        if (e.toString().contains('Route not found')) {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print('Error handling request: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }
}
