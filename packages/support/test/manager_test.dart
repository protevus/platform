import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_support/src/fluent.dart';
import 'package:platform_support/src/manager.dart';
import 'package:test/test.dart';

// Test driver interface
abstract class TestDriver {
  String getName();
}

// Test driver implementations
class LocalDriver implements TestDriver {
  @override
  String getName() => 'local';
}

class CloudDriver implements TestDriver {
  final String region;
  CloudDriver(this.region);
  @override
  String getName() => 'cloud:$region';
}

// Test manager implementation
class TestManager extends Manager {
  TestManager(Container container) : super(container);

  @override
  String? getDefaultDriver() {
    var attributes = config.getAttributes();
    print('Config attributes: $attributes'); // Debug print
    return config.get('test.driver');
  }

  @override
  dynamic callDriverCreator(String method) {
    print('Creating driver with method: $method'); // Debug print
    switch (method) {
      case 'createLocalDriver':
        return LocalDriver();
      case 'createCloudDriver':
        var region = config.get('test.cloud.region', 'us-east-1');
        return CloudDriver(region);
      default:
        return null;
    }
  }

  String getName() => driver<TestDriver>().getName();
}

void main() {
  group('Manager', () {
    late Container container;
    late TestManager manager;

    setUp(() {
      container = Container(MirrorsReflector());
      var attributes = {
        'test': {'driver': 'local'}
      }; // Nested attributes
      var config = Fluent(attributes);
      print('Setting up config with attributes: $attributes'); // Debug print
      container.registerSingleton<Fluent>(config);
      manager = TestManager(container);
    });

    test('uses default driver when no driver specified', () {
      var driver = manager.driver<TestDriver>();
      expect(driver.getName(), equals('local'));
    });

    test('creates driver instance', () {
      var driver = manager.driver<TestDriver>('local');
      expect(driver.getName(), equals('local'));
    });

    test('caches driver instances', () {
      var driver1 = manager.driver<TestDriver>('local');
      var driver2 = manager.driver<TestDriver>('local');
      expect(identical(driver1, driver2), isTrue);
    });

    test('supports custom driver creators', () {
      manager.extend('custom', (container) => CloudDriver('custom-region'));
      var driver = manager.driver<TestDriver>('custom');
      expect(driver.getName(), equals('cloud:custom-region'));
    });

    test('throws on unsupported driver', () {
      expect(
          () => manager.driver('unsupported'), throwsA(isA<ArgumentError>()));
    });

    test('throws on null driver with no default', () {
      // Create new container and manager for this test
      var testContainer = Container(MirrorsReflector());
      testContainer.registerSingleton<Fluent>(Fluent());
      var testManager = TestManager(testContainer);
      expect(() => testManager.driver(), throwsA(isA<ArgumentError>()));
    });

    test('forgets cached drivers', () {
      var driver1 = manager.driver<TestDriver>('local');
      manager.forgetDrivers();
      var driver2 = manager.driver<TestDriver>('local');
      expect(identical(driver1, driver2), isFalse);
    });

    test('returns unmodifiable driver map', () {
      manager.driver<TestDriver>('local');
      var drivers = manager.getDrivers();
      expect(() => drivers['local'] = LocalDriver(),
          throwsA(isA<UnsupportedError>()));
    });

    test('forwards method calls to default driver', () {
      expect(manager.getName(), equals('local'));
    });
  });
}
