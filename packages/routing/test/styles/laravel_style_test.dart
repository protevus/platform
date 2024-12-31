import 'package:platform_routing/src/routing_style.dart';
import 'package:platform_routing/src/styles/laravel_style.dart';
import 'package:test/test.dart';

typedef NextFunction = void Function();
typedef MiddlewareFunction = void Function(dynamic, dynamic, NextFunction);
typedef RouteHandler = void Function(dynamic, dynamic);

void executeHandler(Function? handler) {
  if (handler == null) return;

  if (handler is RouteHandler) {
    handler(null, null);
  } else if (handler is MiddlewareFunction) {
    handler(null, null, () {});
  }
}

void main() {
  group('LaravelStyle', () {
    late RoutingStyleRegistry<Function> registry;
    late LaravelStyle<Function> style;

    setUp(() {
      registry = RoutingStyleRegistry<Function>();
      style = LaravelStyle<Function>(registry.baseRouter);
      registry.registerStyle(style);
      registry.useStyle('laravel');
    });

    test('supports Laravel-style route registration', () {
      var handlerCalled = false;
      var middlewareCalled = false;

      // Register middleware
      middleware(req, res, NextFunction next) {
        middlewareCalled = true;
        next();
      }

      style.middleware([middleware]);

      // Register route
      handler(req, res) {
        handlerCalled = true;
      }

      style.get('/test', handler).name!;

      // Simulate request
      var results = registry.baseRouter.resolveAbsolute('/test', method: 'GET');
      expect(results, isNotEmpty);

      // Execute handlers
      for (var result in results) {
        for (var handler in result.handlers) {
          executeHandler(handler);
        }
      }

      expect(middlewareCalled, isTrue);
      expect(handlerCalled, isTrue);
    });

    test('supports Laravel-style route groups', () {
      var routes = <String>[];
      var groupMiddlewareCalled = false;

      // Register middleware
      middleware(req, res, NextFunction next) {
        groupMiddlewareCalled = true;
        next();
      }

      style.group({
        'prefix': '/api',
        'middleware': [middleware],
      }, () {
        getHandler(req, res) {
          routes.add('/api/users');
        }

        postHandler(req, res) {
          routes.add('/api/users');
        }

        style.get('/users', getHandler).name!;
        style.post('/users', postHandler).name!;
      });

      // Verify routes were registered
      var getResults =
          registry.baseRouter.resolveAbsolute('/api/users', method: 'GET');
      var postResults =
          registry.baseRouter.resolveAbsolute('/api/users', method: 'POST');

      expect(getResults, isNotEmpty);
      expect(postResults, isNotEmpty);

      // Verify route names
      var namedRoute = registry.baseRouter.routes
          .firstWhere((r) => r.name == 'api.users.index');
      expect(namedRoute, isNotNull);

      // Execute handlers to verify middleware
      for (var result in getResults) {
        for (var handler in result.handlers) {
          executeHandler(handler);
        }
      }

      expect(groupMiddlewareCalled, isTrue);
      expect(routes, contains('/api/users'));
    });

    test('supports all HTTP methods', () {
      var methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];
      var calledMethods = <String>[];

      // Register routes for each method
      for (var method in methods) {
        handler(req, res) {
          calledMethods.add(method);
        }

        style.route(method, '/test', handler).name!;
      }

      // Verify each method resolves
      for (var method in methods) {
        var results =
            registry.baseRouter.resolveAbsolute('/test', method: method);
        expect(results, isNotEmpty, reason: 'Method $method should resolve');

        // Execute handler
        for (var result in results) {
          for (var handler in result.handlers) {
            executeHandler(handler);
          }
        }
      }

      // Verify each method was called
      expect(calledMethods, containsAll(methods));
    });

    test('supports named routes', () {
      handler(req, res) {}

      style.get('/users', handler).name!;
      style.post('/users', handler).name!;
      style.get('/users/:id', handler).name!;

      var routes = registry.baseRouter.routes;
      expect(routes.any((r) => r.name == 'users.index'), isTrue);
      expect(routes.any((r) => r.name == 'users.store'), isTrue);
      expect(routes.any((r) => r.name == 'users.show'), isTrue);
    });

    test('supports middleware string resolution', () {
      var authCalled = false;
      var throttleCalled = false;

      MiddlewareFunction createAuthMiddleware() {
        return (req, res, NextFunction next) {
          authCalled = true;
          next();
        };
      }

      MiddlewareFunction createThrottleMiddleware() {
        return (req, res, NextFunction next) {
          throttleCalled = true;
          next();
        };
      }

      var middlewareAdapter = LaravelMiddlewareStyle<Function>({
        'auth': createAuthMiddleware,
        'throttle': createThrottleMiddleware,
      });

      // Test string to middleware conversion
      var authMiddleware =
          middlewareAdapter.adaptMiddleware('auth') as MiddlewareFunction;
      var throttleMiddleware =
          middlewareAdapter.adaptMiddleware('throttle') as MiddlewareFunction;

      // Execute middleware
      doNext() {}
      authMiddleware(null, null, doNext);
      throttleMiddleware(null, null, doNext);

      expect(authCalled, isTrue);
      expect(throttleCalled, isTrue);
    });

    test('throws on unknown middleware string', () {
      var adapter = LaravelMiddlewareStyle<Function>({});
      expect(
        () => adapter.adaptMiddleware('unknown'),
        throwsStateError,
      );
    });
  });
}
