# Pipeline Package Specification

## Overview

The Pipeline package provides a robust implementation of the pipeline pattern, allowing for the sequential processing of tasks through a series of stages. It integrates deeply with our Route, Bus, and Queue packages while maintaining Laravel compatibility.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Contracts Package Specification](contracts_package_specification.md) for pipeline contracts

## Core Features

### 1. Pipeline Base

```dart
/// Core pipeline class with conditional execution
class Pipeline<TPassable> with Conditionable<Pipeline<TPassable>> {
  final Container _container;
  final List<Pipe<TPassable>> _pipes;
  TPassable? _passable;
  String _method = 'handle';
  
  Pipeline(this._container, [List<Pipe<TPassable>>? pipes])
      : _pipes = pipes ?? [];
  
  /// Sends an object through the pipeline
  Pipeline<TPassable> send(TPassable passable) {
    _passable = passable;
    return this;
  }
  
  /// Sets the stages of the pipeline
  Pipeline<TPassable> through(List<dynamic> pipes) {
    for (var pipe in pipes) {
      if (pipe is String) {
        // Resolve from container
        _pipes.add(_container.make(pipe));
      } else if (pipe is Type) {
        _pipes.add(_container.make(pipe));
      } else if (pipe is Pipe<TPassable>) {
        _pipes.add(pipe);
      } else if (pipe is Function) {
        _pipes.add(FunctionPipe(pipe));
      }
    }
    return this;
  }
  
  /// Sets the method to call on the pipes
  Pipeline<TPassable> via(String method) {
    _method = method;
    return this;
  }
  
  /// Process the pipeline to final result
  Future<TResult> then<TResult>(
    FutureOr<TResult> Function(TPassable) destination
  ) async {
    var pass = _passable;
    if (pass == null) {
      throw PipelineException('No passable object provided');
    }
    
    // Build pipeline
    var pipeline = _pipes.fold<Function>(
      destination,
      (next, pipe) => (passable) => 
        _container.call(() => pipe.handle(passable, next))
    );
    
    // Execute pipeline
    return await pipeline(pass);
  }
}
```

### 2. Middleware Pipeline

```dart
/// HTTP middleware pipeline with route integration
class MiddlewarePipeline extends Pipeline<Request> {
  final Router _router;
  
  MiddlewarePipeline(Container container, this._router)
      : super(container);
  
  /// Adds route-specific middleware
  MiddlewarePipeline throughRoute(Route route) {
    // Get global middleware
    var middleware = _router.middleware;
    
    // Add route middleware
    if (route.middleware.isNotEmpty) {
      middleware.addAll(
        route.middleware.map((m) => _container.make<Middleware>(m))
      );
    }
    
    // Add route group middleware
    if (route.group != null) {
      middleware.addAll(route.group!.middleware);
    }
    
    return through(middleware);
  }
  
  /// Processes request through middleware
  Future<Response> process(
    Request request,
    FutureOr<Response> Function(Request) destination
  ) {
    return send(request)
      .when(() => shouldProcessMiddleware(request))
      .then(destination);
  }
  
  /// Checks if middleware should be processed
  bool shouldProcessMiddleware(Request request) {
    return !request.attributes.containsKey('skip_middleware');
  }
}
```

### 3. Bus Pipeline

```dart
/// Command bus pipeline with handler resolution
class BusPipeline<TCommand> extends Pipeline<TCommand> {
  final CommandBus _bus;
  
  BusPipeline(Container container, this._bus)
      : super(container);
  
  /// Processes command through pipeline
  Future<TResult> process<TResult>(
    TCommand command,
    [Handler<TCommand>? handler]
  ) {
    // Resolve handler
    handler ??= _resolveHandler(command);
    
    return send(command).then((cmd) => 
      handler!.handle(cmd) as Future<TResult>
    );
  }
  
  /// Resolves command handler
  Handler<TCommand> _resolveHandler(TCommand command) {
    if (command is Command) {
      return _container.make(command.handler);
    }
    
    var handlerType = _bus.handlers[TCommand];
    if (handlerType == null) {
      throw HandlerNotFoundException(
        'No handler found for ${TCommand}'
      );
    }
    
    return _container.make(handlerType);
  }
}
```

### 4. Job Pipeline

```dart
/// Queue job pipeline with middleware
class JobPipeline extends Pipeline<Job> {
  final QueueManager _queue;
  
  JobPipeline(Container container, this._queue)
      : super(container);
  
  /// Processes job through pipeline
  Future<void> process(Job job) {
    return send(job)
      .through(_queue.middleware)
      .then((j) => j.handle());
  }
  
  /// Adds rate limiting
  JobPipeline withRateLimit(int maxAttempts, Duration timeout) {
    return through([
      RateLimitedPipe(maxAttempts, timeout)
    ]);
  }
  
  /// Prevents overlapping jobs
  JobPipeline withoutOverlapping() {
    return through([WithoutOverlappingPipe()]);
  }
}
```

### 5. Pipeline Hub

```dart
/// Manages application pipelines
class PipelineHub {
  final Container _container;
  final Map<String, Pipeline> _pipelines = {};
  final List<Pipe> _defaults = [];
  
  PipelineHub(this._container);
  
  /// Gets or creates a pipeline
  Pipeline pipeline(String name) {
    return _pipelines.putIfAbsent(
      name,
      () => Pipeline(_container, [..._defaults])
    );
  }
  
  /// Gets middleware pipeline
  MiddlewarePipeline middleware() {
    return pipeline('middleware') as MiddlewarePipeline;
  }
  
  /// Gets bus pipeline
  BusPipeline bus() {
    return pipeline('bus') as BusPipeline;
  }
  
  /// Gets job pipeline
  JobPipeline job() {
    return pipeline('job') as JobPipeline;
  }
  
  /// Sets default pipes
  void defaults(List<Pipe> pipes) {
    _defaults.addAll(pipes);
  }
}
```

## Integration Examples

### 1. Route Integration
```dart
// In RouteServiceProvider
void boot() {
  router.middleware([
    StartSession::class,
    VerifyCsrfToken::class
  ]);
  
  router.group(['middleware' => ['auth']], () {
    router.get('/dashboard', DashboardController);
  });
}

// In Router
Future<Response> dispatch(Request request) {
  var route = matchRoute(request);
  
  return container.make<MiddlewarePipeline>()
    .throughRoute(route)
    .process(request, (req) => route.handle(req));
}
```

### 2. Command Bus Integration
```dart
// In CommandBus
Future<TResult> dispatch<TResult>(Command command) {
  return container.make<BusPipeline>()
    .through([
      TransactionPipe(),
      ValidationPipe(),
      AuthorizationPipe()
    ])
    .process<TResult>(command);
}

// Usage
class CreateOrder implements Command {
  @override
  Type get handler => CreateOrderHandler;
}

var order = await bus.dispatch<Order>(
  CreateOrder(items: items)
);
```

### 3. Queue Integration
```dart
// In QueueWorker
Future<void> process(Job job) {
  return container.make<JobPipeline>()
    .withRateLimit(3, Duration(minutes: 1))
    .withoutOverlapping()
    .process(job);
}

// Usage
class ProcessPayment implements Job {
  @override
  Future<void> handle() async {
    // Process payment
  }
}

await queue.push(ProcessPayment(
  orderId: order.id
));
```

## Testing

```dart
void main() {
  group('Middleware Pipeline', () {
    test('processes route middleware', () async {
      var pipeline = MiddlewarePipeline(container, router);
      var route = Route('/test', middleware: ['auth']);
      
      var response = await pipeline
        .throughRoute(route)
        .process(request, handler);
        
      verify(() => auth.handle(any, any)).called(1);
    });
  });
  
  group('Bus Pipeline', () {
    test('resolves and executes handler', () async {
      var pipeline = BusPipeline(container, bus);
      var command = CreateOrder(items: items);
      
      var result = await pipeline.process<Order>(command);
      
      expect(result, isA<Order>());
      verify(() => handler.handle(command)).called(1);
    });
  });
}
```

## Next Steps

1. Add more middleware types
2. Enhance bus pipeline features
3. Add job pipeline features
4. Improve testing coverage
5. Add performance optimizations

Would you like me to enhance any other package specifications?

## Development Guidelines

### 1. Getting Started
Before implementing pipeline features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Understand [Contracts Package Specification](contracts_package_specification.md)

### 2. Implementation Process
For each pipeline feature:
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
When implementing pipelines:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)
5. Implement all contracts from [Contracts Package Specification](contracts_package_specification.md)

### 5. Performance Guidelines
Pipeline system must:
1. Handle nested pipelines efficiently
2. Minimize memory usage in long pipelines
3. Support async operations
4. Scale with number of stages
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Pipeline tests must:
1. Cover all pipeline types
2. Test stage ordering
3. Verify error handling
4. Check conditional execution
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Pipeline documentation must:
1. Explain pipeline patterns
2. Show integration examples
3. Cover error handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
