import '../router.dart';
import '../routing_style.dart';

/// Laravel-style routing implementation.
///
/// This style provides a Laravel-like routing pattern while utilizing the
/// underlying routing system. It demonstrates how different routing styles
/// can be implemented on top of the core routing functionality.
class LaravelStyle<T> implements RoutingStyle<T> {
  Router<T> _router;
  String? _groupPrefix;
  String? _groupName;
  List<T> _currentMiddleware = [];

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
      {List<T> middleware = const [], String? name}) {
    var allMiddleware = [..._currentMiddleware, ...middleware];

    // If we're in a group, prepend the group prefix to the path
    var fullPath = _groupPrefix != null ? '$_groupPrefix$path' : path;

    var route = _router.addRoute(method.toUpperCase(), fullPath, handler,
        middleware: allMiddleware);

    // Auto-generate route name if not provided
    if (name != null) {
      route.name = name;
    } else {
      // Convert path to route name (e.g., /users/{id} -> users.show)
      var segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        // Clean up segments
        var cleanSegments =
            segments.map((s) => s.replaceAll(RegExp(r'[:{}/]'), '')).toList();

        // Get the resource name from the last non-parameter segment
        var resourceName = cleanSegments.last;
        var hasParams =
            segments.last.contains(':') || segments.last.contains('{');

        if (hasParams && segments.length > 1) {
          // If the last segment is a parameter, use the previous segment
          resourceName = cleanSegments[segments.length - 2];
        }

        var prefix = _groupPrefix
                ?.replaceAll('/', '.')
                .replaceAll(RegExp(r'^\.|\.$'), '') ??
            '';
        var namePrefix = prefix.isEmpty ? '' : '$prefix.';

        // Generate name based on method and path
        switch (method.toUpperCase()) {
          case 'GET':
            route.name = hasParams
                ? '$namePrefix$resourceName.show'
                : '$namePrefix$resourceName.index';
            break;
          case 'POST':
            route.name = '$namePrefix$resourceName.store';
            break;
          case 'PUT':
          case 'PATCH':
            route.name = '$namePrefix$resourceName.update';
            break;
          case 'DELETE':
            route.name = '$namePrefix$resourceName.destroy';
            break;
          default:
            route.name = '$namePrefix$resourceName';
        }
      }
    }
    return route;
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
    var groupName = attributes['name'] as String? ?? '';

    // Store current state
    var previousPrefix = _groupPrefix;
    var previousName = _groupName;
    var previousMiddleware = _currentMiddleware;

    // Update group context
    _groupPrefix = previousPrefix != null ? '$previousPrefix$prefix' : prefix;
    _groupName = groupName.isNotEmpty ? groupName : prefix.replaceAll('/', '.');
    _currentMiddleware = [...previousMiddleware, ...middleware];

    // Execute callback in group context
    callback();

    // Restore previous state
    _groupPrefix = previousPrefix;
    _groupName = previousName;
    _currentMiddleware = previousMiddleware;
  }

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
    _currentMiddleware.addAll(middleware);

    // Apply middleware to all existing routes
    for (var route in _router.routes) {
      if (route is! SymlinkRoute<T>) {
        route.handlers.insertAll(0, middleware);
      }
    }
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
