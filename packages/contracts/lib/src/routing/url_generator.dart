/// Interface for URL generation.
abstract class UrlGenerator {
  /// Get the current URL for the request.
  String current();

  /// Get the URL for the previous request.
  String previous([dynamic fallback = false]);

  /// Generate an absolute URL to the given path.
  String to(String path, [dynamic extra = const [], bool? secure]);

  /// Generate a secure, absolute URL to the given path.
  String secure(String path, [List<dynamic> parameters = const []]);

  /// Generate the URL to an application asset.
  String asset(String path, [bool? secure]);

  /// Get the URL to a named route.
  String route(String name,
      [dynamic parameters = const [], bool absolute = true]);

  /// Create a signed route URL for a named route.
  String signedRoute(String name,
      [dynamic parameters = const [],
      dynamic expiration,
      bool absolute = true]);

  /// Create a temporary signed route URL for a named route.
  String temporarySignedRoute(String name, dynamic expiration,
      [dynamic parameters = const [], bool absolute = true]);

  /// Get the URL to a controller action.
  String action(dynamic action,
      [dynamic parameters = const [], bool absolute = true]);

  /// Get the root controller namespace.
  String getRootControllerNamespace();

  /// Set the root controller namespace.
  UrlGenerator setRootControllerNamespace(String rootNamespace);

  /// Generate a URL with query string.
  String query(String path,
      [Map<String, dynamic> query = const {},
      dynamic extra = const [],
      bool? secure]);
}
