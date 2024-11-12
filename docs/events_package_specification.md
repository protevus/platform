# Events Package Specification

## Overview

The Events package provides a robust event system that matches Laravel's event functionality while leveraging Dart's async capabilities. It integrates with our Queue, Bus, and Database packages to provide a complete event handling solution.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Contracts Package Specification](contracts_package_specification.md) for event contracts

## Core Features

### 1. Event Dispatcher

```dart
/// Core event dispatcher implementation
class EventDispatcher implements EventDispatcherContract {
  final Container _container;
  final Map<Type, List<EventListener>> _listeners = {};
  final List<EventSubscriber> _subscribers = {};
  final QueueContract? _queue;
  final BroadcasterContract? _broadcaster;
  final List<dynamic> _afterCommitEvents = [];
  
  EventDispatcher(
    this._container, {
    QueueContract? queue,
    BroadcasterContract? broadcaster
  }) : _queue = queue,
       _broadcaster = broadcaster;
  
  @override
  void listen<T>(void Function(T event) listener) {
    _listeners.putIfAbsent(T, () => []).add(
      EventListener<T>(listener)
    );
  }
  
  @override
  Future<void> dispatch<T>(T event) async {
    var listeners = _listeners[T] ?? [];
    
    // Handle after commit events
    if (event is ShouldDispatchAfterCommit && _isWithinTransaction()) {
      _afterCommitEvents.add(event);
      return;
    }
    
    // Handle queued events
    if (event is ShouldQueue && _queue != null) {
      await _queueEvent(event, listeners);
      return;
    }
    
    // Handle broadcasting
    if (event is ShouldBroadcast && _broadcaster != null) {
      await _broadcastEvent(event);
    }
    
    // Notify listeners
    await _notifyListeners(event, listeners);
  }
  
  @override
  Future<void> dispatchAfterCommit<T>(T event) async {
    if (_isWithinTransaction()) {
      _afterCommitEvents.add(event);
    } else {
      await dispatch(event);
    }
  }
  
  bool _isWithinTransaction() {
    if (_container.has<DatabaseManager>()) {
      var db = _container.make<DatabaseManager>();
      return db.transactionLevel > 0;
    }
    return false;
  }
  
  Future<void> _dispatchAfterCommitEvents() async {
    var events = List.from(_afterCommitEvents);
    _afterCommitEvents.clear();
    
    for (var event in events) {
      await dispatch(event);
    }
  }
}
```

### 2. Event Discovery

```dart
/// Discovers event handlers through reflection and attributes
class EventDiscovery {
  final Container _container;
  final Reflector _reflector;
  
  EventDiscovery(this._container, this._reflector);
  
  /// Discovers event handlers in a directory
  Future<void> discoverEvents(String path) async {
    var files = Directory(path).listSync(recursive: true);
    
    for (var file in files) {
      if (file.path.endsWith('.dart')) {
        await _processFile(file.path);
      }
    }
  }
  
  Future<void> _processFile(String path) async {
    var library = await _reflector.loadLibrary(path);
    
    for (var type in library.declarations.values) {
      if (type is ClassMirror) {
        _processClass(type);
      }
    }
  }
  
  void _processClass(ClassMirror classMirror) {
    // Find @Handles annotations
    for (var method in classMirror.declarations.values) {
      if (method is MethodMirror) {
        var handles = method.metadata
          .firstWhere((m) => m.type == Handles,
            orElse: () => null);
            
        if (handles != null) {
          var eventType = handles.getField('event').reflectee;
          _registerHandler(classMirror.reflectedType, method.simpleName, eventType);
        }
      }
    }
  }
  
  void _registerHandler(Type classType, Symbol methodName, Type eventType) {
    var instance = _container.make(classType);
    var dispatcher = _container.make<EventDispatcherContract>();
    
    dispatcher.listen(eventType, (event) {
      var mirror = reflect(instance);
      mirror.invoke(methodName, [event]);
    });
  }
}
```

### 3. Event Broadcasting

```dart
/// Contract for event broadcasters
abstract class BroadcasterContract {
  /// Broadcasts an event
  Future<void> broadcast(
    List<String> channels,
    String eventName,
    dynamic data
  );
  
  /// Creates a private channel
  Channel privateChannel(String name);
  
  /// Creates a presence channel
  PresenceChannel presenceChannel(String name);
}

/// Pusher event broadcaster
class PusherBroadcaster implements BroadcasterContract {
  final PusherClient _client;
  final AuthManager _auth;
  
  PusherBroadcaster(this._client, this._auth);
  
  @override
  Future<void> broadcast(
    List<String> channels,
    String eventName,
    dynamic data
  ) async {
    for (var channel in channels) {
      await _client.trigger(channel, eventName, data);
    }
  }
  
  @override
  Channel privateChannel(String name) {
    return PrivateChannel(_client, _auth, name);
  }
  
  @override
  PresenceChannel presenceChannel(String name) {
    return PresenceChannel(_client, _auth, name);
  }
}
```

### 4. Integration with Queue

```dart
/// Job for processing queued events
class QueuedEventJob implements Job {
  final dynamic event;
  final List<EventListener> listeners;
  final Map<String, dynamic> data;
  
  QueuedEventJob({
    required this.event,
    required this.listeners,
    this.data = const {}
  });
  
  @override
  Future<void> handle() async {
    for (var listener in listeners) {
      try {
        await listener.handle(event);
      } catch (e) {
        await _handleFailure(e);
      }
    }
  }
  
  @override
  Future<void> failed([Exception? e]) async {
    if (event is FailedEventHandler) {
      await (event as FailedEventHandler).failed(e);
    }
  }
  
  @override
  int get tries => event is HasTries ? (event as HasTries).tries : 1;
  
  @override
  Duration? get timeout => 
    event is HasTimeout ? (event as HasTimeout).timeout : null;
}
```

### 5. Integration with Bus

```dart
/// Event command for command bus integration
class EventCommand implements Command {
  final dynamic event;
  final List<EventListener> listeners;
  
  EventCommand(this.event, this.listeners);
  
  @override
  Type get handler => EventCommandHandler;
}

/// Handler for event commands
class EventCommandHandler implements Handler<EventCommand> {
  final EventDispatcher _events;
  
  EventCommandHandler(this._events);
  
  @override
  Future<void> handle(EventCommand command) async {
    await _events._notifyListeners(
      command.event,
      command.listeners
    );
  }
}
```

## Usage Examples

### Basic Event Handling
```dart
// Define event
class OrderShipped {
  final Order order;
  OrderShipped(this.order);
}

// Create listener
@Handles(OrderShipped)
class OrderShippedListener {
  void handle(OrderShipped event) {
    // Handle event
  }
}

// Register and dispatch
dispatcher.listen<OrderShipped>((event) {
  // Handle event
});

await dispatcher.dispatch(OrderShipped(order));
```

### After Commit Events
```dart
class OrderCreated implements ShouldDispatchAfterCommit {
  final Order order;
  OrderCreated(this.order);
}

// In transaction
await db.transaction((tx) async {
  var order = await tx.create(orderData);
  await dispatcher.dispatchAfterCommit(OrderCreated(order));
});
```

### Broadcasting
```dart
class MessageSent implements ShouldBroadcast {
  final Message message;
  
  @override
  List<String> broadcastOn() => [
    'private-chat.${message.roomId}'
  ];
  
  @override
  Map<String, dynamic> get broadcastWith => {
    'id': message.id,
    'content': message.content,
    'user': message.user.toJson()
  };
}

// Create private channel
var channel = broadcaster.privateChannel('chat.123');
await channel.whisper('typing', {'user': 'john'});
```

### Queue Integration
```dart
class ProcessOrder implements ShouldQueue {
  final Order order;
  
  @override
  String get queue => 'orders';
  
  @override
  int get tries => 3;
  
  @override
  Duration get timeout => Duration(minutes: 5);
}

// Dispatch queued event
await dispatcher.dispatch(ProcessOrder(order));
```

## Testing

```dart
void main() {
  group('Event Dispatcher', () {
    test('dispatches after commit', () async {
      var dispatcher = MockEventDispatcher();
      var db = MockDatabase();
      
      await db.transaction((tx) async {
        await dispatcher.dispatchAfterCommit(OrderShipped(order));
        expect(dispatcher.hasAfterCommitEvents, isTrue);
      });
      
      expect(dispatcher.hasAfterCommitEvents, isFalse);
      verify(() => dispatcher.dispatch(any())).called(1);
    });
    
    test('discovers event handlers', () async {
      var discovery = EventDiscovery(container, reflector);
      await discovery.discoverEvents('lib/events');
      
      var dispatcher = container.make<EventDispatcherContract>();
      await dispatcher.dispatch(OrderShipped(order));
      
      verify(() => orderListener.handle(any())).called(1);
    });
  });
}
```

## Next Steps

1. Complete after commit handling
2. Enhance event discovery
3. Add more broadcast drivers
4. Improve queue integration
5. Add performance optimizations
6. Write more tests

Would you like me to enhance any other package specifications?

## Development Guidelines

### 1. Getting Started
Before implementing event features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Understand [Contracts Package Specification](contracts_package_specification.md)

### 2. Implementation Process
For each event feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Implement required contracts (see [Contracts Package Specification](contracts_package_specification.md))

### 4. Integration Considerations
When implementing events:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)
5. Implement all contracts from [Contracts Package Specification](contracts_package_specification.md)

### 5. Performance Guidelines
Event system must:
1. Handle high throughput efficiently
2. Minimize memory usage
3. Support async operations
4. Scale horizontally
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Event tests must:
1. Cover all event scenarios
2. Test async behavior
3. Verify queue integration
4. Check broadcasting
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Event documentation must:
1. Explain event patterns
2. Show integration examples
3. Cover error handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
