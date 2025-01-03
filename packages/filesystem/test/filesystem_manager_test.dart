import 'package:test/test.dart';
import 'package:platform_filesystem/filesystem.dart';
import 'package:platform_contracts/contracts.dart';

class CustomDriver implements CloudFilesystemContract {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Map<String, dynamic> config;
  late FilesystemManager manager;

  setUp(() {
    config = {
      'default': 'local',
      'disks': {
        'local': {
          'driver': 'local',
          'root': '/tmp/local',
        },
        'custom': {
          'driver': 'custom',
          'root': '/tmp/custom',
        },
      },
    };
    manager = FilesystemManager(config);
  });

  group('FilesystemManager', () {
    test('creates default disk', () {
      final disk = manager.disk();
      expect(disk, isA<CloudFilesystemContract>());
    });

    test('creates named disk', () {
      final disk = manager.disk('local');
      expect(disk, isA<CloudFilesystemContract>());
    });

    test('caches disk instances', () {
      final disk1 = manager.disk('local');
      final disk2 = manager.disk('local');
      expect(identical(disk1, disk2), isTrue);
    });

    test('returns default driver name', () {
      expect(manager.getDefaultDriver(), equals('local'));
    });

    test('returns disk config', () {
      final diskConfig = manager.getConfig('local');
      expect(
          diskConfig,
          equals({
            'driver': 'local',
            'root': '/tmp/local',
          }));
    });

    test('returns default disk config when name not provided', () {
      final diskConfig = manager.getConfig();
      expect(
          diskConfig,
          equals({
            'driver': 'local',
            'root': '/tmp/local',
          }));
    });

    test('returns empty config for unknown disk', () {
      final diskConfig = manager.getConfig('unknown');
      expect(diskConfig, equals({}));
    });

    test('registers custom driver', () {
      manager.extend('custom', (config) => CustomDriver());
      final disk = manager.disk('custom');
      expect(disk, isA<CustomDriver>());
    });

    test('throws for unknown driver', () {
      expect(
        () => manager.disk('unknown'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('uses provided default disk', () {
      final manager = FilesystemManager(config, 'custom');
      expect(manager.getDefaultDriver(), equals('custom'));
    });

    test('falls back to config default disk', () {
      final manager = FilesystemManager(config);
      expect(manager.getDefaultDriver(), equals('local'));
    });

    test('falls back to local if no default specified', () {
      final manager = FilesystemManager({
        'disks': {
          'local': {'driver': 'local'},
        },
      });
      expect(manager.getDefaultDriver(), equals('local'));
    });
  });
}
