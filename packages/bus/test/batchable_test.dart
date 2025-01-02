import 'package:platform_bus/platform_bus.dart';
import 'package:test/test.dart';

// Test job class that uses Batchable mixin
class TestBatchableJob with Batchable {
  final String name;

  TestBatchableJob(this.name);
}

void main() {
  group('Batchable', () {
    late TestBatchableJob job;

    setUp(() {
      job = TestBatchableJob('test-job');
    });

    test('initially has no batch information', () {
      expect(job.batchId, isNull);
      expect(job.batchIndex, isNull);
      expect(job.inBatch, isFalse);
    });

    test('can be assigned to a batch', () {
      job.withBatch('batch-1', 0);

      expect(job.batchId, equals('batch-1'));
      expect(job.batchIndex, equals(0));
      expect(job.inBatch, isTrue);
    });

    test('can be removed from a batch', () {
      job.withBatch('batch-1', 0);
      job.removeBatch();

      expect(job.batchId, isNull);
      expect(job.batchIndex, isNull);
      expect(job.inBatch, isFalse);
    });

    test('can be reassigned to different batches', () {
      job.withBatch('batch-1', 0);
      expect(job.batchId, equals('batch-1'));
      expect(job.batchIndex, equals(0));

      job.withBatch('batch-2', 1);
      expect(job.batchId, equals('batch-2'));
      expect(job.batchIndex, equals(1));
    });

    test('inBatch reflects batch assignment state', () {
      expect(job.inBatch, isFalse);

      job.withBatch('batch-1', 0);
      expect(job.inBatch, isTrue);

      job.removeBatch();
      expect(job.inBatch, isFalse);
    });
  });
}
