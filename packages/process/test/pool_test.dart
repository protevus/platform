import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('Pool', () {
    late Factory factory;
    late Pool pool;

    setUp(() {
      factory = Factory();
      pool = Pool(factory, (p) {});
    });

    test('executes processes concurrently', () async {
      // Add processes that sleep for different durations
      pool.command('bash -c "sleep 0.2 && echo 1"');
      pool.command('bash -c "sleep 0.1 && echo 2"');
      pool.command('echo 3');

      final startTime = DateTime.now();
      final results = await pool.start();
      final duration = DateTime.now().difference(startTime);

      // Should complete in ~0.2s, not ~0.3s
      expect(duration.inMilliseconds, lessThan(300));
      expect(results.length, equals(3));
      expect(
        results.map((r) => r.output().trim()),
        containsAll(['1', '2', '3']),
      );
    });

    test('captures output from all processes', () async {
      final outputs = <String>[];
      pool.command('echo 1');
      pool.command('echo 2');
      pool.command('echo 3');

      await pool.start((output) {
        outputs.add(output.trim());
      });

      expect(outputs, containsAll(['1', '2', '3']));
    });

    test('handles process failures', () async {
      pool.command('echo success');
      pool.command('false');
      pool.command('echo also success');

      final results = await pool.start();
      final poolResults = ProcessPoolResults(results);

      expect(poolResults.successful(), isFalse);
      expect(poolResults.failed(), isTrue);
      expect(results.length, equals(3));
    });

    test('throws if no processes added', () async {
      final results = await pool.start();
      expect(results, isEmpty);
    });

    test('supports process configuration', () async {
      // Create processes with factory to configure them
      final process1 =
          factory.command('printenv TEST_VAR').env({'TEST_VAR': 'test value'});
      final process2 = factory.command('pwd').path('/tmp');

      // Add configured processes to pool
      pool.command(process1.command);
      pool.command(process2.command);

      final results = await pool.start();
      expect(results.length, equals(2));
      expect(results[0].output().trim(), equals('test value'));
      expect(results[1].output().trim(), equals('/tmp'));
    });

    group('ProcessPoolResults', () {
      test('provides access to all results', () {
        final results = [
          ProcessResultImpl(
            command: 'test1',
            exitCode: 0,
            output: 'output1',
            errorOutput: '',
          ),
          ProcessResultImpl(
            command: 'test2',
            exitCode: 1,
            output: 'output2',
            errorOutput: 'error2',
          ),
        ];

        final poolResults = ProcessPoolResults(results);
        expect(poolResults.results, equals(results));
      });

      test('indicates success when all processes succeed', () {
        final results = [
          ProcessResultImpl(
            command: 'test1',
            exitCode: 0,
            output: '',
            errorOutput: '',
          ),
          ProcessResultImpl(
            command: 'test2',
            exitCode: 0,
            output: '',
            errorOutput: '',
          ),
        ];

        final poolResults = ProcessPoolResults(results);
        expect(poolResults.successful(), isTrue);
        expect(poolResults.failed(), isFalse);
      });

      test('indicates failure when any process fails', () {
        final results = [
          ProcessResultImpl(
            command: 'test1',
            exitCode: 0,
            output: '',
            errorOutput: '',
          ),
          ProcessResultImpl(
            command: 'test2',
            exitCode: 1,
            output: '',
            errorOutput: '',
          ),
        ];

        final poolResults = ProcessPoolResults(results);
        expect(poolResults.successful(), isFalse);
        expect(poolResults.failed(), isTrue);
      });

      test('throws if any process failed', () {
        final results = [
          ProcessResultImpl(
            command: 'test1',
            exitCode: 0,
            output: '',
            errorOutput: '',
          ),
          ProcessResultImpl(
            command: 'test2',
            exitCode: 1,
            output: '',
            errorOutput: 'error',
          ),
        ];

        final poolResults = ProcessPoolResults(results);
        expect(
          () => poolResults.throwIfAnyFailed(),
          throwsA(isA<Exception>()),
        );
      });

      test('does not throw if all processes succeeded', () {
        final results = [
          ProcessResultImpl(
            command: 'test1',
            exitCode: 0,
            output: '',
            errorOutput: '',
          ),
          ProcessResultImpl(
            command: 'test2',
            exitCode: 0,
            output: '',
            errorOutput: '',
          ),
        ];

        final poolResults = ProcessPoolResults(results);
        expect(() => poolResults.throwIfAnyFailed(), returnsNormally);
      });
    });
  });
}
