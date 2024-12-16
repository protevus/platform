import 'dart:async';
import 'package:test/test.dart';
import 'package:platform_support/src/deferred/deferred_callback.dart';

void main() {
  group('DeferredCallback', () {
    test('executes callback with arguments', () async {
      var called = false;
      final callback = DeferredCallback((String arg) {
        called = true;
        expect(arg, equals('test'));
      });

      await callback.execute(['test']);
      expect(called, isTrue);
    });

    test('executes callback with named arguments', () async {
      var called = false;
      final callback = DeferredCallback(({required String name}) {
        called = true;
        expect(name, equals('test'));
      });

      await callback.execute([], {const Symbol('name'): 'test'});
      expect(called, isTrue);
    });

    test('executes callback after delay', () async {
      var called = false;
      final callback = DeferredCallback(() => called = true);

      expect(called, isFalse);
      await callback.executeAfter(Duration(milliseconds: 100));
      expect(called, isTrue);
    });

    test('executes callback deferred', () async {
      var called = false;
      final callback = DeferredCallback(() => called = true);

      expect(called, isFalse);
      await callback.executeDeferred();
      expect(called, isTrue);
    });

    test('executes callback safely', () async {
      var errorCaught = false;
      final callback = DeferredCallback(() => throw Exception('test'));

      await callback.executeSafely((error) {
        errorCaught = true;
        expect(error, isA<Exception>());
      });
      expect(errorCaught, isTrue);
    });

    test('executes callback with timeout', () async {
      final callback = DeferredCallback(() async {
        await Future.delayed(Duration(milliseconds: 200));
      });

      expect(
        () => callback.executeWithTimeout(Duration(milliseconds: 100)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('executes callback with retry', () async {
      var attempts = 0;
      final callback = DeferredCallback(() {
        attempts++;
        if (attempts < 3) {
          throw Exception('retry');
        }
        return 'success';
      });

      final result = await callback.executeWithRetry();
      expect(result, equals('success'));
      expect(attempts, equals(3));
    });

    test('executes callbacks in parallel', () async {
      final results = <int>[];
      final callbacks = [
        DeferredCallback(() async {
          await Future.delayed(Duration(milliseconds: 100));
          results.add(1);
          return 1;
        }),
        DeferredCallback(() async {
          await Future.delayed(Duration(milliseconds: 50));
          results.add(2);
          return 2;
        }),
      ];

      await DeferredCallback.executeParallel(callbacks);
      expect(results, equals([2, 1]));
    });

    test('executes callbacks in sequence', () async {
      final results = <int>[];
      final callbacks = [
        DeferredCallback(() async {
          await Future.delayed(Duration(milliseconds: 100));
          results.add(1);
          return 1;
        }),
        DeferredCallback(() async {
          await Future.delayed(Duration(milliseconds: 50));
          results.add(2);
          return 2;
        }),
      ];

      await DeferredCallback.executeSequential(callbacks);
      expect(results, equals([1, 2]));
    });

    test('executes callback only once', () async {
      var count = 0;
      final callback = DeferredCallback.once(() => count++);

      await callback.execute();
      await callback.execute();
      await callback.execute();

      expect(count, equals(1));
    });

    test('debounces callback execution', () async {
      var count = 0;
      final callback = DeferredCallback.debounce(
        () => count++,
        Duration(milliseconds: 50),
      );

      // Execute multiple times in quick succession
      callback.execute();
      await Future.delayed(Duration(milliseconds: 10));
      callback.execute();
      await Future.delayed(Duration(milliseconds: 10));
      callback.execute();

      // Wait for debounce period to complete
      await Future.delayed(Duration(milliseconds: 100));
      expect(count, equals(1)); // Should only execute once
    });

    test('throttles callback execution', () async {
      var count = 0;
      final callback = DeferredCallback.throttle(
        () => count++,
        Duration(milliseconds: 50),
      );

      // Execute multiple times in quick succession
      await callback.execute();
      await Future.delayed(Duration(milliseconds: 10));
      await callback.execute();
      await Future.delayed(Duration(milliseconds: 10));
      await callback.execute();

      // Wait for throttle period to complete
      await Future.delayed(Duration(milliseconds: 100));
      expect(count, equals(1)); // Should only execute once
    });

    test('memoizes callback results', () async {
      var count = 0;
      final callback = DeferredCallback.memoize((int x) {
        count++;
        return x * 2;
      });

      final result1 = await callback.execute([
        [5]
      ]);
      final result2 = await callback.execute([
        [5]
      ]);
      final result3 = await callback.execute([
        [10]
      ]);

      expect(result1, equals(10));
      expect(result2, equals(10));
      expect(result3, equals(20));
      expect(count, equals(2)); // Only computed twice
    });

    test('memoizes with maxAge', () async {
      var count = 0;
      final callback = DeferredCallback.memoize(
        (int x) {
          count++;
          return x * 2;
        },
        maxAge: Duration(milliseconds: 100),
      );

      await callback.execute([
        [5]
      ]);
      await Future.delayed(Duration(milliseconds: 150));
      await callback.execute([
        [5]
      ]);

      expect(count, equals(2)); // Computed twice due to maxAge
    });

    test('memoizes with maxSize', () async {
      var count = 0;
      final callback = DeferredCallback.memoize(
        (int x) {
          count++;
          return x * 2;
        },
        maxSize: 2,
      );

      await callback.execute([
        [1]
      ]);
      await callback.execute([
        [2]
      ]);
      await callback.execute([
        [3]
      ]);
      await callback.execute([
        [1]
      ]); // Should recompute

      expect(count, equals(4)); // Computed 4 times due to maxSize
    });

    test('creates callback from string', () {
      expect(
        () => DeferredCallback.fromString('invalid'),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => DeferredCallback.fromString('Class@method'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
