import 'dart:async';
import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('Timebox', () {
    test('completes within timeout', () async {
      final result = await Timebox.run(
        () => 'success',
        timeout: Duration(seconds: 1),
      );
      expect(result, equals('success'));
    });

    test('handles async operation within timeout', () async {
      final result = await Timebox.run(
        () async {
          await Future.delayed(Duration(milliseconds: 50));
          return 'success';
        },
        timeout: Duration(seconds: 1),
      );
      expect(result, equals('success'));
    });

    test('throws on timeout', () async {
      expect(
        () => Timebox.run(
          () async {
            await Future.delayed(Duration(seconds: 2));
            return 'success';
          },
          timeout: Duration(milliseconds: 100),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('executes onTimeout callback', () async {
      final result = await Timebox.run(
        () async {
          await Future.delayed(Duration(seconds: 2));
          return 'success';
        },
        timeout: Duration(milliseconds: 100),
        onTimeout: () => 'timeout',
      );
      expect(result, equals('timeout'));
    });

    test('handles async onTimeout callback', () async {
      final result = await Timebox.run(
        () async {
          await Future.delayed(Duration(seconds: 2));
          return 'success';
        },
        timeout: Duration(milliseconds: 100),
        onTimeout: () async {
          await Future.delayed(Duration(milliseconds: 50));
          return 'timeout';
        },
      );
      expect(result, equals('timeout'));
    });

    test('returns default value on timeout', () async {
      final result = await Timebox.runWithDefault(
        () async {
          await Future.delayed(Duration(seconds: 2));
          return 'success';
        },
        defaultValue: 'default',
        timeout: Duration(milliseconds: 100),
      );
      expect(result, equals('default'));
    });

    test('completes check returns true within timeout', () async {
      final completed = await Timebox.completes(
        () async {
          await Future.delayed(Duration(milliseconds: 50));
        },
        timeout: Duration(seconds: 1),
      );
      expect(completed, isTrue);
    });

    test('completes check returns false on timeout', () async {
      final completed = await Timebox.completes(
        () async {
          await Future.delayed(Duration(seconds: 2));
        },
        timeout: Duration(milliseconds: 100),
      );
      expect(completed, isFalse);
    });

    test('retries until success', () async {
      var attempts = 0;
      final result = await Timebox.retry(
        () async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Retry needed');
          }
          return 'success';
        },
        timeout: Duration(seconds: 1),
        retryInterval: Duration(milliseconds: 50),
      );
      expect(result, equals('success'));
      expect(attempts, equals(3));
    });

    test('retries respect max attempts', () async {
      var attempts = 0;
      await expectLater(
        () => Timebox.retry(
          () async {
            attempts++;
            throw Exception('Retry needed');
          },
          timeout: Duration(seconds: 1),
          retryInterval: Duration(milliseconds: 50),
          maxAttempts: 3,
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(attempts, equals(3));
    });

    test('retries respect timeout', () async {
      expect(
        () => Timebox.retry(
          () async {
            await Future.delayed(Duration(milliseconds: 200));
            return 'success';
          },
          timeout: Duration(milliseconds: 100),
          retryInterval: Duration(milliseconds: 50),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('handles zero timeout', () async {
      final result = await Timebox.run(
        () => 'success',
        timeout: Duration.zero,
      );
      expect(result, equals('success'));
    });

    test('handles errors in callback', () async {
      expect(
        () => Timebox.run(
          () => throw Exception('Test error'),
          timeout: Duration(seconds: 1),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('handles errors in onTimeout callback', () async {
      expect(
        () => Timebox.run(
          () async {
            await Future.delayed(Duration(seconds: 2));
            return 'success';
          },
          timeout: Duration(milliseconds: 100),
          onTimeout: () => throw Exception('Timeout error'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
