import 'package:meta/meta.dart';

/// Contract for router functionality.
///
/// Laravel-compatible: Core routing functionality matching Laravel's Router
/// interface, with platform-specific generic type support.
@sealed
abstract class RouterContract<T> {
  /// Adds a route that responds to any HTTP method.
  ///
  /// Laravel-compatible: Any-method route registration.
  RouteContract<T> any(String path, T handler,
      {Iterable<T> middleware = const []});

  /// Adds a route that responds to GET requests.
  ///
  /// Laravel-compatible: GET route registration.
  RouteContract<T> get(String path, T handler,
      {Iterable<T> middleware = const []});

  /// Adds a route that responds to POST requests.
  ///
  /// Laravel-compatible: POST route registration.
  RouteContract<T> post(String path, T handler,
      {Iterable<T> middleware = const []});

  /// Adds a route that responds to PUT requests.
  ///
  /// Laravel-compatible: PUT route registration.
  RouteContract<T> put(String path, T handler,
      {Iterable<T> middleware = const []});

  /// Adds a route that responds to DELETE requests.
  ///
  /// Laravel-compatible: DELETE route registration.
  RouteContract<T> delete(String path, T handler,
      {Iterable<T> middleware = const []});

  /// Adds a route that responds to PATCH requests.
  ///
  /// Laravel-compatible: PATCH route registration.
  RouteContract<T> patch(String path, T handler,
      {Iterable<T> middleware = const []});

  /// Adds a route that responds to OPTIONS requests.
  ///
  /// Laravel-compatible: OPTIONS route registration.
  RouteContract<T> options(String path, T handler,
      {Iterable<T> middleware = const []});

  /// Creates a route group with shared attributes.
  ///
  /// Laravel-compatible: Route grouping with platform-specific
  /// callback-based configuration.
  ///
  /// Parameters:
  ///   - [path]: The prefix path for the group.
  ///   - [callback]: Function to define routes within the group.
  ///   - [middleware]: Middleware to apply to all routes in the group.
  void group(String path, void Function(RouterContract<T> router) callback,
      {Iterable<T> middleware = const []});

  /// Mounts another router at a path prefix.
  ///
  /// Platform-specific: Provides router composition functionality.
  ///
  /// Parameters:
  ///   - [path]: The path to mount at.
  ///   - [router]: The router to mount.
  void mount(String path, RouterContract<T> router);

  /// Resolves a route for a request.
  ///
  /// Laravel-compatible: Route matching with platform-specific
  /// match result contract.
  ///
  /// Parameters:
  ///   - [method]: The HTTP method.
  ///   - [path]: The request path.
  RouteMatchContract<T>? resolve(String method, String path);
}

/// Contract for route definitions.
///
/// Laravel-compatible: Route definition interface matching Laravel's Route
/// class, with platform-specific enhancements.
@sealed
abstract class RouteContract<T> {
  /// Gets the route path pattern.
  ///
  /// Laravel-compatible: Route URI pattern.
  String get path;

  /// Gets the HTTP method this route responds to.
  ///
  /// Laravel-compatible: HTTP method.
  String get method;

  /// Gets the route handler.
  ///
  /// Laravel-compatible: Route action with generic typing.
  T get handler;

  /// Gets the route middleware.
  ///
  /// Laravel-compatible: Route middleware.
  Iterable<T> get middleware;

  /// Gets the route name.
  ///
  /// Laravel-compatible: Route name accessor.
  String? get name;

  /// Sets the route name.
  ///
  /// Laravel-compatible: Route name mutator.
  set name(String? value);

  /// Gets the route parameters.
  ///
  /// Laravel-compatible: Route parameters.
  Map<String, dynamic> get parameters;

  /// Makes a URI for this route.
  ///
  /// Laravel-compatible: URL generation.
  ///
  /// Parameters:
  ///   - [params]: The parameter values to use.
  String makeUri(Map<String, dynamic> params);

  /// Gets the route's regular expression pattern.
  ///
  /// Platform-specific: Direct access to route pattern.
  RegExp get pattern;

  /// Whether the route matches a path.
  ///
  /// Platform-specific: Direct path matching.
  bool matches(String path);
}

/// Contract for route matching results.
///
/// Platform-specific: Defines detailed match results beyond
/// Laravel's basic route matching.
@sealed
abstract class RouteMatchContract<T> {
  /// Gets the matched route.
  RouteContract<T> get route;

  /// Gets the matched parameters.
  Map<String, dynamic> get params;

  /// Gets any remaining path after the match.
  String get remaining;

  /// Gets the full matched path.
  String get matched;
}

/// Contract for route parameters.
///
/// Laravel-compatible: Parameter handling matching Laravel's
/// parameter constraints, with platform-specific validation.
@sealed
abstract class RouteParameterContract {
  /// Gets the parameter name.
  String get name;

  /// Gets the parameter pattern.
  String? get pattern;

  /// Whether the parameter is optional.
  bool get isOptional;

  /// Gets the default value.
  dynamic get defaultValue;

  /// Validates a parameter value.
  bool validate(String value);
}

/// Contract for route collection.
///
/// Laravel-compatible: Route collection functionality matching
/// Laravel's RouteCollection, with platform-specific enhancements.
@sealed
abstract class RouteCollectionContract<T> {
  /// Gets all routes.
  ///
  /// Laravel-compatible: Route listing.
  Iterable<RouteContract<T>> get routes;

  /// Gets routes by method.
  ///
  /// Laravel-compatible: Method filtering.
  Iterable<RouteContract<T>> getByMethod(String method);

  /// Gets a route by name.
  ///
  /// Laravel-compatible: Named route lookup.
  RouteContract<T>? getByName(String name);

  /// Adds a route to the collection.
  ///
  /// Laravel-compatible: Route registration.
  void add(RouteContract<T> route);

  /// Removes a route from the collection.
  ///
  /// Laravel-compatible: Route removal.
  void remove(RouteContract<T> route);

  /// Gets routes with a specific middleware.
  ///
  /// Platform-specific: Middleware filtering.
  Iterable<RouteContract<T>> getByMiddleware(T middleware);
}

/// Contract for route groups.
///
/// Laravel-compatible: Route grouping functionality matching
/// Laravel's route group features, with platform-specific additions.
@sealed
abstract class RouteGroupContract<T> {
  /// Gets the group prefix.
  ///
  /// Laravel-compatible: Group prefix.
  String get prefix;

  /// Gets the group middleware.
  ///
  /// Laravel-compatible: Group middleware.
  Iterable<T> get middleware;

  /// Gets the group namespace.
  ///
  /// Laravel-compatible: Group namespace.
  String? get namespace;

  /// Gets routes in this group.
  ///
  /// Laravel-compatible: Group routes.
  Iterable<RouteContract<T>> get routes;

  /// Adds a route to the group.
  ///
  /// Laravel-compatible: Route addition with platform-specific
  /// middleware support.
  RouteContract<T> addRoute(String method, String path, T handler,
      {Iterable<T> middleware = const []});

  /// Creates a sub-group.
  ///
  /// Laravel-compatible: Nested grouping with platform-specific
  /// namespace support.
  RouteGroupContract<T> group(String prefix,
      {Iterable<T> middleware = const [], String? namespace});
}
