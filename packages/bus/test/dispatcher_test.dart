import 'dart:async';

import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart' hide Dispatcher;
import 'package:test/test.dart';

// Test command for direct dispatch
class DirectCommand {
  final String id;
  DirectCommand(this.id);
}

// Test command handler
class DirectCommandHandler {
  final List<String> handledCommands = [];

  Future<void> handle(DirectCommand command) async {
    handledCommands.add(command.id);
  }
}

// Test command for handler dispatch
class HandledCommand {
  final String id;
  HandledCommand(this.id);
}

// Test command handler
class HandledCommandHandler {
  final List<String> handledCommands = [];

  Future<void> handle(HandledCommand command) async {
    handledCommands.add(command.id);
  }
}

// Test command for pipeline processing
class PipelinedCommand {
  final String id;
  String suffix = '';
  PipelinedCommand(this.id);
}

// Test pipeline
class TestPipeline {
  Future<dynamic> handle(dynamic command, dynamic next) async {
    if (command is PipelinedCommand) {
      command.suffix += '-pipe';
    }
    return next(command);
  }
}

// Test command handler
class PipelinedCommandHandler {
  final List<String> handledCommands = [];

  Future<void> handle(PipelinedCommand command) async {
    handledCommands.add('${command.id}${command.suffix}');
  }
}

// Test queueable command
class QueueableCommand with QueueableMixin implements ShouldQueue {
  final String id;
  QueueableCommand(this.id);

  Future<dynamic> handle() async {
    return this; // Return self to verify in test
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

void main() {
  group('Dispatcher', () {
    late Container container;
    late Dispatcher dispatcher;
    late DirectCommandHandler directHandler;
    late HandledCommandHandler handledHandler;
    late PipelinedCommandHandler pipelinedHandler;
    late TestQueue queue;

    setUp(() {
      container = Container(MirrorsReflector());
      directHandler = DirectCommandHandler();
      handledHandler = HandledCommandHandler();
      pipelinedHandler = PipelinedCommandHandler();
      queue = TestQueue();

      // Register handlers and services in container
      container.registerSingleton<DirectCommandHandler>(directHandler);
      container.registerSingleton<HandledCommandHandler>(handledHandler);
      container.registerSingleton<PipelinedCommandHandler>(pipelinedHandler);
      container.registerSingleton<BatchRepository>(InMemoryBatchRepository());

      dispatcher = Dispatcher(container, (connection) => Future.value(queue));
      dispatcher.map({
        DirectCommand: DirectCommandHandler,
        HandledCommand: HandledCommandHandler,
        PipelinedCommand: PipelinedCommandHandler,
      });
    });

    test('dispatches command directly', () async {
      final command = DirectCommand('test');
      await dispatcher.dispatch(command);
      expect(directHandler.handledCommands, equals(['test']));
    });

    test('dispatches command through handler', () async {
      final command = HandledCommand('test');
      await dispatcher.dispatch(command);
      expect(handledHandler.handledCommands, equals(['test']));
    });

    test('processes command through pipeline', () async {
      final command = PipelinedCommand('test');
      dispatcher.pipeThrough([TestPipeline()]);
      await dispatcher.dispatch(command);
      expect(pipelinedHandler.handledCommands, equals(['test-pipe']));
    });

    test('queues command when implementing ShouldQueue', () async {
      final command = QueueableCommand('test');
      final result = await dispatcher.dispatch(command);
      expect(result, equals(command));
      expect(queue.queuedJobs, equals([command]));
    });

    test('handles sync dispatch of queueable command', () async {
      final command = QueueableCommand('test');
      command.onConnection('sync');
      final result = await dispatcher.dispatchSync(command);
      expect(result, equals(command));
      expect(queue.queuedJobs, equals([command]));
    });

    test('creates and finds batch', () async {
      final jobs = [DirectCommand('1'), DirectCommand('2')];
      final batch = await dispatcher.batch(jobs).dispatch();

      final found = await dispatcher.findBatch(batch.id);
      expect(found, isNotNull);
      expect(found!.id, equals(batch.id));
    });
  });
}
