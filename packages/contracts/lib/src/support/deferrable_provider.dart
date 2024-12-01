/// Interface for service providers that support deferred loading.
///
/// This contract defines a standard way for service providers to specify
/// which services they provide. This information is used by the service
/// container to determine when a provider should be loaded, enabling
/// lazy loading of services for better performance.
///
/// Example:
/// ```dart
/// class CacheServiceProvider implements DeferrableProvider {
///   @override
///   List<String> provides() {
///     return [
///       'cache',
///       'cache.store',
///       'memcached.connector',
///     ];
///   }
/// }
/// ```
abstract class DeferrableProvider {
  /// Get the services provided by the provider.
  ///
  /// Returns a list of service identifiers that this provider can resolve.
  /// These identifiers are used by the service container to determine
  /// when this provider should be loaded.
  List<String> provides();
}
