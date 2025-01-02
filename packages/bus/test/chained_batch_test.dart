import 'dart:async';

import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart' as contracts;
import 'package:test/test.dart';

// Test job for batch chaining
class TestJob with QueueableMixin, InteractsWithQueueMixin {
  final String id;
  TestJob(this.id);

  Future<void> handle() async => print('Handling job $id');
}

void main() {
  group('ChainedBatch', () {
    test('prepares nested batches correctly', () {
      final job1 = TestJob('1');
      final job2 = TestJob('2');
      final nestedJobs = Collection([TestJob('3'), TestJob('4')]);
      final job5 = TestJob('5');

      final jobs = Collection([job1, job2, nestedJobs, job5]);
      final prepared = ChainedBatch.prepareNestedBatches(jobs);

      expect(prepared.length, equals(5));
      expect(
        prepared.map((job) => (job as TestJob).id),
        containsAllInOrder(['1', '2', '3', '4', '5']),
      );
    });

    test('handles empty nested batches', () {
      final job1 = TestJob('1');
      final emptyBatch = Collection([]);
      final job2 = TestJob('2');

      final jobs = Collection([job1, emptyBatch, job2]);
      final prepared = ChainedBatch.prepareNestedBatches(jobs);

      expect(prepared.length, equals(2));
      expect(
        prepared.map((job) => (job as TestJob).id),
        containsAllInOrder(['1', '2']),
      );
    });

    test('handles multiple levels of nesting', () {
      final job1 = TestJob('1');
      final nested1 = Collection([TestJob('2'), TestJob('3')]);
      final nested2 = Collection([
        TestJob('4'),
        Collection([TestJob('5'), TestJob('6')]),
      ]);
      final job7 = TestJob('7');

      final jobs = Collection([job1, nested1, nested2, job7]);
      final prepared = ChainedBatch.prepareNestedBatches(jobs);

      expect(prepared.length, equals(7));
      expect(
        prepared.map((job) => (job as TestJob).id),
        containsAllInOrder(['1', '2', '3', '4', '5', '6', '7']),
      );
    });

    test('chains batches correctly', () async {
      // Set up container with required dependencies
      final container = Container(MirrorsReflector());
      final repository = InMemoryBatchRepository();
      container.registerSingleton<contracts.BatchRepository>(repository);

      // Create test batch and jobs
      final batch = Batch(
        'test-batch',
        'Test Batch',
        1,
        Collection([]),
        {},
      );
      await repository.store(batch);

      final chainedJobs = Collection([
        TestJob('chained-1'),
        TestJob('chained-2'),
      ]);

      // Chain the jobs
      final chainedBatch =
          await ChainedBatch.chain(batch, chainedJobs, container);

      // Verify the chain
      expect(chainedBatch, isNotNull);
      expect(batch.chainedBatches, contains(chainedBatch.id));

      // Verify jobs were stored
      final storedJobs = await repository.getJobs(chainedBatch.id);
      expect(storedJobs.length, equals(2));
      expect(
        storedJobs.map((job) => (job as TestJob).id),
        containsAllInOrder(['chained-1', 'chained-2']),
      );
    });

    test('executes chain correctly', () async {
      // Set up container with required dependencies
      final container = Container(MirrorsReflector());
      final repository = InMemoryBatchRepository();
      container.registerSingleton<contracts.BatchRepository>(repository);

      // Create a queue for tracking executed jobs
      final executedJobs = <String>[];
      final queue = TestQueue(onPush: (job) {
        if (job is TestJob) {
          executedJobs.add(job.id);
        }
        return Future.value(job);
      });

      // Create dispatcher with test queue
      final dispatcher =
          Dispatcher(container, (connection) => Future.value(queue));
      container.registerSingleton<contracts.Dispatcher>(dispatcher);

      // Create main batch with chained batches
      final mainBatch = Batch(
        'main-batch',
        'Main Batch',
        1,
        Collection(['chain1', 'chain2']),
        {},
      );
      await repository.store(mainBatch);

      // Create and store chained batches with jobs
      final chain1Jobs = Collection([TestJob('1-1'), TestJob('1-2')]);
      final chain2Jobs = Collection([TestJob('2-1'), TestJob('2-2')]);

      await repository.storeJobs('chain1', chain1Jobs);
      await repository.storeJobs('chain2', chain2Jobs);

      // Execute the chain
      await ChainedBatch.executeChain(mainBatch, container);

      // Verify all jobs were executed in order
      expect(executedJobs.length, equals(4));
      expect(
        executedJobs,
        containsAllInOrder(['1-1', '1-2', '2-1', '2-2']),
      );
    });
  });
}

// Test queue that tracks job execution
class TestQueue extends contracts.Queue {
  final Future<dynamic> Function(dynamic) onPush;
  final List<dynamic> _jobs = [];

  TestQueue({required this.onPush});

  @override
  Future<int> size() async => _jobs.length;

  @override
  Future<void> clear() async => _jobs.clear();

  @override
  Future<dynamic> push(dynamic job) async {
    _jobs.add(job);
    return onPush(job);
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
