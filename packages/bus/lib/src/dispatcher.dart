import 'dart:async';
import 'dart:mirrors';

import 'package:illuminate_collections/collections.dart';
import 'package:illuminate_container/container.dart';
import 'package:illuminate_contracts/contracts.dart' hide Pipeline;
import 'package:illuminate_pipeline/pipeline.dart';

import 'batch.dart';
import 'batch_repository.dart';
import 'pending_batch.dart';
import 'sync_job.dart';

/// A command dispatcher that handles both synchronous and queued command dispatching.
class Dispatcher implements QueueingDispatcher {
  /// The container implementation.
  final Container _container;

  /// The pipeline instance for the bus.
  final Pipeline _pipeline;

  /// The pipes to send commands through before dispatching.
  final List<dynamic> _pipes = [];

  /// The command to handler mapping for non-self-handling events.
  final Map<Type, dynamic> _handlers = {};

  /// The queue resolver callback.
  final FutureOr<Queue> Function(String?)? _queueResolver;

  /// Creates a new command dispatcher instance.
  ///
  /// [container] The container implementation.
  /// [queueResolver] Optional callback to resolve queue instances.
  Dispatcher(this._container, [this._queueResolver])
      : _pipeline = Pipeline(_container);

  @override
  FutureOr<T> dispatch<T>(dynamic command) {
    if (_queueResolver != null && _commandShouldBeQueued(command)) {
      return dispatchToQueue(command) as FutureOr<T>;
    }
    return dispatchNow<T>(command);
  }

  @override
  FutureOr<T> dispatchSync<T>(dynamic command, [dynamic handler]) {
    if (_queueResolver != null &&
        _commandShouldBeQueued(command) &&
        command is QueueableJob) {
      return dispatchToQueue(command.onConnection('sync')) as FutureOr<T>;
    }
    return dispatchNow<T>(command, handler);
  }

  @override
  FutureOr<T> dispatchNow<T>(dynamic command, [dynamic handler]) async {
    if (command is InteractsWithQueue &&
        command is Queueable &&
        command.job == null) {
      command.setJob(SyncJob(_container, command.toString(), 'sync', 'sync'));
    }

    FutureOr<T> Function(dynamic) callback;
    if (handler != null || (handler = getCommandHandler(command)) != null) {
      callback = (dynamic cmd) async {
        final method = _hasMethod(handler, 'handle') ? 'handle' : 'call';
        return await _invokeMethod(handler, method, [cmd]) as T;
      };
    } else {
      callback = (dynamic cmd) async {
        final method = _hasMethod(cmd, 'handle') ? 'handle' : 'call';
        return await _invokeMethod(cmd, method, []) as T;
      };
    }

    return await _pipeline.send(command).through(_pipes).then(callback);
  }

  @override
  Future<BatchContract?> findBatch(String batchId) async {
    return _container.make<BatchRepository>().find(batchId);
  }

  @override
  PendingBatchContract batch(dynamic jobs) {
    return PendingBatch(_container, Collection.wrap(jobs));
  }

  @override
  Future<dynamic> dispatchToQueue(dynamic command) async {
    final connection = command is QueueableJob ? command.connection : null;

    final queue = await _queueResolver!(connection);

    if (queue is! Queue) {
      throw StateError('Queue resolver did not return a Queue implementation.');
    }

    if (_hasMethod(command, 'queue')) {
      return await _invokeMethod(command, 'queue', [queue, command]);
    }

    return _pushCommandToQueue(queue, command);
  }

  @override
  bool hasCommandHandler(dynamic command) {
    return _handlers.containsKey(command.runtimeType);
  }

  @override
  dynamic getCommandHandler(dynamic command) {
    if (hasCommandHandler(command)) {
      return _container.make(_handlers[command.runtimeType]);
    }
    return null;
  }

  @override
  Dispatcher pipeThrough(List<dynamic> pipes) {
    _pipes.addAll(pipes);
    return this;
  }

  @override
  Dispatcher map(Map<Type, dynamic> map) {
    _handlers.addAll(map);
    return this;
  }

  /// Determines if the given command should be queued.
  bool _commandShouldBeQueued(dynamic command) {
    return command is ShouldQueue;
  }

  /// Pushes a command onto the given queue instance.
  Future<dynamic> _pushCommandToQueue(Queue queue, dynamic command) async {
    if (command is QueueableJob) {
      if (command.queue != null && command.delay != null) {
        return queue.laterOn(command.queue!, command.delay!, command);
      }

      if (command.queue != null) {
        return queue.pushOn(command.queue!, command);
      }

      if (command.delay != null) {
        return queue.later(command.delay!, command);
      }
    }

    return queue.push(command);
  }

  /// Checks if an object has a given method.
  bool _hasMethod(dynamic object, String methodName) {
    final mirror = reflect(object);
    return mirror.type.declarations.containsKey(Symbol(methodName));
  }

  /// Invokes a method on an object using reflection.
  Future<dynamic> _invokeMethod(
      dynamic object, String methodName, List<dynamic> args) async {
    final mirror = reflect(object);
    final methodSymbol = Symbol(methodName);

    if (!mirror.type.declarations.containsKey(methodSymbol)) {
      throw StateError('Method $methodName not found on ${object.runtimeType}');
    }

    final result = mirror.invoke(methodSymbol, args);
    return await result.reflectee;
  }
}
