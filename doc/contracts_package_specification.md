# Contracts Package Specification

## Overview

The Contracts package defines the core interfaces and contracts that form the foundation of the framework. These contracts ensure consistency and interoperability between components while enabling loose coupling and dependency injection.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup

## Core Contracts

### 1. Container Contracts

```dart
/// Core container interface
abstract class ContainerContract {
  /// Resolves a type from the container
  T make<T>([dynamic context]);
  
  /// Binds a type to the container
  void bind<T>(T Function(ContainerContract) concrete);
  
  /// Binds a singleton to the container
  void singleton<T>(T Function(ContainerContract) concrete);
  
  /// Checks if a type is bound
  bool has<T>();
  
  /// Tags implementations for grouped resolution
  void tag(List<Type> implementations, String tag);
  
  /// Gets all implementations with a tag
  List<T> tagged<T>(String tag);
  
  /// Adds a contextual binding
  void addContextualBinding(Type concrete, Type abstract, dynamic implementation);
  
  /// Creates a new child container
  ContainerContract createChild();
}

/// Interface for contextual binding
abstract class ContextualBindingBuilder {
  /// Specifies the type needed in this context
  ContextualNeedsBuilder needs<T>();
}

/// Interface for contextual needs
abstract class ContextualNeedsBuilder {
  /// Specifies what to give for this need
  void give(dynamic implementation);
}

/// Interface for service providers
abstract class ServiceProviderContract {
  /// Registers services with the container
  void register();
  
  /// Bootstraps any services
  Future<void> boot();
  
  /// Gets provided services
  List<Type> provides();
  
  /// Whether provider is deferred
  bool get isDeferred => false;
}
```

### 2. Event Contracts

```dart
/// Core event dispatcher interface
abstract class EventDispatcherContract {
  /// Registers an event listener
  void listen<T>(void Function(T event) listener);
  
  /// Dispatches an event
  Future<void> dispatch<T>(T event);
  
  /// Registers an event subscriber
  void subscribe(EventSubscriber subscriber);
  
  /// Dispatches an event after database commit
  Future<void> dispatchAfterCommit<T>(T event);
  
  /// Gets registered listeners
  List<Function> getListeners(Type event);
}

/// Interface for event subscribers
abstract class EventSubscriber {
  /// Gets events to subscribe to
  Map<Type, Function> subscribe();
}

/// Interface for queueable events
abstract class ShouldQueue {
  /// Gets the queue to use
  String get queue => 'default';
  
  /// Gets the delay before processing
  Duration? get delay => null;
  
  /// Gets the number of tries
  int get tries => 1;
}

/// Interface for broadcastable events
abstract class ShouldBroadcast {
  /// Gets channels to broadcast on
  List<String> broadcastOn();
  
  /// Gets event name for broadcasting
  String broadcastAs() => runtimeType.toString();
  
  /// Gets broadcast data
  Map<String, dynamic> get broadcastWith => {};
}
```

### 3. Queue Contracts

```dart
/// Core queue interface
abstract class QueueContract {
  /// Pushes a job onto the queue
  Future<String> push(dynamic job, [String? queue]);
  
  /// Pushes a job with delay
  Future<String> later(Duration delay, dynamic job, [String? queue]);
  
  /// Gets next job from queue
  Future<Job?> pop([String? queue]);
  
  /// Creates a job batch
  Batch batch(List<Job> jobs);
  
  /// Gets a queue connection
  QueueConnection connection([String? name]);
}

/// Interface for queue jobs
abstract class Job {
  /// Unique job ID
  String get id;
  
  /// Job payload
  Map<String, dynamic> get payload;
  
  /// Number of attempts
  int get attempts;
  
  /// Maximum tries
  int get tries => 1;
  
  /// Timeout in seconds
  int get timeout => 60;
  
  /// Executes the job
  Future<void> handle();
  
  /// Handles job failure
  Future<void> failed([Exception? exception]);
}

/// Interface for job batches
abstract class Batch {
  /// Batch ID
  String get id;
  
  /// Jobs in batch
  List<Job> get jobs;
  
  /// Adds jobs to batch
  void add(List<Job> jobs);
  
  /// Dispatches the batch
  Future<void> dispatch();
}
```

### 4. Bus Contracts

```dart
/// Core command bus interface
abstract class CommandBusContract {
  /// Dispatches a command
  Future<dynamic> dispatch(Command command);
  
  /// Dispatches a command now
  Future<dynamic> dispatchNow(Command command);
  
  /// Dispatches a command to queue
  Future<dynamic> dispatchToQueue(Command command);
  
  /// Creates a command batch
  PendingBatch batch(List<Command> commands);
  
  /// Creates a command chain
  PendingChain chain(List<Command> commands);
}

/// Interface for commands
abstract class Command {
  /// Gets command handler
  Type get handler;
}

/// Interface for command handlers
abstract class Handler<T extends Command> {
  /// Handles the command
  Future<dynamic> handle(T command);
}

/// Interface for command batches
abstract class PendingBatch {
  /// Dispatches the batch
  Future<void> dispatch();
  
  /// Allows failures
  PendingBatch allowFailures();
}
```

### 5. Pipeline Contracts

```dart
/// Core pipeline interface
abstract class PipelineContract<T> {
  /// Sends value through pipeline
  PipelineContract<T> send(T passable);
  
  /// Sets the pipes
  PipelineContract<T> through(List<PipeContract<T>> pipes);
  
  /// Processes the pipeline
  Future<R> then<R>(Future<R> Function(T) destination);
}

/// Interface for pipes
abstract class PipeContract<T> {
  /// Handles the passable
  Future<dynamic> handle(T passable, Function next);
}

/// Interface for pipeline hub
abstract class PipelineHubContract {
  /// Gets a pipeline
  PipelineContract<T> pipeline<T>(String name);
  
  /// Sets default pipes
  void defaults(List<PipeContract> pipes);
}
```

## Usage Examples

### Container Usage
```dart
// Register service provider
class AppServiceProvider implements ServiceProviderContract {
  @override
  void register() {
    container.bind<UserService>((c) => UserService(
      c.make<DatabaseConnection>(),
      c.make<CacheContract>()
    ));
  }
  
  @override
  Future<void> boot() async {
    // Bootstrap services
  }
}
```

### Event Handling
```dart
// Define event
class OrderShipped implements ShouldQueue, ShouldBroadcast {
  final Order order;
  
  @override
  List<String> broadcastOn() => ['orders.${order.id}'];
  
  @override
  String get queue => 'notifications';
}

// Handle event
dispatcher.listen<OrderShipped>((event) async {
  await notifyCustomer(event.order);
});
```

### Command Bus Usage
```dart
// Define command
class CreateOrder implements Command {
  final String customerId;
  final List<String> products;
  
  @override
  Type get handler => CreateOrderHandler;
}

// Handle command
class CreateOrderHandler implements Handler<CreateOrder> {
  @override
  Future<Order> handle(CreateOrder command) async {
    // Create order
  }
}

// Dispatch command
var order = await bus.dispatch(CreateOrder(
  customerId: '123',
  products: ['abc', 'xyz']
));
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
      });
      
      verify(() => dispatcher.dispatch(any())).called(1);
    });
  });
  
  group('Command Bus', () {
    test('handles command batch', () async {
      var bus = MockCommandBus();
      
      await bus.batch([
        CreateOrder(...),
        UpdateInventory(...)
      ]).dispatch();
      
      verify(() => bus.dispatchNow(any())).called(2);
    });
  });
}
```

## Contract Guidelines

1. **Keep Contracts Minimal**
```dart
// Good: Focused contract
abstract class Cache {
  Future<T?> get<T>(String key);
  Future<void> put<T>(String key, T value);
}

// Bad: Too many responsibilities
abstract class Cache {
  Future<T?> get<T>(String key);
  Future<void> put<T>(String key, T value);
  void clearMemory();
  void optimizeStorage();
  void defragment();
}
```

2. **Use Type Parameters**
```dart
// Good: Type safe
abstract class Repository<T> {
  Future<T?> find(String id);
  Future<void> save(T entity);
}

// Bad: Dynamic typing
abstract class Repository {
  Future<dynamic> find(String id);
  Future<void> save(dynamic entity);
}
```

3. **Document Contracts**
```dart
/// Contract for caching implementations.
/// 
/// Implementations must:
/// - Handle serialization
/// - Be thread-safe
/// - Support TTL
abstract class Cache {
  /// Gets a value from cache.
  /// 
  /// Returns null if not found.
  /// Throws [CacheException] on error.
  Future<T?> get<T>(String key);
}
```

## Next Steps

1. Implement core contracts
2. Add integration tests
3. Document Laravel compatibility
4. Add migration guides
5. Create examples
6. Write tests

Would you like me to enhance any other package specifications?

## Development Guidelines

### 1. Getting Started
Before implementing contracts:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)

### 2. Implementation Process
For each contract:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))

### 4. Integration Considerations
When implementing contracts:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)
