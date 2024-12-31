import '../router.dart';
import '../routing_style.dart';

/// Laravel-style routing implementation.
///
/// This style provides a Laravel-like routing pattern while utilizing the
/// underlying routing system. It demonstrates how different routing styles
/// can be implemented on top of the core routing functionality.
class LaravelStyle<T> implements RoutingStyle<T> {
  final Router<T> _router;

  @override
  Router<T> get router => _router;

  @override
  String get styleName => 'laravel';

  /// Creates a new Laravel-style router.
  LaravelStyle(this._router);

  @override
  void initialize() {
    // Laravel style doesn't need special initialization
  }

  @override
  void dispose() {
    // Laravel style doesn't need special cleanup
  }

  /// Register a route with a specific HTTP method.
  ///
  /// ```dart
  /// Route::get('/users', handler);
  /// Route::post('/users', handler);
  /// ```
  Route<T> route(String method, String path, T handler,
      {List<T> middleware = const []}) {
    return _router.addRoute(method.toUpperCase(), path, handler,
        middleware: middleware);
  }

  /// Register a GET route.
  ///
  /// ```dart
  /// Route::get('/users', handler);
  /// ```
  Route<T> get(String path, T handler, {List<T> middleware = const []}) {
    return route('GET', path, handler, middleware: middleware);
  }

  /// Register a POST route.
  ///
  /// ```dart
  /// Route::post('/users', handler);
  /// ```
  Route<T> post(String path, T handler, {List<T> middleware = const []}) {
    return route('POST', path, handler, middleware: middleware);
  }

  /// Register a PUT route.
  ///
  /// ```dart
  /// Route::put('/users/{id}', handler);
  /// ```
  Route<T> put(String path, T handler, {List<T> middleware = const []}) {
    return route('PUT', path, handler, middleware: middleware);
  }

  /// Register a DELETE route.
  ///
  /// ```dart
  /// Route::delete('/users/{id}', handler);
  /// ```
  Route<T> delete(String path, T handler, {List<T> middleware = const []}) {
    return route('DELETE', path, handler, middleware: middleware);
  }

  /// Register a PATCH route.
  ///
  /// ```dart
  /// Route::patch('/users/{id}', handler);
  /// ```
  Route<T> patch(String path, T handler, {List<T> middleware = const []}) {
    return route('PATCH', path, handler, middleware: middleware);
  }

  /// Create a route group with shared attributes.
  ///
  /// ```dart
  /// Route::group({
  ///   'prefix': '/api',
  ///   'middleware': ['auth'],
  /// }, () {
  ///   Route::get('/users', handler);
  ///   Route::post('/users', handler);
  /// });
  /// ```
  void group(Map<String, dynamic> attributes, void Function() callback) {
    var prefix = attributes['prefix'] as String? ?? '';
    var middleware = attributes['middleware'] as List<T>? ?? const [];

    _router.group(prefix, (groupRouter) {
      // Store current router
      var parentRouter = _router;
      // Create new style instance for group
      var groupStyle = LaravelStyle<T>(groupRouter);
      // Set current instance as the active one
      _activeInstance = groupStyle;
      // Execute callback
      callback();
      // Restore parent instance
      _activeInstance = this;
    }, middleware: middleware);
  }

  // Track active instance for group context
  static LaravelStyle? _activeInstance;

  // Forward calls to active instance
  LaravelStyle<T> get _current => _activeInstance as LaravelStyle<T>? ?? this;

  /// Add a name to the last registered route.
  ///
  /// ```dart
  /// Route::get('/users', handler).name('users.index');
  /// ```
  Route<T> name(String name) {
    var lastRoute = _router.routes.last;
    lastRoute.name = name;
    return lastRoute;
  }

  /// Register middleware for all routes.
  ///
  /// ```dart
  /// Route::middleware(['auth', 'throttle']);
  /// ```
  void middleware(List<T> middleware) {
    _router.chain(middleware);
  }
}

/// Laravel middleware adapter.
///
/// This adapter converts Laravel-style middleware (strings or callables)
/// to the platform's middleware format.
class LaravelMiddlewareStyle<T> implements MiddlewareStyle<T> {
  final Map<String, T Function()> _middlewareMap;

  LaravelMiddlewareStyle(this._middlewareMap);

  @override
  T adaptMiddleware(dynamic originalMiddleware) {
    if (originalMiddleware is String) {
      var factory = _middlewareMap[originalMiddleware];
      if (factory == null) {
        throw StateError(
            'No middleware registered for key "$originalMiddleware"');
      }
      return factory();
    }
    return originalMiddleware as T;
  }
}
