import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/src/provider/service_provider_manager.dart';
import 'package:platform_core/src/provider/service_provider.dart';
import 'package:platform_core/src/provider/provider_discovery.dart';
import 'package:platform_container/container.dart' as container;
import 'service_provider_manager_test.mocks.dart';

//class MockAngel extends Mock implements Application {}

//class MockServiceProvider extends Mock implements ServiceProvider {}

//class MockProviderDiscovery extends Mock implements ProviderDiscovery {}

// Generate mocks
@GenerateMocks(
    [Application, ServiceProvider, ProviderDiscovery, container.Container])
void main() {
  group('ServiceProviderManager', () {
    late ServiceProviderManager manager;
    late Application mockAngel;
    late MockProviderDiscovery mockDiscovery;
    late MockContainer mockContainer;

    setUp(() {
      mockAngel = Application();
      mockDiscovery = MockProviderDiscovery();
      mockContainer = MockContainer();
      when(mockAngel.container).thenReturn(mockContainer);
      manager = ServiceProviderManager(mockAngel, mockDiscovery);
    });

    test('register adds provider and calls register method', () async {
      final provider = MockServiceProvider();
      await manager.register(provider);

      verify(provider.registerWithContainer(any)).called(1);
      verify(provider.register()).called(1);
    });

    test('bootAll calls boot for all providers', () async {
      final provider1 = MockServiceProvider();
      final provider2 = MockServiceProvider();

      when(provider1.isEnabled).thenReturn(true);
      when(provider2.isEnabled).thenReturn(true);
      when(provider1.isDeferred).thenReturn(false);
      when(provider2.isDeferred).thenReturn(false);

      await manager.register(provider1);
      await manager.register(provider2);

      await manager.bootAll();

      verify(provider1.beforeBoot()).called(1);
      verify(provider1.boot()).called(1);
      verify(provider1.afterBoot()).called(1);
      verify(provider2.beforeBoot()).called(1);
      verify(provider2.boot()).called(1);
      verify(provider2.afterBoot()).called(1);
    });

    test('bootDeferredProvider boots only the specified provider', () async {
      final provider1 = MockServiceProvider();
      final provider2 = MockServiceProvider();

      when(provider1.isDeferred).thenReturn(true);
      when(provider2.isDeferred).thenReturn(true);

      await manager.register(provider1);
      await manager.register(provider2);

      await manager.bootDeferredProvider(provider1.runtimeType);

      verify(provider1.beforeBoot()).called(1);
      verify(provider1.boot()).called(1);
      verify(provider1.afterBoot()).called(1);
      verifyNever(provider2.beforeBoot());
      verifyNever(provider2.boot());
      verifyNever(provider2.afterBoot());
    });

    test('unregister removes the provider', () async {
      final provider = MockServiceProvider();
      await manager.register(provider);
      manager.unregister(provider.runtimeType);

      expect(manager.getProvider<MockServiceProvider>(), isNull);
    });
  });
}
