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
      if (_matchesWildcard(eventName, key)) {
        return true;
      }
    }
    return false;
  }

  /// Check if an event name matches a wildcard pattern.
  bool _matchesWildcard(String eventName, String pattern) {
    final regex = pattern.replaceAll('*', '.*');
    return RegExp('^$regex\$').hasMatch(eventName);
  }

  @override
  void push(String event, [List payload = const []]) {
    listen('${event}_pushed', (String event, List data) {
      dispatch(event, payload);
    });
  }

  @override
  void flush(String event) {
    dispatch('${event}_pushed');
  }

  @override
  void subscribe(dynamic subscriber) {
    final events = subscriber.subscribe(this);

    if (events is Map) {
      for (final entry in events.entries) {
        final listeners = entry.value is List ? entry.value : [entry.value];
        for (final listener in listeners) {
          if (listener is String) {
            listen(entry.key, [subscriber.runtimeType, listener]);
          } else {
            listen(entry.key, listener);
          }
        }
      }
    }
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
      return (
        true,
        event is Type ? event.toString() : event.runtimeType.toString(),
        [event]
      );
    }
    return (false, event, payload is List ? payload : [payload]);
  }

  /// Invoke the listeners for the given event.
  List<dynamic>? _invokeListeners(String event, List payload, bool halt) {
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

  /// Get all listeners for a given event name.
  List<Function> _getListeners(String eventName) {
    final listeners = [
      ..._prepareListeners(eventName),
      ...(_wildcardsCache[eventName] ?? _getWildcardListeners(eventName))
    ];

    return listeners;
  }

  /// Get the wildcard listeners for the event.
  List<Function> _getWildcardListeners(String eventName) {
    final wildcards = <Function>[];

    for (final entry in _wildcards.entries) {
      if (_matchesWildcard(eventName, entry.key)) {
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
    if (listener is List && listener[0] is Type) {
      return createClassListener(listener, wildcard);
    }

    if (listener is Function) {
      return (String event, List payload) {
        if (wildcard) {
          return Function.apply(listener, [event, payload]);
        }
        return Function.apply(listener, [event, payload]);
      };
    }

    throw ArgumentError('Invalid listener type: ${listener.runtimeType}');
  }

  /// Create a class based listener using the IoC container.
  Function createClassListener(List<dynamic> listener,
      [bool wildcard = false]) {
    final Type classType = listener[0];
    final String methodName = listener[1];

    return (String event, List payload) {
      final instance = _container.make(classType);
      if (instance == null) {
        throw ArgumentError('Failed to create instance of $classType');
      }

      final method =
          _container.reflector.findInstanceMethod(instance, methodName);
      if (method == null) {
        throw ArgumentError('Method $methodName not found on $classType');
      }

      if (wildcard) {
        return method
            .invoke(Invocation.method(Symbol(methodName), [event, payload]));
      }
      return method.invoke(Invocation.method(Symbol(methodName), payload));
    };
  }

  @override
  void forget(String event) {
    if (event.contains('*')) {
      _wildcards.remove(event);
    } else {
      _listeners.remove(event);
    }

    _wildcardsCache.removeWhere((key, _) => _matchesWildcard(key, event));
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
