import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('ProcessFailedException', () {
    late ProcessResult failedResult;
    late ProcessFailedException exception;

    setUp(() {
      failedResult = FakeProcessResult(
        command: 'test command',
        exitCode: 1,
        output: 'test output',
        errorOutput: 'test error',
      );
      exception = ProcessFailedException(failedResult);
    });

    test('provides access to failed result', () {
      expect(exception.result, equals(failedResult));
    });

    test('formats error message', () {
      final message = exception.toString();
      expect(message, contains('test command'));
      expect(message, contains('exit code 1'));
      expect(message, contains('test output'));
      expect(message, contains('test error'));
    });

    test('handles empty output', () {
      failedResult = FakeProcessResult(
        command: 'test command',
        exitCode: 1,
      );
      exception = ProcessFailedException(failedResult);

      final message = exception.toString();
      expect(message, contains('(empty)'));
    });

    test('includes all error details', () {
      failedResult = FakeProcessResult(
        command: 'complex command',
        exitCode: 127,
        output: 'some output\nwith multiple lines',
        errorOutput: 'error line 1\nerror line 2',
      );
      exception = ProcessFailedException(failedResult);

      final message = exception.toString();
      expect(message, contains('complex command'));
      expect(message, contains('exit code 127'));
      expect(message, contains('some output\nwith multiple lines'));
      expect(message, contains('error line 1\nerror line 2'));
    });
  });

  group('ProcessTimeoutException', () {
    late ProcessResult timedOutResult;
    late ProcessTimeoutException exception;
    final timeout = Duration(seconds: 5);

    setUp(() {
      timedOutResult = FakeProcessResult(
        command: 'long running command',
        exitCode: -1,
        output: 'partial output',
        errorOutput: 'timeout occurred',
      );
      exception = ProcessTimeoutException(timedOutResult, timeout);
    });

    test('provides access to timed out result', () {
      expect(exception.result, equals(timedOutResult));
    });

    test('provides access to timeout duration', () {
      expect(exception.timeout, equals(timeout));
    });

    test('formats error message', () {
      final message = exception.toString();
      expect(message, contains('long running command'));
      expect(message, contains('timed out after 5 seconds'));
      expect(message, contains('partial output'));
      expect(message, contains('timeout occurred'));
    });

    test('handles empty output', () {
      timedOutResult = FakeProcessResult(
        command: 'hanging command',
        exitCode: -1,
      );
      exception = ProcessTimeoutException(timedOutResult, timeout);

      final message = exception.toString();
      expect(message, contains('hanging command'));
      expect(message, contains('(empty)'));
    });

    test('handles different timeout durations', () {
      final shortTimeout = Duration(milliseconds: 500);
      exception = ProcessTimeoutException(timedOutResult, shortTimeout);
      expect(exception.toString(), contains('timed out after 0 seconds'));

      final longTimeout = Duration(minutes: 2);
      exception = ProcessTimeoutException(timedOutResult, longTimeout);
      expect(exception.toString(), contains('timed out after 120 seconds'));
    });

    test('includes all error details', () {
      timedOutResult = FakeProcessResult(
        command: 'complex command with args',
        exitCode: -1,
        output: 'output before timeout\nwith multiple lines',
        errorOutput: 'error before timeout\nerror details',
      );
      exception = ProcessTimeoutException(timedOutResult, timeout);

      final message = exception.toString();
      expect(message, contains('complex command with args'));
      expect(message, contains('timed out after 5 seconds'));
      expect(message, contains('output before timeout\nwith multiple lines'));
      expect(message, contains('error before timeout\nerror details'));
    });
  });
}
