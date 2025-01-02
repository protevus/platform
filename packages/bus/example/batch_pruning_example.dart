import 'dart:async';

import 'package:platform_bus/platform_bus.dart' hide Dispatcher;
import 'package:platform_collections/platform_collections.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart'
    show Queue, ShouldQueue, QueueableJob, BatchRepository;
import 'package:platform_bus/src/dispatcher.dart' show Dispatcher;

// Example job that takes some time to process
class LongRunningJob with QueueableMixin, InteractsWithQueueMixin {
  final String id;
  final Duration processingTime;

  LongRunningJob(this.id, this.processingTime);

  Future<void> handle() async {
    print('Starting job $id (Duration: ${processingTime.inSeconds}s)');
    await Future.delayed(processingTime);
    print('Completed job $id');
  }
}

void main() async {
  // Create a prunable repository to store batches
  final repository = PrunableInMemoryBatchRepository();

  // Set up the container and dispatcher
  final container = Container(MirrorsReflector());
  container.registerSingleton<BatchRepository>(repository);

  final queue = InMemoryQueue();
  final dispatcher = Dispatcher(container, (connection) => queue);

  print('Creating batches with different processing times...\n');

  // Create and process batches with different durations
  for (var i = 1; i <= 3; i++) {
    final jobs = [
      LongRunningJob('batch${i}_job1', Duration(seconds: i)),
      LongRunningJob('batch${i}_job2', Duration(seconds: i)),
    ];

    print('Dispatching Batch $i');
    final batch = await dispatcher.batch(jobs).dispatch();

    // Wait for batch to complete
    while (!batch.finished) {
      await Future.delayed(Duration(milliseconds: 100));
      print('Batch $i progress: ${batch.processedJobs}/${batch.totalJobs}');
    }
    print('Batch $i completed\n');
  }

  // Show current batch statistics
  print('Current batch statistics:');
  print('- Total batches: ${(await repository.all()).length}');
  print('- Finished batches: ${(await repository.getFinished()).length}');
  print('- Pending batches: ${(await repository.getPending()).length}\n');

  // Prune old batches (those older than 1 hour)
  print('Pruning batches older than 1 hour...');
  final prunedCount = await repository.prune(1);
  print('Pruned $prunedCount batches (expected 0 since batches are recent)\n');

  // Force prune all batches (0 hours means prune everything)
  print('Force pruning all batches...');
  final forcePrunedCount = await repository.prune(0);
  print('Pruned $forcePrunedCount batches\n');

  // Verify all batches were pruned
  print('Final batch statistics:');
  print('- Total batches: ${(await repository.all()).length}');
  print('- Finished batches: ${(await repository.getFinished()).length}');
  print('- Pending batches: ${(await repository.getPending()).length}');
}

// Simple in-memory queue implementation
class InMemoryQueue implements Queue {
  final List<dynamic> _jobs = [];

  @override
  Future<int> size() async => _jobs.length;

  @override
  Future<void> clear() async {
    _jobs.clear();
  }

  @override
  Future<dynamic> push(dynamic job) async {
    _jobs.add(job);
    if (job is LongRunningJob) {
      await job.handle();
    }
    return job;
  }

  @override
  Future<dynamic> later(Duration delay, dynamic job) async {
    await Future.delayed(delay);
    return push(job);
  }

  @override
  Future<dynamic> pushOn(String queue, dynamic job) async {
    return push(job);
  }

  @override
  Future<dynamic> laterOn(String queue, Duration delay, dynamic job) async {
    await Future.delayed(delay);
    return pushOn(queue, job);
  }
}
