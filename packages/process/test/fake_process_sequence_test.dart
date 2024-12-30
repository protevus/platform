import 'package:test/test.dart';
import 'package:platform_process/process.dart';

void main() {
  group('FakeProcessSequence', () {
    test('creates empty sequence', () {
      final sequence = FakeProcessSequence();
      expect(sequence.hasMore, isFalse);
      expect(sequence.remaining, equals(0));
    });

    test('adds results to sequence', () {
      final sequence = FakeProcessSequence()
        ..then('first')
        ..then('second')
        ..then('third');

      expect(sequence.hasMore, isTrue);
      expect(sequence.remaining, equals(3));
    });

    test('retrieves results in order', () {
      final sequence = FakeProcessSequence()
        ..then('first')
        ..then('second');

      expect(sequence.call(), equals('first'));
      expect(sequence.call(), equals('second'));
      expect(sequence.hasMore, isFalse);
    });

    test('throws when empty', () {
      final sequence = FakeProcessSequence();
      expect(() => sequence.call(), throwsStateError);
    });

    test('creates from results list', () {
      final results = [
        FakeProcessResult(output: 'one'),
        FakeProcessResult(output: 'two'),
      ];

      final sequence = FakeProcessSequence.fromResults(results);
      expect(sequence.remaining, equals(2));

      final first = sequence.call() as FakeProcessResult;
      expect(first.output(), equals('one'));

      final second = sequence.call() as FakeProcessResult;
      expect(second.output(), equals('two'));
    });

    test('creates from descriptions list', () {
      final descriptions = [
        FakeProcessDescription()..replaceOutput('first'),
        FakeProcessDescription()..replaceOutput('second'),
      ];

      final sequence = FakeProcessSequence.fromDescriptions(descriptions);
      expect(sequence.remaining, equals(2));

      final first = sequence.call() as FakeProcessDescription;
      expect(first.predictedOutput, equals('first'));

      final second = sequence.call() as FakeProcessDescription;
      expect(second.predictedOutput, equals('second'));
    });

    test('creates from outputs list', () {
      final outputs = ['one', 'two', 'three'];
      final sequence = FakeProcessSequence.fromOutputs(outputs);

      expect(sequence.remaining, equals(3));

      for (final expected in outputs) {
        final result = sequence.call() as FakeProcessResult;
        expect(result.output(), equals(expected));
        expect(result.successful(), isTrue);
      }
    });

    test('creates alternating success/failure sequence', () {
      final sequence = FakeProcessSequence.alternating(4);
      expect(sequence.remaining, equals(4));

      // First result (success)
      var result = sequence.call() as FakeProcessResult;
      expect(result.successful(), isTrue);
      expect(result.output(), equals('Output 1'));
      expect(result.errorOutput(), isEmpty);

      // Second result (failure)
      result = sequence.call() as FakeProcessResult;
      expect(result.failed(), isTrue);
      expect(result.output(), equals('Output 2'));
      expect(result.errorOutput(), equals('Error 2'));

      // Third result (success)
      result = sequence.call() as FakeProcessResult;
      expect(result.successful(), isTrue);
      expect(result.output(), equals('Output 3'));
      expect(result.errorOutput(), isEmpty);

      // Fourth result (failure)
      result = sequence.call() as FakeProcessResult;
      expect(result.failed(), isTrue);
      expect(result.output(), equals('Output 4'));
      expect(result.errorOutput(), equals('Error 4'));
    });

    test('supports method chaining', () {
      final sequence =
          FakeProcessSequence().then('first').then('second').then('third');

      expect(sequence.remaining, equals(3));
    });

    test('clears sequence', () {
      final sequence = FakeProcessSequence()
        ..then('first')
        ..then('second');

      expect(sequence.remaining, equals(2));

      sequence.clear();
      expect(sequence.remaining, equals(0));
      expect(sequence.hasMore, isFalse);
    });

    test('handles mixed result types', () {
      final sequence = FakeProcessSequence()
        ..then('string result')
        ..then(FakeProcessResult(output: 'result output'))
        ..then(FakeProcessDescription()..replaceOutput('description output'));

      expect(sequence.call(), equals('string result'));

      final result = sequence.call() as FakeProcessResult;
      expect(result.output(), equals('result output'));

      final description = sequence.call() as FakeProcessDescription;
      expect(description.predictedOutput, equals('description output'));
    });
  });
}
