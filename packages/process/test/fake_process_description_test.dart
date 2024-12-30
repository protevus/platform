import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('FakeProcessDescription', () {
    late FakeProcessDescription description;

    setUp(() {
      description = FakeProcessDescription();
    });

    test('provides default values', () {
      expect(description.predictedExitCode, equals(0));
      expect(description.predictedOutput, isEmpty);
      expect(description.predictedErrorOutput, isEmpty);
      expect(description.outputSequence, isEmpty);
      expect(description.delay, equals(Duration(milliseconds: 100)));
      expect(description.runDuration, equals(Duration.zero));
    });

    test('configures exit code', () {
      description.withExitCode(1);
      expect(description.predictedExitCode, equals(1));
    });

    test('configures output', () {
      description.replaceOutput('test output');
      expect(description.predictedOutput, equals('test output'));
    });

    test('configures error output', () {
      description.replaceErrorOutput('test error');
      expect(description.predictedErrorOutput, equals('test error'));
    });

    test('configures output sequence', () {
      description.withOutputSequence(['one', 'two', 'three']);
      expect(description.outputSequence, equals(['one', 'two', 'three']));
    });

    test('configures delay', () {
      description.withDelay(Duration(seconds: 1));
      expect(description.delay, equals(Duration(seconds: 1)));
    });

    test('configures run duration with duration', () {
      description.runsFor(duration: Duration(seconds: 2));
      expect(description.runDuration, equals(Duration(seconds: 2)));
    });

    test('configures run duration with iterations', () {
      description.withDelay(Duration(seconds: 1));
      description.runsFor(iterations: 3);
      expect(description.runDuration, equals(Duration(seconds: 3)));
    });

    test('handles kill signal', () {
      expect(description.kill(), isTrue);
      expect(description.predictedExitCode, equals(-1));
    });

    test('provides process result', () {
      description
        ..withExitCode(1)
        ..replaceOutput('test output')
        ..replaceErrorOutput('test error');

      final result = description.toProcessResult('test command');
      expect(result.pid, isPositive);
      expect(result.exitCode, equals(1));
      expect(result.stdout, equals('test output'));
      expect(result.stderr, equals('test error'));
    });

    test('provides exit code future', () async {
      description
        ..withExitCode(1)
        ..runsFor(duration: Duration(milliseconds: 100));

      final startTime = DateTime.now();
      final exitCode = await description.exitCodeFuture;
      final duration = DateTime.now().difference(startTime);

      expect(exitCode, equals(1));
      expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
    });

    test('supports method chaining', () {
      final result = description
          .withExitCode(1)
          .replaceOutput('output')
          .replaceErrorOutput('error')
          .withOutputSequence(['one', 'two'])
          .withDelay(Duration(seconds: 1))
          .runsFor(duration: Duration(seconds: 2));

      expect(result, equals(description));
    });
  });
}
