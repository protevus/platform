import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';
import 'dart:io';
import 'dart:async';

void main() {
  group('ProcessUtils', () {
    test('escapes empty string', () {
      expect(ProcessUtils.escape(''), equals('""'));
    });

    test('escapes Windows arguments', () {
      if (Platform.isWindows) {
        expect(ProcessUtils.escape('test'), equals('test'));
        expect(ProcessUtils.escape('test file'), equals('"test file"'));
        expect(ProcessUtils.escape('test"quote"'), equals(r'"test\"quote\""'));
      }
    });

    test('escapes Unix arguments', () {
      if (!Platform.isWindows) {
        expect(ProcessUtils.escape('test'), equals('test'));
        expect(ProcessUtils.escape('test file'), equals(r'test\ file'));
        expect(ProcessUtils.escape('test"quote"'), equals(r'test\"quote\"'));
        expect(ProcessUtils.escape(r'test\path'), equals(r'test\\path'));
        expect(
            ProcessUtils.escape('test\$variable'), equals(r'test\$variable'));
        expect(ProcessUtils.escape('test`cmd`'), equals(r'test\`cmd\`'));
      }
    });

    test('escapes array of arguments', () {
      final args = ['test', 'file name', 'with"quote"'];
      final escaped = ProcessUtils.escapeArray(args);
      expect(escaped.length, equals(3));
      if (Platform.isWindows) {
        expect(escaped[0], equals('test'));
        expect(escaped[1], equals('"file name"'));
        expect(escaped[2], equals(r'"with\"quote\""'));
      } else {
        expect(escaped[0], equals('test'));
        expect(escaped[1], equals(r'file\ name'));
        expect(escaped[2], equals(r'with\"quote\"'));
      }
    });

    test('runs command and returns output', () async {
      final result = await ProcessUtils.run(
        'echo',
        ['test'],
        runInShell: true,
      );
      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), equals('test'));
    });

    test('streams command output', () async {
      var output = '';
      var error = '';
      var completer = Completer<void>();

      final exitCode = await ProcessUtils.stream(
        'echo',
        ['test'],
        runInShell: true,
        onOutput: (line) {
          output += line;
          completer.complete();
        },
        onError: (line) => error += line,
      );

      await completer.future;
      expect(exitCode, equals(0));
      expect(output.trim(), equals('test'));
      expect(error, isEmpty);
    });

    test('checks if process is running', () async {
      final process = await ProcessUtils.start(
        'sleep',
        ['1'],
        runInShell: true,
      );

      expect(await ProcessUtils.isRunning(process), isTrue);
      await Future.delayed(Duration(milliseconds: 1500));
      expect(await ProcessUtils.isRunning(process), isFalse);
    });

    test('kills process', () async {
      final process = await ProcessUtils.start(
        'sleep',
        ['5'],
        runInShell: true,
      );

      expect(await ProcessUtils.isRunning(process), isTrue);
      await ProcessUtils.kill(process);
      await Future.delayed(Duration(milliseconds: 100));
      expect(await ProcessUtils.isRunning(process), isFalse);
    });
  });
}
