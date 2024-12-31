import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  group('ProcessFailedException', () {
    test('contains process result', () {
      final result = ProcessResult(1, 'output', 'error');
      final exception = ProcessFailedException(result);
      expect(exception.result, equals(result));
    });

    test('provides access to error details', () {
      final result = ProcessResult(2, 'output', 'error message');
      final exception = ProcessFailedException(result);
      expect(exception.exitCode, equals(2));
      expect(exception.errorOutput, equals('error message'));
      expect(exception.output, equals('output'));
    });

    test('toString includes error details', () {
      final result = ProcessResult(1, 'output', 'error message');
      final exception = ProcessFailedException(result);
      expect(exception.toString(), contains('error message'));
      expect(exception.toString(), contains('1'));
    });

    test('handles empty error output', () {
      final result = ProcessResult(1, 'output', '');
      final exception = ProcessFailedException(result);
      expect(
          exception.toString(), contains('Process failed with exit code: 1'));
    });

    test('handles empty output', () {
      final result = ProcessResult(1, '', 'error');
      final exception = ProcessFailedException(result);
      expect(exception.output, isEmpty);
      expect(exception.errorOutput, equals('error'));
    });
  });

  group('ProcessTimedOutException', () {
    test('contains timeout message', () {
      final exception = ProcessTimedOutException('Process timed out after 60s');
      expect(exception.message, equals('Process timed out after 60s'));
    });

    test('optionally includes process result', () {
      final result = ProcessResult(143, 'partial output', '');
      final exception = ProcessTimedOutException('Timed out', result);
      expect(exception.result, equals(result));
    });

    test('toString includes message', () {
      final exception = ProcessTimedOutException('Custom timeout message');
      expect(exception.toString(), contains('Custom timeout message'));
    });

    test('toString includes result details when available', () {
      final result = ProcessResult(143, 'output', 'error');
      final exception = ProcessTimedOutException('Timed out', result);
      expect(exception.toString(), contains('Timed out'));
      expect(exception.result, equals(result));
    });

    test('handles null result', () {
      final exception = ProcessTimedOutException('Timed out');
      expect(exception.result, isNull);
      expect(exception.toString(), contains('Timed out'));
    });
  });
}
