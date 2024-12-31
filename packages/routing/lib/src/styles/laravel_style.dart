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
    var route = _router.addRoute(method.toUpperCase(), path, handler,
        middleware: allMiddleware);

    // Auto-generate route name if not provided
    if (name != null) {
      route.name = name;
    } else {
      // Convert path to route name (e.g., /users/{id} -> users.show)
      var segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        var lastSegment = segments.last;
        var prefix = segments.length > 1 ? segments[segments.length - 2] : '';
        var groupPrefix = _groupName ?? _groupPrefix?.replaceAll('/', '.');
        var namePrefix = groupPrefix != null ? '$groupPrefix.' : '';

        // Generate name based on method and path
        switch (method.toUpperCase()) {
          case 'GET':
            route.name = lastSegment.contains(':') || lastSegment.contains('{')
                ? '$namePrefix${prefix.isEmpty ? lastSegment : prefix}.show'
                : '$namePrefix${lastSegment}.index';
            break;
          case 'POST':
            route.name =
                '$namePrefix${prefix.isEmpty ? lastSegment : prefix}.store';
            break;
          case 'PUT':
          case 'PATCH':
            route.name =
                '$namePrefix${prefix.isEmpty ? lastSegment : prefix}.update';
            break;
          case 'DELETE':
            route.name =
                '$namePrefix${prefix.isEmpty ? lastSegment : prefix}.destroy';
            break;
          default:
            route.name = '$namePrefix$lastSegment';
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

    // Create new router for group
    var groupRouter = Router<T>();

    // Create new style instance for group
    var groupStyle = LaravelStyle<T>(groupRouter);

    // Set group prefix and name for route naming
    groupStyle._groupPrefix = prefix;
    groupStyle._groupName = groupName;
    groupStyle._currentMiddleware = [..._currentMiddleware, ...middleware];

    // Store previous active instance
    var previousInstance = _activeInstance;
    // Set group style as active instance
    _activeInstance = groupStyle;

    // Execute callback with group context
    callback();

    // Mount group router with prefix
    var route = _router.mount(prefix, groupRouter);
    if (groupName.isNotEmpty) {
      route.name = groupName;
    }

    // Restore previous active instance
    _activeInstance = previousInstance;
  }

  // Track active instance for group context
  static LaravelStyle? _activeInstance;

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
