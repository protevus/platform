import 'dart:io';
import 'package:test/test.dart';
import 'package:illuminate_process/process.dart';

void main() {
  late Factory factory;

  setUp(() {
    factory = Factory();
  });

  group('Laravel Process Tests', () {
    test('successful process', () async {
      final result = await factory
          .command(['ls'])
          .withWorkingDirectory(Directory.current.path)
          .run();

      expect(result.successful(), isTrue);
      expect(result.failed(), isFalse);
      expect(result.exitCode, equals(0));
      expect(result.output(), contains('test'));
      expect(result.errorOutput(), isEmpty);
    });

    test('process with error output', () async {
      if (!Platform.isWindows) {
        try {
          await factory
              .command(['sh', '-c', 'echo "Hello World" >&2; exit 1']).run();
          fail('Should have thrown');
        } on ProcessFailedException catch (e) {
          expect(e.exitCode, equals(1));
          expect(e.output, isEmpty);
          expect(e.errorOutput.trim(), equals('Hello World'));
        }
      }
    });

    test('process can throw without output', () async {
      if (!Platform.isWindows) {
        try {
          await factory.command(['sh', '-c', 'exit 1']).run();
          fail('Should have thrown');
        } on ProcessFailedException catch (e) {
          expect(e.exitCode, equals(1));
          expect(e.output, isEmpty);
          expect(e.errorOutput, isEmpty);
        }
      }
    });

    test('process can throw with error output', () async {
      if (!Platform.isWindows) {
        try {
          await factory
              .command(['sh', '-c', 'echo "Hello World" >&2; exit 1']).run();
          fail('Should have thrown');
        } on ProcessFailedException catch (e) {
          expect(e.exitCode, equals(1));
          expect(e.output, isEmpty);
          expect(e.errorOutput.trim(), equals('Hello World'));
        }
      }
    });

    test('process can throw with output', () async {
      if (!Platform.isWindows) {
        try {
          await factory
              .command(['sh', '-c', 'echo "Hello World"; exit 1']).run();
          fail('Should have thrown');
        } on ProcessFailedException catch (e) {
          expect(e.exitCode, equals(1));
          expect(e.output.trim(), equals('Hello World'));
          expect(e.errorOutput, isEmpty);
        }
      }
    });

    test('process can timeout', () async {
      if (!Platform.isWindows) {
        try {
          await factory.command(['sleep', '0.5']).withTimeout(0).run();
          fail('Should have thrown');
        } on ProcessTimedOutException catch (e) {
          expect(e.message, contains('exceeded the timeout'));
          expect(e.message, contains('sleep 0.5'));
          expect(e.message, contains('0 seconds'));
        }
      }
    });

    test('process can use standard input', () async {
      if (!Platform.isWindows) {
        final result = await factory.command(['cat']).withInput('foobar').run();

        expect(result.output(), equals('foobar'));
      }
    });

    test('process pipe operations', () async {
      if (!Platform.isWindows) {
        final result = await factory.command([
          'sh',
          '-c',
          'echo "Hello, world\nfoo\nbar" | grep -i "foo"'
        ]).run();

        expect(result.output().trim(), equals('foo'));
      }
    });

    test('process with working directory', () async {
      if (!Platform.isWindows) {
        final result =
            await factory.command(['pwd']).withWorkingDirectory('/tmp').run();

        expect(result.output().trim(), equals('/tmp'));
      }
    });

    test('process with environment variables', () async {
      if (!Platform.isWindows) {
        final result = await factory
            .command(['sh', '-c', 'echo \$TEST_VAR']).withEnvironment(
                {'TEST_VAR': 'test_value'}).run();

        expect(result.output().trim(), equals('test_value'));
      }
    });

    test('process output can be captured via callback', () async {
      final output = <String>[];

      final process = await factory.command(['ls']).start((data) {
        output.add(data);
      });

      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(output, isNotEmpty);
      expect(output.join(), contains('test'));

      await process.wait();
    });
  });
}
