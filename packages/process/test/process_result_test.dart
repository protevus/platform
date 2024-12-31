import 'package:test/test.dart';
import 'package:platform_process/platform_process.dart';

void main() {
  group('ProcessResult', () {
    test('successful process is detected correctly', () {
      final result = ProcessResult(0, 'output', '');
      expect(result.successful(), isTrue);
      expect(result.failed(), isFalse);
    });

    test('failed process is detected correctly', () {
      final result = ProcessResult(1, '', 'error');
      expect(result.successful(), isFalse);
      expect(result.failed(), isTrue);
    });

    test('output methods return correct streams', () {
      final result = ProcessResult(0, 'stdout', 'stderr');
      expect(result.output(), equals('stdout'));
      expect(result.errorOutput(), equals('stderr'));
    });

    test('toString returns stdout', () {
      final result = ProcessResult(0, 'test output', 'error output');
      expect(result.toString(), equals('test output'));
    });

    test('empty output is handled correctly', () {
      final result = ProcessResult(0, '', '');
      expect(result.output(), isEmpty);
      expect(result.errorOutput(), isEmpty);
    });

    test('exit code is accessible', () {
      final result = ProcessResult(123, '', '');
      expect(result.exitCode, equals(123));
    });

    test('multiline output is preserved', () {
      final stdout = 'line1\nline2\nline3';
      final stderr = 'error1\nerror2';
      final result = ProcessResult(0, stdout, stderr);
      expect(result.output(), equals(stdout));
      expect(result.errorOutput(), equals(stderr));
    });

    test('whitespace in output is preserved', () {
      final stdout = '  leading and trailing spaces  ';
      final result = ProcessResult(0, stdout, '');
      expect(result.output(), equals(stdout));
    });

    test('non-zero exit code indicates failure', () {
      for (var code in [1, 2, 127, 255]) {
        final result = ProcessResult(code, '', '');
        expect(result.failed(), isTrue,
            reason: 'Exit code $code should indicate failure');
        expect(result.successful(), isFalse,
            reason: 'Exit code $code should not indicate success');
      }
    });

    test('zero exit code indicates success', () {
      final result = ProcessResult(0, '', '');
      expect(result.successful(), isTrue);
      expect(result.failed(), isFalse);
    });
  });
}
