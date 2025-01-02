import 'dart:async';

import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart' as contracts;
import 'package:test/test.dart';

// Test job that supports batch configuration
class ConfigurableJob with QueueableMixin, InteractsWithQueueMixin, Batchable {
  final String id;
  final List<String> events = [];

  ConfigurableJob(this.id);

  Future<void> handle() async {
    events.add('Handling job $id');
    await Future.delayed(Duration(milliseconds: 50));
    events.add('Completed job $id');
  }
}

void main() {
  group('PendingBatch', () {
    late Container container;
    late InMemoryBatchRepository repository;

    setUp(() {
      container = Container(MirrorsReflector());
      repository = InMemoryBatchRepository();
      container.registerSingleton<contracts.BatchRepository>(repository);
    });

    test('configures basic batch properties', () async {
      final jobs = [
        ConfigurableJob('1'),
        ConfigurableJob('2'),
      ];

      final batch = await PendingBatch(container, Collection(jobs))
          .name('Test Batch')
          .dispatch();

      expect(batch.name, equals('Test Batch'));
      expect(batch.totalJobs, equals(2));
      expect(batch.processedJobs, equals(0));
      expect(batch.failedJobs, equals(0));
      expect(batch.options, isEmpty);
    });

    test('configures batch options', () async {
      final jobs = [ConfigurableJob('1')];

      final batch = await PendingBatch(container, Collection(jobs))
          .allowFailures()
          .tries(3)
          .timeout(Duration(seconds: 30))
          .retryAfter(Duration(seconds: 5))
          .dispatch();

      expect(batch.options['allowFailures'], isTrue);
      expect(batch.options['tries'], equals(3));
      expect(batch.options['timeout'], equals(30));
      expect(batch.options['retryAfter'], equals(5));
    });

    test('assigns batch information to jobs', () async {
      final job1 = ConfigurableJob('1');
      final job2 = ConfigurableJob('2');

      final batch = await PendingBatch(container, Collection([job1, job2]))
          .name('Test Batch')
          .dispatch();

      expect(job1.batchId, equals(batch.id));
      expect(job1.batchIndex, equals(0));
      expect(job2.batchId, equals(batch.id));
      expect(job2.batchIndex, equals(1));
    });

    test('configures job retry settings', () async {
      final job = ConfigurableJob('1');

      await PendingBatch(container, Collection([job]))
          .tries(3)
          .retryAfter(Duration(seconds: 5))
          .dispatch();

      expect(job.maxTries, equals(3));
      expect(job.retryAfter?.inSeconds, equals(5));
    });

    test('configures job timeout', () async {
      final job = ConfigurableJob('1');

      await PendingBatch(container, Collection([job]))
          .timeout(Duration(seconds: 30))
          .dispatch();

      expect(job.timeout?.inSeconds, equals(30));
    });

    test('stores jobs in repository', () async {
      final jobs = [
        ConfigurableJob('1'),
        ConfigurableJob('2'),
      ];

      final batch = await PendingBatch(container, Collection(jobs)).dispatch();
      final storedJobs = await repository.getJobs(batch.id);

      expect(storedJobs.length, equals(2));
      expect(
        (storedJobs[0] as ConfigurableJob).id,
        equals('1'),
      );
      expect(
        (storedJobs[1] as ConfigurableJob).id,
        equals('2'),
      );
    });

    test('chains batches', () async {
      // Create main batch
      final mainJobs = [ConfigurableJob('main')];

      // Create chained batch jobs
      final chain1Jobs = [ConfigurableJob('chain1')];
      final chain2Jobs = [ConfigurableJob('chain2')];

      // Create the batch with chains
      final batch = await PendingBatch(container, Collection(mainJobs))
          .chain(chain1Jobs)
          .chain(chain2Jobs)
          .dispatch();

      // Verify chains were created
      expect(batch.chainedBatches.length, equals(2));

      // Verify chained batches exist in repository
      for (final chainedId in batch.chainedBatches) {
        final chainedBatch = await repository.find(chainedId);
        expect(chainedBatch, isNotNull);
      }

      // Verify jobs were stored for each batch
      final storedChain1Jobs =
          await repository.getJobs(batch.chainedBatches[0]);
      final storedChain2Jobs =
          await repository.getJobs(batch.chainedBatches[1]);

      expect(storedChain1Jobs.length, equals(1));
      expect(storedChain2Jobs.length, equals(1));
      expect((storedChain1Jobs[0] as ConfigurableJob).id, equals('chain1'));
      expect((storedChain2Jobs[0] as ConfigurableJob).id, equals('chain2'));
    });

    test('registers callbacks', () async {
      var successCallbackCalled = false;
      var errorCallbackCalled = false;
      var finallyCallbackCalled = false;

      await PendingBatch(container, Collection([ConfigurableJob('1')]))
          .then((b) => successCallbackCalled = true)
          .onError((b, e) => errorCallbackCalled = true)
          .onFinish((b) => finallyCallbackCalled = true)
          .dispatch();

      // Callbacks are registered but not executed in this test
      // They will be executed by the dispatcher when processing the batch
      expect(successCallbackCalled, isFalse);
      expect(errorCallbackCalled, isFalse);
      expect(finallyCallbackCalled, isFalse);
    });
  });
}
