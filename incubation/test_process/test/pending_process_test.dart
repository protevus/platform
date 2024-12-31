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
        final process = factory.command(['sleep', '5']).withIdleTimeout(1);

        await expectLater(
          process.run(),
          throwsA(isA<ProcessTimedOutException>().having(
            (e) => e.message,
            'message',
            contains('exceeded the idle timeout of 1 seconds'),
          )),
        );
      }
    }, timeout: Timeout(Duration(seconds: 5)));
  });
}
