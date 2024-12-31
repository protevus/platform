import 'dart:io';
import 'package:test/test.dart';
import 'package:platform_process/platform_process.dart';

void main() {
  group('InvokedProcess Tests', () {
    test('latestOutput() returns latest stdout', () async {
      final factory = Factory();
      final process = await factory.command(
          ['sh', '-c', 'echo "line1"; sleep 0.1; echo "line2"']).start();

      await Future.delayed(Duration(milliseconds: 50));
      expect(process.latestOutput().trim(), equals('line1'));

      await Future.delayed(Duration(milliseconds: 100));
      expect(process.latestOutput().trim(), contains('line2'));

      await process.wait();
    }, timeout: Timeout(Duration(seconds: 5)));

    test('latestErrorOutput() returns latest stderr', () async {
      final factory = Factory();
      final process = await factory.command([
        'sh',
        '-c',
        'echo "error1" >&2; sleep 0.1; echo "error2" >&2'
      ]).start();

      await Future.delayed(Duration(milliseconds: 50));
      expect(process.latestErrorOutput().trim(), equals('error1'));

      await Future.delayed(Duration(milliseconds: 100));
      expect(process.latestErrorOutput().trim(), contains('error2'));

      await process.wait();
    }, timeout: Timeout(Duration(seconds: 5)));

    test('running() returns correct state', () async {
      final factory = Factory();
      final process = await factory.command(['sleep', '0.5']).start();

      expect(process.running(), isTrue);
      await Future.delayed(Duration(milliseconds: 600));
      expect(process.running(), isFalse);
    }, timeout: Timeout(Duration(seconds: 5)));

    test('write() sends input to process', () async {
      final factory = Factory();
      final process = await factory.command(['cat']).start();

      process.write('Hello');
      process.write(' World');
      await process.closeStdin();
      final result = await process.wait();
      expect(result.output().trim(), equals('Hello World'));
    }, timeout: Timeout(Duration(seconds: 5)));

    test('write() handles byte input', () async {
      final factory = Factory();
      final process = await factory.command(['cat']).start();

      process.write([72, 101, 108, 108, 111]); // "Hello" in bytes
      await process.closeStdin();
      final result = await process.wait();
      expect(result.output().trim(), equals('Hello'));
    }, timeout: Timeout(Duration(seconds: 5)));

    test('kill() terminates process', () async {
      final factory = Factory();
      final process = await factory.command(['sleep', '10']).start();

      expect(process.running(), isTrue);
      final killed = process.kill();
      expect(killed, isTrue);

      final result = await process.wait();
      expect(result.exitCode, equals(-15)); // SIGTERM
      expect(process.running(), isFalse);
    }, timeout: Timeout(Duration(seconds: 5)));

    test('kill() with custom signal', () async {
      if (!Platform.isWindows) {
        final factory = Factory();
        final process = await factory.command(['sleep', '10']).start();

        expect(process.running(), isTrue);
        final killed = process.kill(ProcessSignal.sigint);
        expect(killed, isTrue);

        final result = await process.wait();
        expect(result.exitCode, equals(-2)); // SIGINT
        expect(process.running(), isFalse);
      }
    }, timeout: Timeout(Duration(seconds: 5)));

    test('pid returns process ID', () async {
      final factory = Factory();
      final process = await factory.command(['echo', 'test']).start();

      expect(process.pid, isPositive);
      await process.wait();
    }, timeout: Timeout(Duration(seconds: 5)));
  });
}
