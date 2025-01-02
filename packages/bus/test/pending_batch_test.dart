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

// Test queue
class TestQueue implements Queue {
  final List<dynamic> queuedJobs = [];

  @override
  Future<void> clear() async {
    queuedJobs.clear();
  }

  @override
  Future<dynamic> later(Duration delay, dynamic job) async {
    queuedJobs.add(job);
    return Future.value(job);
  }

  @override
  Future<dynamic> laterOn(String queue, Duration delay, dynamic job) async {
    queuedJobs.add(job);
    return Future.value(job);
  }

  @override
  Future<dynamic> push(dynamic job) async {
    queuedJobs.add(job);
    return Future.value(job);
  }

  @override
  Future<dynamic> pushOn(String queue, dynamic job) async {
    queuedJobs.add(job);
    return Future.value(job);
  }

  @override
  Future<int> size() async {
    return queuedJobs.length;
  }
}

// Test command for batch operations
class TestCommand {
  final String id;
  TestCommand(this.id);
}

void main() {
  group('PendingBatch', () {
    late Container container;
    late BatchRepository repository;
    late MockDispatcher dispatcher;

    setUp(() {
      container = Container(MirrorsReflector());
      repository = InMemoryBatchRepository();
      dispatcher = MockDispatcher(container);

      container.registerSingleton<BatchRepository>(repository);
      container.registerSingleton<Queue>(TestQueue());
      container.registerSingleton<Dispatcher>(dispatcher);
    });

    test('configures basic batch properties', () async {
      final batch =
          await PendingBatch(container, Collection([TestCommand('1')]))
              .name('Test Batch')
              .dispatch();

      expect(batch.name, equals('Test Batch'));
      expect(batch.totalJobs, equals(1));
      expect(batch.processedJobs, equals(0));
      expect(batch.failedJobs, equals(0));
      expect(batch.options, equals({'allowFailures': false}));
    });

    test('configures batch options', () async {
      final batch =
          await PendingBatch(container, Collection([TestCommand('1')]))
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
      final job = TestCommand('1');
      final batch = await PendingBatch(container, Collection([job])).dispatch();

      final storedJobs = await repository.getJobs(batch.id);
      expect(storedJobs.length, equals(1));
    });

    test('chains batches', () async {
      final mainJob = TestCommand('main');
      final chainedJob = TestCommand('chained');

      final batch = await PendingBatch(container, Collection([mainJob]))
          .chain([chainedJob]).dispatch();

      expect(batch.chainedBatches.length, equals(1));
      expect(dispatcher.dispatchedJobs.length, equals(1));
    });

    test('registers callbacks', () async {
      var successCallbackCalled = false;
      var errorCallbackCalled = false;
      var finallyCallbackCalled = false;

      final batch =
          await PendingBatch(container, Collection([TestCommand('1')]))
              .then((b) => successCallbackCalled = true)
              .onError((b, e) => errorCallbackCalled = true)
              .onFinish((b) => finallyCallbackCalled = true)
              .dispatch();

      // Verify callbacks are registered but not called yet
      expect(successCallbackCalled, isFalse);
      expect(errorCallbackCalled, isFalse);
      expect(finallyCallbackCalled, isFalse);
    });
  });
}
