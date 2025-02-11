import 'dart:io';

import 'package:illuminate_container/container.dart';
import 'package:illuminate_encryption/encryption.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_session/session.dart';
import 'package:test/test.dart';

void main() {
  late Application app;
  late SessionManager manager;
  late SessionConfig config;

  setUp(() {
    app = Application();
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
    sessionHandler(RequestContext req, ResponseContext res) {
      final request = req as HttpRequestContext;
      final response = res as HttpResponseContext;
      return session(manager, config)(request, response);
    }

    // Create test route
    app.get('/test', (RequestContext req, ResponseContext res) async {
      final request = req as HttpRequestContext;
      final response = res as HttpResponseContext;

      // Set session data
      request.illuminateSession?['test'] = 'value';
      response.write('OK');
      return true;
    }, middleware: [sessionHandler]);

    // Create test server
    final server = await HttpServer.bind('localhost', 0);
    final port = server.port;

    // Handle requests
    server.listen((request) async {
      final httpRequest =
          await HttpRequestContext.from(request, app, request.uri.path);
      final httpResponse = HttpResponseContext(request.response, app);
      await app.executeHandler(app.optimizedRouter, httpRequest, httpResponse);
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

  test('session store handles encryption', () {
    final store = SessionStore(
      'test-id',
      ArraySessionDriver(),
      encrypt: true,
      encrypter: app.container.make<Encrypter>(),
    );

    // Set encrypted value
    store.set('key', 'secret');

    // Get decrypted value
    expect(store.get('key'), equals('secret'));

    // Verify value is actually encrypted in store
    final rawData = store.all();
    expect(rawData['key'], isNot(equals('secret')));
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
