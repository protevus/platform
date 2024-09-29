import 'package:test/test.dart';
import 'package:platform_core/src/provider/service_provider_config.dart';

void main() {
  group('ServiceProviderConfig', () {
    test('fromMap creates correct config', () {
      final map = {
        'providers': [
          {
            'type': 'TestServiceProvider',
            'deferred': true,
            'config': {'key': 'value'}
          },
          {'type': 'AnotherServiceProvider', 'deferred': false},
        ]
      };

      final config = ServiceProviderConfig.fromMap(map);

      expect(config.providers.length, equals(2));
      expect(config.deferredProviders.length, equals(1));
      expect(config.providerConfigs.length, equals(1));
      // Note: This test assumes you've implemented _getTypeFromString to handle these provider types
      // You might need to adjust this part of the test based on your actual implementation
    });
  });
}
