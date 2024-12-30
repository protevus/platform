import 'dart:io';
import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('PendingProcess', () {
    late PendingProcess process;

    setUp(() {
      process = PendingProcess();
    });

    test('configures command', () {
      process.command('echo test');
      expect(process.run(), completes);
    });

    test('configures working directory', () async {
      final result =
          await process.command('pwd').path(Directory.current.path).run();
      expect(result.output().trim(), equals(Directory.current.path));
    });

    test('configures environment variables', () async {
      final result = await process
          .command('printenv TEST_VAR')
          .env({'TEST_VAR': 'test_value'}).run();
      expect(result.output().trim(), equals('test_value'));
    });

    test('handles string input', () async {
      final result = await process.command('cat').input('test input\n').run();
      expect(result.output().trim(), equals('test input'));
    });

    test('handles list input', () async {
      final result = await process
          .command('cat')
          .input([116, 101, 115, 116]) // "test" in bytes
          .run();
      expect(result.output(), equals('test'));
    });

    test('respects timeout', () async {
      // Use a longer timeout to avoid flakiness
      process.command('sleep 5').timeout(1);

      final startTime = DateTime.now();
      try {
        await process.run();
        fail('Expected ProcessTimeoutException');
      } catch (e) {
        expect(e, isA<ProcessTimeoutException>());
        final duration = DateTime.now().difference(startTime);
        expect(duration.inSeconds, lessThanOrEqualTo(2)); // Allow some buffer
      }
    });

    test('runs forever when timeout disabled', () async {
      final result = await process.command('echo test').forever().run();
      expect(result.successful(), isTrue);
    });

    test('captures output in real time', () async {
      final output = <String>[];

      // Create a platform-independent way to generate sequential output
      final command = Platform.isWindows
          ? 'cmd /c "(echo 1 && timeout /T 1 > nul) && (echo 2 && timeout /T 1 > nul) && echo 3"'
          : 'sh -c "echo 1; sleep 0.1; echo 2; sleep 0.1; echo 3"';

      final result = await process
          .command(command)
          .run((String data) => output.add(data.trim()));

      final numbers = output
          .where((s) => s.isNotEmpty)
          .map((s) => s.trim())
          .where((s) => s.contains(RegExp(r'^[123]$')))
          .toList();

      expect(numbers, equals(['1', '2', '3']));
      expect(result.successful(), isTrue);
    });

    test('disables output when quiet', () async {
      final output = <String>[];
      final result = await process
          .command('echo test')
          .quietly()
          .run((String data) => output.add(data));

      expect(output, isEmpty);
      expect(result.output(), isNotEmpty);
    });

    test('enables TTY mode', () async {
      final result = await process.command('test -t 0').tty().run();
      expect(result.successful(), isTrue);
    });

    test('starts process in background', () async {
      final proc = await process.command('sleep 1').start();
      expect(proc.pid, isPositive);
      await proc.kill();
    });

    test('throws on invalid command', () {
      expect(
        () => process.run(),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'No command has been specified.',
        )),
      );
    });

    test('handles command as list', () async {
      final result = await process.command(['echo', 'test']).run();
      expect(result.output().trim(), equals('test'));
    });

    test('preserves environment isolation', () async {
      // First process
      final result1 = await process
          .command('printenv TEST_VAR')
          .env({'TEST_VAR': 'value1'}).run();

      // Second process with different environment
      final result2 = await PendingProcess()
          .command('printenv TEST_VAR')
          .env({'TEST_VAR': 'value2'}).run();

      expect(result1.output().trim(), equals('value1'));
      expect(result2.output().trim(), equals('value2'));
    });

    test('handles process termination', () async {
      final proc = await process.command('sleep 10').start();

      expect(proc.kill(), isTrue);
      expect(await proc.exitCode, isNot(0));
    });

    test('supports chained configuration', () async {
      final result = await process
          .command('echo test')
          .path(Directory.current.path)
          .env({'TEST': 'value'})
          .timeout(5)
          .quietly()
          .run();

      expect(result.successful(), isTrue);
    });
  });
}
