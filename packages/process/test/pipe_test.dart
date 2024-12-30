import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('Pipe', () {
    late Factory factory;
    late Pipe pipe;

    setUp(() {
      factory = Factory();
      pipe = Pipe(factory, (p) {});
    });

    test('executes processes sequentially', () async {
      pipe.command('echo "hello world"');
      pipe.command('tr "a-z" "A-Z"');

      final result = await pipe.run();
      expect(result.output().trim(), equals('HELLO WORLD'));
    });

    test('stops on first failure', () async {
      pipe.command('echo "test"');
      pipe.command('false');
      pipe.command('echo "never reached"');

      final result = await pipe.run();
      expect(result.failed(), isTrue);
      expect(result.output().trim(), equals('test'));
    });

    test('captures output in real time', () async {
      final outputs = <String>[];
      pipe.command('echo "line1"');
      pipe.command('echo "line2"');

      await pipe.run(output: (data) {
        outputs.add(data.trim());
      });

      expect(outputs, equals(['line1', 'line2']));
    });

    test('pipes output between processes', () async {
      pipe.command('echo "hello\nworld\nhello\ntest"');
      pipe.command('sort');
      pipe.command('uniq -c');
      pipe.command('sort -nr');

      final result = await pipe.run();
      final lines = result.output().trim().split('\n');
      expect(lines[0].trim(), contains('2 hello'));
      expect(lines[1].trim(), contains('1 test'));
      expect(lines[2].trim(), contains('1 world'));
    });

    test('supports process configuration', () async {
      final pending = factory.newPendingProcess().command('pwd').path('/tmp');
      pipe.command(pending.command);
      pipe.command('grep tmp');

      final result = await pipe.run();
      expect(result.output().trim(), equals('/tmp'));
    });

    test('handles environment variables', () async {
      final pending = factory
          .newPendingProcess()
          .command('printenv TEST_VAR')
          .env({'TEST_VAR': 'test value'});
      pipe.command(pending.command);
      pipe.command('tr "a-z" "A-Z"');

      final result = await pipe.run();
      expect(result.output().trim(), equals('TEST VALUE'));
    });

    test('handles binary data', () async {
      pipe.command('printf "\\x48\\x45\\x4C\\x4C\\x4F"'); // "HELLO"
      pipe.command('cat');

      final result = await pipe.run();
      expect(result.output(), equals('HELLO'));
    });

    test('supports input redirection', () async {
      final pending =
          factory.newPendingProcess().command('cat').input('test input\n');
      pipe.command(pending.command);
      pipe.command('tr "a-z" "A-Z"');

      final result = await pipe.run();
      expect(result.output().trim(), equals('TEST INPUT'));
    });

    test('handles empty pipe', () async {
      final result = await pipe.run();
      expect(result.successful(), isTrue);
      expect(result.output(), isEmpty);
    });

    test('preserves exit codes', () async {
      pipe.command('echo "test"');
      pipe.command('grep missing'); // Will fail
      pipe.command('echo "never reached"');

      final result = await pipe.run();
      expect(result.failed(), isTrue);
      expect(result.exitCode(), equals(1));
    });

    test('supports complex pipelines', () async {
      // Create a file with test content
      pipe.command('echo "apple\nbanana\napple\ncherry\nbanana"');
      pipe.command('sort'); // Sort lines
      pipe.command('uniq -c'); // Count unique lines
      pipe.command('sort -nr'); // Sort by count
      pipe.command('head -n 2'); // Get top 2

      final result = await pipe.run();
      final lines = result.output().trim().split('\n');
      expect(lines.length, equals(2));
      expect(lines[0].trim(), contains('2')); // Most frequent
      expect(lines[1].trim(), contains('1')); // Less frequent
    });

    test('handles process timeouts', () async {
      pipe.command('echo start');
      final pending = factory.newPendingProcess().command('sleep 5').timeout(1);
      pipe.command(pending.command);
      pipe.command('echo never reached');

      final result = await pipe.run();
      expect(result.failed(), isTrue);
      expect(result.output().trim(), equals('start'));
    });

    test('supports TTY mode', () async {
      final pending = factory.newPendingProcess().command('test -t 0').tty();
      pipe.command(pending.command);

      final result = await pipe.run();
      expect(result.successful(), isTrue);
    });

    test('handles process cleanup', () async {
      pipe.command('sleep 10');
      pipe.command('echo "never reached"');

      // Start the pipe and immediately kill it
      final future = pipe.run();
      await Future.delayed(Duration(milliseconds: 100));

      // Verify the pipe was cleaned up
      final result = await future;
      expect(result.failed(), isTrue);
    });
  });
}
