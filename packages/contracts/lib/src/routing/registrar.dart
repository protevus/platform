import 'route.dart';

// TODO: Fix Imports.

abstract class Registrar {
  /// Register a new GET route with the router.
  ///
  /// @param  string  $uri
  /// @param  array|string|callable  $action
  /// @return \Illuminate\Routing\Route
  Route get(String uri, dynamic action);

  /// Register a new POST route with the router.
  ///
  /// @param  string  $uri
  /// @param  array|string|callable  $action
  /// @return \Illuminate\Routing\Route
  Route post(String uri, dynamic action);

  /// Register a new PUT route with the router.
  ///
  /// @param  string  $uri
  /// @param  array|string|callable  $action
  /// @return \Illuminate\Routing\Route
  Route put(String uri, dynamic action);

  /// Register a new DELETE route with the router.
  ///
  /// @param  string  $uri
  /// @param  array|string|callable  $action
  /// @return \Illuminate\Routing\Route
  Route delete(String uri, dynamic action);

  /// Register a new PATCH route with the router.
  ///
  /// @param  string  $uri
  /// @param  array|string|callable  $action
  /// @return \Illuminate\Routing\Route
  Route patch(String uri, dynamic action);

  /// Register a new OPTIONS route with the router.
  ///
  /// @param  string  $uri
  /// @param  array|string|callable  $action
  /// @return \Illuminate\Routing\Route
  Route options(String uri, dynamic action);

  /// Register a new route with the given verbs.
  ///
  /// @param  array|string  $methods
  /// @param  string  $uri
  /// @param  array|string|callable  $action
  /// @return \Illuminate\Routing\Route
  Route match(dynamic methods, String uri, dynamic action);

  /// Route a resource to a controller.
  ///
  /// @param  string  $name
  /// @param  string  $controller
  /// @param  array  $options
  /// @return \Illuminate\Routing\PendingResourceRegistration
  PendingResourceRegistration resource(String name, String controller, [Map<String, dynamic>? options]);

  /// Create a route group with shared attributes.
  ///
  /// @param  array  $attributes
  /// @param  \Closure|string  $routes
  /// @return void
  void group(Map<String, dynamic> attributes, dynamic routes);

  /// Substitute the route bindings onto the route.
  ///
  /// @param  \Illuminate\Routing\Route  $route
  /// @return \Illuminate\Routing\Route
  Route substituteBindings(Route route);

  /// Substitute the implicit Eloquent model bindings for the route.
  ///
  /// @param  \Illuminate\Routing\Route  $route
  /// @return void
  void substituteImplicitBindings(Route route);
}
