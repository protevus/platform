import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('Functions', () {
    test('defers callback execution', () async {
      var executed = false;
      final callback = Functions.defer(() => executed = true);
      expect(executed, isFalse);
      await callback.execute();
      expect(executed, isTrue);
    });

    test('creates callback collection', () {
      final collection = Functions.collection([
        Functions.defer(() => 1),
        Functions.defer(() => 2),
      ]);
      expect(collection, isA<DeferredCallbackCollection>());
      expect(collection.length, equals(2));
    });

    test('executes callback only once', () async {
      var count = 0;
      final callback = Functions.once(() => count++);
      await callback.execute();
      await callback.execute();
      expect(count, equals(1));
    });

    test('debounces callback execution', () async {
      var count = 0;
      final callback = Functions.debounce(
        () => count++,
        Duration(milliseconds: 50),
      );

      // First execution is delayed
      callback.execute();
      expect(count, equals(0));

      // Second execution cancels first and starts new delay
      callback.execute();
      expect(count, equals(0));

      // Wait for debounce to complete
      await Future.delayed(Duration(milliseconds: 100));
      expect(count, equals(1));
    });

    test('throttles callback execution', () async {
      var count = 0;
      final callback = Functions.throttle(
        () => count++,
        Duration(milliseconds: 50),
      );

      await callback.execute();
      await callback.execute();
      expect(count, equals(1));
    });

    test('memoizes callback results', () async {
      // Test with parameterless function
      var count = 0;
      final callback = Functions.memoize(() {
        count++;
        return 'result';
      });

      final result1 = await callback.execute([[]]);
      final result2 = await callback.execute([[]]);
      expect(result1, equals('result'));
      expect(result2, equals('result'));
      expect(count, equals(1));

      // Test with arguments
      count = 0;
      final callbackWithArgs = Functions.memoize((List<dynamic> args) {
        count++;
        return 'result ${args[0]}';
      });

      final result3 = await callbackWithArgs.execute([
        ['a']
      ]);
      final result4 = await callbackWithArgs.execute([
        ['a']
      ]);
      final result5 = await callbackWithArgs.execute([
        ['b']
      ]);
      expect(result3, equals('result a'));
      expect(result4, equals('result a'));
      expect(result5, equals('result b'));
      expect(count, equals(2));

      // Test with parameterless function again
      count = 0;
      final callbackNoArgs = Functions.memoize(() {
        count++;
        return 'result';
      });

      final result6 = await callbackNoArgs.execute([[]]);
      final result7 = await callbackNoArgs.execute([[]]);
      expect(result6, equals('result'));
      expect(result7, equals('result'));
      expect(count, equals(1));
    });

    test('executes callback after delay', () async {
      var executed = false;
      await Functions.after(Duration(milliseconds: 50), () {
        executed = true;
      });
      expect(executed, isTrue);
    });

    test('executes callback periodically', () async {
      var count = 0;
      final timer = Functions.every(
        Duration(milliseconds: 50),
        () => count++,
        immediate: true,
      );

      expect(count, equals(1)); // Immediate execution
      await Future.delayed(Duration(milliseconds: 120));
      timer.cancel();
      expect(count, greaterThan(1));
    });

    test('retries callback on failure', () async {
      var attempts = 0;
      final result = await Functions.retry(
        () {
          attempts++;
          if (attempts < 3) throw Exception('Retry needed');
          return 'success';
        },
        maxAttempts: 3,
        delay: Duration(milliseconds: 50),
      );

      expect(attempts, equals(3));
      expect(result, equals('success'));
    });

    test('times out callback execution', () async {
      expect(
        () => Functions.timeout(
          () => Future.delayed(Duration(seconds: 2)),
          Duration(milliseconds: 50),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('executes callback safely', () async {
      var error;
      final result = await Functions.safely(
        () => throw Exception('Test error'),
        (e) => error = e,
      );

      expect(result, isNull);
      expect(error, isA<Exception>());
    });

    test('executes callbacks in parallel', () async {
      final results = await Functions.parallel([
        () => Future.value(1),
        () => Future.value(2),
      ]);

      expect(results, equals([1, 2]));
    });

    test('executes callbacks in sequence', () async {
      final results = await Functions.sequence([
        () => Future.value(1),
        () => Future.value(2),
      ]);

      expect(results, equals([1, 2]));
    });

    test('executes callbacks until one completes', () async {
      final result = await Functions.any([
        () => Future.delayed(Duration(milliseconds: 100), () => 1),
        () => Future.value(2),
      ]);

      expect(result, equals(2));
    });

    test('finds executable in PATH', () {
      // This test assumes 'ls' exists on Unix or 'cmd.exe' on Windows
      final executable = Functions.executable(
        Platform.isWindows ? 'cmd.exe' : 'ls',
      );
      expect(executable, isNotNull);
    });

    test('rate limits callback execution', () async {
      var count = 0;
      final callback = Functions.rateLimit(
        () => count++,
        2,
        Duration(milliseconds: 100),
      );

      await callback.execute();
      await callback.execute();
      final result = await callback.execute();
      expect(count, equals(2));
      expect(result, isNull);
    });

    test('executes callback on next tick', () async {
      var executed = false;
      final callback = Functions.nextTick(() => executed = true);
      expect(executed, isFalse);
      await callback.execute();
      expect(executed, isTrue);
    });

    test('executes callback with error handler', () async {
      var error;
      final callback = Functions.withErrorHandler(
        () => throw Exception('Test error'),
        (e) => error = e,
      );

      expect(
        () => callback.execute(),
        throwsA(isA<Exception>()),
      );
      expect(error, isA<Exception>());
    });

    test('executes callback with completion handler', () async {
      var completed = false;
      final callback = Functions.withCompletion(
        () => 'result',
        () => completed = true,
      );

      final result = await callback.execute();
      expect(result, equals('result'));
      expect(completed, isTrue);
    });
  });
}
