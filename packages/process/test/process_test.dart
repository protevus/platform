import 'package:test/test.dart';
import 'package:illuminate_process/process.dart';

void main() {
  late Factory factory;

  setUp(() {
    factory = Factory();
  });

  group('Basic Process Operations', () {
    test('echo command returns expected output', () async {
      final result = await factory.command(['echo', 'test']).run();
      expect(result.output().trim(), equals('test'));
      expect(result.exitCode, equals(0));
    });

    test('nonexistent command throws ProcessFailedException', () async {
      expect(
        () => factory.command(['nonexistent-command']).run(),
        throwsA(isA<ProcessFailedException>()),
      );
    });

    test('command with arguments works correctly', () async {
      final result = await factory.command(['echo', '-n', 'test']).run();
      expect(result.output(), equals('test'));
    });
  });

  group('Process Configuration', () {
    test('working directory is respected', () async {
      final result =
          await factory.command(['pwd']).withWorkingDirectory('/tmp').run();
      expect(result.output().trim(), equals('/tmp'));
    });

    test('environment variables are passed correctly', () async {
      final result = await factory
          .command(['sh', '-c', 'echo \$TEST_VAR']).withEnvironment(
              {'TEST_VAR': 'test_value'}).run();
      expect(result.output().trim(), equals('test_value'));
    });

    test('quiet mode suppresses output', () async {
      final result =
          await factory.command(['echo', 'test']).withoutOutput().run();
      expect(result.output(), isEmpty);
    });
  });

  group('Async Process Operations', () {
    test('async process completes successfully', () async {
      final process = await factory.command(['sleep', '0.1']).start();

      expect(process.pid, greaterThan(0));

      final result = await process.wait();
      expect(result.exitCode, equals(0));
    });

    test('process input is handled correctly', () async {
      final result =
          await factory.command(['cat']).withInput('test input').run();
      expect(result.output(), equals('test input'));
    });

    test('process can be killed', () async {
      final process = await factory.command(['sleep', '10']).start();

      expect(process.kill(), isTrue);

      final result = await process.wait();
      expect(result.exitCode, isNot(0));
    });
  });

  group('Shell Commands', () {
    test('pipe operations work correctly', () async {
      final result =
          await factory.command(['sh', '-c', 'echo hello | tr a-z A-Z']).run();
      expect(result.output().trim(), equals('HELLO'));
    });

    test('multiple commands execute in sequence', () async {
      final result = await factory
          .command(['sh', '-c', 'echo start && sleep 0.1 && echo end']).run();
      expect(
        result.output().trim().split('\n'),
        equals(['start', 'end']),
      );
    });

    test('complex shell operations work', () async {
      final result = await factory
          .command(['sh', '-c', 'echo "Count: 1" && echo "Count: 2"']).run();
      expect(
        result.output().trim().split('\n'),
        equals(['Count: 1', 'Count: 2']),
      );
    });
  });

  group('Error Handling', () {
    test('failed process throws with correct exit code', () async {
      try {
        await factory.command(['sh', '-c', 'exit 1']).run();
        fail('Should have thrown');
      } on ProcessFailedException catch (e) {
        expect(e.exitCode, equals(1));
      }
    });

    test('process failure includes error output', () async {
      try {
        await factory
            .command(['sh', '-c', 'echo error message >&2; exit 1']).run();
        fail('Should have thrown');
      } on ProcessFailedException catch (e) {
        expect(e.errorOutput.trim(), equals('error message'));
        expect(e.exitCode, equals(1));
      }
    });
  });
}
