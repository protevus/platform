/// Interface for route caching.
abstract class CachesRoutes {
  /// Determine if the application routes are cached.
  bool routesAreCached();

  /// Get the path to the routes cache file.
  String getCachedRoutesPath();
}
