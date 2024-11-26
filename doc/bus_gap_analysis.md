# Bus Package Gap Analysis

## Overview

This document analyzes the gaps between our Bus package's actual implementation and Laravel's Bus functionality, identifying areas that need implementation or documentation updates.

> **Related Documentation**
> - See [Bus Package Specification](bus_package_specification.md) for current implementation
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for overall status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup

## Implementation Gaps

### 1. Missing Laravel Features
```dart
// Documented but not implemented:

// 1. Job Chaining
class ChainedCommand {
  // Need to implement:
  void onConnection(String connection);
  void onQueue(String queue);
  void delay(Duration duration);
  void middleware(List<PipeContract> middleware);
}

// 2. Rate Limiting
class RateLimitedCommand {
  // Need to implement:
  void rateLimit(int maxAttempts, Duration duration);
  void rateLimitPerUser(int maxAttempts, Duration duration);
  void withoutOverlapping();
}

// 3. Error Handling
class FailedCommandHandler {
  // Need to implement:
  Future<void> failed(Command command, Exception exception);
  Future<void> retry(String commandId);
  Future<void> forget(String commandId);
  Future<void> flush();
}
```

### 2. Existing Features Not Documented

```dart
// Implemented but not documented:

// 1. Command Mapping
class CommandMapper {
  /// Maps command types to handlers
  final Map<Type, Type> _handlers = {};
  
  /// Registers command handler
  void map<TCommand extends Command, THandler extends Handler>(
    THandler Function() factory
  );
}

// 2. Command Context
class CommandContext {
  /// Command metadata
  final Map<String, dynamic> _metadata = {};
  
  /// Sets command context
  void withContext(String key, dynamic value);
  
  /// Gets command context
  T? getContext<T>(String key);
}

// 3. Command Lifecycle
class CommandLifecycle {
  /// Command hooks
  final List<Function> _beforeHandling = [];
  final List<Function> _afterHandling = [];
  
  /// Registers lifecycle hooks
  void beforeHandling(Function callback);
  void afterHandling(Function callback);
}
```

### 3. Integration Points Not Documented

```dart
// 1. Queue Integration
class QueuedCommand {
  /// Queue configuration
  String get connection => 'default';
  String get queue => 'default';
  Duration? get delay => null;
  
  /// Queue callbacks
  void onQueue(QueueContract queue);
  void onConnection(String connection);
}

// 2. Event Integration
class EventedCommand {
  /// Event dispatcher
  final EventDispatcherContract _events;
  
  /// Dispatches command events
  void dispatchCommandEvent(String event, dynamic data);
  void subscribeCommandEvents(EventSubscriber subscriber);
}

// 3. Cache Integration
class CachedCommand {
  /// Cache configuration
  String get cacheKey => '';
  Duration get cacheTTL => Duration(minutes: 60);
  
  /// Cache operations
  Future<void> cache();
  Future<void> clearCache();
}
```

## Documentation Gaps

### 1. Missing API Documentation

```dart
// Need to document:

/// Maps command types to their handlers.
/// 
/// Example:
/// ```dart
/// mapper.map<CreateOrder, CreateOrderHandler>(
///   () => CreateOrderHandler(repository)
/// );
/// ```
void map<TCommand extends Command, THandler extends Handler>(
  THandler Function() factory
);

/// Sets command execution context.
///
/// Example:
/// ```dart
/// command.withContext('user_id', userId);
/// command.withContext('tenant', tenant);
/// ```
void withContext(String key, dynamic value);
```

### 2. Missing Integration Examples

```dart
// Need examples for:

// 1. Queue Integration
var command = CreateOrder(...)
  ..onQueue('orders')
  ..delay(Duration(minutes: 5));

await bus.dispatch(command);

// 2. Event Integration
class OrderCommand extends EventedCommand {
  void handle() {
    // Handle command
    dispatchCommandEvent('order.handled', order);
  }
}

// 3. Cache Integration
class GetOrderCommand extends CachedCommand {
  @override
  String get cacheKey => 'order.$orderId';
  
  Future<Order> handle() async {
    return await cache(() => repository.find(orderId));
  }
}
```

### 3. Missing Test Coverage

```dart
// Need tests for:

void main() {
  group('Command Mapping', () {
    test('maps commands to handlers', () {
      var mapper = CommandMapper();
      mapper.map<CreateOrder, CreateOrderHandler>(
        () => CreateOrderHandler(repository)
      );
      
      var handler = mapper.resolveHandler(CreateOrder());
      expect(handler, isA<CreateOrderHandler>());
    });
  });
  
  group('Command Context', () {
    test('handles command context', () {
      var command = TestCommand()
        ..withContext('key', 'value');
      
      expect(command.getContext('key'), equals('value'));
    });
  });
}
```

## Implementation Priority

1. **High Priority**
   - Command chaining (Laravel compatibility)
   - Rate limiting (Laravel compatibility)
   - Better error handling

2. **Medium Priority**
   - Command mapping
   - Command context
   - Performance optimizations

3. **Low Priority**
   - Additional helper methods
   - Extended testing utilities
   - Debug/profiling tools

## Next Steps

1. **Implementation Tasks**
   - Add command chaining
   - Add rate limiting
   - Add error handling
   - Improve queue integration

2. **Documentation Tasks**
   - Document command mapping
   - Document command context
   - Document command lifecycle
   - Add integration examples

3. **Testing Tasks**
   - Add command mapping tests
   - Add context tests
   - Add lifecycle tests
   - Add integration tests

## Development Guidelines

### 1. Getting Started
Before implementing bus features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Bus Package Specification](bus_package_specification.md)

### 2. Implementation Process
For each bus feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Match specifications in [Bus Package Specification](bus_package_specification.md)

### 4. Integration Considerations
When implementing bus features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)

### 5. Performance Guidelines
Bus system must:
1. Handle high command throughput
2. Process chains efficiently
3. Support async operations
4. Scale horizontally
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Bus tests must:
1. Cover all command scenarios
2. Test chaining behavior
3. Verify rate limiting
4. Check error handling
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Bus documentation must:
1. Explain command patterns
2. Show chaining examples
3. Cover error handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
