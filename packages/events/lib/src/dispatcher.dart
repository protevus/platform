import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_macroable/platform_macroable.dart';
import 'package:platform_support/platform_support.dart';

import 'queued_listener.dart';
import 'reflection/reflection.dart';

/// The event dispatcher implementation.
class EventDispatcher with Macroable implements EventDispatcherContract {
  /// The IoC container instance.
  final Container _container;

  /// The registered event listeners.
  final Map<String, List<dynamic>> _listeners = {};

  /// The wildcard listeners.
  final Map<String, List<dynamic>> _wildcards = {};

  /// The cached wildcard listeners.
  final Map<String, List<Function>> _wildcardsCache = {};

  /// The queue resolver instance.
  Function? _queueResolver;

  /// The database transaction manager resolver instance.
  Function? _transactionManagerResolver;

  /// Create a new event dispatcher instance.
  EventDispatcher([Container? container])
      : _container = container ?? Container(MirrorsReflector());

  @override
  void listen(dynamic events, [dynamic listener]) {
    if (events is Function) {
      final types = ContainerReflection.getParameterTypes(_container, events);
      for (final type in types) {
        listen(type, events);
      }
      return;
    }

    // Convert single event to list for consistent handling
    final eventList = events is List ? events : [events];

    for (final event in eventList) {
      if (event.toString().contains('*')) {
        _setupWildcardListen(event.toString(), listener);
      } else {
        final eventName = event is Type
            ? event.toString()
            : event is String
                ? event
                : event.runtimeType.toString();
        _listeners[eventName] = [...(_listeners[eventName] ?? []), listener];
      }
    }
  }

  /// Setup a wildcard listener callback.
  void _setupWildcardListen(String event, dynamic listener) {
    _wildcards[event] = [...(_wildcards[event] ?? []), listener];
    _wildcardsCache.clear(); // Reset cache when adding new wildcards
  }

  @override
  bool hasListeners(String eventName) {
    return _listeners.containsKey(eventName) ||
        _wildcards.containsKey(eventName) ||
        _hasWildcardListeners(eventName);
  }

  /// Determine if the given event has any wildcard listeners.
  bool _hasWildcardListeners(String eventName) {
    for (final key in _wildcards.keys) {
      if (Str.contains(key, eventName)) {
        return true;
      }
    }
    return false;
  }

  @override
  void push(String event, [List payload = const []]) {
    listen('${event}_pushed', () {
      dispatch(event, payload);
    });
  }

  @override
  void flush(String event) {
    dispatch('${event}_pushed');
  }

  @override
  void subscribe(dynamic subscriber) {
    final resolvedSubscriber = _resolveSubscriber(subscriber);
    final events = resolvedSubscriber.subscribe(this);

    if (events is Map) {
      for (final entry in events.entries) {
        final listeners = entry.value is List ? entry.value : [entry.value];
        for (final listener in listeners) {
          if (listener is String) {
            final reflection =
                ContainerReflection.forInstance(_container, resolvedSubscriber);
            if (reflection?.declarations.any((d) => d.name == listener) ??
                false) {
              listen(entry.key, [resolvedSubscriber.runtimeType, listener]);
              continue;
            }
          }
          listen(entry.key, listener);
        }
      }
    }
  }

  /// Resolve the subscriber instance.
  dynamic _resolveSubscriber(dynamic subscriber) {
    if (subscriber is String) {
      final type = _container.reflector.findTypeByName(subscriber);
      if (type == null) {
        throw ArgumentError('Class not found: $subscriber');
      }
      return _container.make(type);
    }
    return subscriber;
  }

  @override
  dynamic until(dynamic event, [dynamic payload = const []]) {
    return dispatch(event, payload, true);
  }

  @override
  List<dynamic>? dispatch(dynamic event,
      [dynamic payload = const [], bool halt = false]) {
    final eventDetails = _parseEventAndPayload(event, payload);
    final isEventObject = eventDetails.$1;
    final String eventName = eventDetails.$2;
    final List eventPayload = eventDetails.$3;

    // Handle events that should dispatch after commit
    if (isEventObject &&
        eventPayload[0] is ShouldDispatchAfterCommit &&
        _resolveTransactionManager() != null) {
      _resolveTransactionManager()
          ?.addCallback(() => _invokeListeners(eventName, eventPayload, halt));
      return null;
    }

    final result = _invokeListeners(eventName, eventPayload, halt);
    if (result is Future) {
      // If the result is a Future, we can't wait for it in a sync method
      // This matches Laravel's behavior where async listeners are queued
      return null;
    }
    return result;
  }

  /// Parse the given event and payload and prepare them for dispatching.
  (bool, String, List) _parseEventAndPayload(dynamic event, dynamic payload) {
    if (event is! String) {
      final reflection = ContainerReflection.forInstance(_container, event);
      return (
        true,
        reflection?.typeName ?? event.runtimeType.toString(),
        [event]
      );
    }
    return (false, event, payload is List ? payload : [payload]);
  }

  /// Invoke the listeners for the given event.
  List<dynamic>? _invokeListeners(String event, List payload, bool halt) {
    // Handle broadcasting if needed
    if (_shouldBroadcast(payload)) {
      _broadcastEvent(payload[0] as ShouldBroadcast);
    }

    final responses = <dynamic>[];

    for (final listener in _getListeners(event)) {
      final response = Function.apply(listener, [event, payload]);

      if (halt && response != null) {
        return null;
      }

      if (response == false) {
        break;
      }

      if (response != null) {
        responses.add(response);
      }
    }

    return halt ? null : responses;
  }

  /// Determine if the payload has a broadcastable event.
  bool _shouldBroadcast(List payload) {
    return payload.isNotEmpty &&
        payload[0] is ShouldBroadcast &&
        _broadcastWhen(payload[0]);
  }

  /// Check if event should be broadcasted by condition.
  bool _broadcastWhen(dynamic event) {
    final reflection = ContainerReflection.forInstance(_container, event);
    return reflection?.invoke('broadcastWhen', []) as bool? ?? true;
  }

  /// Broadcast the given event.
  Future<void> _broadcastEvent(ShouldBroadcast event) async {
    final factory = _container.make<BroadcastFactory>();
    if (factory == null) return;

    final broadcaster = await factory.connection();
    final reflection = ContainerReflection.forInstance(_container, event);
    if (reflection == null) return;

    final channels =
        reflection.getFieldValue('broadcastOn') as List<String>? ?? [];
    final eventName = reflection.getFieldValue('broadcastAs') as String? ??
        reflection.typeName;
    final payload =
        reflection.getFieldValue('broadcastWith') as Map<String, dynamic>? ??
            {};

    await broadcaster.broadcast(channels, eventName, payload);
  }

  /// Get all listeners for a given event name.
  List<Function> _getListeners(String eventName) {
    final listeners = [
      ..._prepareListeners(eventName),
      ...(_wildcardsCache[eventName] ?? _getWildcardListeners(eventName))
    ];

    // Add interface listeners if class exists
    final type = _container.reflector.findTypeByName(eventName);
    if (type != null) {
      final reflection = ContainerReflection.forClass(_container, type);
      if (reflection != null) {
        return _addInterfaceListeners(reflection, listeners);
      }
    }

    return listeners;
  }

  /// Add interface listeners to the given array.
  List<Function> _addInterfaceListeners(
      ContainerReflection reflection, List<Function> listeners) {
    for (final declaration in reflection.declarations) {
      if (_listeners.containsKey(declaration.name)) {
        listeners.addAll(_prepareListeners(declaration.name));
      }
    }

    return listeners;
  }

  /// Get the wildcard listeners for the event.
  List<Function> _getWildcardListeners(String eventName) {
    final wildcards = <Function>[];

    for (final entry in _wildcards.entries) {
      if (Str.contains(entry.key, eventName)) {
        for (final listener in entry.value) {
          wildcards.add(makeListener(listener, true));
        }
      }
    }

    _wildcardsCache[eventName] = wildcards;
    return wildcards;
  }

  /// Prepare the listeners for a given event.
  List<Function> _prepareListeners(String eventName) {
    final listeners = <Function>[];

    for (final listener in _listeners[eventName] ?? []) {
      listeners.add(makeListener(listener));
    }

    return listeners;
  }

  /// Register an event listener with the dispatcher.
  Function makeListener(dynamic listener, [bool wildcard = false]) {
    if (listener is String) {
      return createClassListener(listener, wildcard);
    }

    if (listener is List && listener[0] is String) {
      return createClassListener(listener, wildcard);
    }

    return (String event, List payload) {
      if (wildcard) {
        return Function.apply(listener as Function, [event, payload]);
      }
      return Function.apply(listener as Function, payload);
    };
  }

  /// Create a class based listener using the IoC container.
  Function createClassListener(dynamic listener, [bool wildcard = false]) {
    return (String event, List payload) {
      if (wildcard) {
        return Function.apply(_createClassCallable(listener), [event, payload]);
      }

      final callable = _createClassCallable(listener);
      return Function.apply(callable, payload);
    };
  }

  /// Create the class based event callable.
  Function _createClassCallable(dynamic listener) {
    final classMethod = _parseClassCallable(listener);
    final String className = classMethod.$1;
    var methodName = classMethod.$2;

    final type = _container.reflector.findTypeByName(className);
    if (type == null) {
      throw ArgumentError('Class not found: $className');
    }

    final classType = type is Type ? type : type.runtimeType;
    final reflection = ContainerReflection.forClass(_container, classType);
    if (reflection == null) {
      throw ArgumentError('Failed to reflect class: $className');
    }

    if (!reflection.declarations.any((d) => d.name == methodName)) {
      methodName = 'call';
    }

    if (_handlerShouldBeQueued(reflection)) {
      return _createQueuedHandlerCallable(className, methodName);
    }

    final instance = _container.make(type);
    final instanceReflection =
        ContainerReflection.forInstance(_container, instance);
    if (instanceReflection == null) {
      throw ArgumentError('Failed to create instance of $className');
    }

    if (_handlerShouldBeDispatchedAfterDatabaseTransactions(instance)) {
      return _createCallbackForListenerRunningAfterCommits(
          instance, methodName);
    }

    return (args) => instanceReflection.invoke(methodName, args);
  }

  /// Parse the class listener into class and method.
  (String, String) _parseClassCallable(dynamic listener) {
    if (listener is List) {
      return (listener[0], listener[1]);
    }
    final parts = Str.parseCallback(listener, 'handle');
    if (parts == null) {
      throw ArgumentError('Invalid listener format: $listener');
    }
    return (parts[0], parts[1]);
  }

  /// Determine if the event handler class should be queued.
  bool _handlerShouldBeQueued(ContainerReflection reflection) {
    try {
      return reflection.isAssignableTo(ShouldQueue);
    } catch (_) {
      return false;
    }
  }

  /// Create a callable for putting an event handler on the queue.
  Function _createQueuedHandlerCallable(String className, String method) {
    return (List args) {
      final arguments = args.map((a) {
        if (a is Object) {
          final reflection = ContainerReflection.forInstance(_container, a);
          return reflection?.clone() ?? a;
        }
        return a;
      }).toList();

      if (_handlerWantsToBeQueued(className, arguments)) {
        _queueHandler(className, method, arguments);
      }
    };
  }

  /// Determine if handler should be dispatched after database transactions.
  bool _handlerShouldBeDispatchedAfterDatabaseTransactions(dynamic listener) {
    final reflection = ContainerReflection.forInstance(_container, listener);
    return ((reflection?.getFieldValue('afterCommit') as bool?) ??
            false || listener is ShouldHandleEventsAfterCommit) &&
        _resolveTransactionManager() != null;
  }

  /// Create callback for dispatching listener after database transactions.
  Function _createCallbackForListenerRunningAfterCommits(
      dynamic listener, String method) {
    return (List args) {
      _resolveTransactionManager()?.addCallback(() {
        final reflection =
            ContainerReflection.forInstance(_container, listener);
        return reflection?.invoke(method, args);
      });
    };
  }

  /// Determine if the event handler wants to be queued.
  bool _handlerWantsToBeQueued(String className, List arguments) {
    final type = _container.reflector.findTypeByName(className);
    if (type == null) return true;

    final instance = _container.make(type);
    final reflection = ContainerReflection.forInstance(_container, instance);

    if (reflection?.declarations.any((d) => d.name == 'shouldQueue') ?? false) {
      return reflection?.invoke('shouldQueue', [arguments[0]]) as bool? ?? true;
    }

    return true;
  }

  /// Queue the handler class.
  void _queueHandler(String className, String method, List arguments) {
    final listenerAndJob = _createListenerAndJob(className, method, arguments);
    final listener = listenerAndJob.$1;
    final job = listenerAndJob.$2;

    final listenerReflection =
        ContainerReflection.forInstance(_container, listener);
    if (listenerReflection == null) return;

    final connection = _resolveQueue()?.connection(
        listenerReflection.declarations.any((d) => d.name == 'viaConnection')
            ? (arguments.isNotEmpty
                ? listenerReflection.invoke('viaConnection', [arguments[0]])
                : listenerReflection.invoke('viaConnection', []))
            : listenerReflection.getFieldValue('connection'));

    final queue =
        listenerReflection.declarations.any((d) => d.name == 'viaQueue')
            ? (arguments.isNotEmpty
                ? listenerReflection.invoke('viaQueue', [arguments[0]])
                : listenerReflection.invoke('viaQueue', []))
            : listenerReflection.getFieldValue('queue');

    final delay =
        listenerReflection.declarations.any((d) => d.name == 'withDelay')
            ? (arguments.isNotEmpty
                ? listenerReflection.invoke('withDelay', [arguments[0]])
                : listenerReflection.invoke('withDelay', []))
            : listenerReflection.getFieldValue('delay');

    delay == null
        ? connection?.pushOn(queue, job)
        : connection?.laterOn(queue, delay, job);
  }

  /// Create the listener and job for a queued listener.
  (dynamic, dynamic) _createListenerAndJob(
      String className, String method, List arguments) {
    final instance = ContainerReflection.createInstance(_container, className);
    if (instance == null) {
      throw ArgumentError('Failed to create instance of $className');
    }

    return (
      instance,
      _propagateListenerOptions(
          instance, CallQueuedListener(className, method, arguments))
    );
  }

  /// Propagate listener options to the job.
  T _propagateListenerOptions<T extends Object>(dynamic listener, T job) {
    final jobReflection = ContainerReflection.forInstance(_container, job);
    final listenerReflection =
        ContainerReflection.forInstance(_container, listener);
    if (jobReflection == null || listenerReflection == null) return job;

    final data = jobReflection.getFieldValue('data') as List? ?? [];

    if (listener is ShouldQueueAfterCommit) {
      jobReflection.setFieldValue('afterCommit', true);
    } else {
      jobReflection.setFieldValue(
          'afterCommit',
          listenerReflection.hasField('afterCommit')
              ? listenerReflection.getFieldValue('afterCommit')
              : null);
    }

    if (listenerReflection.declarations.any((d) => d.name == 'backoff')) {
      jobReflection.setFieldValue(
          'backoff', listenerReflection.invoke('backoff', data));
    } else {
      jobReflection.setFieldValue(
          'backoff', listenerReflection.getFieldValue('backoff'));
    }

    jobReflection.setFieldValue(
        'maxExceptions', listenerReflection.getFieldValue('maxExceptions'));

    if (listenerReflection.declarations.any((d) => d.name == 'retryUntil')) {
      jobReflection.setFieldValue(
          'retryUntil', listenerReflection.invoke('retryUntil', data));
    }

    jobReflection.setFieldValue(
        'shouldBeEncrypted', listener is ShouldBeEncrypted);

    jobReflection.setFieldValue(
        'timeout', listenerReflection.getFieldValue('timeout'));

    jobReflection.setFieldValue('failOnTimeout',
        listenerReflection.getFieldValue('failOnTimeout') ?? false);

    jobReflection.setFieldValue(
        'tries', listenerReflection.getFieldValue('tries'));

    final middleware = [
      if (listenerReflection.declarations.any((d) => d.name == 'middleware'))
        ...?listenerReflection.invoke('middleware', data) as List?,
      ...?listenerReflection.getFieldValue('middleware') as List?
    ];

    jobReflection.invoke('through', [middleware]);

    return job;
  }

  @override
  void forget(String event) {
    if (event.contains('*')) {
      _wildcards.remove(event);
    } else {
      _listeners.remove(event);
    }

    _wildcardsCache.removeWhere((key, _) => Str.contains(event, key));
  }

  @override
  void forgetPushed() {
    final pushedEvents =
        _listeners.keys.where((key) => key.endsWith('_pushed')).toList();

    for (final event in pushedEvents) {
      forget(event);
    }
  }

  /// Get the queue implementation from the resolver.
  dynamic _resolveQueue() {
    return _queueResolver?.call();
  }

  /// Set the queue resolver implementation.
  EventDispatcher setQueueResolver(Function resolver) {
    _queueResolver = resolver;
    return this;
  }

  /// Get the database transaction manager implementation from the resolver.
  dynamic _resolveTransactionManager() {
    return _transactionManagerResolver?.call();
  }

  /// Set the database transaction manager resolver implementation.
  EventDispatcher setTransactionManagerResolver(Function resolver) {
    _transactionManagerResolver = resolver;
    return this;
  }

  /// Gets the raw, unprepared listeners.
  Map<String, List<dynamic>> getRawListeners() {
    return Map.unmodifiable(_listeners);
  }
}
