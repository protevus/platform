import 'package:platform_core/core.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:logging/logging.dart';
import 'service_provider.dart';
import 'service_provider_manager.dart';
import 'service_provider_config.dart';
import 'provider_discovery.dart';

class PlatformWithProviders {
  final Application app;
  late ServiceProviderManager _serviceProviderManager;
  late ProviderDiscovery _discovery;
  late Container container;

  PlatformWithProviders(this.app,
      {ServiceProviderManager? serviceProviderManager}) {
    container = Container(MirrorsReflector());
    app.configure(configureContainer);

    _serviceProviderManager =
        serviceProviderManager ?? ServiceProviderManager(app, _discovery);
  }

  Future<void> configureContainer(Application app) async {
    // Register the container itself
    container.registerSingleton((c) => container);

    // Configure the container here
    // For example, you might want to register some services:
    // container.registerSingleton((c) => SomeService());

    // You might need to set up dependency injection for routes here
    // app.use((req, res) => container.make<SomeService>().handleRequest(req, res));
  }

  Future<void> registerProvidersFromConfig(ServiceProviderConfig config) async {
    for (var providerType in config.providers) {
      var provider = _discovery.createInstance(providerType);
      if (provider != null) {
        if (config.deferredProviders.containsKey(providerType)) {
          provider.setDeferred(config.deferredProviders[providerType]!);
        }
        if (config.providerConfigs.containsKey(providerType)) {
          provider.configure(config.providerConfigs[providerType]!);
        }
        await _serviceProviderManager.register(provider);
      }
    }
  }

  Future<void> registerServiceProvider(ServiceProvider provider) async {
    await _serviceProviderManager.register(provider);
  }

  void unregisterServiceProvider(Type providerType) {
    _serviceProviderManager.unregister(providerType);
  }

  T? getServiceProvider<T extends ServiceProvider>() {
    return _serviceProviderManager.getProvider<T>();
  }

  Future<void> bootServiceProviders() async {
    await _serviceProviderManager.bootAll();
  }

  Future<void> bootDeferredServiceProvider(Type providerType) async {
    await _serviceProviderManager.bootDeferredProvider(providerType);
  }

  void setServiceProviderLogLevel(Level level) {
    _serviceProviderManager.setLogLevel(level);
  }

  Future<void> discoverServiceProviders() async {
    await _serviceProviderManager.discoverProviders();
  }

  void registerProviderType(Type type, ServiceProvider Function() factory) {
    if (_discovery is ManualProviderDiscovery) {
      (_discovery as ManualProviderDiscovery)
          .registerProviderType(type, factory);
    } else {
      throw UnsupportedError(
          'Provider type registration is only supported with ManualProviderDiscovery');
    }
  }

  T? getService<T>() {
    return app.container.make<T>();
  }
}
