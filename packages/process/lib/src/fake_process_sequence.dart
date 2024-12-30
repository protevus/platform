import 'dart:collection';
import 'contracts/process_result.dart';
import 'fake_process_description.dart';
import 'fake_process_result.dart';

/// Represents a sequence of fake process results for testing.
class FakeProcessSequence {
  /// The sequence of results.
  final Queue<dynamic> _sequence;

  /// Create a new fake process sequence instance.
  FakeProcessSequence([List<dynamic> sequence = const []])
      : _sequence = Queue.from(sequence);

  /// Add a result to the sequence.
  FakeProcessSequence then(dynamic result) {
    _sequence.add(result);
    return this;
  }

  /// Get the next result in the sequence.
  dynamic call() {
    if (_sequence.isEmpty) {
      throw StateError('No more results in sequence.');
    }
    return _sequence.removeFirst();
  }

  /// Create a sequence from a list of results.
  static FakeProcessSequence fromResults(List<ProcessResult> results) {
    return FakeProcessSequence(results);
  }

  /// Create a sequence from a list of descriptions.
  static FakeProcessSequence fromDescriptions(
      List<FakeProcessDescription> descriptions) {
    return FakeProcessSequence(descriptions);
  }

  /// Create a sequence from a list of outputs.
  static FakeProcessSequence fromOutputs(List<String> outputs) {
    return FakeProcessSequence(
      outputs.map((output) => FakeProcessResult(output: output)).toList(),
    );
  }

  /// Create a sequence that alternates between success and failure.
  static FakeProcessSequence alternating(int count) {
    return FakeProcessSequence(
      List.generate(
        count,
        (i) => FakeProcessResult(
          exitCode: i.isEven ? 0 : 1,
          output: 'Output ${i + 1}',
          errorOutput: i.isEven ? '' : 'Error ${i + 1}',
        ),
      ),
    );
  }

  /// Check if there are more results in the sequence.
  bool get hasMore => _sequence.isNotEmpty;

  /// Get the number of remaining results.
  int get remaining => _sequence.length;

  /// Clear the sequence.
  void clear() => _sequence.clear();
}
