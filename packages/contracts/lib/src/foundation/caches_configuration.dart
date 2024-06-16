
abstract class CachesConfiguration {
  /// Determine if the application configuration is cached.
  ///
  /// Returns a boolean indicating if the configuration is cached.
  bool configurationIsCached();

  /// Get the path to the configuration cache file.
  ///
  /// Returns a string representing the path to the configuration cache file.
  String getCachedConfigPath();

  /// Get the path to the cached services file.
  ///
  /// Returns a string representing the path to the cached services file.
  String getCachedServicesPath();
}
