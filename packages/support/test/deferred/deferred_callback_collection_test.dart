import 'dart:async';
import 'package:test/test.dart';
import 'package:illuminate_support/src/deferred/deferred_callback.dart';
import 'package:illuminate_support/src/deferred/deferred_callback_collection.dart';

void main() {
  group('DeferredCallbackCollection', () {
    test('executes callbacks in parallel', () async {
      final results = <int>[];
      final collection = DeferredCallbackCollection([
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
      ]);

      await collection.executeParallel();
      expect(results, equals([2, 1]));
    });

    test('executes callbacks in sequence', () async {
      final results = <int>[];
      final collection = DeferredCallbackCollection([
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
      ]);

      await collection.executeSequential();
      expect(results, equals([1, 2]));
    });

    test('executes until success', () async {
      var attempts = 0;
      final collection = DeferredCallbackCollection([
        DeferredCallback(() {
          attempts++;
          throw Exception('fail');
        }),
        DeferredCallback(() {
          attempts++;
          return 'success';
        }),
        DeferredCallback(() {
          attempts++;
          return 'not reached';
        }),
      ]);

      final result = await collection.executeUntilSuccess();
      expect(result, equals('success'));
      expect(attempts, equals(2));
    });

    test('executes until failure', () async {
      final results = <String>[];
      final collection = DeferredCallbackCollection([
        DeferredCallback(() {
          results.add('success1');
          return 'success1';
        }),
        DeferredCallback(() {
          throw Exception('fail');
        }),
        DeferredCallback(() {
          results.add('not reached');
          return 'not reached';
        }),
      ]);

      final executedResults = await collection.executeUntilFailure();
      expect(executedResults, equals(['success1']));
      expect(results, equals(['success1']));
    });

    test('executes with delay', () async {
      final results = <int>[];
      final collection = DeferredCallbackCollection([
        DeferredCallback(() {
          results.add(1);
          return 1;
        }),
        DeferredCallback(() {
          results.add(2);
          return 2;
        }),
      ]);

      final startTime = DateTime.now();
      await collection.executeWithDelay(Duration(milliseconds: 100));
      final duration = DateTime.now().difference(startTime);

      expect(results, equals([1, 2]));
      expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
    });

    test('executes with timeout', () async {
      final collection = DeferredCallbackCollection([
        DeferredCallback(() async {
          await Future.delayed(Duration(milliseconds: 50));
          return 1;
        }),
        DeferredCallback(() async {
          await Future.delayed(Duration(milliseconds: 200));
          return 2;
        }),
      ]);

      final results =
          await collection.executeWithTimeout(Duration(milliseconds: 100));
      expect(results[0], equals(1));
      expect(results[1], isA<TimeoutException>());
    });

    test('executes safely', () async {
      final collection = DeferredCallbackCollection([
        DeferredCallback(() => 1),
        DeferredCallback(() => throw Exception('error')),
        DeferredCallback(() => 3),
      ]);

      final results = await collection.executeSafely();
      expect(results, equals([1, null, 3]));
    });

    test('executes with retry', () async {
      var attempts = 0;
      final collection = DeferredCallbackCollection([
        DeferredCallback(() {
          attempts++;
          if (attempts < 3) throw Exception('retry');
          return 'success';
        }),
      ]);

      final results = await collection.executeWithRetry();
      expect(results, equals(['success']));
      expect(attempts, equals(3));
    });

    test('executes with parallel limit', () async {
      final results = <int>[];
      final collection = DeferredCallbackCollection([
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
        DeferredCallback(() async {
          await Future.delayed(Duration(milliseconds: 75));
          results.add(3);
          return 3;
        }),
      ]);

      await collection.executeParallelLimit(2);
      expect(results.length, equals(3));
    });

    test('executes with rate limit', () async {
      final results = <int>[];
      final collection = DeferredCallbackCollection([
        DeferredCallback(() {
          results.add(1);
          return 1;
        }),
        DeferredCallback(() {
          results.add(2);
          return 2;
        }),
        DeferredCallback(() {
          results.add(3);
          return 3;
        }),
      ]);

      final startTime = DateTime.now();
      await collection.executeRateLimited(2, Duration(milliseconds: 100));
      final duration = DateTime.now().difference(startTime);

      expect(results, equals([1, 2, 3]));
      expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
    });

    test('filters callbacks', () async {
      final collection = DeferredCallbackCollection([
        DeferredCallback(() => 1),
        DeferredCallback(() => 2),
        DeferredCallback(() => 3),
      ]);

      // Create a map of callbacks to their results for filtering
      final results = <DeferredCallback, int>{};
      for (final callback in collection.all()) {
        results[callback] = await callback.execute() as int;
      }

      final filtered = collection.where((callback) => results[callback]! > 1);
      expect(filtered.length, equals(2));
    });

    test('maps callbacks', () {
      final collection = DeferredCallbackCollection([
        DeferredCallback(() => 1),
        DeferredCallback(() => 2),
      ]);

      final mapped =
          collection.mapItems((callback) => DeferredCallback(() async {
                final result = await callback.execute();
                return result * 2;
              }));

      expect(mapped.length, equals(2));
    });

    test('gets only specified callbacks', () {
      final collection = DeferredCallbackCollection([
        DeferredCallback(() => 1),
        DeferredCallback(() => 2),
        DeferredCallback(() => 3),
      ]);

      final subset = collection.only([0, 2]);
      expect(subset.length, equals(2));
    });

    test('gets except specified callbacks', () {
      final collection = DeferredCallbackCollection([
        DeferredCallback(() => 1),
        DeferredCallback(() => 2),
        DeferredCallback(() => 3),
      ]);

      final subset = collection.except([1]);
      expect(subset.length, equals(2));
    });

    test('gets random callback', () {
      final collection = DeferredCallbackCollection([
        DeferredCallback(() => 1),
        DeferredCallback(() => 2),
        DeferredCallback(() => 3),
      ]);

      final random = collection.random();
      expect(random, isA<DeferredCallback>());
      expect(collection.contains(random), isTrue);
    });

    test('gets unique callbacks', () {
      final collection = DeferredCallbackCollection([
        DeferredCallback(() => 1),
        DeferredCallback(() => 1),
        DeferredCallback(() => 2),
      ]);

      final unique = collection.unique();
      expect(unique.length, equals(3)); // Each callback is unique by reference
    });
  });
}
