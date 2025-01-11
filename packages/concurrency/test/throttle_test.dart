import 'dart:async';

import 'package:platform_concurrency/platform_concurrency.dart';
import 'package:test/test.dart';

void main() {
  group('Throttle', () {
    test('throttles task execution', () async {
      final throttle = Throttle(minInterval: const Duration(milliseconds: 100));
      final executions = <DateTime>[];

      // Execute tasks rapidly
      for (var i = 0; i < 3; i++) {
        await throttle.execute(() async {
          executions.add(DateTime.now());
        });
      }

      expect(executions.length, 3);
      expect(
        executions[1].difference(executions[0]).inMilliseconds,
        greaterThanOrEqualTo(90),
      );
      expect(
        executions[2].difference(executions[1]).inMilliseconds,
        greaterThanOrEqualTo(90),
      );
    });

    test('combines requests when enabled', () async {
      final throttle = Throttle(
        minInterval: const Duration(milliseconds: 100),
        combineRequests: true,
      );
      final executions = <int>[];

      // Start multiple tasks simultaneously
      final futures = await Future.wait([
        throttle.execute(() async {
          executions.add(1);
          return 1;
        }),
        throttle.execute(() async {
          executions.add(2);
          return 2;
        }),
        throttle.execute(() async {
          executions.add(3);
          return 3;
        }),
      ].map((f) => f.catchError((e) => e is ThrottleException ? -1 : throw e)));

      // Only the last task should have executed
      expect(executions, [3]);
      expect(futures, [-1, -1, 3]);
    });

    test('handles timeouts', () async {
      final throttle = Throttle(minInterval: const Duration(seconds: 1));
      final executions = <DateTime>[];

      // Execute first task
      await throttle.execute(() async {
        executions.add(DateTime.now());
      });

      // Try to execute second task with timeout
      expect(
        () => throttle.execute(
          () async => executions.add(DateTime.now()),
          timeout: const Duration(milliseconds: 100),
        ),
        throwsA(isA<ThrottleException>()),
      );

      expect(executions.length, 1);
    });

    test('processes queue in order without combining', () async {
      final throttle = Throttle(
        minInterval: const Duration(milliseconds: 100),
        combineRequests: false,
      );
      final executions = <int>[];

      // Queue up several tasks
      final futures = <Future>[];
      for (var i = 0; i < 3; i++) {
        futures.add(
          throttle.execute(() async {
            executions.add(i);
            return i;
          }),
        );
      }

      await Future.wait(futures);

      // Tasks should execute in order
      expect(executions, [0, 1, 2]);
    });

    test('cancels pending requests', () async {
      final throttle = Throttle(minInterval: const Duration(milliseconds: 100));
      final executions = <int>[];

      // Execute first task
      await throttle.execute(() async {
        executions.add(1);
      });

      // Queue up more tasks
      final futures = <Future>[];
      for (var i = 2; i <= 4; i++) {
        futures.add(
          throttle.execute(() async {
            executions.add(i);
          }),
        );
      }

      // Cancel before they execute
      throttle.cancel();

      // Wait a bit to ensure no more executions
      await Future.delayed(const Duration(milliseconds: 200));
      expect(executions, [1]);

      // Verify futures were rejected
      for (final future in futures) {
        expect(
          () => future,
          throwsA(isA<ThrottleException>()),
        );
      }
    });

    test('allows execution after minimum interval', () async {
      final throttle = Throttle(minInterval: const Duration(milliseconds: 100));
      final executions = <DateTime>[];

      // Execute first task
      await throttle.execute(() async {
        executions.add(DateTime.now());
      });

      // Wait just over minimum interval
      await Future.delayed(const Duration(milliseconds: 110));

      // Execute second task
      await throttle.execute(() async {
        executions.add(DateTime.now());
      });

      expect(executions.length, 2);
      expect(
        executions[1].difference(executions[0]).inMilliseconds,
        greaterThanOrEqualTo(100),
      );
    });

    test('runs void tasks', () async {
      final throttle = Throttle(minInterval: const Duration(milliseconds: 100));
      var executed = false;

      await throttle.run(() async {
        executed = true;
      });

      expect(executed, isTrue);
    });

    test('maintains execution order with async tasks', () async {
      final throttle = Throttle(minInterval: const Duration(milliseconds: 50));
      final order = <int>[];

      await Future.wait([
        throttle.execute(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          order.add(1);
          return 1;
        }),
        throttle.execute(() async {
          order.add(2);
          return 2;
        }),
      ]);

      expect(order, [1, 2]);
    });
  });
}
