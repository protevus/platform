import 'package:test/test.dart';
import 'package:platform_reflection/reflection.dart';
import 'package:platform_support/platform_support.dart';

void main() {
  late Onceable onceable;

  setUp(() {
    onceable = Onceable();
  });

  tearDown(() {
    Reflector.reset();
  });

  group('Onceable', () {
    test('executes callback only once', () {
      var count = 0;
      final callback = () {
        count++;
        return 'result';
      };

      // First call should execute
      final result1 = onceable.once('test', callback);
      expect(count, equals(1));
      expect(result1, equals('result'));

      // Second call should not execute
      final result2 = onceable.once('test', callback);
      expect(count, equals(1));
      expect(result2, equals('result'));
    });

    test('handles void callbacks', () {
      var count = 0;
      final callback = () {
        count++;
      };

      // First call should execute
      onceable.once('test', callback);
      expect(count, equals(1));

      // Second call should not execute
      onceable.once('test', callback);
      expect(count, equals(1));
    });

    test('maintains separate state for different keys', () {
      var count1 = 0;
      var count2 = 0;

      final callback1 = () {
        count1++;
        return 'result1';
      };

      final callback2 = () {
        count2++;
        return 'result2';
      };

      // Execute first callback
      final result1 = onceable.once('test1', callback1);
      expect(count1, equals(1));
      expect(count2, equals(0));
      expect(result1, equals('result1'));

      // Execute second callback
      final result2 = onceable.once('test2', callback2);
      expect(count1, equals(1));
      expect(count2, equals(1));
      expect(result2, equals('result2'));
    });

    test('reset allows callback to execute again', () {
      var count = 0;
      final callback = () {
        count++;
        return 'result';
      };

      // First execution
      final result1 = onceable.once('test', callback);
      expect(count, equals(1));
      expect(result1, equals('result'));

      // Reset
      onceable.resetOnce('test');

      // Should execute again
      final result2 = onceable.once('test', callback);
      expect(count, equals(2));
      expect(result2, equals('result'));
    });

    test('resetAllOnce resets all callbacks', () {
      var count1 = 0;
      var count2 = 0;

      final callback1 = () {
        count1++;
        return 'result1';
      };

      final callback2 = () {
        count2++;
        return 'result2';
      };

      // Execute both callbacks
      onceable.once('test1', callback1);
      onceable.once('test2', callback2);
      expect(count1, equals(1));
      expect(count2, equals(1));

      // Reset all
      onceable.resetAllOnce();

      // Both should execute again
      onceable.once('test1', callback1);
      onceable.once('test2', callback2);
      expect(count1, equals(2));
      expect(count2, equals(2));
    });

    test('hasExecutedOnce returns correct state', () {
      final callback = () => 'result';

      expect(onceable.hasExecutedOnce('test'), isFalse);

      onceable.once('test', callback);
      expect(onceable.hasExecutedOnce('test'), isTrue);

      onceable.resetOnce('test');
      expect(onceable.hasExecutedOnce('test'), isFalse);
    });

    test('keys returns all registered keys', () {
      final callback = () => 'result';

      expect(onceable.keys, isEmpty);

      onceable.once('test1', callback);
      expect(onceable.keys, equals({'test1'}));

      onceable.once('test2', callback);
      expect(onceable.keys, equals({'test1', 'test2'}));
    });

    test('count returns number of registered callbacks', () {
      final callback = () => 'result';

      expect(onceable.count, equals(0));

      onceable.once('test1', callback);
      expect(onceable.count, equals(1));

      onceable.once('test2', callback);
      expect(onceable.count, equals(2));

      onceable.resetAllOnce();
      expect(onceable.count, equals(0));
    });
  });
}
