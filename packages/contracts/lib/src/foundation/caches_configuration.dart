/// Interface for configuration caching.
abstract class CachesConfiguration {
  /// Determine if the application configuration is cached.
  bool configurationIsCached();

  /// Get the path to the configuration cache file.
  String getCachedConfigPath();

  /// Get the path to the cached services.php file.
  String getCachedServicesPath();
}
