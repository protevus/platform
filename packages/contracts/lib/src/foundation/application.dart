import 'container.dart'; // Assuming Container is defined in container.dart
import 'maintenance_mode.dart'; // Assuming MaintenanceMode is defined in maintenance_mode.dart

// TODO: Replace missing imports with dar equivalents.

abstract class Application extends Container {
  /// Get the version number of the application.
  String version();

  /// Get the base path of the installation.
  String basePath([String path = '']);

  /// Get the path to the bootstrap directory.
  String bootstrapPath([String path = '']);

  /// Get the path to the application configuration files.
  String configPath([String path = '']);

  /// Get the path to the database directory.
  String databasePath([String path = '']);

  /// Get the path to the language files.
  String langPath([String path = '']);

  /// Get the path to the public directory.
  String publicPath([String path = '']);

  /// Get the path to the resources directory.
  String resourcePath([String path = '']);

  /// Get the path to the storage directory.
  String storagePath([String path = '']);

  /// Get or check the current application environment.
  dynamic environment(List<String> environments);

  /// Determine if the application is running in the console.
  bool runningInConsole();

  /// Determine if the application is running unit tests.
  bool runningUnitTests();

  /// Determine if the application is running with debug mode enabled.
  bool hasDebugModeEnabled();

  /// Get an instance of the maintenance mode manager implementation.
  MaintenanceMode maintenanceMode();

  /// Determine if the application is currently down for maintenance.
  bool isDownForMaintenance();

  /// Register all of the configured providers.
  void registerConfiguredProviders();

  /// Register a service provider with the application.
  ServiceProvider register(dynamic provider, [bool force = false]);

  /// Register a deferred provider and service.
  void registerDeferredProvider(String provider, [String? service]);

  /// Resolve a service provider instance from the class name.
  ServiceProvider resolveProvider(String provider);

  /// Boot the application's service providers.
  void boot();

  /// Register a new boot listener.
  void booting(Function callback);

  /// Register a new "booted" listener.
  void booted(Function callback);

  /// Run the given array of bootstrap classes.
  void bootstrapWith(List<String> bootstrappers);

  /// Get the current application locale.
  String getLocale();

  /// Get the application namespace.
  String getNamespace();

  /// Get the registered service provider instances if any exist.
  List<ServiceProvider> getProviders(dynamic provider);

  /// Determine if the application has been bootstrapped before.
  bool hasBeenBootstrapped();

  /// Load and boot all of the remaining deferred providers.
  void loadDeferredProviders();

  /// Set the current application locale.
  void setLocale(String locale);

  /// Determine if middleware has been disabled for the application.
  bool shouldSkipMiddleware();

  /// Register a terminating callback with the application.
  Application terminating(dynamic callback);

  /// Terminate the application.
  void terminate();
}
