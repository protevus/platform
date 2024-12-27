# Platform Container

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/platform_container?include_prereleases)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![License](https://img.shields.io/github/license/dart-backend/angel)](https://github.com/dart-backend/angel/tree/master/packages/container/angel_container/LICENSE)

A powerful IoC (Inversion of Control) container for Dart, providing robust dependency injection with support for multiple reflection strategies. The container can be used with or without `dart:mirrors`, making it suitable for all Dart platforms including web and Flutter.

## Features

- **Constructor Injection**: Automatically resolves and injects constructor dependencies
- **Contextual Binding**: Define how abstractions should be resolved in different contexts
- **Multiple Registration Types**: Support for singletons, factories, and scoped instances
- **Attribute/Annotation Support**: Use annotations to configure injection behavior
- **Flexible Reflection**: Choose between mirrors-based, static, or custom reflection
- **Type-Safe**: Leverages Dart's type system for reliable dependency resolution
- **Tagging System**: Group and resolve related dependencies
- **Parameter Overrides**: Override specific dependencies during resolution
- **Method Binding**: Inject dependencies into method parameters

## Installation

```yaml
dependencies:
  platform_container: ^latest_version
```

## Basic Usage

### Constructor Injection

```dart
// Define some services
abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) => print(message);
}

class UserService {
  final Logger logger;
  
  // Constructor injection - container will automatically inject Logger
  UserService(this.logger);
  
  void createUser(String name) {
    logger.log('Creating user: $name');
  }
}

// Setup the container
var container = Container(MirrorsReflector());
container.bind(Logger).to(ConsoleLogger);

// Resolve with automatic dependency injection
var userService = container.make<UserService>();
```

### Singleton Registration

```dart
// Register a singleton
container.registerSingleton<Logger>(ConsoleLogger());

// Or register a lazy singleton
container.registerLazySingleton<Logger>((container) => ConsoleLogger());
```

### Factory Registration

```dart
// Register a factory
container.registerFactory<Logger>((container) => ConsoleLogger());

// Or use the shorter syntax
container[Logger] = (container) => ConsoleLogger();
```

### Contextual Binding

```dart
// Bind different implementations based on context
container.when(UserService).needs(Logger).give(ConsoleLogger);
container.when(AdminService).needs(Logger).give(FileLogger);
```

### Attribute/Annotation Based Injection

```dart
@injectable
class UserRepository {
  @inject
  final Database db;
  
  UserRepository(this.db);
}
```

### Scoped Instances

```dart
// Register a scoped instance
container.scoped<RequestContext>((c) => RequestContext());

// Clear scoped instances
container.clearScoped();
```

### Tagged Dependencies

```dart
// Tag related services
container.tag([UserService, OrderService], 'business-logic');

// Resolve all tagged services
var services = container.tagged('business-logic');
```

## Reflection Strategies

### Mirrors Reflection (Full Runtime Reflection)

```dart
import 'package:platform_container/mirrors.dart';

var container = Container(MirrorsReflector());
```

### Static Reflection (AOT-Friendly)

```dart
import 'package:platform_container/static.dart';

var container = Container(StaticReflector());
```

### Empty Reflection (Minimal)

```dart
import 'package:platform_container/empty.dart';

var container = Container(EmptyReflector());
```

## Advanced Features

### Parameter Overrides

```dart
// Override specific parameters during resolution
var instance = container.makeWith<Service>({
  'config': CustomConfig(),
  'timeout': Duration(seconds: 30),
});
```

### Method Binding

```dart
// Bind a method with injected parameters
container.bindMethod('processUser', (Logger logger, User user) {
  logger.log('Processing user: ${user.name}');
});

// Call the method
container.callMethod('processUser', [user]);
```

### Child Containers

```dart
// Create a child container with its own bindings
var child = container.createChild();
child.bind(Logger).to(SpecialLogger);
```

## Web Framework Integration

The container is used as the core DI system in the Protevus web framework:

```dart
import 'package:platform_container/mirrors.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';

@Expose('/api')
class ApiController extends Controller {
    final UserService userService;
    
    // Constructor injection works automatically
    ApiController(this.userService);
    
    @Expose('/users')
    Future<List<User>> getUsers() async {
        return userService.getAllUsers();
    }
}

void main() async {
    var app = Protevus(reflector: MirrorsReflector());
    
    // Register your services
    app.container.registerSingleton<UserService>(UserService());
    
    // Mount the controller
    await app.mountController<ApiController>();
    
    var http = PlatformHttp(app);
    var server = await http.startServer('localhost', 3000);
    print('Server listening at ${http.uri}');
}
```

## Contributing

Contributions are welcome! Please read our [contributing guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
