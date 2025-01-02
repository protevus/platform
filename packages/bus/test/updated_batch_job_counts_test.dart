import 'package:platform_bus/platform_bus.dart';
import 'package:test/test.dart';

void main() {
  group('UpdatedBatchJobCounts', () {
    test('initializes with correct counts', () {
      final counts = UpdatedBatchJobCounts(
        processedJobs: 5,
        failedJobs: 2,
      );

      expect(counts.processedJobs, equals(5));
      expect(counts.failedJobs, equals(2));
    });

    test('increments processed jobs correctly', () {
      final counts = UpdatedBatchJobCounts(
        processedJobs: 5,
        failedJobs: 2,
      );

      final updated = counts.incrementProcessed();

      expect(updated.processedJobs, equals(6));
      expect(updated.failedJobs, equals(2)); // Should remain unchanged

      // Original should be unchanged
      expect(counts.processedJobs, equals(5));
      expect(counts.failedJobs, equals(2));
    });

    test('increments failed jobs correctly', () {
      final counts = UpdatedBatchJobCounts(
        processedJobs: 5,
        failedJobs: 2,
      );

      final updated = counts.incrementFailed();

      // Both processed and failed should increment
      expect(updated.processedJobs, equals(6));
      expect(updated.failedJobs, equals(3));

      // Original should be unchanged
      expect(counts.processedJobs, equals(5));
      expect(counts.failedJobs, equals(2));
    });

    test('updates counts selectively', () {
      final counts = UpdatedBatchJobCounts(
        processedJobs: 5,
        failedJobs: 2,
      );

      final updatedProcessed = counts.withCounts(processedJobs: 10);
      expect(updatedProcessed.processedJobs, equals(10));
      expect(updatedProcessed.failedJobs, equals(2)); // Should remain unchanged

      final updatedFailed = counts.withCounts(failedJobs: 4);
      expect(updatedFailed.processedJobs, equals(5)); // Should remain unchanged
      expect(updatedFailed.failedJobs, equals(4));

      final updatedBoth = counts.withCounts(
        processedJobs: 15,
        failedJobs: 6,
      );
      expect(updatedBoth.processedJobs, equals(15));
      expect(updatedBoth.failedJobs, equals(6));

      // Original should be unchanged
      expect(counts.processedJobs, equals(5));
      expect(counts.failedJobs, equals(2));
    });

    test('serializes to JSON correctly', () {
      final counts = UpdatedBatchJobCounts(
        processedJobs: 5,
        failedJobs: 2,
      );

      final json = counts.toJson();

      expect(
          json,
          equals({
            'processed_jobs': 5,
            'failed_jobs': 2,
          }));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'processed_jobs': 5,
        'failed_jobs': 2,
      };

      final counts = UpdatedBatchJobCounts.fromJson(json);

      expect(counts.processedJobs, equals(5));
      expect(counts.failedJobs, equals(2));
    });

    test('maintains immutability through operations', () {
      final original = UpdatedBatchJobCounts(
        processedJobs: 5,
        failedJobs: 2,
      );

      // Perform multiple operations
      final afterProcessed = original.incrementProcessed();
      final afterFailed = afterProcessed.incrementFailed();
      final afterUpdate = afterFailed.withCounts(
        processedJobs: 10,
        failedJobs: 5,
      );

      // Verify each operation created a new instance with correct values
      expect(original.processedJobs, equals(5));
      expect(original.failedJobs, equals(2));

      expect(afterProcessed.processedJobs, equals(6));
      expect(afterProcessed.failedJobs, equals(2));

      expect(afterFailed.processedJobs, equals(7));
      expect(afterFailed.failedJobs, equals(3));

      expect(afterUpdate.processedJobs, equals(10));
      expect(afterUpdate.failedJobs, equals(5));
    });

    test('handles zero counts', () {
      final counts = UpdatedBatchJobCounts(
        processedJobs: 0,
        failedJobs: 0,
      );

      expect(counts.processedJobs, equals(0));
      expect(counts.failedJobs, equals(0));

      final updated =
          counts.incrementProcessed().incrementProcessed().incrementFailed();

      expect(updated.processedJobs, equals(3));
      expect(updated.failedJobs, equals(1));
    });
  });
}
