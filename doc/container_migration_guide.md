# Container Migration Guide

## Overview

This guide helps you migrate from the current Container implementation to the new Laravel-compatible version. It covers:
1. Breaking changes
2. New features
3. Migration strategies
4. Code examples
5. Best practices

## Breaking Changes

### 1. Binding Registration

#### Old Way
```dart
// Old implementation
container.bind<Service>(instance);
container.singleton<Service>(instance);
```

#### New Way
```dart
// New implementation
container.bind<Service>((c) => instance);
container.singleton<Service>((c) => instance);

// With contextual binding
container.when(UserController)
        .needs<Service>()
        .give((c) => SpecialService());
```

### 2. Service Resolution

#### Old Way
```dart
// Old implementation
var service = container.make<Service>();
var namedService = container.makeNamed<Service>('name');
```

#### New Way
```dart
// New implementation
var service = container.make<Service>();
var contextualService = container.make<Service>(context: UserController);
var taggedServices = container.taggedAs<Service>('tag');
```

### 3. Method Injection

#### Old Way
```dart
// Old implementation - manual parameter resolution
class UserService {
  void process(User user) {
    var logger = container.make<Logger>();
    var validator = container.make<Validator>();
    // Process user...
  }
}
```

#### New Way
```dart
// New implementation - automatic method injection
class UserService {
  void process(
    User user,
    Logger logger,  // Automatically injected
    Validator validator  // Automatically injected
  ) {
    // Process user...
  }
}

// Usage
container.call(userService, 'process', {'user': user});
```

## New Features

### 1. Contextual Binding

```dart
// Register different implementations based on context
void setupBindings(Container container) {
  // Default storage
  container.bind<Storage>((c) => LocalStorage());
  
  // User uploads use cloud storage
  container.when(UserUploadController)
          .needs<Storage>()
          .give((c) => CloudStorage());
          
  // System files use local storage
  container.when(SystemFileController)
          .needs<Storage>()
          .give((c) => LocalStorage());
}
```

### 2. Tagged Bindings

```dart
// Register and tag related services
void setupReportServices(Container container) {
  // Register services
  container.bind<PerformanceReport>((c) => PerformanceReport());
  container.bind<FinancialReport>((c) => FinancialReport());
  container.bind<UserReport>((c) => UserReport());
  
  // Tag them for easy retrieval
  container.tag([
    PerformanceReport,
    FinancialReport,
    UserReport
  ], 'reports');
  
  // Additional categorization
  container.tag([PerformanceReport], 'metrics');
  container.tag([FinancialReport], 'financial');
}

// Usage
var reports = container.taggedAs<Report>('reports');
var metricReports = container.taggedAs<Report>('metrics');
```

### 3. Method Injection

```dart
class ReportGenerator {
  void generateReport(
    Report report,
    Logger logger,  // Automatically injected
    Formatter formatter,  // Automatically injected
    {required DateTime date}  // Manually provided
  ) {
    logger.info('Generating report...');
    var data = report.getData();
    var formatted = formatter.format(data);
    // Generate report...
  }
}

// Usage
container.call(
  generator,
  'generateReport',
  {'report': report, 'date': DateTime.now()}
);
```

## Migration Strategies

### 1. Gradual Migration

```dart
// Step 1: Update bindings
class ServiceRegistry {
  void register(Container container) {
    // Old way (still works)
    container.bind<OldService>(OldService());
    
    // New way
    container.bind<NewService>((c) => NewService());
    
    // Add contextual bindings
    container.when(NewController)
            .needs<Service>()
            .give((c) => NewService());
  }
}

// Step 2: Update resolution
class ServiceConsumer {
  void process() {
    // Old way (still works)
    var oldService = container.make<OldService>();
    
    // New way
    var newService = container.make<NewService>();
    var contextual = container.make<Service>(
      context: NewController
    );
  }
}

// Step 3: Add method injection
class ServiceProcessor {
  // Old way
  void processOld(Data data) {
    var service = container.make<Service>();
    service.process(data);
  }
  
  // New way
  void processNew(
    Data data,
    Service service  // Injected automatically
  ) {
    service.process(data);
  }
}
```

### 2. Feature-by-Feature Migration

1. **Update Bindings First**
```dart
// Update all bindings to new style
void registerBindings(Container container) {
  // Update simple bindings
  container.bind<Service>((c) => ServiceImpl());
  
  // Add contextual bindings
  container.when(Controller)
          .needs<Service>()
          .give((c) => SpecialService());
}
```

2. **Add Tagged Services**
```dart
// Group related services
void registerServices(Container container) {
  // Register services
  container.bind<ServiceA>((c) => ServiceA());
  container.bind<ServiceB>((c) => ServiceB());
  
  // Add tags
  container.tag([ServiceA, ServiceB], 'services');
}
```

3. **Implement Method Injection**
```dart
// Convert to method injection
class UserController {
  // Before
  void oldProcess(User user) {
    var validator = container.make<Validator>();
    var logger = container.make<Logger>();
    // Process...
  }
  
  // After
  void newProcess(
    User user,
    Validator validator,
    Logger logger
  ) {
    // Process...
  }
}
```

## Testing During Migration

### 1. Verify Bindings

```dart
void main() {
  group('Container Migration Tests', () {
    late Container container;
    
    setUp(() {
      container = Container();
      registerBindings(container);
    });
    
    test('should support old-style bindings', () {
      var oldService = container.make<OldService>();
      expect(oldService, isNotNull);
    });
    
    test('should support new-style bindings', () {
      var newService = container.make<NewService>();
      expect(newService, isNotNull);
    });
    
    test('should resolve contextual bindings', () {
      var service = container.make<Service>(
        context: Controller
      );
      expect(service, isA<SpecialService>());
    });
  });
}
```

### 2. Verify Tagged Services

```dart
void main() {
  group('Tagged Services Tests', () {
    late Container container;
    
    setUp(() {
      container = Container();
      registerServices(container);
    });
    
    test('should resolve tagged services', () {
      var services = container.taggedAs<Service>('services');
      expect(services, hasLength(2));
      expect(services, contains(isA<ServiceA>()));
      expect(services, contains(isA<ServiceB>()));
    });
  });
}
```

### 3. Verify Method Injection

```dart
void main() {
  group('Method Injection Tests', () {
    late Container container;
    
    setUp(() {
      container = Container();
      registerServices(container);
    });
    
    test('should inject method dependencies', () {
      var controller = UserController();
      
      // Call with only required parameters
      container.call(
        controller,
        'newProcess',
        {'user': testUser}
      );
      
      // Verify injection worked
      verify(() => mockValidator.validate(any)).called(1);
      verify(() => mockLogger.log(any)).called(1);
    });
  });
}
```

## Best Practices

1. **Update Bindings Consistently**
```dart
// Good: Consistent new style
container.bind<Service>((c) => ServiceImpl());
container.singleton<Logger>((c) => FileLogger());

// Bad: Mixed styles
container.bind<Service>(ServiceImpl());  // Old style
container.singleton<Logger>((c) => FileLogger());  // New style
```

2. **Use Contextual Bindings Appropriately**
```dart
// Good: Clear context and purpose
container.when(UserController)
        .needs<Storage>()
        .give((c) => UserStorage());

// Bad: Unclear or overly broad context
container.when(Object)
        .needs<Storage>()
        .give((c) => GenericStorage());
```

3. **Organize Tagged Services**
```dart
// Good: Logical grouping
container.tag([
  PerformanceReport,
  SystemReport
], 'system-reports');

container.tag([
  UserReport,
  ActivityReport
], 'user-reports');

// Bad: Mixed concerns
container.tag([
  PerformanceReport,
  UserReport,
  Logger,
  Storage
], 'services');
```

## Common Issues and Solutions

1. **Binding Resolution Errors**
```dart
// Problem: Missing binding
var service = container.make<Service>();  // Throws error

// Solution: Register binding first
container.bind<Service>((c) => ServiceImpl());
var service = container.make<Service>();  // Works
```

2. **Contextual Binding Conflicts**
```dart
// Problem: Multiple contexts
container.when(Controller)
        .needs<Service>()
        .give((c) => ServiceA());
        
container.when(Controller)  // Conflict!
        .needs<Service>()
        .give((c) => ServiceB());

// Solution: Use specific contexts
container.when(UserController)
        .needs<Service>()
        .give((c) => ServiceA());
        
container.when(AdminController)
        .needs<Service>()
        .give((c) => ServiceB());
```

3. **Method Injection Failures**
```dart
// Problem: Unresolvable parameter
void process(
  CustomType param  // Not registered with container
) { }

// Solution: Register or provide parameter
container.bind<CustomType>((c) => CustomType());
// or
container.call(instance, 'process', {
  'param': customInstance
});
```

## Next Steps

1. Audit existing container usage
2. Plan migration phases
3. Update bindings
4. Add new features
5. Update tests
6. Document changes

Would you like me to create detailed specifications for any of these next steps?
