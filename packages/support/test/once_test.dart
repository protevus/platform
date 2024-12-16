import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';

void main() {
  group('Once', () {
    test('executes callback only once', () {
      var count = 0;
      final once = Once();

      // First call should execute
      once.call(() {
        count++;
        return 'result';
      });
      expect(count, equals(1));

      // Second call should not execute
      once.call(() {
        count++;
        return 'different result';
      });
      expect(count, equals(1));
    });

    test('returns same result for subsequent calls', () {
      final once = Once();
      final result1 = once.call(() => 'first');
      final result2 = once.call(() => 'second');

      expect(result1, equals('first'));
      expect(result2, equals('first'));
    });

    test('maintains type safety', () {
      final once = Once();
      final result1 = once.call<int>(() => 42);
      final result2 = once.call<int>(() => 24);

      expect(result1, equals(42));
      expect(result2, equals(42));
      expect(result1.runtimeType, equals(int));
    });

    test('reset allows callback to execute again', () {
      var count = 0;
      final once = Once();

      // First execution
      final result1 = once.call(() {
        count++;
        return 'first';
      });
      expect(count, equals(1));
      expect(result1, equals('first'));

      // Reset
      once.reset();

      // Should execute again after reset
      final result2 = once.call(() {
        count++;
        return 'second';
      });
      expect(count, equals(2));
      expect(result2, equals('second'));
    });

    test('executed property reflects state correctly', () {
      final once = Once();
      expect(once.executed, isFalse);

      once.call(() => 'result');
      expect(once.executed, isTrue);

      once.reset();
      expect(once.executed, isFalse);
    });

    test('handles null return values', () {
      final once = Once();
      final result1 = once.call<String?>(() => null);
      final result2 = once.call<String?>(() => 'not null');

      expect(result1, isNull);
      expect(result2, isNull);
    });

    test('handles complex return types', () {
      final once = Once();
      final result1 = once.call<Map<String, int>>(() => {'a': 1, 'b': 2});
      final result2 = once.call<Map<String, int>>(() => {'c': 3});

      expect(result1, equals({'a': 1, 'b': 2}));
      expect(result2, equals({'a': 1, 'b': 2}));
    });
  });
}
