import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('ProcessPoolResults', () {
    late List<ProcessResult> results;
    late ProcessPoolResults poolResults;

    setUp(() {
      results = [
        FakeProcessResult(
          command: 'success1',
          exitCode: 0,
          output: 'output1',
        ),
        FakeProcessResult(
          command: 'failure',
          exitCode: 1,
          errorOutput: 'error',
        ),
        FakeProcessResult(
          command: 'success2',
          exitCode: 0,
          output: 'output2',
        ),
      ];
      poolResults = ProcessPoolResults(results);
    });

    test('provides access to all results', () {
      expect(poolResults.results, equals(results));
      expect(poolResults.total, equals(3));
      expect(poolResults[0], equals(results[0]));
      expect(poolResults[1], equals(results[1]));
      expect(poolResults[2], equals(results[2]));
    });

    test('indicates overall success/failure', () {
      // With mixed results
      expect(poolResults.successful(), isFalse);
      expect(poolResults.failed(), isTrue);

      // With all successes
      results = List.generate(
        3,
        (i) => FakeProcessResult(
          command: 'success$i',
          exitCode: 0,
          output: 'output$i',
        ),
      );
      poolResults = ProcessPoolResults(results);
      expect(poolResults.successful(), isTrue);
      expect(poolResults.failed(), isFalse);

      // With all failures
      results = List.generate(
        3,
        (i) => FakeProcessResult(
          command: 'failure$i',
          exitCode: 1,
          errorOutput: 'error$i',
        ),
      );
      poolResults = ProcessPoolResults(results);
      expect(poolResults.successful(), isFalse);
      expect(poolResults.failed(), isTrue);
    });

    test('provides success and failure counts', () {
      expect(poolResults.successCount, equals(2));
      expect(poolResults.failureCount, equals(1));
      expect(poolResults.total, equals(3));
    });

    test('provides filtered results', () {
      expect(poolResults.successes.length, equals(2));
      expect(poolResults.failures.length, equals(1));

      expect(poolResults.successes[0].command(), equals('success1'));
      expect(poolResults.successes[1].command(), equals('success2'));
      expect(poolResults.failures[0].command(), equals('failure'));
    });

    test('throws if any process failed', () {
      expect(
        () => poolResults.throwIfAnyFailed(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('One or more processes in the pool failed'),
        )),
      );

      // Should not throw with all successes
      results = List.generate(
        3,
        (i) => FakeProcessResult(
          command: 'success$i',
          exitCode: 0,
          output: 'output$i',
        ),
      );
      poolResults = ProcessPoolResults(results);
      expect(() => poolResults.throwIfAnyFailed(), returnsNormally);
    });

    test('formats failure messages', () {
      try {
        poolResults.throwIfAnyFailed();
      } catch (e) {
        final message = e.toString();
        expect(message, contains('failure'));
        expect(message, contains('exit code 1'));
        expect(message, contains('error'));
      }
    });

    test('handles empty results', () {
      poolResults = ProcessPoolResults([]);
      expect(poolResults.total, equals(0));
      expect(poolResults.successful(), isTrue);
      expect(poolResults.failed(), isFalse);
      expect(poolResults.successCount, equals(0));
      expect(poolResults.failureCount, equals(0));
      expect(poolResults.successes, isEmpty);
      expect(poolResults.failures, isEmpty);
    });

    test('provides first and last results', () {
      expect(poolResults.first, equals(results.first));
      expect(poolResults.last, equals(results.last));
    });

    test('checks emptiness', () {
      expect(poolResults.isEmpty, isFalse);
      expect(poolResults.isNotEmpty, isTrue);

      poolResults = ProcessPoolResults([]);
      expect(poolResults.isEmpty, isTrue);
      expect(poolResults.isNotEmpty, isFalse);
    });
  });
}
