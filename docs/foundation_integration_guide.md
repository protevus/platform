# Foundation Integration Guide

## Overview

This guide demonstrates how Level 0 and Level 1 packages work together to provide the foundation for the framework. It includes implementation priorities, integration patterns, and best practices.

## Implementation Timeline

### Phase 1: Core Foundation (Level 0)

#### Week 1: Contracts Package
```dart
Priority: Highest
Dependencies: None
Steps:
1. Define core interfaces
2. Create base exceptions
3. Add documentation
4. Write interface tests
```

#### Week 2: Support Package
```dart
Priority: Highest
Dependencies: Contracts
Steps:
1. Implement collections
2. Add string helpers
3. Create service provider base
4. Add utility functions
```

#### Weeks 3-4: Container Package
```dart
Priority: Highest
Dependencies: Contracts, Support
Steps:
1. Implement core container
2. Add contextual binding
3. Add method injection
4. Add tagged bindings
5. Implement caching
```

#### Week 5: Pipeline Package
```dart
Priority: High
Dependencies: Contracts, Support, Container
Steps:
1. Implement core pipeline
2. Add pipeline hub
3. Create middleware support
4. Add async handling
```

### Phase 2: Infrastructure (Level 1)

#### Weeks 6-7: Events Package
```dart
Priority: High
Dependencies: All Level 0
Steps:
1. Implement event dispatcher
2. Add event discovery
3. Create subscriber support
4. Add queueing integration
```

#### Week 8: Config Package
```dart
Priority: High
Dependencies: All Level 0
Steps:
1. Implement config repository
2. Add environment loading
3. Create config caching
4. Add array casting
```

#### Weeks 9-10: FileSystem Package
```dart
Priority: High
Dependencies: All Level 0
Steps:
1. Implement filesystem manager
2. Create local driver
3. Add cloud drivers
4. Implement streaming
```

## Integration Examples

### 1. Service Provider Integration
```dart
/// Example showing how packages integrate through service providers
void main() {
  var container = Container();
  
  // Register foundation services
  container.register(SupportServiceProvider());
  container.register(PipelineServiceProvider());
  container.register(EventServiceProvider());
  container.register(ConfigServiceProvider());
  container.register(FilesystemServiceProvider());
  
  // Boot application
  await container.bootProviders();
}
```

### 2. Event-Driven File Operations
```dart
/// Example showing Events and FileSystem integration
class FileUploadHandler {
  final EventDispatcherContract _events;
  final FilesystemContract _storage;
  
  Future<void> handleUpload(Upload upload) async {
    // Store file using FileSystem
    await _storage.put(
      'uploads/${upload.filename}',
      upload.contents,
      {'visibility': 'public'}
    );
    
    // Dispatch event using Events
    await _events.dispatch(FileUploaded(
      filename: upload.filename,
      size: upload.size,
      url: await _storage.url('uploads/${upload.filename}')
    ));
  }
}
```

### 3. Configuration-Based Pipeline
```dart
/// Example showing Config and Pipeline integration
class RequestHandler {
  final ConfigContract _config;
  final Pipeline<Request> _pipeline;
  
  Future<Response> handle(Request request) async {
    // Get middleware from config
    var middleware = _config.get<List>('http.middleware', [])
      .map((m) => container.make<Middleware>(m))
      .toList();
    
    // Process request through pipeline
    return _pipeline
      .through(middleware)
      .send(request)
      .then((request) => processRequest(request));
  }
}
```

## Common Integration Patterns

### 1. Service Provider Pattern
```dart
abstract class ServiceProvider {
  void register() {
    container.singleton<Service>((c) => 
      ServiceImpl(
        c.make<EventDispatcherContract>(),
        c.make<ConfigContract>(),
        c.make<FilesystemContract>()
      )
    );
  }
}
```

### 2. Event-Driven Pattern
```dart
class EventDrivenService {
  final EventDispatcherContract events;
  
  void initialize() {
    events.listen<ConfigurationChanged>(_handleConfigChange);
    events.listen<StorageEvent>(_handleStorageEvent);
  }
}
```

### 3. Pipeline Pattern
```dart
class ServicePipeline {
  final Pipeline<Request> pipeline;
  
  ServicePipeline(this.pipeline) {
    pipeline.through([
      ConfigMiddleware(container.make<ConfigContract>()),
      EventMiddleware(container.make<EventDispatcherContract>()),
      StorageMiddleware(container.make<FilesystemContract>())
    ]);
  }
}
```

## Testing Strategy

### 1. Unit Tests
```dart
void main() {
  group('Package Tests', () {
    test('core functionality', () {
      // Test core features
    });
    
    test('integration points', () {
      // Test integration with other packages
    });
  });
}
```

### 2. Integration Tests
```dart
void main() {
  group('Integration Tests', () {
    late Container container;
    
    setUp(() {
      container = Container();
      container.register(SupportServiceProvider());
      container.register(EventServiceProvider());
    });
    
    test('should handle file upload with events', () async {
      var handler = container.make<FileUploadHandler>();
      var events = container.make<EventDispatcherContract>();
      
      var received = <FileUploaded>[];
      events.listen<FileUploaded>((event) {
        received.add(event);
      });
      
      await handler.handleUpload(testUpload);
      expect(received, hasLength(1));
    });
  });
}
```

## Quality Checklist

### 1. Code Quality
- [ ] Follows style guide
- [ ] Uses static analysis
- [ ] Has documentation
- [ ] Has tests
- [ ] Handles errors

### 2. Package Quality
- [ ] Has README
- [ ] Has examples
- [ ] Has changelog
- [ ] Has license
- [ ] Has CI/CD

### 3. Integration Quality
- [ ] Works with container
- [ ] Supports events
- [ ] Uses configuration
- [ ] Has providers

## Best Practices

1. **Use Service Providers**
```dart
// Register dependencies in providers
class ServiceProvider {
  void register() {
    // Register all required services
  }
}
```

2. **Event-Driven Communication**
```dart
// Use events for cross-package communication
class Service {
  final EventDispatcherContract _events;
  
  Future<void> doSomething() async {
    await _events.dispatch(SomethingHappened());
  }
}
```

3. **Configuration-Based Setup**
```dart
// Use configuration for service setup
class Service {
  void initialize(ConfigContract config) {
    if (config.get('service.enabled')) {
      // Initialize service
    }
  }
}
```

## Next Steps

1. Follow implementation timeline
2. Review package dependencies
3. Implement integration tests
4. Document common patterns
5. Create example applications

Would you like me to:
1. Start implementing a specific package?
2. Create detailed integration tests?
3. Build example applications?
