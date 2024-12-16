import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';
import 'package:platform_macroable/platform_macroable.dart';

void main() {
  group('Optional', () {
    test('can be instantiated with null value', () {
      final optional = Optional(null);
      expect(optional.value, isNull);
      expect(optional.isPresent, isFalse);
      expect(optional.isEmpty, isTrue);
    });

    test('can be instantiated with non-null value', () {
      final optional = Optional(42);
      expect(optional.value, equals(42));
      expect(optional.isPresent, isTrue);
      expect(optional.isEmpty, isFalse);
    });

    test('can be created using Optional.of factory', () {
      final optional = Optional.of('test');
      expect(optional.value, equals('test'));
      expect(optional.isPresent, isTrue);
    });

    test('get returns default value when empty', () {
      final optional = Optional<String>(null);
      expect(optional.get('default'), equals('default'));
    });

    test('get returns value when present', () {
      final optional = Optional('value');
      expect(optional.get('default'), equals('value'));
    });

    test('map transforms value when present', () {
      final optional = Optional(5);
      final result = optional.map((value) => value * 2);
      expect(result.value, equals(10));
    });

    test('map returns empty optional when value is null', () {
      final optional = Optional<int>(null);
      final result = optional.map((value) => value * 2);
      expect(result.value, isNull);
    });

    test('valueOrThrow returns value when present', () {
      final optional = Optional(42);
      expect(optional.valueOrThrow, equals(42));
    });

    test('valueOrThrow throws when empty', () {
      final optional = Optional<int>(null);
      expect(() => optional.valueOrThrow, throwsStateError);
    });

    test('ifPresent executes callback when value is present', () {
      var executed = false;
      final optional = Optional(42);
      optional.ifPresent((_) => executed = true);
      expect(executed, isTrue);
    });

    test('ifPresent does not execute callback when value is null', () {
      var executed = false;
      final optional = Optional<int>(null);
      optional.ifPresent((_) => executed = true);
      expect(executed, isFalse);
    });

    test('equals works correctly', () {
      final optional1 = Optional(42);
      final optional2 = Optional(42);
      final optional3 = Optional(24);
      final optional4 = Optional<int>(null);

      expect(optional1, equals(optional2));
      expect(optional1, isNot(equals(optional3)));
      expect(optional1, isNot(equals(optional4)));
    });

    test('toString provides meaningful representation', () {
      expect(Optional(42).toString(), equals('Optional(42)'));
      expect(Optional(null).toString(), equals('Optional(null)'));
    });

    test('supports macros through noSuchMethod', () {
      // Create an optional with a value
      final optional = Optional(5);

      // Try to call a non-existent method
      expect(
        () => (optional as dynamic).nonExistentMethod(),
        throwsNoSuchMethodError,
      );
    });
  });
}
