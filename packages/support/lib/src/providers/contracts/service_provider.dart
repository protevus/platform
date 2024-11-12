/// Contract for service providers.
///
/// This interface defines the core functionality that all service providers
/// must implement. It matches Laravel's ServiceProvider contract to ensure
/// API compatibility.
abstract class ServiceProviderContract {
  /// Register any application services.
  void register();

  /// Bootstrap any application services.
  void boot();

  /// Get the services provided by the provider.
  List<String> provides();

  /// Get the events that trigger this service provider to register.
  List<String> when();

  /// Determine if the provider is deferred.
  bool isDeferred();
}

/// Contract for deferrable providers.
///
/// This interface matches Laravel's DeferrableProvider contract to ensure
/// API compatibility.
abstract class DeferrableProviderContract {
  /// Get the services provided by the provider.
  List<String> provides();
}
