import 'dart:async';

import 'package:platform_concurrency/platform_concurrency.dart';
import 'package:test/test.dart';

void main() {
  group('Scheduler', () {
    late Scheduler scheduler;
    late Driver driver;

    setUp(() {
      driver = SyncDriver();
      scheduler = Scheduler(driver);
    });

    tearDown(() {
      scheduler.stop();
    });

    test('schedules tasks with intervals', () async {
      final executions = <DateTime>[];
      final completer = Completer<void>();

      scheduler.schedule(
        () async {
          executions.add(DateTime.now());
          if (executions.length == 3) {
            completer.complete();
          }
        },
        interval: const Duration(milliseconds: 100),
      );

      scheduler.start();
      await completer.future;

      // Should have executed roughly 100ms apart
      expect(executions.length, 3);
      expect(
        executions[1].difference(executions[0]).inMilliseconds,
        closeTo(100, 50),
      );
      expect(
        executions[2].difference(executions[1]).inMilliseconds,
        closeTo(100, 50),
      );
    });

    test('schedules tasks with cron expressions', () async {
      final executions = <DateTime>[];
      final completer = Completer<void>();

      // Schedule for every minute
      scheduler.schedule(
        () async {
          executions.add(DateTime.now());
          if (executions.length == 2) {
            completer.complete();
          }
        },
        cron: '* * * * *',
      );

      scheduler.start();

      // Wait until next minute boundary
      final now = DateTime.now();
      await Future.delayed(
        Duration(
          seconds: 60 - now.second,
          milliseconds: -now.millisecond,
        ),
      );

      await completer.future;
      expect(executions.length, 2);
    });

    test('handles immediate execution', () async {
      final executions = <DateTime>[];

      scheduler.schedule(
        () async => executions.add(DateTime.now()),
        interval: const Duration(hours: 1),
        runImmediately: true,
      );

      scheduler.start();
      await Future.delayed(Duration.zero);

      expect(executions.length, 1);
    });

    test('cancels tasks', () async {
      final executions = <DateTime>[];

      final id = scheduler.schedule(
        () async => executions.add(DateTime.now()),
        interval: const Duration(milliseconds: 100),
      );

      scheduler.start();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(scheduler.cancel(id), isTrue);
      await Future.delayed(const Duration(milliseconds: 200));

      expect(executions.isEmpty, isTrue);
    });

    test('stops and restarts scheduling', () async {
      final executions = <DateTime>[];

      scheduler.schedule(
        () async => executions.add(DateTime.now()),
        interval: const Duration(milliseconds: 100),
      );

      scheduler.start();
      await Future.delayed(const Duration(milliseconds: 250));

      scheduler.stop();
      final countAfterStop = executions.length;

      await Future.delayed(const Duration(milliseconds: 200));
      expect(executions.length, countAfterStop);

      scheduler.start();
      await Future.delayed(const Duration(milliseconds: 200));
      expect(executions.length, greaterThan(countAfterStop));
    });
  });

  group('CronExpression', () {
    test('parses valid expressions', () {
      expect(() => CronExpression('* * * * *'), returnsNormally);
      expect(() => CronExpression('0 0 * * *'), returnsNormally);
      expect(() => CronExpression('*/15 * * * *'), returnsNormally);
      expect(() => CronExpression('0 */2 * * *'), returnsNormally);
    });

    test('rejects invalid expressions', () {
      expect(() => CronExpression('* * *'), throwsA(isA<SchedulerException>()));
      expect(() => CronExpression('60 * * * *'),
          throwsA(isA<SchedulerException>()));
      expect(() => CronExpression('* 24 * * *'),
          throwsA(isA<SchedulerException>()));
    });

    test('calculates next execution time', () {
      final cron = CronExpression('0 * * * *'); // Every hour
      final now = DateTime.now();
      final next = cron.nextAfter(now);

      expect(next.minute, equals(0));
      expect(
        next.hour,
        equals(now.minute > 0 ? (now.hour + 1) % 24 : now.hour),
      );
    });

    test('handles step values', () {
      final cron = CronExpression('*/15 * * * *'); // Every 15 minutes
      final now = DateTime(2024, 1, 1, 10, 10); // 10:10
      final next = cron.nextAfter(now);

      expect(next.minute, equals(15));
      expect(next.hour, equals(10));
    });

    test('handles ranges', () {
      final cron =
          CronExpression('0 9-17 * * *'); // Every hour from 9 AM to 5 PM
      final now = DateTime(2024, 1, 1, 8, 0); // 8:00
      final next = cron.nextAfter(now);

      expect(next.hour, equals(9));
      expect(next.minute, equals(0));
    });

    test('handles lists', () {
      final cron =
          CronExpression('0 9,12,17 * * *'); // At 9 AM, 12 PM, and 5 PM
      final now = DateTime(2024, 1, 1, 10, 0); // 10:00
      final next = cron.nextAfter(now);

      expect(next.hour, equals(12));
      expect(next.minute, equals(0));
    });
  });
}
