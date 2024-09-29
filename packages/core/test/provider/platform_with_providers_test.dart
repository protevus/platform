import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:platform_core/core.dart';
import 'package:platform_container/container.dart';
import 'package:platform_core/src/provider/platform_with_providers.dart';
import 'package:platform_core/src/provider/service_provider.dart';
import 'package:platform_core/src/provider/service_provider_manager.dart';
import 'package:platform_core/src/provider/provider_discovery.dart';

@GenerateMocks([ServiceProviderManager, ProviderDiscovery])
import 'platform_with_providers_test.mocks.dart';

void main() {
  group('PlatformWithProviders', () {
    late PlatformWithProviders platformWithProviders;
    late Application app;
    late MockServiceProviderManager mockManager;

    setUp(() {
      app = Application();
      mockManager = MockServiceProviderManager();

      platformWithProviders =
          PlatformWithProviders(app, serviceProviderManager: mockManager);
    });

    test('PlatformWithProviders initializes correctly', () {
      expect(platformWithProviders, isNotNull);
      expect(platformWithProviders.app, equals(app));
    });

    test('container is created', () {
      expect(platformWithProviders.container, isNotNull);
      expect(platformWithProviders.container, isA<Container>());
    });

    test('registerServiceProvider calls manager.register', () async {
      final provider = MockServiceProvider();
      await platformWithProviders.registerServiceProvider(provider);

      verify(mockManager.register(provider)).called(1);
    });

    test('bootServiceProviders calls manager.bootAll', () async {
      await platformWithProviders.bootServiceProviders();

      verify(mockManager.bootAll()).called(1);
    });

    // Add more tests for other methods in PlatformWithProviders
  });
}

class MockServiceProvider extends Mock implements ServiceProvider {}
