import 'package:test/test.dart';
import 'package:platform_core/src/provider/provider_discovery.dart';
import 'package:platform_core/src/provider/service_provider.dart';

class TestServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {}

  @override
  Future<void> boot() async {}
}

void main() {
  group('ManualProviderDiscovery', () {
    late ManualProviderDiscovery discovery;

    setUp(() {
      discovery = ManualProviderDiscovery();
    });

    test('registerProviderType adds type and factory', () {
      discovery.registerProviderType(
          TestServiceProvider, () => TestServiceProvider());

      expect(discovery.discoverProviders(), contains(TestServiceProvider));
      expect(discovery.createInstance(TestServiceProvider),
          isA<TestServiceProvider>());
    });
  });

  // Note: Testing MirrorProviderDiscovery is challenging in a unit test environment
  // due to its reliance on runtime reflection. Consider integration tests for this.
}
