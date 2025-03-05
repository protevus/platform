import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_hashing/hashing.dart';
import 'package:test/test.dart';

class TestConfig implements ConfigContract {
  final Map<String, dynamic> _data = {};

  @override
  Map<String, dynamic> all() => _data;

  @override
  T? get<T>(String key, [T? defaultValue]) {
    final parts = key.split('.');
    dynamic current = _data;

    for (final part in parts) {
      if (current is! Map) return defaultValue;
      if (!current.containsKey(part)) return defaultValue;
      current = current[part];
    }

    return current as T?;
  }

  @override
  bool has(String key) {
    final parts = key.split('.');
    dynamic current = _data;

    for (final part in parts) {
      if (current is! Map) return false;
      if (!current.containsKey(part)) return false;
      current = current[part];
    }

    return true;
  }

  @override
  void prepend(String key, dynamic value) {
    final current = get<List>(key) ?? [];
    current.insert(0, value);
    set(key, current);
  }

  @override
  void push(String key, dynamic value) {
    final current = get<List>(key) ?? [];
    current.add(value);
    set(key, current);
  }

  @override
  void set(String key, dynamic value) {
    final parts = key.split('.');
    dynamic current = _data;

    for (var i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      current[part] = current[part] is Map ? current[part] : {};
      current = current[part];
    }

    current[parts.last] = value;
  }
}

void main() {
  group('HashManager', () {
    late ConfigContract config;
    late HashManager manager;

    setUp(() {
      config = TestConfig();
      manager = HashManager(config);
    });

    test('default driver is bcrypt', () {
      expect(manager.getDefaultDriver(), equals('bcrypt'));
    });

    test('can override default driver', () {
      config.set('hashing.driver', 'argon2id');
      expect(manager.getDefaultDriver(), equals('argon2id'));
    });

    test('can create bcrypt hasher', () {
      final hasher = manager.createBcryptDriver();
      expect(hasher, isA<BcryptHasher>());
    });

    test('can create argon hasher', () {
      final hasher = manager.createArgonDriver();
      expect(hasher, isA<ArgonHasher>());
    });

    test('can create argon2id hasher', () {
      final hasher = manager.createArgon2idDriver();
      expect(hasher, isA<Argon2IdHasher>());
    });

    test('driver method returns default driver', () {
      final hasher = manager.driver();
      expect(hasher, isA<BcryptHasher>());
    });

    test('driver method returns specified driver', () {
      final hasher = manager.driver('argon2id');
      expect(hasher, isA<Argon2IdHasher>());
    });

    test('driver method caches instances', () {
      final hasher1 = manager.driver();
      final hasher2 = manager.driver();
      expect(identical(hasher1, hasher2), isTrue);
    });

    test('driver method throws for invalid driver', () {
      expect(
        () => manager.driver('invalid'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('isHashed returns false for non-hashed value', () {
      expect(manager.isHashed('foo'), isFalse);
    });

    test('isHashed returns true for hashed value', () {
      final hash = manager.make('password');
      expect(manager.isHashed(hash), isTrue);
    });

    test('make delegates to driver', () {
      final hash = manager.make('password');
      expect(manager.check('password', hash), isTrue);
    });

    test('check delegates to driver', () {
      final hash = manager.make('password');
      expect(manager.check('wrong', hash), isFalse);
    });

    test('needsRehash delegates to driver', () {
      final hash = manager.make('password');
      expect(manager.needsRehash(hash), isFalse);
      expect(manager.needsRehash(hash, {'rounds': 1}), isTrue);
    });

    test('info delegates to driver', () {
      final hash = manager.make('password');
      final info = manager.info(hash);
      expect(info['algoName'], equals('bcrypt'));
    });
  });
}
