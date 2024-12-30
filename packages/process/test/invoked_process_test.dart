import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('InvokedProcess', () {
    late Process process;
    late InvokedProcess invokedProcess;

    setUp(() async {
      process = await Process.start('echo', ['test']);
      invokedProcess = InvokedProcess(process, 'echo test');
    });

    test('provides process ID', () {
      expect(invokedProcess.pid, equals(process.pid));
    });

    test('captures output', () async {
      final result = await invokedProcess.wait();
      expect(result.output().trim(), equals('test'));
    });

    test('handles error output', () async {
      process = await Process.start('sh', ['-c', 'echo error >&2']);
      invokedProcess = InvokedProcess(process, 'echo error >&2');

      final result = await invokedProcess.wait();
      expect(result.errorOutput().trim(), equals('error'));
    });

    test('provides exit code', () async {
      final exitCode = await invokedProcess.exitCode;
      expect(exitCode, equals(0));
    });

    test('handles process kill', () async {
      process = await Process.start('sleep', ['10']);
      invokedProcess = InvokedProcess(process, 'sleep 10');

      expect(invokedProcess.kill(), isTrue);
      final exitCode = await invokedProcess.exitCode;
      expect(exitCode, isNot(0));
    });

    test('provides access to stdout stream', () async {
      final output = await invokedProcess.stdout.transform(utf8.decoder).join();
      expect(output.trim(), equals('test'));
    });

    test('provides access to stderr stream', () async {
      process = await Process.start('sh', ['-c', 'echo error >&2']);
      invokedProcess = InvokedProcess(process, 'echo error >&2');

      final error = await invokedProcess.stderr.transform(utf8.decoder).join();
      expect(error.trim(), equals('error'));
    });

    test('provides access to stdin', () async {
      process = await Process.start('cat', []);
      invokedProcess = InvokedProcess(process, 'cat');

      await invokedProcess.write('test input\n');
      final result = await invokedProcess.wait();
      expect(result.output().trim(), equals('test input'));
    });

    test('writes multiple lines to stdin', () async {
      process = await Process.start('cat', []);
      invokedProcess = InvokedProcess(process, 'cat');

      await invokedProcess.writeLines(['line 1', 'line 2', 'line 3']);
      final result = await invokedProcess.wait();
      expect(result.output().trim().split('\n'),
          equals(['line 1', 'line 2', 'line 3']));
    });

    test('captures real-time output', () async {
      final outputs = <String>[];
      process = await Process.start(
          'sh', ['-c', 'echo line1; sleep 0.1; echo line2']);
      invokedProcess = InvokedProcess(process, 'echo lines', (data) {
        outputs.add(data.trim());
      });

      await invokedProcess.wait();
      expect(outputs, equals(['line1', 'line2']));
    });

    test('handles process failure', () async {
      process = await Process.start('false', []);
      invokedProcess = InvokedProcess(process, 'false');

      final result = await invokedProcess.wait();
      expect(result.failed(), isTrue);
      expect(result.exitCode(), equals(1));
    });

    test('handles process with arguments', () async {
      process = await Process.start('echo', ['arg1', 'arg2']);
      invokedProcess = InvokedProcess(process, 'echo arg1 arg2');

      final result = await invokedProcess.wait();
      expect(result.output().trim(), equals('arg1 arg2'));
    });

    test('handles binary output', () async {
      process =
          await Process.start('printf', [r'\x48\x45\x4C\x4C\x4F']); // "HELLO"
      invokedProcess = InvokedProcess(process, 'printf HELLO');

      final result = await invokedProcess.wait();
      expect(result.output(), equals('HELLO'));
    });

    test('handles process cleanup', () async {
      process = await Process.start('sleep', ['10']);
      invokedProcess = InvokedProcess(process, 'sleep 10');

      // Kill process and ensure resources are cleaned up
      expect(invokedProcess.kill(), isTrue);
      await invokedProcess.wait();

      // Verify process is terminated
      expect(await invokedProcess.exitCode, isNot(0));
    });
  });
}
