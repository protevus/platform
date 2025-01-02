import 'dart:async';

import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart' hide Dispatcher;
import 'package:test/test.dart';

// Mock dispatcher for testing
class MockDispatcher implements Dispatcher {
  final Container container;
  final List<dynamic> dispatchedJobs = [];
  final Map<Type, dynamic> _handlers = {};

  MockDispatcher(this.container);

  @override
  PendingBatchContract batch(dynamic jobs) {
    return PendingBatch(container, Collection(jobs is List ? jobs : [jobs]));
  }

  @override
  FutureOr<T> dispatch<T>(dynamic command) {
    dispatchedJobs.add(command);
    return Future.value(command as T);
  }

  @override
  FutureOr<T> dispatchNow<T>(dynamic command, [dynamic handler]) {
    dispatchedJobs.add(command);
    return Future.value(command as T);
  }

  @override
  FutureOr<T> dispatchSync<T>(dynamic command, [dynamic handler]) {
    dispatchedJobs.add(command);
    return Future.value(command as T);
  }

  @override
  Future<dynamic> dispatchToQueue(dynamic command) async {
    dispatchedJobs.add(command);
    return command;
  }

  @override
  Future<BatchContract?> findBatch(String id) async {
    return null;
  }

  @override
  dynamic getCommandHandler(dynamic command) {
    final type = command.runtimeType;
    return _handlers[type];
  }

  @override
  bool hasCommandHandler(dynamic command) {
    final type = command.runtimeType;
    return _handlers.containsKey(type);
  }

  @override
  Dispatcher map(Map<Type, dynamic> handlers) {
    _handlers.addAll(handlers);
    return this;
  }

  @override
  Dispatcher pipeThrough(List<dynamic> pipes) {
    return this;
  }
}

// Test job for batch chaining
class TestJob with QueueableMixin, InteractsWithQueueMixin {
  final String id;
  final List<String> executionOrder;

  TestJob(this.id, this.executionOrder);

  Future<void> handle() async {
    executionOrder.add('start-$id');
    await Future.delayed(Duration(milliseconds: 50));
    executionOrder.add('end-$id');
  }
}

void main() {
  group('ChainedBatch', () {
    late Container container;
    late BatchRepository repository;
    late MockDispatcher dispatcher;
    late List<String> executionOrder;

    setUp(() {
      container = Container(MirrorsReflector());
      repository = InMemoryBatchRepository();
      dispatcher = MockDispatcher(container);
      executionOrder = [];

      container.registerSingleton<BatchRepository>(repository);
      container.registerSingleton<Dispatcher>(dispatcher);
    });

    test('prepares nested batches correctly', () {
      final job1 = TestJob('1', executionOrder);
      final job2 = TestJob('2', executionOrder);
      final nestedJobs = Collection(
          [TestJob('3', executionOrder), TestJob('4', executionOrder)]);
      final job5 = TestJob('5', executionOrder);

      final jobs = Collection([job1, job2, nestedJobs, job5]);
      final prepared = ChainedBatch.prepareNestedBatches(jobs);

      expect(prepared.length, equals(5));
      final jobIds = prepared.whereType<TestJob>().map((job) => job.id);
      expect(
        jobIds,
        containsAllInOrder(['1', '2', '3', '4', '5']),
      );
    });

    test('handles empty nested batches', () {
      final job1 = TestJob('1', executionOrder);
      final emptyBatch = Collection([]);
      final job2 = TestJob('2', executionOrder);

      final jobs = Collection([job1, emptyBatch, job2]);
      final prepared = ChainedBatch.prepareNestedBatches(jobs);

      expect(prepared.length, equals(2));
      expect(
        prepared.map((job) => (job as TestJob).id),
        containsAllInOrder(['1', '2']),
      );
    });

    test('handles multiple levels of nesting', () {
      final job1 = TestJob('1', executionOrder);
      final nested1 = Collection(
          [TestJob('2', executionOrder), TestJob('3', executionOrder)]);
      final nested2 = Collection([
        TestJob('4', executionOrder),
        Collection(
            [TestJob('5', executionOrder), TestJob('6', executionOrder)]),
      ]);

      final jobs = Collection([job1, nested1, nested2]);
      final prepared = ChainedBatch.prepareNestedBatches(jobs);

      expect(prepared.length, equals(5));
      final jobIds =
          prepared.whereType<TestJob>().map((job) => job.id).toList();
      expect(
        jobIds,
        containsAllInOrder(['1', '2', '3', '4', '5']),
      );
    });

    test('chains batches correctly', () async {
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
        TestJob('chained-1', executionOrder),
        TestJob('chained-2', executionOrder),
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
      final chain1Jobs = Collection([
        TestJob('1-1', executionOrder),
        TestJob('1-2', executionOrder),
      ]);
      final chain2Jobs = Collection([
        TestJob('2-1', executionOrder),
        TestJob('2-2', executionOrder),
      ]);

      await repository.storeJobs('chain1', chain1Jobs);
      await repository.storeJobs('chain2', chain2Jobs);

      // Execute the chain
      await ChainedBatch.executeChain(mainBatch, container);

      // Verify execution order
      expect(executionOrder.length, equals(8)); // start + end for each job
      expect(
        executionOrder,
        containsAllInOrder([
          'start-1-1',
          'end-1-1',
          'start-1-2',
          'end-1-2',
          'start-2-1',
          'end-2-1',
          'start-2-2',
          'end-2-2',
        ]),
      );
    });
  });
}
