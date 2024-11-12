import 'dart:async';
import 'package:platform_core/core.dart';
import 'service_provider.dart';

/// Storage class for service provider state
class ServiceProviderStorage {
  /// The registered service providers
  final Map<String, ServiceProvider> providers = {};

  /// The loaded provider types
  final Set<Type> loaded = {};

  /// The deferred services and their dependencies
  final Map<String, List<String>> deferred = {};
}

/// Extension that adds service provider support to [Application].
extension ServiceProviderSupport on Application {
  /// Get the provider storage instance.
  ServiceProviderStorage get _storage {
    if (!container.has<ServiceProviderStorage>()) {
      container.registerSingleton(ServiceProviderStorage());
    }
    return container.make<ServiceProviderStorage>();
  }

  /// Register a service provider with the application.
  Future<void> registerProvider(ServiceProvider provider) async {
    provider.app = this;

    var provides = provider.provides();
    for (var service in provides) {
      _storage.providers[service] = provider;
      if (provider.isDeferred()) {
        _storage.deferred[service] = provider.when();
      }
    }

    if (!provider.isDeferred()) {
      await _bootProvider(provider);
    }
  }

  /// Boot a service provider.
  Future<void> _bootProvider(ServiceProvider provider) async {
    if (_storage.loaded.contains(provider.runtimeType)) return;

    try {
      // Boot dependencies first
      for (var dependency in provider.when()) {
        await resolveProvider(dependency);
      }

      // Call booting callbacks
      provider.callBootingCallbacks();

      // Register the provider
      await Future.sync(() => provider.register());

      // Execute any startup hooks that were registered during registration
      for (var hook in startupHooks.toList()) {
        await hook(this);
      }
      startupHooks.clear();

      // Boot the provider
      await Future.sync(() => provider.boot());

      // Call booted callbacks
      provider.callBootedCallbacks();

      _storage.loaded.add(provider.runtimeType);
    } catch (e) {
      // If registration fails, remove from loaded providers
      _storage.loaded.remove(provider.runtimeType);
      rethrow;
    }
  }

  /// Resolve a service provider.
  Future<void> resolveProvider(String service) async {
    var provider = _storage.providers[service];
    if (provider != null && !_storage.loaded.contains(provider.runtimeType)) {
      await _bootProvider(provider);
    }
  }
}
