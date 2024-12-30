import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('FakeProcessResult', () {
    late FakeProcessResult result;

    setUp(() {
      result = FakeProcessResult(
        command: 'test command',
        exitCode: 0,
        output: 'test output',
        errorOutput: 'test error',
      );
    });

    test('provides command', () {
      expect(result.command(), equals('test command'));
    });

    test('indicates success', () {
      expect(result.successful(), isTrue);
      expect(result.failed(), isFalse);
    });

    test('indicates failure', () {
      result = FakeProcessResult(exitCode: 1);
      expect(result.successful(), isFalse);
      expect(result.failed(), isTrue);
    });

    test('provides exit code', () {
      expect(result.exitCode(), equals(0));
    });

    test('provides output', () {
      expect(result.output(), equals('test output'));
    });

    test('provides error output', () {
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

    test('throws on failure', () {
      result = FakeProcessResult(
        command: 'failing command',
        exitCode: 1,
        errorOutput: 'error message',
      );

      expect(
        () => result.throwIfFailed(),
        throwsA(predicate((e) {
          if (e is! ProcessFailedException) return false;
          expect(e.result.command(), equals('failing command'));
          expect(e.result.exitCode(), equals(1));
          expect(e.result.errorOutput(), equals('error message'));
          return true;
        })),
      );
    });

    test('handles callback on failure', () {
      result = FakeProcessResult(exitCode: 1);
      var callbackCalled = false;

      expect(
        () => result.throwIfFailed((result, exception) {
          callbackCalled = true;
          expect(exception, isA<ProcessFailedException>());
          if (exception is ProcessFailedException) {
            expect(exception.result.exitCode(), equals(1));
          }
        }),
        throwsA(isA<ProcessFailedException>()),
      );

      expect(callbackCalled, isTrue);
    });

    test('returns self on success', () {
      expect(result.throwIfFailed(), equals(result));
    });

    test('throws conditionally', () {
      result = FakeProcessResult(exitCode: 1);

      expect(
        () => result.throwIf(true),
        throwsA(isA<ProcessFailedException>()),
      );

      expect(
        () => result.throwIf(false),
        returnsNormally,
      );
    });

    test('creates copy with different command', () {
      final copy = result.withCommand('new command');
      expect(copy.command(), equals('new command'));
      expect(copy.exitCode(), equals(result.exitCode()));
      expect(copy.output(), equals(result.output()));
      expect(copy.errorOutput(), equals(result.errorOutput()));
    });

    test('creates copy with different exit code', () {
      final copy = result.withExitCode(1);
      expect(copy.command(), equals(result.command()));
      expect(copy.exitCode(), equals(1));
      expect(copy.output(), equals(result.output()));
      expect(copy.errorOutput(), equals(result.errorOutput()));
    });

    test('creates copy with different output', () {
      final copy = result.withOutput('new output');
      expect(copy.command(), equals(result.command()));
      expect(copy.exitCode(), equals(result.exitCode()));
      expect(copy.output(), equals('new output'));
      expect(copy.errorOutput(), equals(result.errorOutput()));
    });

    test('creates copy with different error output', () {
      final copy = result.withErrorOutput('new error');
      expect(copy.command(), equals(result.command()));
      expect(copy.exitCode(), equals(result.exitCode()));
      expect(copy.output(), equals(result.output()));
      expect(copy.errorOutput(), equals('new error'));
    });

    test('provides default values', () {
      final defaultResult = FakeProcessResult();
      expect(defaultResult.command(), isEmpty);
      expect(defaultResult.exitCode(), equals(0));
      expect(defaultResult.output(), isEmpty);
      expect(defaultResult.errorOutput(), isEmpty);
    });
  });
}
