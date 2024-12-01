/// Interface for route registration.
abstract class Registrar {
  /// Register a new GET route with the router.
  dynamic get(String uri, dynamic action);

  /// Register a new POST route with the router.
  dynamic post(String uri, dynamic action);

  /// Register a new PUT route with the router.
  dynamic put(String uri, dynamic action);

  /// Register a new DELETE route with the router.
  dynamic delete(String uri, dynamic action);

  /// Register a new PATCH route with the router.
  dynamic patch(String uri, dynamic action);

  /// Register a new OPTIONS route with the router.
  dynamic options(String uri, dynamic action);

  /// Register a new route with the given verbs.
  dynamic match(dynamic methods, String uri, dynamic action);

  /// Route a resource to a controller.
  dynamic resource(String name, String controller,
      [Map<String, dynamic> options = const {}]);

  /// Create a route group with shared attributes.
  void group(Map<String, dynamic> attributes, dynamic routes);

  /// Substitute the route bindings onto the route.
  dynamic substituteBindings(dynamic route);

  /// Substitute the implicit model bindings for the route.
  void substituteImplicitBindings(dynamic route);
}
