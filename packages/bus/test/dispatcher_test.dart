import 'dart:async';

import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';
import 'package:platform_container/container.dart' show Container;
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart'
    show Queue, ShouldQueue, BatchRepository;
import 'package:platform_pipeline/pipeline.dart';
import 'package:test/test.dart';

// Test command
class TestCommand {
  final String data;
  TestCommand(this.data);

  Future<String> handle() async {
    return 'Handled: $data';
  }
}

// Test handler
class TestHandler {
  Future<String> handle(TestCommand command) async {
    return 'Handler processed: ${command.data}';
  }
}

// Queueable command
class QueueableCommand
    with QueueableMixin, InteractsWithQueueMixin
    implements ShouldQueue {
  final String data;
  QueueableCommand(this.data);

  @override
  Future<void> handle() async {
    print('Processing queued command: $data');
  }
}

// Test pipeline pipe
class TestPipe {
  Future<dynamic> handle(
      dynamic command, FutureOr<dynamic> Function(dynamic) next) async {
    if (command is TestCommand) {
      command = TestCommand('Modified ${command.data}');
    }
    return await next(command);
  }
}

void main() {
  group('Dispatcher', () {
    late Container container;
    late Dispatcher dispatcher;
    late InMemoryBatchRepository batchRepository;

    setUp(() {
      container = Container(MirrorsReflector());
      batchRepository = InMemoryBatchRepository();
      container.registerSingleton<BatchRepository>(batchRepository);

      // Simple queue resolver that creates an in-memory queue
      FutureOr<Queue> queueResolver(String? connection) {
        return InMemoryQueue();
      }

      dispatcher = Dispatcher(container, queueResolver);
    });

    test('dispatches command directly', () async {
      final command = TestCommand('test data');
      final result = await dispatcher.dispatchNow<String>(command);
      expect(result, equals('Handled: test data'));
    });

    test('dispatches command through handler', () async {
      final command = TestCommand('test data');
      dispatcher.map({TestCommand: TestHandler});

      final result = await dispatcher.dispatchNow<String>(command);
      expect(result, equals('Handler processed: test data'));
    });

    test('processes command through pipeline', () async {
      final command = TestCommand('test data');
      dispatcher.pipeThrough([TestPipe()]);

      final result = await dispatcher.dispatchNow<String>(command);
      expect(result, equals('Handled: Modified test data'));
    });

    test('queues command when implementing ShouldQueue', () async {
      final command = QueueableCommand('test data');
      final result = await dispatcher.dispatch(command);

      expect(result, isA<Future>());
    });

    test('creates and finds batch', () async {
      final batch = await dispatcher.batch([
        TestCommand('data1'),
        TestCommand('data2'),
      ]).dispatch();

      final foundBatch = await dispatcher.findBatch(batch.id);
      expect(foundBatch, isNotNull);
      expect(foundBatch?.id, equals(batch.id));
    });

    test('handles sync dispatch of queueable command', () async {
      final command = QueueableCommand('test data')..onConnection('sync');

      final result = await dispatcher.dispatchSync(command);
      expect(result, isA<Future>());
    });
  });
}

// Simple in-memory queue implementation for testing
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
    return job;
  }

  @override
  Future<dynamic> later(Duration delay, dynamic job) async {
    return push(job);
  }

  @override
  Future<dynamic> pushOn(String queue, dynamic job) async {
    return push(job);
  }

  @override
  Future<dynamic> laterOn(String queue, Duration delay, dynamic job) async {
    return push(job);
  }
}
