# Events Package Gap Analysis

## Overview

This document analyzes the gaps between our Events package's actual implementation and our documentation, identifying areas that need implementation or documentation updates.

> **Related Documentation**
> - See [Events Package Specification](events_package_specification.md) for current implementation
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for overall status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup

## Implementation Gaps

### 1. Missing Laravel Features
```dart
// Documented but not implemented:

// 1. Event Discovery
class EventDiscovery {
  // Need to implement:
  Map<Type, Function> discoverHandlers(Type type);
  void discoverEvents(String path);
}

// 2. After Commit Handling
class DatabaseEventDispatcher {
  // Need to implement:
  Future<void> dispatchAfterCommit<T>(T event);
  void afterCommit(Function callback);
}

// 3. Better Broadcasting
class BroadcastManager {
  // Need to implement:
  Channel privateChannel(String name);
  PresenceChannel presenceChannel(String name);
  Future<void> broadcast(List<String> channels, String event, dynamic data);
}
```

### 2. Existing Features Not Documented

```dart
// Implemented but not documented:

// 1. Wildcard Event Listeners
class Dispatcher {
  /// Adds wildcard event listener
  void _setupWildcardListen(String event, Function listener) {
    _wildcards.putIfAbsent(event, () => []).add(listener);
    _wildcardsCache.clear();
  }
  
  /// Gets wildcard listeners
  List<Function> _getWildcardListeners(String eventName);
}

// 2. Event Bus Integration
class Dispatcher {
  /// EventBus integration
  final EventBus _eventBus;
  final Map<String, StreamSubscription> _eventBusSubscriptions = {};
  
  /// Subscribes to EventBus
  void subscribe(EventBusSubscriber subscriber);
}

// 3. Message Queue Integration
class Dispatcher {
  /// MQ integration
  late final MQClient? _mqClient;
  
  /// Queue setup
  void _setupQueuesAndExchanges();
  void _startProcessingQueuedEvents();
}
```

### 3. Integration Points Not Documented

```dart
// 1. Container Integration
class Dispatcher {
  /// Container reference
  final Container container;
  
  /// Queue resolver
  late final Function _queueResolver;
  
  /// Transaction manager resolver
  late final Function _transactionManagerResolver;
}

// 2. ReactiveX Integration
class Dispatcher {
  /// Subject management
  final Map<String, BehaviorSubject<dynamic>> _subjects = {};
  
  /// Stream access
  Stream<T> on<T>(String event);
}

// 3. Resource Management
class Dispatcher {
  /// Cleanup
  Future<void> close();
  void dispose();
}
```

## Documentation Gaps

### 1. Missing API Documentation

```dart
// Need to document:

/// Listens for events using wildcard patterns.
/// 
/// Example:
/// ```dart
/// dispatcher.listen('user.*', (event, data) {
///   // Handles all user events
/// });
/// ```
void listen(String pattern, Function listener);

/// Subscribes to event streams using ReactiveX.
///
/// Example:
/// ```dart
/// dispatcher.on<UserCreated>('user.created')
///   .listen((event) {
///     // Handle user created event
///   });
/// ```
Stream<T> on<T>(String event);
```

### 2. Missing Integration Examples

```dart
// Need examples for:

// 1. EventBus Integration
var subscriber = MyEventSubscriber();
dispatcher.subscribe(subscriber);

// 2. Message Queue Integration
dispatcher.setMQClient(mqClient);
await dispatcher.push('user.created', userData);

// 3. ReactiveX Integration
dispatcher.on<UserEvent>('user.*')
  .where((e) => e.type == 'premium')
  .listen((e) => handlePremiumUser(e));
```

### 3. Missing Test Coverage

```dart
// Need tests for:

void main() {
  group('Wildcard Events', () {
    test('matches wildcard patterns', () {
      var dispatcher = Dispatcher(container);
      var received = <String>[];
      
      dispatcher.listen('user.*', (event, _) {
        received.add(event);
      });
      
      await dispatcher.dispatch('user.created');
      await dispatcher.dispatch('user.updated');
      
      expect(received, ['user.created', 'user.updated']);
    });
  });
  
  group('Queue Integration', () {
    test('queues events properly', () async {
      var dispatcher = Dispatcher(container);
      dispatcher.setMQClient(mockClient);
      
      await dispatcher.push('delayed.event', data);
      
      verify(() => mockClient.sendMessage(
        exchangeName: any,
        routingKey: any,
        message: any
      )).called(1);
    });
  });
}
```

## Implementation Priority

1. **High Priority**
   - Event discovery (Laravel compatibility)
   - After commit handling (Laravel compatibility)
   - Better broadcasting support

2. **Medium Priority**
   - Better queue integration
   - Enhanced wildcard support
   - Performance optimizations

3. **Low Priority**
   - Additional helper methods
   - Extended testing utilities
   - Debug/profiling tools

## Next Steps

1. **Implementation Tasks**
   - Add event discovery
   - Add after commit handling
   - Enhance broadcasting
   - Improve queue integration

2. **Documentation Tasks**
   - Document wildcard events
   - Document EventBus integration
   - Document MQ integration
   - Add integration examples

3. **Testing Tasks**
   - Add wildcard event tests
   - Add queue integration tests
   - Add ReactiveX integration tests
   - Add resource cleanup tests

Would you like me to:
1. Start implementing missing features?
2. Update documentation for existing features?
3. Create test cases for missing coverage?

## Development Guidelines

### 1. Getting Started
Before implementing event features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Events Package Specification](events_package_specification.md)

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
4. Match specifications in [Events Package Specification](events_package_specification.md)

### 4. Integration Considerations
When implementing event features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)

### 5. Performance Guidelines
Events system must:
1. Handle high event throughput
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
