import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:platform_container/container.dart';
import 'package:platform_support/providers.dart';
import 'package:test/test.dart';

// Test service class
class TestService {
  final String message;
  TestService(this.message);
}

// Service registry for testing
class ServiceRegistry {
  static final Map<String, ServiceProvider> providers = {};
  static final Map<String, bool> booted = {};

  static void register(String key, ServiceProvider provider) {
    providers[key] = provider;
  }

  static void markBooted(String key) {
    booted[key] = true;
  }

  static ServiceProvider? get(String key) {
    return providers[key];
  }

  static bool isBooted(String key) {
    return booted[key] == true;
  }

  static void clear() {
    providers.clear();
    booted.clear();
  }
}

// Basic service provider for testing
class TestServiceProvider extends ServiceProvider {
  bool registerCalled = false;
  bool bootCalled = false;
  final String message;
  TestService? _service;

  TestServiceProvider([this.message = 'test']);

  @override
  void register() {
    super.register();
    registerCalled = true;
    _service = TestService(message);
    ServiceRegistry.register('test-service', this);
  }

  @override
  void boot() {
    super.boot();
    bootCalled = true;
    ServiceRegistry.markBooted('test-service');
  }

  @override
  List<String> provides() => ['test-service'];

  TestService? getService() => _service;
}

// Deferred service provider for testing
class DeferredTestProvider extends DeferredServiceProvider {
  bool registerCalled = false;
  bool bootCalled = false;
  TestService? _service;

  @override
  void register() {
    super.register();
    registerCalled = true;
    _service = TestService('deferred');
    ServiceRegistry.register('deferred-service', this);
  }

  @override
  void boot() {
    super.boot();
    bootCalled = true;
    ServiceRegistry.markBooted('deferred-service');
  }

  @override
  List<String> provides() => ['deferred-service'];

  TestService? getService() => _service;
}

// Provider with dependencies for testing
class DependentProvider extends ServiceProvider {
  bool registerCalled = false;
  bool bootCalled = false;
  TestService? _service;

  @override
  void register() {
    super.register();
    registerCalled = true;

    // Get the base service
    var baseProvider =
        ServiceRegistry.get('test-service') as TestServiceProvider?;
    if (baseProvider != null && ServiceRegistry.isBooted('test-service')) {
      var baseService = baseProvider.getService();
      if (baseService != null) {
        _service = TestService('dependent: ${baseService.message}');
      }
    }
    ServiceRegistry.register('dependent-service', this);
  }

  @override
  void boot() {
    super.boot();
    bootCalled = true;
    ServiceRegistry.markBooted('dependent-service');
  }

  @override
  List<String> provides() => ['dependent-service'];

  @override
  List<String> dependencies() => ['test-service'];

  TestService? getService() => _service;
}

void main() {
  group('ServiceProvider Tests', () {
    late Application app;

    setUp(() {
      app = Application(reflector: const EmptyReflector());
      ServiceRegistry.clear();
    });

    tearDown(() async {
      await app.close();
      ServiceRegistry.clear();
    });

    test('registers and boots non-deferred provider immediately', () async {
      var provider = TestServiceProvider();
      await app.registerProvider(provider);

      expect(provider.registerCalled, isTrue,
          reason: 'register() should be called');
      expect(provider.bootCalled, isTrue, reason: 'boot() should be called');
      expect(provider.getService(), isNotNull,
          reason: 'Service should be created');
      expect(provider.getService()?.message, equals('test'));
    });

    test('defers loading of deferred provider', () async {
      var provider = DeferredTestProvider();
      await app.registerProvider(provider);

      expect(provider.registerCalled, isFalse,
          reason: 'register() should not be called yet');
      expect(provider.bootCalled, isFalse,
          reason: 'boot() should not be called yet');
      expect(provider.getService(), isNull,
          reason: 'Service should not be created yet');
    });

    test('loads deferred provider when resolved', () async {
      var provider = DeferredTestProvider();
      await app.registerProvider(provider);
      await app.resolveProvider('deferred-service');

      expect(provider.registerCalled, isTrue,
          reason: 'register() should be called after resolution');
      expect(provider.bootCalled, isTrue,
          reason: 'boot() should be called after resolution');
      expect(provider.getService(), isNotNull,
          reason: 'Service should be created after resolution');
      expect(provider.getService()?.message, equals('deferred'));
    });

    test('resolves dependencies before booting provider', () async {
      var baseProvider = TestServiceProvider('base');
      var dependentProvider = DependentProvider();

      // Register base provider first to ensure it's ready
      await app.registerProvider(baseProvider);
      await app.registerProvider(dependentProvider);

      expect(baseProvider.registerCalled, isTrue,
          reason: 'Base provider register() should be called');
      expect(baseProvider.bootCalled, isTrue,
          reason: 'Base provider boot() should be called');
      expect(dependentProvider.registerCalled, isTrue,
          reason: 'Dependent provider register() should be called');
      expect(dependentProvider.bootCalled, isTrue,
          reason: 'Dependent provider boot() should be called');

      expect(
          dependentProvider.getService()?.message, equals('dependent: base'));
    });

    test('singleton registration works correctly', () async {
      var provider = TestServiceProvider();
      await app.registerProvider(provider);

      var service1 = provider.getService();
      var service2 = provider.getService();

      expect(identical(service1, service2), isTrue,
          reason: 'Should get same instance');
    });

    test('provider storage persists across resolutions', () async {
      var provider = DeferredTestProvider();
      await app.registerProvider(provider);

      // First resolution
      await app.resolveProvider('deferred-service');
      var service1 = provider.getService();

      // Second resolution
      await app.resolveProvider('deferred-service');
      var service2 = provider.getService();

      expect(identical(service1, service2), isTrue,
          reason: 'Should get same instance across resolutions');
    });
  });
}
