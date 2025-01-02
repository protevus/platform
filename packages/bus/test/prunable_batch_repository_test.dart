import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';
import 'package:test/test.dart';

void main() {
  group('PrunableInMemoryBatchRepository', () {
    late PrunableInMemoryBatchRepository repository;

    setUp(() {
      repository = PrunableInMemoryBatchRepository();
    });

    test('stores and retrieves batches', () async {
      final batch = Batch(
        'test-batch',
        'Test Batch',
        2,
        Collection([]),
        {'test': true},
      );

      await repository.store(batch);
      final retrieved = await repository.find('test-batch');

      expect(retrieved, isNotNull);
      expect(retrieved?.id, equals('test-batch'));
      expect(retrieved?.name, equals('Test Batch'));
    });

    test('prunes old batches', () async {
      // Store some batches
      final batch1 = Batch('batch1', 'Batch 1', 1, Collection([]), {});
      final batch2 = Batch('batch2', 'Batch 2', 1, Collection([]), {});
      final batch3 = Batch('batch3', 'Batch 3', 1, Collection([]), {});

      await repository.store(batch1);
      await repository.store(batch2);
      await repository.store(batch3);

      // Verify all batches are stored
      expect((await repository.all()).length, equals(3));

      // Prune batches older than 0 hours (all batches)
      final prunedCount = await repository.prune(0);

      expect(prunedCount, equals(3));
      expect((await repository.all()).length, equals(0));
    });

    test('only prunes batches older than specified hours', () async {
      final batch = Batch('test-batch', 'Test Batch', 1, Collection([]), {});
      await repository.store(batch);

      // Prune batches older than 1 hour (should not prune any)
      final prunedCount = await repository.prune(1);

      expect(prunedCount, equals(0));
      expect((await repository.all()).length, equals(1));
    });

    test('stores and retrieves batch jobs', () async {
      final jobs = Collection(['job1', 'job2']);
      await repository.storeJobs('test-batch', jobs);

      final retrievedJobs = await repository.getJobs('test-batch');
      expect(retrievedJobs.length, equals(2));
      expect(retrievedJobs, containsAll(['job1', 'job2']));
    });

    test('deletes batch and its jobs', () async {
      final batch = Batch('test-batch', 'Test Batch', 2, Collection([]), {});
      final jobs = Collection(['job1', 'job2']);

      await repository.store(batch);
      await repository.storeJobs('test-batch', jobs);

      await repository.delete('test-batch');

      expect(await repository.find('test-batch'), isNull);
      expect((await repository.getJobs('test-batch')).isEmpty, isTrue);
    });

    test('gets finished and pending batches', () async {
      final pendingBatch = Batch('pending', 'Pending', 2, Collection([]), {});
      final finishedBatch = Batch('finished', 'Finished', 1, Collection([]), {})
        ..processedJobs = 1; // Mark as finished

      await repository.store(pendingBatch);
      await repository.store(finishedBatch);

      final pending = await repository.getPending();
      final finished = await repository.getFinished();

      expect(pending.length, equals(1));
      expect(pending.first.id, equals('pending'));

      expect(finished.length, equals(1));
      expect(finished.first.id, equals('finished'));
    });
  });
}
