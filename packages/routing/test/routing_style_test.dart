import 'package:platform_routing/src/router.dart';
import 'package:platform_routing/src/routing_style.dart';
import 'package:platform_routing/src/styles/express_style.dart';
import 'package:test/test.dart';

// Test style implementation
class _TestStyle implements RoutingStyle<Function> {
  final Router<Function> _router;
  final void Function() _onDispose;

  _TestStyle(this._router, this._onDispose);

  @override
  Router<Function> get router => _router;

  @override
  String get styleName => 'test';

  @override
  void initialize() {}

  @override
  void dispose() {
    _onDispose();
  }
}

void main() {
  group('RoutingStyleRegistry', () {
    late RoutingStyleRegistry<Function> registry;

    setUp(() {
      registry = RoutingStyleRegistry<Function>();
    });

    test('registers and activates styles', () {
      var expressStyle = ExpressStyle<Function>(registry.baseRouter);

      // Register style
      registry.registerStyle(expressStyle);
      expect(registry.activeStyle, isNull);

      // Activate style
      registry.useStyle('express');
      expect(registry.activeStyle, equals(expressStyle));
    });

    test('throws on duplicate style registration', () {
      var style1 = ExpressStyle<Function>(registry.baseRouter);
      var style2 = ExpressStyle<Function>(registry.baseRouter);

      registry.registerStyle(style1);
      expect(
        () => registry.registerStyle(style2),
        throwsStateError,
      );
    });

    test('throws when activating unregistered style', () {
      expect(
        () => registry.useStyle('nonexistent'),
        throwsStateError,
      );
    });

    test('disposes previous style when switching', () {
      var disposed = false;

      var testStyle = _TestStyle(registry.baseRouter, () => disposed = true);
      var expressStyle = ExpressStyle<Function>(registry.baseRouter);

      registry.registerStyle(testStyle);
      registry.registerStyle(expressStyle);

      // Activate test style
      registry.useStyle('test');
      expect(disposed, isFalse);

      // Switch to express style
      registry.useStyle('express');
      expect(disposed, isTrue);
    });
  });

  group('ExpressStyle', () {
    late RoutingStyleRegistry<Function> registry;
    late ExpressStyle<Function> style;

    setUp(() {
      registry = RoutingStyleRegistry<Function>();
      style = ExpressStyle<Function>(registry.baseRouter);
      registry.registerStyle(style);
      registry.useStyle('express');
    });

    test('maintains express-style routing pattern', () {
      var handlerCalled = false;
      var middlewareCalled = false;

      // Register middleware
      style.use((req, res, next) {
        middlewareCalled = true;
        next();
      });

      // Register route
      style.get('/test', (req, res) {
        handlerCalled = true;
      });

      // Simulate request
      var results = registry.baseRouter.resolveAbsolute('/test', method: 'GET');
      expect(results, isNotEmpty);

      // Execute handlers
      for (var result in results) {
        for (var handler in result.handlers) {
          handler(null, null);
        }
      }

      expect(middlewareCalled, isTrue);
      expect(handlerCalled, isTrue);
    });

    test('supports route groups', () {
      var routes = <String>[];

      style.group('/api', (router) {
        router.get('/users', (req, res) {
          routes.add('/api/users');
        });

        router.post('/users', (req, res) {
          routes.add('/api/users');
        });
      });

      // Verify routes were registered
      var getResults =
          registry.baseRouter.resolveAbsolute('/api/users', method: 'GET');
      var postResults =
          registry.baseRouter.resolveAbsolute('/api/users', method: 'POST');

      expect(getResults, isNotEmpty);
      expect(postResults, isNotEmpty);
    });

    test('supports all HTTP methods', () {
      var methods = [
        'GET',
        'POST',
        'PUT',
        'DELETE',
        'PATCH',
        'HEAD',
        'OPTIONS'
      ];
      var calledMethods = <String>[];

      // Register routes for each method
      for (var method in methods) {
        switch (method) {
          case 'GET':
            style.get('/test', (req, res) => calledMethods.add(method));
            break;
          case 'POST':
            style.post('/test', (req, res) => calledMethods.add(method));
            break;
          case 'PUT':
            style.put('/test', (req, res) => calledMethods.add(method));
            break;
          case 'DELETE':
            style.delete('/test', (req, res) => calledMethods.add(method));
            break;
          case 'PATCH':
            style.patch('/test', (req, res) => calledMethods.add(method));
            break;
          case 'HEAD':
            style.head('/test', (req, res) => calledMethods.add(method));
            break;
          case 'OPTIONS':
            style.options('/test', (req, res) => calledMethods.add(method));
            break;
        }
      }

      // Verify each method resolves
      for (var method in methods) {
        var results =
            registry.baseRouter.resolveAbsolute('/test', method: method);
        expect(results, isNotEmpty, reason: 'Method $method should resolve');

        // Execute handler
        for (var result in results) {
          for (var handler in result.handlers) {
            handler(null, null);
          }
        }
      }

      // Verify each method was called
      expect(calledMethods, containsAll(methods));
    });

    test('supports middleware in route groups', () {
      var middlewareCalled = false;
      var handlerCalled = false;

      style.group('/api', (router) {
        router.get('/test', (req, res) {
          handlerCalled = true;
        });
      }, middleware: [
        (req, res, next) {
          middlewareCalled = true;
          next();
        }
      ]);

      // Simulate request
      var results =
          registry.baseRouter.resolveAbsolute('/api/test', method: 'GET');
      expect(results, isNotEmpty);

      // Execute handlers
      for (var result in results) {
        for (var handler in result.handlers) {
          handler(null, null);
        }
      }

      expect(middlewareCalled, isTrue);
      expect(handlerCalled, isTrue);
    });
  });
}
