import 'dart:async';

import 'package:platform_concurrency/platform_concurrency.dart';
import 'package:test/test.dart';

void main() {
  group('SyncDriver', () {
    late Driver driver;

    setUp(() {
      driver = SyncDriver();
    });

    test('runs tasks sequentially', () async {
      final order = <int>[];
      final tasks = List.generate(
          3,
          (i) => () async {
                order.add(i);
                return i;
              });

      final results = await driver.runAll(tasks);

      expect(results, [0, 1, 2]);
      expect(order, [0, 1, 2]);
    });

    test('handles task failures', () async {
      expect(
        () => driver.run(() => throw Exception('Task failed')),
        throwsA(isA<ConcurrencyException>()),
      );
    });

    test('defers task execution', () async {
      final order = <int>[];

      // Schedule deferred tasks
      await driver.defer(() async {
        order.add(1);
      });

      await driver.defer(() async {
        order.add(2);
      });

      // Add immediate task
      order.add(0);

      // Wait for deferred tasks to complete
      await Future.delayed(Duration.zero);

      expect(order, [0, 1, 2]);
    });
  });

  group('IsolateDriver', () {
    late Driver driver;

    setUp(() {
      driver = IsolateDriver();
    });

    test('runs tasks concurrently', () async {
      final startTime = DateTime.now();
      final tasks = List.generate(
          3,
          (_) => () async {
                await Future.delayed(const Duration(milliseconds: 100));
                return true;
              });

      final results = await driver.runAll(tasks);
      final duration = DateTime.now().difference(startTime);

      // All tasks should complete in roughly 100ms, not 300ms
      expect(duration.inMilliseconds, lessThan(200));
      expect(results, [true, true, true]);
    });

    test('handles task failures', () async {
      expect(
        () => driver.run(() => throw Exception('Task failed')),
        throwsA(isA<ConcurrencyException>()),
      );
    });

    test('respects maxConcurrent limit', () async {
      final driver = IsolateDriver(maxConcurrent: 2);
      final order = <int>[];
      final tasks = List.generate(
          4,
          (i) => () async {
                order.add(i);
                await Future.delayed(const Duration(milliseconds: 100));
                return i;
              });

      final results = await driver.runAll(tasks);

      // Tasks should run in pairs due to maxConcurrent: 2
      expect(order.take(2).toSet().length, 2); // First two ran concurrently
      expect(order.skip(2).toSet().length, 2); // Last two ran concurrently
      expect(results, [0, 1, 2, 3]);
    });
  });

  group('ProcessDriver', () {
    late Driver driver;

    setUp(() {
      driver = ProcessDriver();
    });

    test('runs tasks in separate processes', () async {
      final results = await driver.runAll([
        () async => 1,
        () async => 2,
        () async => 3,
      ]);

      expect(results, [1, 2, 3]);
    });

    test('handles task failures', () async {
      expect(
        () => driver.run(() => throw Exception('Task failed')),
        throwsA(isA<ConcurrencyException>()),
      );
    });

    test('respects maxConcurrent limit', () async {
      final driver = ProcessDriver(maxConcurrent: 2);
      final startTime = DateTime.now();
      final tasks = List.generate(
          4,
          (_) => () async {
                await Future.delayed(const Duration(milliseconds: 100));
                return true;
              });

      await driver.runAll(tasks);
      final duration = DateTime.now().difference(startTime);

      // Should take roughly 200ms (2 batches of 2 tasks)
      expect(duration.inMilliseconds, greaterThan(190));
      expect(duration.inMilliseconds, lessThan(300));
    });
  });

  group('ConcurrencyManager', () {
    late ConcurrencyManager manager;

    setUp(() {
      manager = ConcurrencyManager();
    });

    test('uses default driver', () async {
      final result = await manager.run(() => 42);
      expect(result, [42]);
    });

    test('switches drivers', () async {
      manager.setDefaultDriver('sync');
      final result = await manager.run(() => 42);
      expect(result, [42]);
    });

    test('throws on invalid driver', () {
      expect(
        () => manager.setDefaultDriver('invalid'),
        throwsA(isA<ConcurrencyException>()),
      );
    });

    test('caches driver instances', () async {
      final driver1 = await manager.driver('sync');
      final driver2 = await manager.driver('sync');
      expect(identical(driver1, driver2), isTrue);
    });
  });
}
