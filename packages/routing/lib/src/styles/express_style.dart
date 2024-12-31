import '../router.dart';
import '../routing_style.dart';

/// Express-style routing implementation.
///
/// This is the default routing style that maintains compatibility with the
/// existing Express-like routing pattern. It provides the familiar app.get(),
/// app.post(), etc. methods while utilizing the underlying routing system.
class ExpressStyle<T> implements RoutingStyle<T> {
  Router<T> _router;

  @override
  Router<T> get router => _router;

  @override
  String get styleName => 'express';

  /// Creates a new Express-style router.
  ExpressStyle(this._router);

  @override
  void initialize() {
    // Express style is the default, so no special initialization needed
  }

  @override
  void dispose() {
    // Express style doesn't need special cleanup
  }

  /// Register a route that handles GET requests.
  ///
  /// ```dart
  /// app.get('/users', (req, res) {
  ///   // Handle GET request
  /// });
  /// ```
  Route<T> get(String path, T handler, {List<T> middleware = const []}) {
    return _router.get(path, _wrapHandler(handler),
        middleware: middleware.map(_wrapMiddleware).toList());
  }

  /// Register a route that handles POST requests.
  ///
  /// ```dart
  /// app.post('/users', (req, res) {
  ///   // Handle POST request
  /// });
  /// ```
  Route<T> post(String path, T handler, {List<T> middleware = const []}) {
    return _router.post(path, _wrapHandler(handler),
        middleware: middleware.map(_wrapMiddleware).toList());
  }

  /// Register a route that handles PUT requests.
  ///
  /// ```dart
  /// app.put('/users/:id', (req, res) {
  ///   // Handle PUT request
  /// });
  /// ```
  Route<T> put(String path, T handler, {List<T> middleware = const []}) {
    return _router.addRoute('PUT', path, _wrapHandler(handler),
        middleware: middleware.map(_wrapMiddleware).toList());
  }

  /// Register a route that handles DELETE requests.
  ///
  /// ```dart
  /// app.delete('/users/:id', (req, res) {
  ///   // Handle DELETE request
  /// });
  /// ```
  Route<T> delete(String path, T handler, {List<T> middleware = const []}) {
    return _router.delete(path, _wrapHandler(handler),
        middleware: middleware.map(_wrapMiddleware).toList());
  }

  /// Register a route that handles PATCH requests.
  ///
  /// ```dart
  /// app.patch('/users/:id', (req, res) {
  ///   // Handle PATCH request
  /// });
  /// ```
  Route<T> patch(String path, T handler, {List<T> middleware = const []}) {
    return _router.patch(path, _wrapHandler(handler),
        middleware: middleware.map(_wrapMiddleware).toList());
  }

  /// Register a route that handles HEAD requests.
  ///
  /// ```dart
  /// app.head('/status', (req, res) {
  ///   // Handle HEAD request
  /// });
  /// ```
  Route<T> head(String path, T handler, {List<T> middleware = const []}) {
    return _router.head(path, _wrapHandler(handler),
        middleware: middleware.map(_wrapMiddleware).toList());
  }

  /// Register a route that handles OPTIONS requests.
  ///
  /// ```dart
  /// app.options('/api', (req, res) {
  ///   // Handle OPTIONS request
  /// });
  /// ```
  Route<T> options(String path, T handler, {List<T> middleware = const []}) {
    return _router.options(path, _wrapHandler(handler),
        middleware: middleware.map(_wrapMiddleware).toList());
  }

  /// Register a route that handles all HTTP methods.
  ///
  /// ```dart
  /// app.all('/any', (req, res) {
  ///   // Handle any HTTP method
  /// });
  /// ```
  Route<T> all(String path, T handler, {List<T> middleware = const []}) {
    return _router.all(path, _wrapHandler(handler),
        middleware: middleware.map(_wrapMiddleware).toList());
  }

  /// Use middleware for all routes.
  ///
  /// ```dart
  /// app.use((req, res, next) {
  ///   // Middleware logic
  ///   next();
  /// });
  /// ```
  void use(T middleware) {
    // Chain middleware and update router
    var chainedRouter = _router.chain([_wrapMiddleware(middleware)]);
    _router = chainedRouter;

    // Apply middleware to existing routes
    for (var route in _router.routes) {
      if (route is! SymlinkRoute<T>) {
        route.handlers.insert(0, _wrapMiddleware(middleware));
      }
    }
  }

  /// Create a route group with optional prefix and middleware.
  ///
  /// ```dart
  /// app.group('/api', (router) {
  ///   router.get('/users', handler);
  ///   router.post('/users', createHandler);
  /// }, middleware: [authMiddleware]);
  /// ```
  void group(String prefix, void Function(ExpressStyle<T> router) callback,
      {List<T> middleware = const []}) {
    // Create a new router for the group
    var groupRouter = Router<T>();

    // Create new style instance for group
    var groupStyle = ExpressStyle<T>(groupRouter);

    // Execute callback with group style
    callback(groupStyle);

    // Apply middleware to all routes in the group
    if (middleware.isNotEmpty) {
      for (var route in groupRouter.routes) {
        if (route is! SymlinkRoute<T>) {
          route.handlers.insertAll(0, middleware.map(_wrapMiddleware).toList());
        }
      }
    }

    // Mount group router with prefix
    _router.mount(prefix, groupRouter);
  }

  // Helper to wrap handler functions to match expected signature
  T _wrapHandler(T handler) {
    if (handler is Function) {
      return ((req, res) {
        if (handler is Function(dynamic, dynamic)) {
          handler(req, res);
        } else if (handler is Function(dynamic, dynamic, Function)) {
          handler(req, res, () {});
        }
      }) as T;
    }
    return handler;
  }

  // Helper to wrap middleware functions to match expected signature
  T _wrapMiddleware(T middleware) {
    if (middleware is Function) {
      return ((req, res) {
        if (middleware is Function(dynamic, dynamic, Function)) {
          middleware(req, res, () {});
        } else if (middleware is Function(dynamic, dynamic)) {
          middleware(req, res);
        }
      }) as T;
    }
    return middleware;
  }
}

/// Express middleware adapter.
///
/// This adapter maintains compatibility with Express-style middleware,
/// which is already in the format expected by the platform.
class ExpressMiddlewareStyle<T> implements MiddlewareStyle<T> {
  @override
  T adaptMiddleware(dynamic originalMiddleware) {
    // Express middleware is already in the correct format
    return originalMiddleware as T;
  }
}
