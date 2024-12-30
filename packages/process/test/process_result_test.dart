import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('ProcessResult', () {
    late ProcessResultImpl result;

    setUp(() {
      result = ProcessResultImpl(
        command: 'test-command',
        exitCode: 0,
        output: 'test output',
        errorOutput: 'test error',
      );
    });

    test('returns command', () {
      expect(result.command(), equals('test-command'));
    });

    test('indicates success when exit code is 0', () {
      expect(result.successful(), isTrue);
      expect(result.failed(), isFalse);
    });

    test('indicates failure when exit code is non-zero', () {
      result = ProcessResultImpl(
        command: 'test-command',
        exitCode: 1,
        output: '',
        errorOutput: '',
      );
      expect(result.successful(), isFalse);
      expect(result.failed(), isTrue);
    });

    test('returns exit code', () {
      expect(result.exitCode(), equals(0));
    });

    test('returns output', () {
      expect(result.output(), equals('test output'));
    });

    test('returns error output', () {
      expect(result.errorOutput(), equals('test error'));
    });

    test('checks output content', () {
      expect(result.seeInOutput('test'), isTrue);
      expect(result.seeInOutput('missing'), isFalse);
    });

    test('checks error output content', () {
      expect(result.seeInErrorOutput('error'), isTrue);
      expect(result.seeInErrorOutput('missing'), isFalse);
    });

    test('throwIfFailed does not throw on success', () {
      expect(() => result.throwIfFailed(), returnsNormally);
    });

    test('throwIfFailed throws on failure', () {
      result = ProcessResultImpl(
        command: 'test-command',
        exitCode: 1,
        output: 'failed output',
        errorOutput: 'error message',
      );

      expect(
          () => result.throwIfFailed(), throwsA(isA<ProcessFailedException>()));
    });

    test('throwIfFailed executes callback before throwing', () {
      result = ProcessResultImpl(
        command: 'test-command',
        exitCode: 1,
        output: '',
        errorOutput: '',
      );

      var callbackExecuted = false;
      expect(
          () => result.throwIfFailed((result, exception) {
                callbackExecuted = true;
              }),
          throwsA(isA<ProcessFailedException>()));
      expect(callbackExecuted, isTrue);
    });

    test('throwIf respects condition', () {
      expect(() => result.throwIf(false), returnsNormally);
      expect(() => result.throwIf(true), returnsNormally);

      result = ProcessResultImpl(
        command: 'test-command',
        exitCode: 1,
        output: '',
        errorOutput: '',
      );

      expect(() => result.throwIf(false), returnsNormally);
      expect(
          () => result.throwIf(true), throwsA(isA<ProcessFailedException>()));
    });

    test('toString includes command and outputs', () {
      final string = result.toString();
      expect(string, contains('test-command'));
      expect(string, contains('test output'));
      expect(string, contains('test error'));
    });
  });
}
