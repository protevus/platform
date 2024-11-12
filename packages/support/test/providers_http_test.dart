import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:platform_container/container.dart';
import 'package:platform_support/providers.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

// Test service provider with HTTP functionality
class HttpTestProvider extends ServiceProvider {
  final events = <String>[];
  final middlewareCalls = <String>[];

  @override
  void register() {
    super.register();

    // Add a route handler
    app.fallback((req, res) {
      // Record middleware call
      middlewareCalls.add(req.uri?.path ?? '');

      if (req.uri?.path == '/test') {
        events.add('route-hit');
        res.write('test');
        return false;
      }
      return true;
    });
  }

  @override
  void boot() {
    super.boot();
  }

  @override
  List<String> provides() => ['http-test'];
}

void main() {
  group('ServiceProvider HTTP Tests', () {
    late Application app;
    late PlatformHttp server;
    late HttpTestProvider provider;
    late int port;

    setUp(() async {
      app = Application(reflector: const EmptyReflector());
      server = PlatformHttp(app);
      provider = HttpTestProvider();

      // Register provider before starting server
      await app.registerProvider(provider);

      // Start server on random port
      await server.startServer('127.0.0.1', 0);
      port = server.server?.port ?? 0;
      expect(port, isNot(0), reason: 'Server should be assigned a port');

      // Wait a bit for server to be ready
      await Future.delayed(Duration(milliseconds: 100));
    });

    tearDown(() async {
      await server.close();
      await app.close();
    });

    test('routes registered by provider work', () async {
      expect(provider.events, isEmpty,
          reason: 'No events should be recorded yet');

      // Make request to test route
      var response = await http.get(Uri.parse('http://127.0.0.1:$port/test'));

      // Wait a bit for async handlers to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(response.statusCode, equals(200),
          reason: 'Should get successful response');
      expect(response.body, equals('test'),
          reason: 'Should get expected response body');
      expect(provider.events, contains('route-hit'),
          reason: 'Route should be hit');
    });

    test('middleware registered by provider works', () async {
      expect(provider.middlewareCalls, isEmpty,
          reason: 'No middleware calls should be recorded yet');

      // Make request to trigger middleware
      await http.get(Uri.parse('http://127.0.0.1:$port/test'));

      // Wait a bit for async handlers to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(provider.middlewareCalls, contains('/test'),
          reason: 'Middleware should record request path');
    });

    test('multiple requests are handled correctly', () async {
      // Make multiple requests
      await Future.wait([
        http.get(Uri.parse('http://127.0.0.1:$port/test')),
        http.get(Uri.parse('http://127.0.0.1:$port/test')),
        http.get(Uri.parse('http://127.0.0.1:$port/test'))
      ]);

      // Wait a bit for async handlers to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(provider.events.length, equals(3),
          reason: 'Should record 3 route hits');
      expect(provider.middlewareCalls.length, equals(3),
          reason: 'Should record 3 middleware calls');
    });

    test('middleware runs for all requests', () async {
      // Make request to non-existent route
      await http.get(Uri.parse('http://127.0.0.1:$port/not-found'));

      // Wait a bit for async handlers to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(provider.middlewareCalls, contains('/not-found'),
          reason: 'Middleware should run even for non-existent routes');
    });
  });
}
