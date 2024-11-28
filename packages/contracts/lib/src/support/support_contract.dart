import 'package:meta/meta.dart';

/// Contract for service providers.
///
/// Laravel-compatible: Core service provider functionality matching
/// Laravel's ServiceProvider class, adapted for Dart's type system.
@sealed
abstract class ServiceProviderContract {
  /// Registers application services.
  ///
  /// Laravel-compatible: Core registration method.
  void register();

  /// Bootstraps application services.
  ///
  /// Laravel-compatible: Core bootstrap method.
  void boot();

  /// Gets services provided by this provider.
  ///
  /// Laravel-compatible: Lists provided services.
  List<String> provides();

  /// Gets events that trigger registration.
  ///
  /// Laravel-compatible: Lists registration triggers.
  List<String> when();

  /// Whether provider is deferred.
  ///
  /// Laravel-compatible: Controls lazy loading.
  bool isDeferred();

  /// Gets the application instance.
  ///
  /// Laravel-compatible: Application access.
  /// Uses dynamic type for flexibility.
  dynamic get app;

  /// Sets the application instance.
  ///
  /// Laravel-compatible: Application injection.
  /// Uses dynamic type for flexibility.
  set app(dynamic value);

  /// Gets booting callbacks.
  ///
  /// Laravel-compatible: Boot phase callbacks.
  List<Function> get bootingCallbacks;

  /// Gets booted callbacks.
  ///
  /// Laravel-compatible: Post-boot callbacks.
  List<Function> get bootedCallbacks;

  /// Registers a booting callback.
  ///
  /// Laravel-compatible: Boot phase hook.
  void booting(Function callback);

  /// Registers a booted callback.
  ///
  /// Laravel-compatible: Post-boot hook.
  void booted(Function callback);

  /// Calls booting callbacks.
  ///
  /// Laravel-compatible: Executes boot phase hooks.
  void callBootingCallbacks();

  /// Calls booted callbacks.
  ///
  /// Laravel-compatible: Executes post-boot hooks.
  void callBootedCallbacks();

  /// Merges configuration.
  ///
  /// Laravel-compatible: Config merging.
  void mergeConfigFrom(String path, String key);

  /// Replaces configuration recursively.
  ///
  /// Laravel-compatible: Deep config replacement.
  void replaceConfigRecursivelyFrom(String path, String key);

  /// Loads routes from file.
  ///
  /// Laravel-compatible: Route loading.
  void loadRoutesFrom(String path);

  /// Loads views from directory.
  ///
  /// Laravel-compatible: View loading.
  void loadViewsFrom(String path, String namespace);

  /// Loads view components.
  ///
  /// Laravel-compatible: Component loading.
  void loadViewComponentsAs(String prefix, List<Type> components);

  /// Loads translations from directory.
  ///
  /// Laravel-compatible: Translation loading.
  void loadTranslationsFrom(String path, String namespace);

  /// Loads JSON translations.
  ///
  /// Laravel-compatible: JSON translation loading.
  void loadJsonTranslationsFrom(String path);

  /// Loads database migrations.
  ///
  /// Laravel-compatible: Migration loading.
  void loadMigrationsFrom(dynamic paths);

  /// Loads model factories.
  ///
  /// Laravel-compatible: Factory loading.
  @Deprecated('Will be removed in a future version.')
  void loadFactoriesFrom(dynamic paths);

  /// Sets up after resolving listener.
  ///
  /// Laravel-compatible: Resolution hook.
  void callAfterResolving(String name, Function callback);

  /// Publishes migrations.
  ///
  /// Laravel-compatible: Migration publishing.
  void publishesMigrations(List<String> paths, [dynamic groups]);

  /// Registers publishable paths.
  ///
  /// Laravel-compatible: Asset publishing.
  void registerPublishables(Map<String, String> paths, [dynamic groups]);

  /// Legacy method for registering publishables.
  ///
  /// Laravel-compatible: Legacy publish method.
  @Deprecated('Use registerPublishables instead')
  void publishes(Map<String, String> paths, [dynamic groups]);

  /// Initializes publish array.
  ///
  /// Laravel-compatible: Publish setup.
  void ensurePublishArrayInitialized(String className);

  /// Adds a publish group.
  ///
  /// Laravel-compatible: Group publishing.
  void addPublishGroup(String group, Map<String, String> paths);

  /// Gets paths to publish.
  ///
  /// Laravel-compatible: Publish path lookup.
  Map<String, String> pathsToPublish([String? provider, String? group]);

  /// Gets paths for provider or group.
  ///
  /// Laravel-compatible: Provider/group path lookup.
  Map<String, String> pathsForProviderOrGroup(String? provider, String? group);

  /// Gets paths for provider and group.
  ///
  /// Laravel-compatible: Combined path lookup.
  Map<String, String> pathsForProviderAndGroup(String provider, String group);

  /// Gets publishable providers.
  ///
  /// Laravel-compatible: Provider listing.
  List<String> publishableProviders();

  /// Gets publishable migration paths.
  ///
  /// Laravel-compatible: Migration path listing.
  List<String> publishableMigrationPaths();

  /// Gets publishable groups.
  ///
  /// Laravel-compatible: Group listing.
  List<String> publishableGroups();

  /// Registers commands.
  ///
  /// Laravel-compatible: Command registration.
  void commands(List<Type> commands);

  /// Gets default providers.
  ///
  /// Laravel-compatible: Default provider listing.
  List<Type> defaultProviders();

  /// Adds provider to bootstrap file.
  ///
  /// Laravel-compatible: Provider bootstrapping.
  bool addProviderToBootstrapFile(String provider, [String? path]);

  /// Registers a singleton.
  ///
  /// Laravel-compatible: Singleton binding with Dart typing.
  void singleton<T>(T instance);

  /// Registers a factory binding.
  ///
  /// Laravel-compatible: Factory binding with Dart typing.
  void bind<T>(T Function(dynamic) factory);

  /// Gets a service.
  ///
  /// Laravel-compatible: Service resolution with Dart typing.
  T make<T>([Type? type]);

  /// Checks if service exists.
  ///
  /// Laravel-compatible: Binding check with Dart typing.
  bool has<T>();

  /// Registers tagged bindings.
  ///
  /// Laravel-compatible: Tag binding with Dart typing.
  void tag(List<Type> abstracts, List<Type> tags);

  /// Registers an event listener.
  ///
  /// Laravel-compatible: Event listener registration.
  void listen(String event, Function listener);

  /// Registers middleware.
  ///
  /// Laravel-compatible: Middleware registration.
  void middleware(String name, Function handler);
}

/// Contract for deferrable providers.
///
/// Laravel-compatible: Defines providers that can be loaded
/// on demand rather than at application startup.
@sealed
abstract class DeferrableProviderContract {
  /// Gets services provided by this provider.
  ///
  /// Laravel-compatible: Lists deferred services.
  List<String> provides();
}

/// Contract for provider static functionality.
///
/// Platform-specific: Provides static helper methods and properties
/// following Laravel's patterns for static configuration.
@sealed
abstract class ServiceProviderStaticContract {
  /// Gets publishable migration paths.
  static final List<String> publishableMigrationPaths = [];

  /// Gets publishable paths.
  static final Map<String, Map<String, String>> publishablePaths = {};

  /// Gets publishable groups.
  static final Map<String, Map<String, String>> publishableGroups = {};

  /// Gets publishable provider paths.
  static final Map<String, Map<String, String>> publishableProviderPaths = {};
}
