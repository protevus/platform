import 'dart:io';

import 'package:illuminate_container/container.dart';
import 'package:illuminate_encryption/encryption.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:illuminate_session/session.dart';
import 'package:test/test.dart';

void main() {
  late Application app;
  late SessionManager manager;
  late SessionConfig config;

  setUp(() {
    app = Application();
    app.container.flush(); // Clear container before each test
    config = SessionConfig(
      driver: 'array', // Use array driver for testing
      lifetime: 120,
      secure: true,
      httpOnly: true,
    );
    manager = SessionManager(config, app.container);

    // Register encrypter
    app.container.registerSingleton<Encrypter>(
      Encrypter(Encrypter.generateKey('aes-256-cbc')),
    );
  });

  test('session middleware sets and gets values', () async {
    // Create session middleware
    sessionHandler(Request req, Response res) {
      return session(manager, config)(req, res);
    }

    // Create test route
    Route.middleware([sessionHandler], () {
      Route.get('/test', (Request req, Response res) async {
        // Set session data
        req.platformSession?['test'] = 'value';
        res.content('OK');
        return true;
      });
    });

    // Create test server
    final server = await HttpServer.bind('localhost', 0);
    final port = server.port;

    // Handle requests
    server.listen((request) async {
      try {
        final route = Route().routes.firstWhere(
              (r) =>
                  r.path == request.uri.path &&
                  r.method == request.method.toUpperCase(),
              orElse: () => throw Exception('Route not found'),
            );
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

        try {
          // Process response first to set headers
          final result = await res.process(request);

          // Write response content
          if (result is Stream<List<int>>) {
            await request.response.addStream(result);
          } else if (result != null) {
            request.response.write(result.toString());
          }

          // Debug: Print cookies being set
          print(
              'Set-Cookie headers: ${request.response.headers[HttpHeaders.setCookieHeader]}');

          // Ensure response is sent
          await request.response.close();
        } catch (e, stack) {
          print('Error processing response: $e\n$stack');
          rethrow;
        }
      } catch (e, stack) {
        print('Error handling request: $e\n$stack');
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    });

    try {
      // Make first request to set session data
      final client = HttpClient();
      var request = await client.get('localhost', port, '/test');
      var response = await request.close();
      var cookies = response.cookies;
      expect(cookies, isNotEmpty);
      var sessionCookie = cookies.first;

      // Make second request with session cookie
      request = await client.get('localhost', port, '/test');
      request.cookies.add(sessionCookie);
      response = await request.close();

      // Get session data
      final store = manager.getSession(sessionCookie.value);
      expect(store, isNotNull);
      expect(store?.get('test'), equals('value'));
    } finally {
      await server.close();
    }
  });

  test('session store handles encryption', () async {
    final store = SessionStore(
      'test-id',
      ArraySessionDriver(),
      encrypt: true,
      encrypter: Encrypter(Encrypter.generateKey('aes-256-cbc')),
    );

    // Set encrypted value
    store.set('key', 'secret');

    // Get decrypted value
    expect(store.get('key'), equals('secret'));

    // Save to driver
    await store.save();

    // Read raw data from driver
    final driver = ArraySessionDriver();
    final rawData = await driver.read(store.id);
    expect(rawData?['key'], isNot(equals('secret')));
  });

  test('session store handles flash data', () {
    final store = SessionStore(
      'test-id',
      ArraySessionDriver(),
    );

    // Set flash data
    store.flash('status', 'success');

    // Get flash data
    expect(store.get('status'), equals('success'));

    // Age flash data
    store.ageFlashData();

    // Flash data should still be available
    expect(store.get('status'), equals('success'));

    // Age flash data again
    store.ageFlashData();

    // Flash data should be gone
    expect(store.get('status'), isNull);
  });

  test('session manager creates and retrieves sessions', () async {
    // Create session
    final store = await manager.createSession();
    expect(store, isNotNull);

    // Set session data
    store.set('key', 'value');

    // Get session
    final retrieved = manager.getSession(store.id);
    expect(retrieved, isNotNull);
    expect(retrieved?.get('key'), equals('value'));
  });
}
