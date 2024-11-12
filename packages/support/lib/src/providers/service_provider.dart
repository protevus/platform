import 'package:meta/meta.dart';
import 'package:platform_core/core.dart';
import 'package:platform_container/container.dart';
import 'contracts/service_provider.dart';
import 'service_provider_static.dart';

/// Base class for all service providers.
///
/// Service providers are the central place to configure your application's services.
/// Within a service provider, you may bind things into the service container, register
/// events, middleware, or perform any other tasks to prepare your application for
/// incoming requests.
abstract class ServiceProvider
    with ServiceProviderStatic
    implements ServiceProviderContract {
  /// The application instance.
  late Application app;

  /// All of the registered booting callbacks.
  final List<Function> bootingCallbacks = [];

  /// All of the registered booted callbacks.
  final List<Function> bootedCallbacks = [];

  /// Create a new service provider instance.
  ServiceProvider();

  /// Register any application services.
  @override
  @mustCallSuper
  void register() {}

  /// Bootstrap any application services.
  @override
  @mustCallSuper
  void boot() {
    callBootingCallbacks();
    callBootedCallbacks();
  }

  /// Register a booting callback to be run before the boot operations.
  void booting(Function callback) {
    bootingCallbacks.add(callback);
  }

  /// Register a booted callback to be run after the boot operations.
  void booted(Function callback) {
    bootedCallbacks.add(callback);
  }

  /// Call the registered booting callbacks.
  void callBootingCallbacks() {
    for (var callback in bootingCallbacks) {
      callback();
    }
  }

  /// Call the registered booted callbacks.
  void callBootedCallbacks() {
    for (var callback in bootedCallbacks) {
      callback();
    }
  }

  /// Merge the given configuration with the existing configuration.
  @protected
  void mergeConfigFrom(String path, String key) {
    // TODO: Implement config merging
  }

  /// Replace the given configuration with the existing configuration recursively.
  @protected
  void replaceConfigRecursivelyFrom(String path, String key) {
    // TODO: Implement recursive config replacement
  }

  /// Load the given routes file if routes are not already cached.
  @protected
  void loadRoutesFrom(String path) {
    // TODO: Implement route loading
  }

  /// Register a view file namespace.
  @protected
  void loadViewsFrom(String path, String namespace) {
    // TODO: Implement view loading
  }

  /// Register the given view components with a custom prefix.
  @protected
  void loadViewComponentsAs(String prefix, List<Type> components) {
    // TODO: Implement view component loading
  }

  /// Register a translation file namespace.
  @protected
  void loadTranslationsFrom(String path, String namespace) {
    // TODO: Implement translation loading
  }

  /// Register a JSON translation file path.
  @protected
  void loadJsonTranslationsFrom(String path) {
    // TODO: Implement JSON translation loading
  }

  /// Register database migration paths.
  @protected
  void loadMigrationsFrom(dynamic paths) {
    // TODO: Implement migration loading
  }

  /// Register Eloquent model factory paths.
  @protected
  @Deprecated('Will be removed in a future version.')
  void loadFactoriesFrom(dynamic paths) {
    // TODO: Implement factory loading
  }

  /// Setup an after resolving listener, or fire immediately if already resolved.
  @protected
  void callAfterResolving(String name, Function callback) {
    // TODO: Implement after resolving
  }

  /// Register migration paths to be published by the publish command.
  @protected
  void publishesMigrations(List<String> paths, [dynamic groups]) {
    // TODO: Implement migration publishing
  }

  /// Register paths to be published by the publish command.
  @protected
  void registerPublishables(Map<String, String> paths, [dynamic groups]) {
    // TODO: Implement path publishing
  }

  /// Laravel API compatibility method - forwards to registerPublishables
  @protected
  @Deprecated('Use registerPublishables instead')
  void publishes(Map<String, String> paths, [dynamic groups]) =>
      registerPublishables(paths, groups);

  /// Ensure the publish array for the service provider is initialized.
  @protected
  void ensurePublishArrayInitialized(String className) {
    // TODO: Implement publish array initialization
  }

  /// Add a publish group / tag to the service provider.
  @protected
  void addPublishGroup(String group, Map<String, String> paths) {
    // TODO: Implement publish group addition
  }

  /// Get the paths to publish.
  Map<String, String> pathsToPublish([String? provider, String? group]) {
    // TODO: Implement paths to publish
    return {};
  }

  /// Get the paths for the provider or group (or both).
  @protected
  Map<String, String> pathsForProviderOrGroup(String? provider, String? group) {
    // TODO: Implement provider/group paths
    return {};
  }

  /// Get the paths for the provider and group.
  @protected
  Map<String, String> pathsForProviderAndGroup(String provider, String group) {
    // TODO: Implement provider and group paths
    return {};
  }

  /// Get the service providers available for publishing.
  List<String> publishableProviders() {
    // TODO: Implement publishable providers
    return [];
  }

  /// Get the migration paths available for publishing.
  List<String> publishableMigrationPaths() {
    return List.from(ServiceProviderStatic.publishableMigrationPaths);
  }

  /// Get the groups available for publishing.
  List<String> publishableGroups() {
    // TODO: Implement publishable groups
    return [];
  }

  /// Register the package's custom Artisan commands.
  void commands(List<Type> commands) {
    // TODO: Implement command registration
  }

  /// Get the services provided by the provider.
  List<String> provides() => [];

  /// Get the events that trigger this service provider to register.
  List<String> when() => [];

  /// Determine if the provider is deferred.
  bool isDeferred() => false;

  /// Get the default providers for a Laravel application.
  List<Type> defaultProviders() {
    // TODO: Implement default providers
    return [];
  }

  /// Add the given provider to the application's provider bootstrap file.
  bool addProviderToBootstrapFile(String provider, [String? path]) {
    // TODO: Implement provider bootstrap
    return false;
  }

  // Container convenience methods - these are extensions to Laravel's spec
  // to make working with Dart's type system more ergonomic

  /// Register a singleton binding in the container.
  void singleton<T>(T instance) {
    app.container.registerSingleton(instance);
  }

  /// Register a binding in the container.
  void bind<T>(T Function(Container) factory) {
    app.container.registerFactory<T>(factory);
  }

  /// Get a service from the container.
  T make<T>([Type? type]) {
    return app.container.make<T>(type);
  }

  /// Determine if a service exists in the container.
  bool has<T>() {
    return app.container.has<T>();
  }

  /// Register a tagged binding in the container.
  void tag(List<Type> abstracts, List<Type> tags) {
    app.startupHooks.add((app) {
      for (var type in abstracts) {
        for (var tag in tags) {
          app.container.registerSingleton(app.container.make(type), as: tag);
        }
      }
    });
  }

  /// Register an event listener.
  void listen(String event, RequestHandler listener) {
    app.startupHooks.add((app) {
      app.fallback((req, res) {
        if (req.uri?.path == event) {
          return listener(req, res);
        }
        return true;
      });
    });
  }

  /// Register a middleware.
  void middleware(String name, RequestHandler handler) {
    app.startupHooks.add((app) {
      app.responseFinalizers.add(handler);
    });
  }
}
