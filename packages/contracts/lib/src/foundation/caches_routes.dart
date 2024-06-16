abstract class CachesRoutes {
  /// Determine if the application routes are cached.
  ///
  /// @return bool
  bool routesAreCached();

  /// Get the path to the routes cache file.
  ///
  /// @return string
  String getCachedRoutesPath();
}
