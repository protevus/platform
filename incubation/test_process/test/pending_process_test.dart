import 'dart:io';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  group('PendingProcess Tests', () {
    late Factory factory;

    setUp(() {
      factory = Factory();
    });

    test('forever() disables timeout', () async {
      final process = factory.command(['sleep', '0.5']).forever();
      expect(process.timeout, isNull);
    });

    test('withIdleTimeout() sets idle timeout', () async {
      final process = factory.command(['echo', 'test']).withIdleTimeout(5);
      expect(process.idleTimeout, equals(5));
    });

    test('withTty() enables TTY mode', () async {
      final process = factory.command(['echo', 'test']).withTty();
      expect(process.tty, isTrue);
    });

    test('withTty(false) disables TTY mode', () async {
      final process = factory.command(['echo', 'test']).withTty(false);
      expect(process.tty, isFalse);
    });

    test('run() without command throws ArgumentError', () async {
      final process = PendingProcess(factory);
      expect(() => process.run(), throwsArgumentError);
    });

    test('start() without command throws ArgumentError', () async {
      final process = PendingProcess(factory);
      expect(() => process.start(), throwsArgumentError);
    });

    test('run() with command parameter overrides previous command', () async {
      final process = factory.command(['echo', 'old']);
      final result = await process.run(['echo', 'new']);
      expect(result.output().trim(), equals('new'));
    });

    test('run() handles process exceptions', () async {
      if (!Platform.isWindows) {
        final process = factory.command(['nonexistent']);
        expect(() => process.run(), throwsA(isA<ProcessFailedException>()));
      }
    });

    test('start() handles process exceptions', () async {
      if (!Platform.isWindows) {
        final process = factory.command(['nonexistent']);
        expect(() => process.start(), throwsA(isA<ProcessFailedException>()));
      }
    });

    test('withoutOutput() disables output', () async {
      final result =
          await factory.command(['echo', 'test']).withoutOutput().run();
      expect(result.output(), isEmpty);
    });

    test('idle timeout triggers', () async {
      if (!Platform.isWindows) {
        // Use tail -f to wait indefinitely without producing output
        final process =
            factory.command(['tail', '-f', '/dev/null']).withIdleTimeout(1);

        await expectLater(
          process.run(),
          throwsA(
            allOf(
              isA<ProcessTimedOutException>(),
              predicate((ProcessTimedOutException e) =>
                  e.message.contains('exceeded the idle timeout of 1 seconds')),
            ),
          ),
        );
      }
    }, timeout: Timeout(Duration(seconds: 5)));

    test('timeout triggers', () async {
      if (!Platform.isWindows) {
        final process = factory.command(['sleep', '5']).withTimeout(1);

        await expectLater(
          process.run(),
          throwsA(
            allOf(
              isA<ProcessTimedOutException>(),
              predicate((ProcessTimedOutException e) =>
                  e.message.contains('exceeded the timeout of 1 seconds')),
            ),
          ),
        );
      }
    }, timeout: Timeout(Duration(seconds: 5)));

    test('immediate timeout triggers', () async {
      if (!Platform.isWindows) {
        final process = factory.command(['sleep', '1']).withTimeout(0);

        await expectLater(
          process.run(),
          throwsA(
            allOf(
              isA<ProcessTimedOutException>(),
              predicate((ProcessTimedOutException e) =>
                  e.message.contains('exceeded the timeout of 0 seconds')),
            ),
          ),
        );
      }
    });

    test('string command is executed through shell', () async {
      if (!Platform.isWindows) {
        final result = await factory.command('echo "Hello from shell"').run();
        expect(result.output().trim(), equals('Hello from shell'));
      }
    });

    test('input as bytes is handled', () async {
      final process =
          factory.command(['cat']).withInput([72, 101, 108, 108, 111]);
      final result = await process.run();
      expect(result.output().trim(), equals('Hello'));
    });
  });
}
