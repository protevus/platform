import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';
import 'package:test/test.dart';

void main() {
  group('Batch', () {
    test('creates batch with correct properties', () {
      final batch = Batch(
        'test-id',
        'test-batch',
        10,
        Collection([]),
        {'option1': 'value1'},
      );

      expect(batch.id, equals('test-id'));
      expect(batch.name, equals('test-batch'));
      expect(batch.totalJobs, equals(10));
      expect(batch.processedJobs, equals(0));
      expect(batch.failedJobs, equals(0));
      expect(batch.pendingJobs, equals(10));
      expect(batch.finished, isFalse);
      expect(batch.cancelled, isFalse);
      expect(batch.options['option1'], equals('value1'));
    });

    test('tracks job progress correctly', () {
      final batch = Batch('id', 'name', 3, Collection([]), {});

      expect(batch.pendingJobs, equals(3));
      expect(batch.finished, isFalse);

      batch.processedJobs = 2;
      expect(batch.pendingJobs, equals(1));
      expect(batch.finished, isFalse);

      batch.processedJobs = 3;
      expect(batch.pendingJobs, equals(0));
      expect(batch.finished, isTrue);
    });

    test('handles failed jobs', () {
      final batch = Batch('id', 'name', 3, Collection([]), {});

      batch.failedJobs = 1;
      batch.processedJobs = 2;

      expect(batch.failedJobs, equals(1));
      expect(batch.pendingJobs, equals(1));
      expect(batch.finished, isFalse);
    });

    test('executes success callback', () async {
      final batch = Batch('id', 'name', 1, Collection([]), {});
      var callbackExecuted = false;

      batch.then((b) {
        callbackExecuted = true;
        expect(b, equals(batch));
      });

      await batch.invokeSuccessCallback();
      expect(callbackExecuted, isTrue);
    });

    test('executes error callback', () {
      final batch = Batch('id', 'name', 1, Collection([]), {});
      var callbackExecuted = false;
      final testError = Exception('Test error');

      batch.onError((b, error) {
        callbackExecuted = true;
        expect(b, equals(batch));
        expect(error, equals(testError));
      });

      batch.invokeErrorCallback(testError);
      expect(callbackExecuted, isTrue);
    });

    test('executes finally callback', () {
      final batch = Batch('id', 'name', 1, Collection([]), {});
      var callbackExecuted = false;

      batch.onFinish((b) {
        callbackExecuted = true;
        expect(b, equals(batch));
      });

      batch.invokeFinallyCallback();
      expect(callbackExecuted, isTrue);
    });

    test('handles batch chaining', () {
      final chainedBatchIds = Collection(['chain1', 'chain2']);
      final batch = Batch('id', 'name', 1, chainedBatchIds, {});

      expect(batch.chainedBatches, equals(chainedBatchIds));

      final newChainedBatchIds = Collection(['chain3']);
      final newBatch = batch.withChainedBatches(newChainedBatchIds);

      expect(newBatch.chainedBatches, equals(newChainedBatchIds));
      expect(
          batch.chainedBatches, equals(chainedBatchIds)); // Original unchanged
    });

    test('can be cancelled', () async {
      final batch = Batch('id', 'name', 1, Collection([]), {});

      expect(batch.cancelled, isFalse);
      await batch.cancel();
      expect(batch.cancelled, isTrue);
    });
  });
}
