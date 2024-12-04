import 'package:test/test.dart';
import 'package:platform_support/src/env.dart';

void main() {
  setUp(() {
    // Clear the cache before each test
    Env.clear();
  });

  group('Env', () {
    test('get returns environment variable value', () {
      Env.put('APP_NAME', 'MyApp');
      expect(Env.get('APP_NAME'), equals('MyApp'));
    });

    test('get returns default value when variable not found', () {
      expect(Env.get('MISSING_VAR', 'default'), equals('default'));
    });

    test('get returns null when no default provided and variable not found',
        () {
      expect(Env.get('MISSING_VAR'), isNull);
    });

    test('getBool returns true for truthy values', () {
      final truthyValues = {
        'true': true,
        'TRUE': true,
        '1': true,
        'yes': true,
        'YES': true,
        'on': true,
        'ON': true,
      };

      for (final entry in truthyValues.entries) {
        Env.put('BOOL_VAR', entry.key);
        expect(Env.getBool('BOOL_VAR'), equals(entry.value),
            reason: 'Failed for value: ${entry.key}');
      }
    });

    test('getBool returns false for non-truthy values', () {
      final falsyValues = {
        'false': false,
        'FALSE': false,
        '0': false,
        'no': false,
        'NO': false,
        'off': false,
        'OFF': false,
        'invalid': false,
      };

      for (final entry in falsyValues.entries) {
        Env.put('BOOL_VAR', entry.key);
        expect(Env.getBool('BOOL_VAR'), equals(entry.value),
            reason: 'Failed for value: ${entry.key}');
      }
    });

    test('getBool returns default value when variable not found', () {
      expect(Env.getBool('MISSING_VAR', true), isTrue);
      expect(Env.getBool('MISSING_VAR', false), isFalse);
    });

    test('getInt returns integer value', () {
      Env.put('INT_VAR', '42');
      expect(Env.getInt('INT_VAR'), equals(42));
    });

    test('getInt returns default value for invalid integer', () {
      Env.put('INT_VAR', 'not-an-int');
      expect(Env.getInt('INT_VAR', 123), equals(123));
    });

    test('getInt returns default value when variable not found', () {
      expect(Env.getInt('MISSING_VAR', 456), equals(456));
    });

    test('getDouble returns double value', () {
      Env.put('DOUBLE_VAR', '3.14');
      expect(Env.getDouble('DOUBLE_VAR'), equals(3.14));
    });

    test('getDouble returns default value for invalid double', () {
      Env.put('DOUBLE_VAR', 'not-a-double');
      expect(Env.getDouble('DOUBLE_VAR', 2.718), equals(2.718));
    });

    test('getDouble returns default value when variable not found', () {
      expect(Env.getDouble('MISSING_VAR', 1.618), equals(1.618));
    });

    test('has returns true when variable exists', () {
      Env.put('EXISTING_VAR', 'value');
      expect(Env.has('EXISTING_VAR'), isTrue);
    });

    test('has returns false when variable does not exist', () {
      expect(Env.has('NON_EXISTING_VAR'), isFalse);
    });

    test('put sets environment variable', () {
      Env.put('NEW_VAR', 'value');
      expect(Env.get('NEW_VAR'), equals('value'));
    });

    test('forget removes variable from cache', () {
      Env.put('TEMP_VAR', 'value');
      expect(Env.get('TEMP_VAR'), equals('value'));

      Env.forget('TEMP_VAR');
      expect(Env.get('TEMP_VAR'), isNull);
    });

    test('clear removes all variables from cache', () {
      Env.put('VAR1', 'value1');
      Env.put('VAR2', 'value2');
      expect(Env.get('VAR1'), equals('value1'));
      expect(Env.get('VAR2'), equals('value2'));

      Env.clear();
      expect(Env.get('VAR1'), isNull);
      expect(Env.get('VAR2'), isNull);
    });

    test('values are cached', () {
      Env.put('CACHED_VAR', 'original');
      expect(Env.get('CACHED_VAR'), equals('original'));

      // Modifying the environment outside the cache shouldn't affect the cached value
      Env.put('CACHED_VAR', 'modified');
      expect(Env.get('CACHED_VAR'), equals('modified'));

      // Forgetting should clear the cache
      Env.forget('CACHED_VAR');
      expect(Env.get('CACHED_VAR'), isNull);
    });
  });
}
