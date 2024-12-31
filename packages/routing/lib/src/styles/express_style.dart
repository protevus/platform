import '../router.dart';
import '../routing_style.dart';

/// Express-style routing implementation.
///
/// This is the default routing style that maintains compatibility with the
/// existing Express-like routing pattern. It provides the familiar app.get(),
/// app.post(), etc. methods while utilizing the underlying routing system.
class ExpressStyle<T> implements RoutingStyle<T> {
  final Router<T> _router;

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
    return _router.get(path, handler, middleware: middleware);
  }

  /// Register a route that handles POST requests.
  ///
  /// ```dart
  /// app.post('/users', (req, res) {
  ///   // Handle POST request
  /// });
  /// ```
  Route<T> post(String path, T handler, {List<T> middleware = const []}) {
    return _router.post(path, handler, middleware: middleware);
  }

  /// Register a route that handles PUT requests.
  ///
  /// ```dart
  /// app.put('/users/:id', (req, res) {
  ///   // Handle PUT request
  /// });
  /// ```
  Route<T> put(String path, T handler, {List<T> middleware = const []}) {
    return _router.put(path, handler, middleware: middleware) as Route<T>;
  }

  /// Register a route that handles DELETE requests.
  ///
  /// ```dart
  /// app.delete('/users/:id', (req, res) {
  ///   // Handle DELETE request
  /// });
  /// ```
  Route<T> delete(String path, T handler, {List<T> middleware = const []}) {
    return _router.delete(path, handler, middleware: middleware);
  }

  /// Register a route that handles PATCH requests.
  ///
  /// ```dart
  /// app.patch('/users/:id', (req, res) {
  ///   // Handle PATCH request
  /// });
  /// ```
  Route<T> patch(String path, T handler, {List<T> middleware = const []}) {
    return _router.patch(path, handler, middleware: middleware);
  }

  /// Register a route that handles HEAD requests.
  ///
  /// ```dart
  /// app.head('/status', (req, res) {
  ///   // Handle HEAD request
  /// });
  /// ```
  Route<T> head(String path, T handler, {List<T> middleware = const []}) {
    return _router.head(path, handler, middleware: middleware);
  }

  /// Register a route that handles OPTIONS requests.
  ///
  /// ```dart
  /// app.options('/api', (req, res) {
  ///   // Handle OPTIONS request
  /// });
  /// ```
  Route<T> options(String path, T handler, {List<T> middleware = const []}) {
    return _router.options(path, handler, middleware: middleware);
  }

  /// Register a route that handles all HTTP methods.
  ///
  /// ```dart
  /// app.all('/any', (req, res) {
  ///   // Handle any HTTP method
  /// });
  /// ```
  Route<T> all(String path, T handler, {List<T> middleware = const []}) {
    return _router.all(path, handler, middleware: middleware);
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
    _router.chain([middleware]);
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
    _router.group(prefix, (router) {
      callback(ExpressStyle<T>(router));
    }, middleware: middleware);
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
