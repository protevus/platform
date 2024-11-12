import 'dart:async';
import 'package:platform_container/container.dart';
import 'package:angel3_reactivex/angel3_reactivex.dart';
import 'package:angel3_event_bus/event_bus.dart';
import 'package:angel3_mq/mq.dart';

// Simulating some of the Laravel interfaces/classes
abstract class ShouldBroadcast {}

abstract class ShouldQueue {}

abstract class ShouldBeEncrypted {}

abstract class ShouldDispatchAfterCommit {}

class Dispatcher implements DispatcherContract {
  // Properties as specified in YAML
  final Container container;
  final Map<String, List<Function>> _listeners = {};
  final Map<String, List<Function>> _wildcards = {};
  final Map<String, List<Function>> _wildcardsCache = {};
  late final Function _queueResolver;
  late final Function _transactionManagerResolver;
  final Map<String, List<Function>> _eventBusListeners = {};
  final Map<String, Completer<dynamic>> _untilCompleters = {};
  final Map<String, StreamSubscription> _eventBusSubscriptions = {};
  final Set<String> _processedMessageIds = {};

  // Properties for Angel3 packages
  final EventBus _eventBus;
  late final MQClient? _mqClient;
  final Map<String, BehaviorSubject<dynamic>> _subjects = {};

  // Queue and exchange names
  static const String _eventsQueue = 'events_queue';
  static const String _delayedEventsQueue = 'delayed_events_queue';
  static const String _eventsExchange = 'events_exchange';

  Dispatcher(this.container) : _eventBus = EventBus();

  // Setter for _mqClient
  set mqClient(MQClient client) {
    _mqClient = client;
    _setupQueuesAndExchanges();
    _startProcessingQueuedEvents();
  }

  void _setupQueuesAndExchanges() {
    _mqClient?.declareQueue(_eventsQueue);
    _mqClient?.declareQueue(_delayedEventsQueue);
    _mqClient?.declareExchange(
      exchangeName: _eventsExchange,
      exchangeType: ExchangeType.direct,
    );
    _mqClient?.bindQueue(
      queueId: _eventsQueue,
      exchangeName: _eventsExchange,
      bindingKey: _eventsQueue,
    );
    _mqClient?.bindQueue(
      queueId: _delayedEventsQueue,
      exchangeName: _eventsExchange,
      bindingKey: _delayedEventsQueue,
    );
  }

  void _startProcessingQueuedEvents() {
    _mqClient?.fetchQueue(_eventsQueue).listen((Message message) async {
      if (message.payload is Map) {
        final eventData = message.payload as Map<String, dynamic>;
        if (eventData.containsKey('event') &&
            eventData.containsKey('payload')) {
          await dispatch(eventData['event'], eventData['payload']);
        } else {
          print('Invalid message format: ${message.payload}');
        }
      } else {
        print('Unexpected payload type: ${message.payload.runtimeType}');
      }
    });
  }

  @override
  void listen(dynamic events, dynamic listener) {
    if (events is String) {
      _addListener(events, listener);
    } else if (events is List) {
      for (var event in events) {
        _addListener(event, listener);
      }
    }
    if (events is String && events.contains('*')) {
      _setupWildcardListen(events, listener);
    }
  }

  void _addListener(String event, dynamic listener) {
    _listeners.putIfAbsent(event, () => []).add(listener);

    // Create a subject for this event if it doesn't exist
    _subjects.putIfAbsent(event, () => BehaviorSubject<dynamic>());

    // Add EventBus listener and store the subscription
    final subscription = _eventBus.on().listen((AppEvent busEvent) {
      if (busEvent is CustomAppEvent && busEvent.eventName == event) {
        listener(event, busEvent.payload);
      }
    });
    _eventBusSubscriptions[event] = subscription;
  }

  void _setupWildcardListen(String event, Function listener) {
    _wildcards.putIfAbsent(event, () => []).add(listener);
    _wildcardsCache.clear();
  }

  @override
  bool hasListeners(String eventName) {
    return _listeners.containsKey(eventName) ||
        _wildcards.containsKey(eventName) ||
        hasWildcardListeners(eventName);
  }

  bool hasWildcardListeners(String eventName) {
    return _wildcards.keys
        .any((pattern) => _isWildcardMatch(pattern, eventName));
  }

  @override
  void push(String event, [dynamic payload]) {
    final effectivePayload = payload ?? [];
    _mqClient?.sendMessage(
      exchangeName: _eventsExchange,
      routingKey: _delayedEventsQueue,
      message: Message(
        headers: {'expiration': '5000'}, // 5 seconds delay
        payload: {
          'event': event,
          'payload':
              effectivePayload is List ? effectivePayload : [effectivePayload],
        },
        timestamp: DateTime.now().toIso8601String(),
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}', // Ensure unique ID
      ),
    );
  }

  @override
  Future<void> flush(String event) async {
    final messageStream = _mqClient?.fetchQueue(_delayedEventsQueue);
    if (messageStream == null) {
      print('Warning: MQClient is not initialized');
      return;
    }

    final messagesToProcess = <Message>[];

    // Collect messages to process
    await for (final message in messageStream) {
      print('Examining message: ${message.id}');
      if (message.payload is Map<String, dynamic> &&
          !_processedMessageIds.contains(message.id)) {
        final eventData = message.payload as Map<String, dynamic>;
        if (eventData['event'] == event) {
          print('Adding message to process: ${message.id}');
          messagesToProcess.add(message);
        }
      }
    }

    print('Total messages to process: ${messagesToProcess.length}');

    // Process collected messages
    for (final message in messagesToProcess) {
      final eventData = message.payload as Map<String, dynamic>;
      print('Processing message: ${message.id}');
      await dispatch(eventData['event'], eventData['payload']);
      _mqClient?.deleteMessage(_delayedEventsQueue, message);
      _processedMessageIds.add(message.id);
    }
  }

  @override
  void subscribe(dynamic subscriber) {
    if (subscriber is EventBusSubscriber) {
      subscriber.subscribe(_eventBus);
    } else {
      // Handle other types of subscribers
    }
  }

  @override
  Future<dynamic> until(dynamic event, [dynamic payload]) {
    if (event is String) {
      final completer = Completer<dynamic>();
      _untilCompleters[event] = completer;

      // Set up a one-time listener for this event
      listen(event, (dynamic e, dynamic p) {
        if (!completer.isCompleted) {
          completer.complete(p);
          _untilCompleters.remove(event);
        }
      });

      // If payload is provided, dispatch the event immediately
      if (payload != null) {
        // Use dispatch instead of push to ensure immediate processing
        dispatch(event, payload);
      }

      return completer.future;
    }
    throw ArgumentError('Event must be a String');
  }

  @override
  Future<dynamic> dispatch(dynamic event, [dynamic payload, bool? halt]) async {
    final eventName = event is String ? event : event.runtimeType.toString();
    final eventPayload = payload ?? (event is AppEvent ? event : []);

    if (event is ShouldBroadcast ||
        (eventPayload is List &&
            eventPayload.isNotEmpty &&
            eventPayload[0] is ShouldBroadcast)) {
      await _broadcastEvent(event);
    }

    if (event is ShouldQueue ||
        (eventPayload is List &&
            eventPayload.isNotEmpty &&
            eventPayload[0] is ShouldQueue)) {
      return _queueEvent(eventName, eventPayload);
    }

    final listeners = getListeners(eventName);
    for (var listener in listeners) {
      final response =
          await Function.apply(listener, [eventName, eventPayload]);
      if (halt == true && response != null) {
        return response;
      }
      if (response == false) {
        break;
      }
    }

    return halt == true ? null : listeners;
  }

  // void _addToSubject(String eventName, dynamic payload) {
  //   if (_subjects.containsKey(eventName)) {
  //     _subjects[eventName]!.add(payload);
  //   }
  // }

  @override
  List<Function> getListeners(String eventName) {
    var listeners = <Function>[
      ...(_listeners[eventName] ?? []),
      ...(_wildcardsCache[eventName] ?? _getWildcardListeners(eventName)),
      ...(_eventBusListeners[eventName] ?? []),
    ];

    return listeners;
  }

  List<Function> _getWildcardListeners(String eventName) {
    final wildcardListeners = <Function>[];
    for (var entry in _wildcards.entries) {
      if (_isWildcardMatch(entry.key, eventName)) {
        wildcardListeners.addAll(entry.value);
      }
    }
    _wildcardsCache[eventName] = wildcardListeners;
    return wildcardListeners;
  }

  @override
  void forget(String event) {
    // Remove from _listeners
    _listeners.remove(event);

    // Remove from _subjects
    if (_subjects.containsKey(event)) {
      _subjects[event]?.close();
      _subjects.remove(event);
    }

    // Cancel and remove EventBus subscription
    _eventBusSubscriptions[event]?.cancel();
    _eventBusSubscriptions.remove(event);

    // Remove from wildcards if applicable
    if (event.contains('*')) {
      _wildcards.remove(event);
      _wildcardsCache.clear();
    } else {
      // If it's not a wildcard, we need to remove it from any matching wildcard listeners
      _wildcards.forEach((pattern, listeners) {
        if (_isWildcardMatch(pattern, event)) {
          _wildcards[pattern] = listeners
              .where((listener) => listener != _listeners[event])
              .toList();
        }
      });
      _wildcardsCache.clear();
    }

    // Remove any 'until' completers for this event
    _untilCompleters.remove(event);
  }

  @override
  void forgetPushed() {
    _listeners.removeWhere((key, _) => key.endsWith('_pushed'));
    _eventBusListeners.removeWhere((key, _) => key.endsWith('_pushed'));
    // Note: We're not clearing all EventBus listeners here, as that might affect other parts of your application
  }

  @override
  void setQueueResolver(Function resolver) {
    _queueResolver = resolver;
  }

  @override
  void setTransactionManagerResolver(Function resolver) {
    _transactionManagerResolver = resolver;
  }

  // Add these methods for testing purposes
  void triggerQueueResolver() {
    _queueResolver();
  }

  void triggerTransactionManagerResolver() {
    _transactionManagerResolver();
  }

  @override
  Map<String, List<Function>> getRawListeners() {
    return Map.unmodifiable(_listeners);
  }

  bool _shouldBroadcast(List payload) {
    return payload.isNotEmpty && payload[0] is ShouldBroadcast;
  }

  Future<void> _broadcastEvent(dynamic event) async {
    // Implement broadcasting logic here
    // For now, we'll just print a message
    print('Broadcasting event: ${event.runtimeType}');
  }

  bool _isWildcardMatch(String pattern, String eventName) {
    final regExp = RegExp('^${pattern.replaceAll('*', '.*')}\$');
    return regExp.hasMatch(eventName);
  }

  bool _shouldQueue(List payload) {
    return payload.isNotEmpty && payload[0] is ShouldQueue;
  }

  Future<void> _queueEvent(String eventName, dynamic payload) async {
    _mqClient?.sendMessage(
      exchangeName: _eventsExchange,
      routingKey: _eventsQueue,
      message: Message(
        payload: {'event': eventName, 'payload': payload},
        timestamp: DateTime.now().toIso8601String(),
      ),
    );
  }

  // Updated on<T> method
  Stream<T> on<T>(String event) {
    return (_subjects
            .putIfAbsent(event, () => BehaviorSubject<dynamic>())
            .stream as Stream<T>)
        .where((event) => event is T)
        .cast<T>();
  }

  // In your Dispatcher class
  void setMQClient(MQClient client) {
    _mqClient = client;
  }

  // Method to close the MQClient connection
  Future<void> close() async {
    _mqClient?.close();
  }

  // Don't forget to close the subjects when they're no longer needed
  void dispose() {
    for (var subject in _subjects.values) {
      subject.close();
    }
  }
}
// ... rest of the code (DispatcherContract, EventBusSubscriber, etc.) remains the same

abstract class DispatcherContract {
  void listen(dynamic events, dynamic listener);
  bool hasListeners(String eventName);
  void push(String event, [dynamic payload]);
  Future<void> flush(String event);
  void subscribe(dynamic subscriber);
  Future<dynamic> until(dynamic event, [dynamic payload]);
  Future<dynamic> dispatch(dynamic event, [dynamic payload, bool halt]);
  List<Function> getListeners(String eventName);
  void forget(String event);
  void forgetPushed();
  void setQueueResolver(Function resolver);
  void setTransactionManagerResolver(Function resolver);
  Map<String, List<Function>> getRawListeners();
}

// Helper class for EventBus subscribers
abstract class EventBusSubscriber {
  void subscribe(EventBus eventBus);
}

// Mixin to simulate Macroable trait
mixin Macroable {
  // Implementation of Macroable functionality
}

// Mixin to simulate ReflectsClosures trait
mixin ReflectsClosures {
  // Implementation of ReflectsClosures functionality
}

// If not already defined, you might need to create an Event class
class Event {
  final String name;
  final dynamic data;

  Event(this.name, this.data);
}

// Custom AppEvent subclasses for handling different event types
class StringBasedEvent extends AppEvent {
  final String eventName;
  final dynamic payload;

  StringBasedEvent(this.eventName, this.payload);

  @override
  List<Object?> get props => [eventName, payload];
}

class CustomAppEvent extends AppEvent {
  final String eventName;
  final dynamic payload;

  CustomAppEvent(this.eventName, this.payload);

  @override
  List<Object?> get props => [eventName, payload];
}

// This is a simple implementation of Reflector that does nothing
class EmptyReflector implements Reflector {
  const EmptyReflector();

  @override
  ReflectedType reflectType(Type type) {
    throw UnimplementedError();
  }

  @override
  ReflectedInstance reflectInstance(Object object) {
    throw UnimplementedError();
  }

  @override
  ReflectedType reflectFutureOf(Type type) {
    throw UnimplementedError();
  }

  @override
  String? getName(Symbol symbol) {
    // TODO: implement getName
    throw UnimplementedError();
  }

  @override
  ReflectedClass? reflectClass(Type clazz) {
    // TODO: implement reflectClass
    throw UnimplementedError();
  }

  @override
  ReflectedFunction? reflectFunction(Function function) {
    // TODO: implement reflectFunction
    throw UnimplementedError();
  }
}
