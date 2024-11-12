# Bus Package Specification

## Overview

The Bus package provides a robust command and event bus implementation that matches Laravel's bus functionality. It integrates with our Queue, Event, and Pipeline packages to provide a complete message bus solution with support for command handling, event dispatching, and middleware processing.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Events Package Specification](events_package_specification.md) for event handling
> - See [Queue Package Specification](queue_package_specification.md) for queue integration

## Core Features

### 1. Command Bus

```dart
/// Core command bus implementation
class CommandBus implements CommandBusContract {
  final Container _container;
  final QueueContract? _queue;
  final PipelineContract _pipeline;
  
  CommandBus(
    this._container,
    this._pipeline, [
    this._queue
  ]);
  
  /// Dispatches a command
  Future<dynamic> dispatch(Command command) async {
    if (command is ShouldQueue && _queue != null) {
      return await dispatchToQueue(command);
    }
    
    return await dispatchNow(command);
  }
  
  /// Dispatches a command immediately
  Future<dynamic> dispatchNow(Command command) async {
    var handler = _resolveHandler(command);
    
    return await _pipeline
      .send(command)
      .through(_getPipes())
      .then((cmd) => handler.handle(cmd));
  }
  
  /// Dispatches a command to queue
  Future<dynamic> dispatchToQueue(Command command) async {
    await _queue!.push(QueuedCommandJob(
      command: command,
      handler: _resolveHandler(command)
    ));
  }
  
  /// Creates a command batch
  PendingBatch batch(List<Command> commands) {
    return PendingCommandBatch(this, commands);
  }
  
  /// Creates a command chain
  PendingChain chain(List<Command> commands) {
    return PendingCommandChain(this, commands);
  }
  
  /// Resolves command handler
  Handler _resolveHandler(Command command) {
    var handlerType = command.handler;
    return _container.make(handlerType);
  }
  
  /// Gets command pipes
  List<PipeContract> _getPipes() {
    return [
      TransactionPipe(),
      ValidationPipe(),
      AuthorizationPipe()
    ];
  }
}
```

### 2. Event Bus

```dart
/// Core event bus implementation
class EventBus implements EventBusContract {
  final Container _container;
  final EventDispatcherContract _events;
  final QueueContract? _queue;
  
  EventBus(
    this._container,
    this._events, [
    this._queue
  ]);
  
  /// Dispatches an event
  Future<void> dispatch(Event event) async {
    if (event is ShouldQueue && _queue != null) {
      await dispatchToQueue(event);
    } else {
      await dispatchNow(event);
    }
  }
  
  /// Dispatches an event immediately
  Future<void> dispatchNow(Event event) async {
    await _events.dispatch(event);
  }
  
  /// Dispatches an event to queue
  Future<void> dispatchToQueue(Event event) async {
    await _queue!.push(QueuedEventJob(
      event: event,
      listeners: _events.getListeners(event.runtimeType)
    ));
  }
  
  /// Registers an event listener
  void listen<T>(void Function(T event) listener) {
    _events.listen<T>(listener);
  }
  
  /// Registers an event subscriber
  void subscribe(EventSubscriber subscriber) {
    _events.subscribe(subscriber);
  }
}
```

### 3. Bus Middleware

```dart
/// Transaction middleware
class TransactionPipe implements PipeContract {
  final DatabaseManager _db;
  
  TransactionPipe(this._db);
  
  @override
  Future<dynamic> handle(dynamic passable, Function next) async {
    return await _db.transaction((tx) async {
      return await next(passable);
    });
  }
}

/// Validation middleware
class ValidationPipe implements PipeContract {
  final Validator _validator;
  
  ValidationPipe(this._validator);
  
  @override
  Future<dynamic> handle(dynamic passable, Function next) async {
    if (passable is ValidatableCommand) {
      await _validator.validate(
        passable.toMap(),
        passable.rules()
      );
    }
    
    return await next(passable);
  }
}

/// Authorization middleware
class AuthorizationPipe implements PipeContract {
  final AuthManager _auth;
  
  AuthorizationPipe(this._auth);
  
  @override
  Future<dynamic> handle(dynamic passable, Function next) async {
    if (passable is AuthorizableCommand) {
      if (!await passable.authorize(_auth)) {
        throw UnauthorizedException();
      }
    }
    
    return await next(passable);
  }
}
```

### 4. Command Batching

```dart
/// Pending command batch
class PendingCommandBatch implements PendingBatch {
  final CommandBus _bus;
  final List<Command> _commands;
  bool _allowFailures = false;
  
  PendingCommandBatch(this._bus, this._commands);
  
  /// Allows failures in batch
  PendingBatch allowFailures() {
    _allowFailures = true;
    return this;
  }
  
  /// Dispatches the batch
  Future<void> dispatch() async {
    for (var command in _commands) {
      try {
        await _bus.dispatchNow(command);
      } catch (e) {
        if (!_allowFailures) rethrow;
      }
    }
  }
}

/// Pending command chain
class PendingCommandChain implements PendingChain {
  final CommandBus _bus;
  final List<Command> _commands;
  
  PendingCommandChain(this._bus, this._commands);
  
  /// Dispatches the chain
  Future<void> dispatch() async {
    dynamic result;
    
    for (var command in _commands) {
      if (command is ChainedCommand) {
        command.setPreviousResult(result);
      }
      
      result = await _bus.dispatchNow(command);
    }
  }
}
```

## Integration Examples

### 1. Command Bus Usage
```dart
// Define command
class CreateOrder implements Command {
  final String customerId;
  final List<String> products;
  
  @override
  Type get handler => CreateOrderHandler;
}

// Define handler
class CreateOrderHandler implements Handler<CreateOrder> {
  final OrderRepository _orders;
  
  CreateOrderHandler(this._orders);
  
  @override
  Future<Order> handle(CreateOrder command) async {
    return await _orders.create(
      customerId: command.customerId,
      products: command.products
    );
  }
}

// Dispatch command
var order = await bus.dispatch(CreateOrder(
  customerId: '123',
  products: ['abc', 'xyz']
));
```

### 2. Event Bus Usage
```dart
// Define event
class OrderCreated implements Event {
  final Order order;
  OrderCreated(this.order);
}

// Register listener
eventBus.listen<OrderCreated>((event) async {
  await notifyCustomer(event.order);
});

// Dispatch event
await eventBus.dispatch(OrderCreated(order));
```

### 3. Command Batching
```dart
// Create batch
await bus.batch([
  CreateOrder(...),
  UpdateInventory(...),
  NotifyShipping(...)
])
.allowFailures()
.dispatch();

// Create chain
await bus.chain([
  CreateOrder(...),
  ProcessPayment(...),
  ShipOrder(...)
])
.dispatch();
```

## Testing

```dart
void main() {
  group('Command Bus', () {
    test('dispatches commands', () async {
      var bus = CommandBus(container, pipeline);
      var command = CreateOrder(...);
      
      await bus.dispatch(command);
      
      verify(() => handler.handle(command)).called(1);
    });
    
    test('handles command batch', () async {
      var bus = CommandBus(container, pipeline);
      
      await bus.batch([
        CreateOrder(...),
        UpdateInventory(...)
      ]).dispatch();
      
      verify(() => bus.dispatchNow(any())).called(2);
    });
  });
  
  group('Event Bus', () {
    test('dispatches events', () async {
      var bus = EventBus(container, dispatcher);
      var event = OrderCreated(order);
      
      await bus.dispatch(event);
      
      verify(() => dispatcher.dispatch(event)).called(1);
    });
    
    test('queues events', () async {
      var bus = EventBus(container, dispatcher, queue);
      var event = OrderShipped(order);
      
      await bus.dispatch(event);
      
      verify(() => queue.push(any())).called(1);
    });
  });
}
```

## Next Steps

1. Implement core bus features
2. Add middleware support
3. Add batching/chaining
4. Add queue integration
5. Write tests
6. Add benchmarks

## Development Guidelines

### 1. Getting Started
Before implementing bus features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Events Package Specification](events_package_specification.md)
6. Review [Queue Package Specification](queue_package_specification.md)

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
4. Match specifications in related packages

### 4. Integration Considerations
When implementing bus features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)

### 5. Performance Guidelines
Bus system must:
1. Handle high command throughput
2. Process events efficiently
3. Support async operations
4. Scale horizontally
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Bus tests must:
1. Cover all command scenarios
2. Test event handling
3. Verify queue integration
4. Check middleware behavior
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Bus documentation must:
1. Explain command patterns
2. Show event examples
3. Cover error handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
