import 'dart:async';

import 'package:platform_concurrency/platform_concurrency.dart';
import 'package:test/test.dart';

void main() {
  group('Mutex', () {
    late Mutex mutex;

    setUp(() {
      mutex = Mutex();
    });

    test('allows sequential access', () async {
      final results = <int>[];

      await mutex.synchronized(() async {
        results.add(1);
        await Future.delayed(Duration.zero);
        results.add(2);
      });

      await mutex.synchronized(() async {
        results.add(3);
        await Future.delayed(Duration.zero);
        results.add(4);
      });

      expect(results, [1, 2, 3, 4]);
    });

    test('prevents concurrent access', () async {
      final results = <int>[];
      var task1Started = false;
      var task2Started = false;

      // Start two tasks that try to acquire the lock
      final future1 = mutex.synchronized(() async {
        task1Started = true;
        await Future.delayed(const Duration(milliseconds: 50));
        results.add(1);
      });

      final future2 = mutex.synchronized(() async {
        task2Started = true;
        results.add(2);
      });

      // Wait a bit to let tasks start
      await Future.delayed(const Duration(milliseconds: 10));

      // First task should have started, second should be waiting
      expect(task1Started, isTrue);
      expect(task2Started, isFalse);

      // Wait for both tasks to complete
      await Future.wait([future1, future2]);

      // Results should be in order
      expect(results, [1, 2]);
    });

    test('handles timeouts', () async {
      // Acquire lock
      final lockFuture = mutex.acquire();
      await Future.delayed(Duration.zero);
      expect(mutex.isLocked, isTrue);

      // Try to acquire with timeout
      expect(
        () => mutex.acquire(timeout: const Duration(milliseconds: 50)),
        throwsA(isA<MutexException>()),
      );
    });

    test('releases lock after task completion', () async {
      await mutex.synchronized(() async {
        expect(mutex.isLocked, isTrue);
      });

      expect(mutex.isLocked, isFalse);
    });

    test('releases lock after task failure', () async {
      expect(
        mutex.synchronized(() => throw Exception('Task failed')),
        throwsException,
      );

      expect(mutex.isLocked, isFalse);
    });

    test('supports guard pattern', () async {
      final results = <int>[];
      final task = () async {
        results.add(1);
        await Future.delayed(Duration.zero);
        results.add(2);
      };

      final guard = mutex.guard(task);
      await guard.protect();

      expect(results, [1, 2]);
    });

    test('guard supports timeout', () async {
      // Acquire lock
      final lockFuture = mutex.acquire();
      await Future.delayed(Duration.zero);
      expect(mutex.isLocked, isTrue);

      // Try to acquire with guard and timeout
      final guard = mutex.guard(() async {}).withTimeout(
            const Duration(milliseconds: 50),
          );

      expect(
        () => guard.protect(),
        throwsA(isA<MutexException>()),
      );
    });

    test('throws when releasing unlocked mutex', () {
      expect(
        () => mutex.release(),
        throwsA(isA<MutexException>()),
      );
    });

    test('maintains FIFO order for waiting tasks', () async {
      final order = <int>[];

      // Acquire initial lock
      final initialLock = mutex.acquire();
      await Future.delayed(Duration.zero);

      // Queue up several tasks
      final futures = <Future>[];
      for (var i = 0; i < 3; i++) {
        futures.add(mutex.synchronized(() async {
          order.add(i);
        }));
      }

      // Release initial lock
      mutex.release();

      // Wait for all tasks to complete
      await Future.wait(futures);

      // Tasks should complete in order
      expect(order, [0, 1, 2]);
    });
  });
}
