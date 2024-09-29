import 'package:test/test.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/src/provider/platform_with_providers.dart';
import 'package:platform_core/src/provider/service_provider.dart';
import 'package:platform_core/src/provider/service_provider_config.dart';

class TestService {
  String getData() => 'Test Data';
}

class TestServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    container.registerSingleton((container) => TestService());
  }

  @override
  Future<void> boot() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

class DeferredServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    container.registerSingleton((container) => 'Deferred Service');
  }

  @override
  Future<void> boot() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

void main() {
  late Application app;
  late PlatformWithProviders platformWithProviders;

  setUp(() async {
    app = Application();
    platformWithProviders = PlatformWithProviders(app);
    // Allow some time for the platform to initialize
    await Future.delayed(Duration(milliseconds: 100));
  });

  tearDown(() async {
    await app.close();
  });

  group('Service Provider Integration Tests', () {
    test('Manual provider registration works', () async {
      await platformWithProviders
          .registerServiceProvider(TestServiceProvider());
      await platformWithProviders.bootServiceProviders();

      var testService = platformWithProviders.container.make<TestService>();
      expect(testService, isNotNull);
      expect(testService.getData(), equals('Test Data'));
    });

    test('Deferred provider is not booted initially', () async {
      var config = ServiceProviderConfig(
        providers: [DeferredServiceProvider],
        deferredProviders: {DeferredServiceProvider: true},
      );
      await platformWithProviders.registerProvidersFromConfig(config);
      await platformWithProviders.bootServiceProviders();

      expect(() => platformWithProviders.container.make<String>(),
          throwsException);
    });

    test('Deferred provider can be booted on demand', () async {
      var config = ServiceProviderConfig(
        providers: [DeferredServiceProvider],
        deferredProviders: {DeferredServiceProvider: true},
      );
      await platformWithProviders.registerProvidersFromConfig(config);
      await platformWithProviders.bootServiceProviders();
      await platformWithProviders
          .bootDeferredServiceProvider(DeferredServiceProvider);

      var deferredService = platformWithProviders.container.make<String>();
      expect(deferredService, equals('Deferred Service'));
    });
  });
}
