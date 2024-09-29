import 'package:platform_core/core.dart';
import 'package:platform_container/container.dart';
import 'package:logging/logging.dart';
import 'service_provider.dart';
import 'provider_discovery.dart';

class ServiceProviderManager {
  final Application app;
  final Container container;
  final Map<Type, ServiceProvider> _providers = {};
  final Set<Type> _booted = {};
  final Logger _logger;
  final ProviderDiscovery _discovery;

  ServiceProviderManager(this.app, this._discovery)
      : container = app.container,
        _logger = Logger('ServiceProviderManager');

  void setLogLevel(Level level) {
    _logger.level = level;
  }

  Future<void> register(ServiceProvider provider) async {
    provider.app = app;
    provider.registerWithContainer(container);
    _providers[provider.runtimeType] = provider;
    try {
      _logger.info('Registering ${provider.runtimeType}');
      await provider.register();
      _logger.info('Registered ${provider.runtimeType}');
    } catch (e) {
      _logger.severe('Failed to register ${provider.runtimeType}', e);
      rethrow;
    }
  }

  void unregister(Type providerType) {
    if (_providers.containsKey(providerType)) {
      _logger.info('Unregistering $providerType');
      _providers.remove(providerType);
      _booted.remove(providerType);
    } else {
      _logger.warning(
          'Attempted to unregister non-existent provider: $providerType');
    }
  }

  T? getProvider<T extends ServiceProvider>() {
    return _providers[T] as T?;
  }

  Future<void> bootAll() async {
    for (var providerType in _providers.keys) {
      await _bootProvider(providerType);
    }
  }

  Future<void> _bootProvider(Type providerType) async {
    if (_booted.contains(providerType)) return;

    var provider = _providers[providerType];
    if (provider == null) {
      _logger.severe('Provider not found: $providerType');
      throw ProviderNotFoundException(providerType);
    }

    if (!provider.isEnabled) {
      _logger.info('Skipping disabled provider: $providerType');
      return;
    }

    if (provider.isDeferred) {
      _logger.info('Skipping deferred provider: $providerType');
      return;
    }

    for (var dependencyType in provider.dependencies) {
      await _bootProvider(dependencyType);
    }

    try {
      _logger.info('Booting ${provider.runtimeType}');
      await provider.beforeBoot();
      await provider.boot();
      await provider.afterBoot();
      _booted.add(providerType);
      _logger.info('Booted ${provider.runtimeType}');
    } catch (e) {
      _logger.severe('Failed to boot ${provider.runtimeType}', e);
      throw ProviderBootException(provider, e);
    }
  }

  Future<void> bootDeferredProvider(Type providerType) async {
    var provider = _providers[providerType];
    if (provider == null || !provider.isDeferred) {
      throw ProviderNotFoundException(providerType);
    }
    await _bootProvider(providerType);
  }

  Future<void> discoverProviders() async {
    for (var type in _discovery.discoverProviders()) {
      if (!_providers.containsKey(type)) {
        var instance = _discovery.createInstance(type);
        if (instance != null) {
          await register(instance);
        }
      }
    }
  }
}

class ProviderNotFoundException implements Exception {
  final Type providerType;

  ProviderNotFoundException(this.providerType);

  @override
  String toString() => 'Provider not found: $providerType';
}

class ProviderBootException implements Exception {
  final ServiceProvider provider;
  final Object error;

  ProviderBootException(this.provider, this.error);

  @override
  String toString() => 'Failed to boot ${provider.runtimeType}: $error';
}
