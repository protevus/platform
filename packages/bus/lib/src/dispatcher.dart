// lib/src/dispatcher.dart

import 'dart:async';

import 'package:platform_container/container.dart';
import 'package:angel3_reactivex/angel3_reactivex.dart';
import 'package:angel3_event_bus/event_bus.dart';
import 'package:angel3_mq/mq.dart';

import 'command.dart';
import 'handler.dart';
import 'batch.dart';
import 'chain.dart';

/// A class that handles dispatching and processing of commands.
///
/// This dispatcher supports both synchronous and asynchronous command execution,
/// as well as queueing commands for later processing.
class Dispatcher implements QueueingDispatcher {
  final Container container;
  final EventBus _eventBus;
  final Subject<Command> _commandSubject;
  final MQClient _queue;
  final Map<Type, Type> _handlers = {};

  /// Creates a new [Dispatcher] instance.
  ///
  /// [container] is used for dependency injection and to retrieve necessary services.
  Dispatcher(this.container)
      : _eventBus = container.make<EventBus>(),
        _commandSubject = BehaviorSubject<Command>(),
        _queue = container.make<MQClient>() {
    _setupCommandProcessing();
  }

  /// Sets up the command processing pipeline.
  ///
  /// This method initializes the stream that processes commands and emits events.
  void _setupCommandProcessing() {
    _commandSubject
        .flatMap((command) => Stream.fromFuture(_processCommand(command))
            .map((result) => CommandEvent(command, result: result))
            .onErrorReturnWith(
                (error, stackTrace) => CommandEvent(command, error: error)))
        .listen((event) {
      _eventBus.fire(event);
    });
  }

  /// Dispatches a command for execution.
  ///
  /// If the command implements [ShouldQueue], it will be dispatched to a queue.
  /// Otherwise, it will be executed immediately.
  ///
  /// [command] is the command to be dispatched.
  @override
  Future<dynamic> dispatch(Command command) {
    if (command is ShouldQueue) {
      return dispatchToQueue(command);
    } else {
      return dispatchNow(command);
    }
  }

  /// Dispatches a command for immediate execution.
  ///
  /// [command] is the command to be executed.
  /// [handler] is an optional specific handler for the command.
  @override
  Future<dynamic> dispatchNow(Command command, [Handler? handler]) {
    final completer = Completer<dynamic>();
    _commandSubject.add(command);

    _eventBus
        .on<CommandEvent>()
        .where((event) => event.command == command)
        .take(1)
        .listen((event) {
      if (event.error != null) {
        completer.completeError(event.error);
      } else {
        completer.complete(event.result);
      }
    });

    return completer.future;
  }

  /// Processes a command by finding and executing its appropriate handler.
  ///
  /// [command] is the command to be processed.
  Future<dynamic> _processCommand(Command command) async {
    final handlerType = _handlers[command.runtimeType];
    if (handlerType != null) {
      final handler = container.make(handlerType) as Handler;
      return await handler.handle(command);
    } else {
      throw Exception('No handler found for command: ${command.runtimeType}');
    }
  }

  /// Dispatches a command to a queue for later processing.
  ///
  /// [command] is the command to be queued.
  @override
  Future<dynamic> dispatchToQueue(Command command) async {
    final message = Message(
      payload: command,
      headers: {
        'commandType': command.runtimeType.toString(),
      },
    );
    _queue.sendMessage(
      message: message,
      // You might want to specify an exchange name and routing key if needed
      // exchangeName: 'your_exchange_name',
      // routingKey: 'your_routing_key',
    );
    return message.id;
  }

  /// Dispatches a command synchronously.
  ///
  /// This is an alias for [dispatchNow].
  ///
  /// [command] is the command to be executed.
  /// [handler] is an optional specific handler for the command.
  @override
  Future<dynamic> dispatchSync(Command command, [Handler? handler]) {
    return dispatchNow(command, handler);
  }

  /// Finds a batch by its ID.
  ///
  /// [batchId] is the ID of the batch to find.
  @override
  Future<Batch?> findBatch(String batchId) async {
    // Implement batch finding logic
    throw UnimplementedError();
  }

  /// Creates a new pending batch of commands.
  ///
  /// [commands] is the list of commands to be included in the batch.
  @override
  PendingBatch batch(List<Command> commands) {
    return PendingBatch(this, commands);
  }

  /// Creates a new pending chain of commands.
  ///
  /// [commands] is the list of commands to be included in the chain.
  @override
  PendingChain chain(List<Command> commands) {
    return PendingChain(this, commands);
  }

  /// Applies a list of pipes to the command processing pipeline.
  ///
  /// [pipes] is the list of pipes to be applied.
  @override
  Dispatcher pipeThrough(List<Pipe> pipes) {
    _commandSubject.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          var result = data;
          for (var pipe in pipes) {
            result = pipe(result);
          }
          sink.add(result);
        },
      ),
    );
    return this;
  }

  /// Maps command types to their respective handler types.
  ///
  /// [handlers] is a map where keys are command types and values are handler types.
  @override
  Dispatcher map(Map<Type, Type> handlers) {
    _handlers.addAll(handlers);
    return this;
  }

  /// Dispatches a command to be executed after the current request-response cycle.
  ///
  /// [command] is the command to be dispatched after the response.
  @override
  void dispatchAfterResponse(Command command) {
    final message = Message(
      payload: command,
      headers: {
        'commandType': command.runtimeType.toString(),
        'dispatchAfterResponse': 'true',
      },
    );

    _queue.sendMessage(
      message: message,
      // You might want to specify an exchange name if needed
      // exchangeName: 'your_exchange_name',
      // If you want to use a specific queue for after-response commands:
      routingKey: 'after_response_queue',
    );
  }
}

abstract class QueueingDispatcher {
  Future<dynamic> dispatch(Command command);
  Future<dynamic> dispatchSync(Command command, [Handler? handler]);
  Future<dynamic> dispatchNow(Command command, [Handler? handler]);
  Future<dynamic> dispatchToQueue(Command command);
  Future<Batch?> findBatch(String batchId);
  PendingBatch batch(List<Command> commands);
  PendingChain chain(List<Command> commands);
  Dispatcher pipeThrough(List<Pipe> pipes);
  Dispatcher map(Map<Type, Type> handlers);
  void dispatchAfterResponse(Command command);
}

typedef Pipe = Command Function(Command);

class CommandCompletedEvent extends AppEvent {
  final dynamic result;

  CommandCompletedEvent(this.result);

  @override
  List<Object?> get props => [result];
}

class CommandErrorEvent extends AppEvent {
  final dynamic error;

  CommandErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class CommandEvent extends AppEvent {
  final Command command;
  final dynamic result;
  final dynamic error;

  CommandEvent(this.command, {this.result, this.error});

  @override
  List<Object?> get props => [command, result, error];
}
