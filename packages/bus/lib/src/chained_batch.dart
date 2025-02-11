import 'package:illuminate_collections/collections.dart';
import 'package:illuminate_contracts/contracts.dart';

/// Helper class for handling chained batches.
///
/// This class provides methods for working with batches that are chained
/// together to be executed in sequence.
class ChainedBatch {
  /// Prepare any nested batches within a collection of jobs.
  ///
  /// This method will extract any nested batches from the jobs collection
  /// and prepare them for chaining.
  ///
  /// [jobs] The collection of jobs to prepare.
  static Collection<dynamic> prepareNestedBatches(Collection<dynamic> jobs) {
    final prepared = <dynamic>[];

    void processJob(dynamic job) {
      if (job is Collection<dynamic>) {
        // If the job is a collection, recursively process its items
        for (final nestedJob in job) {
          processJob(nestedJob);
        }
      } else {
        prepared.add(job);
      }
    }

    for (final job in jobs) {
      processJob(job);
    }

    return Collection<dynamic>(prepared);
  }

  /// Chain a collection of jobs to be executed after a batch.
  ///
  /// This method will create a new batch for the jobs and chain it
  /// to be executed after the given batch.
  ///
  /// [batch] The batch to chain after.
  /// [jobs] The jobs to execute after the batch.
  /// [container] The container instance.
  static Future<BatchContract> chain(
    BatchContract batch,
    Collection<dynamic> jobs,
    dynamic container,
  ) async {
    final repository = container.make<BatchRepository>();
    final dispatcher = container.make<Dispatcher>();

    // Create a new batch for the chained jobs
    final chainedBatch = await dispatcher.batch(jobs).dispatch();

    // Add the chained batch ID to the original batch's chain list
    final chainedBatches =
        Collection<String>([...batch.chainedBatches, chainedBatch.id]);
    final updatedBatch = await repository.find(batch.id);
    if (updatedBatch != null) {
      await repository.store(updatedBatch);
    }

    return chainedBatch;
  }

  /// Execute any batches that are chained after a batch.
  ///
  /// This method will execute any batches that are chained to be
  /// executed after the given batch.
  ///
  /// [batch] The batch whose chains to execute.
  /// [container] The container instance.
  static Future<void> executeChain(
      BatchContract batch, dynamic container) async {
    final repository = container.make<BatchRepository>();
    final dispatcher = container.make<Dispatcher>();

    for (final chainedId in batch.chainedBatches) {
      final chainedBatch = await dispatcher.findBatch(chainedId);
      if (chainedBatch != null) {
        // Get the jobs for this batch from the repository
        final jobs = await repository.getJobs(chainedBatch.id);

        // Queue each job in the batch
        for (final job in jobs) {
          if (job is QueueableJob) {
            await dispatcher.dispatchToQueue(job);
          } else {
            await dispatcher.dispatch(job);
          }
        }
      }
    }
  }
}
