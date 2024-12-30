import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('Factory', () {
    late Factory factory;

    setUp(() {
      factory = Factory();
    });

    test('creates new pending process', () {
      expect(factory.newPendingProcess(), isA<PendingProcess>());
    });

    test('creates process with command', () async {
      final result = await factory.command('echo test').run();
      expect(result.output().trim(), equals('test'));
    });

    test('creates process pool', () async {
      final results = await factory.pool((pool) {
        pool.command('echo 1');
        pool.command('echo 2');
        pool.command('echo 3');
      }).start();

      expect(results.length, equals(3));
      expect(
        results.map((r) => r.output().trim()),
        containsAll(['1', '2', '3']),
      );
    });

    test('creates process pipe', () async {
      final result = await factory.pipeThrough((pipe) {
        pipe.command('echo "hello world"');
        pipe.command('tr "a-z" "A-Z"');
      }).run();

      expect(result.output().trim(), equals('HELLO WORLD'));
    });

    group('Process Faking', () {
      test('fakes specific commands', () async {
        factory.fake({
          'ls': 'file1.txt\nfile2.txt',
          'cat file1.txt': 'Hello, World!',
          'grep pattern': (process) => 'Matched line',
        });

        final ls = await factory.command('ls').run();
        expect(ls.output().trim(), equals('file1.txt\nfile2.txt'));

        final cat = await factory.command('cat file1.txt').run();
        expect(cat.output().trim(), equals('Hello, World!'));

        final grep = await factory.command('grep pattern').run();
        expect(grep.output().trim(), equals('Matched line'));
      });

      test('prevents stray processes', () {
        factory.fake().preventStrayProcesses();

        expect(
          () => factory.command('unfaked-command').run(),
          throwsA(isA<Exception>()),
        );
      });

      test('records process executions', () async {
        factory.fake();

        await factory.command('ls').run();
        await factory.command('pwd').run();

        expect(factory.isRecording(), isTrue);
      });

      test('supports dynamic fake results', () async {
        var counter = 0;
        factory.fake({
          'counter': (process) => (++counter).toString(),
        });

        final result1 = await factory.command('counter').run();
        final result2 = await factory.command('counter').run();

        expect(result1.output(), equals('1'));
        expect(result2.output(), equals('2'));
      });

      test('fakes process descriptions', () async {
        factory.fake({
          'test-command': FakeProcessDescription()
            ..withExitCode(1)
            ..replaceOutput('test output')
            ..replaceErrorOutput('test error'),
        });

        final result = await factory.command('test-command').run();
        expect(result.failed(), isTrue);
        expect(result.output(), equals('test output'));
        expect(result.errorOutput(), equals('test error'));
      });

      test('fakes process sequences', () async {
        factory.fake({
          'sequence': FakeProcessSequence()
            ..then('first')
            ..then('second')
            ..then('third'),
        });

        final result1 = await factory.command('sequence').run();
        final result2 = await factory.command('sequence').run();
        final result3 = await factory.command('sequence').run();

        expect(result1.output(), equals('first'));
        expect(result2.output(), equals('second'));
        expect(result3.output(), equals('third'));
      });

      test('handles process configuration in fakes', () async {
        factory.fake({
          'env-test': (process) => process.env['TEST_VAR'] ?? 'not set',
        });

        final result = await factory
            .command('env-test')
            .env({'TEST_VAR': 'test value'}).run();

        expect(result.output(), equals('test value'));
      });

      test('supports mixed fake types', () async {
        factory.fake({
          'string': 'simple output',
          'function': (process) => 'dynamic output',
          'description': FakeProcessDescription()..replaceOutput('desc output'),
          'sequence': FakeProcessSequence()..then('seq output'),
        });

        expect((await factory.command('string').run()).output(),
            equals('simple output'));
        expect((await factory.command('function').run()).output(),
            equals('dynamic output'));
        expect((await factory.command('description').run()).output(),
            equals('desc output'));
        expect((await factory.command('sequence').run()).output(),
            equals('seq output'));
      });
    });

    group('Error Handling', () {
      test('handles command failures', () async {
        final result = await factory.command('false').run();
        expect(result.failed(), isTrue);
      });

      test('handles invalid commands', () {
        expect(
          () => factory.command('nonexistent-command').run(),
          throwsA(anything),
        );
      });

      test('handles process timeouts', () async {
        final result = await factory.command('sleep 5').timeout(1).run();
        expect(result.failed(), isTrue);
      });
    });
  });
}
