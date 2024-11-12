# Core Package Specification

## Overview

The Core package provides the foundation and entry point for our framework. It manages the application lifecycle, bootstraps services, handles HTTP requests, and coordinates all other framework packages.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Container Package Specification](container_package_specification.md) for dependency injection
> - See [Events Package Specification](events_package_specification.md) for application events

## Core Features

### 1. Application

```dart
/// Core application class
class Application {
  /// Container instance
  final Container _container;
  
  /// Service providers
  final List<ServiceProvider> _providers = [];
  
  /// Booted flag
  bool _booted = false;
  
  /// Environment
  late final String environment;
  
  /// Base path
  late final String basePath;
  
  Application(this._container) {
    _container.instance<Application>(this);
    _registerBaseBindings();
    _registerCoreProviders();
  }
  
  /// Registers base bindings
  void _registerBaseBindings() {
    _container.instance<Container>(_container);
    _container.instance<String>('base_path', basePath);
    _container.instance<String>('env', environment);
  }
  
  /// Registers core providers
  void _registerCoreProviders() {
    register(EventServiceProvider());
    register(LogServiceProvider());
    register(RoutingServiceProvider());
    register(ConfigServiceProvider());
  }
  
  /// Registers a service provider
  void register(ServiceProvider provider) {
    provider.app = this;
    provider.register();
    _providers.add(provider);
    
    if (_booted) {
      _bootProvider(provider);
    }
  }
  
  /// Boots the application
  Future<void> boot() async {
    if (_booted) return;
    
    for (var provider in _providers) {
      await _bootProvider(provider);
    }
    
    _booted = true;
  }
  
  /// Boots a provider
  Future<void> _bootProvider(ServiceProvider provider) async {
    await provider.callBootingCallbacks();
    await provider.boot();
    await provider.callBootedCallbacks();
  }
  
  /// Handles HTTP request
  Future<Response> handle(Request request) async {
    try {
      return await _pipeline.handle(request);
    } catch (e) {
      return _handleError(e, request);
    }
  }
  
  /// Gets container instance
  Container get container => _container;
  
  /// Makes instance from container
  T make<T>([dynamic parameters]) {
    return _container.make<T>(parameters);
  }
  
  /// Gets environment
  bool environment(String env) {
    return this.environment == env;
  }
  
  /// Determines if application is in production
  bool get isProduction => environment == 'production';
  
  /// Determines if application is in development
  bool get isDevelopment => environment == 'development';
  
  /// Determines if application is in testing
  bool get isTesting => environment == 'testing';
  
  /// Gets base path
  String path([String? path]) {
    return [basePath, path].where((p) => p != null).join('/');
  }
}
```

### 2. Service Providers

```dart
/// Base service provider
abstract class ServiceProvider {
  /// Application instance
  late Application app;
  
  /// Container instance
  Container get container => app.container;
  
  /// Booting callbacks
  final List<Function> _bootingCallbacks = [];
  
  /// Booted callbacks
  final List<Function> _bootedCallbacks = [];
  
  /// Registers services
  void register();
  
  /// Boots services
  Future<void> boot() async {}
  
  /// Registers booting callback
  void booting(Function callback) {
    _bootingCallbacks.add(callback);
  }
  
  /// Registers booted callback
  void booted(Function callback) {
    _bootedCallbacks.add(callback);
  }
  
  /// Calls booting callbacks
  Future<void> callBootingCallbacks() async {
    for (var callback in _bootingCallbacks) {
      await callback(app);
    }
  }
  
  /// Calls booted callbacks
  Future<void> callBootedCallbacks() async {
    for (var callback in _bootedCallbacks) {
      await callback(app);
    }
  }
}

/// Event service provider
class EventServiceProvider extends ServiceProvider {
  @override
  void register() {
    container.singleton<EventDispatcherContract>((c) =>
      EventDispatcher(c)
    );
  }
}

/// Routing service provider
class RoutingServiceProvider extends ServiceProvider {
  @override
  void register() {
    container.singleton<RouterContract>((c) =>
      Router(c)
    );
  }
  
  @override
  Future<void> boot() async {
    var router = container.make<RouterContract>();
    await loadRoutes(router);
  }
}
```

### 3. HTTP Kernel

```dart
/// HTTP kernel
class HttpKernel {
  /// Application instance
  final Application _app;
  
  /// Global middleware
  final List<dynamic> middleware = [
    CheckForMaintenanceMode::class,
    ValidatePostSize::class,
    TrimStrings::class,
    ConvertEmptyStringsToNull::class
  ];
  
  /// Route middleware groups
  final Map<String, List<dynamic>> middlewareGroups = {
    'web': [
      EncryptCookies::class,
      AddQueuedCookiesToResponse::class,
      StartSession::class,
      ShareErrorsFromSession::class,
      VerifyCsrfToken::class,
      SubstituteBindings::class
    ],
    
    'api': [
      'throttle:60,1',
      SubstituteBindings::class
    ]
  };
  
  /// Route middleware aliases
  final Map<String, dynamic> routeMiddleware = {
    'auth': Authenticate::class,
    'auth.basic': AuthenticateWithBasicAuth::class,
    'bindings': SubstituteBindings::class,
    'cache.headers': SetCacheHeaders::class,
    'can': Authorize::class,
    'guest': RedirectIfAuthenticated::class,
    'signed': ValidateSignature::class,
    'throttle': ThrottleRequests::class,
    'verified': EnsureEmailIsVerified::class,
  };
  
  HttpKernel(this._app);
  
  /// Handles HTTP request
  Future<Response> handle(Request request) async {
    try {
      request = await _handleGlobalMiddleware(request);
      return await _app.handle(request);
    } catch (e) {
      return _handleError(e, request);
    }
  }
  
  /// Handles global middleware
  Future<Request> _handleGlobalMiddleware(Request request) async {
    var pipeline = _app.make<Pipeline>();
    
    return await pipeline
      .send(request)
      .through(middleware)
      .then((request) => request);
  }
  
  /// Handles error
  Response _handleError(Object error, Request request) {
    var handler = _app.make<ExceptionHandler>();
    return handler.render(error, request);
  }
}
```

### 4. Console Kernel

```dart
/// Console kernel
class ConsoleKernel {
  /// Application instance
  final Application _app;
  
  /// Console commands
  final List<dynamic> commands = [
    // Framework Commands
    KeyGenerateCommand::class,
    ConfigCacheCommand::class,
    ConfigClearCommand::class,
    RouteListCommand::class,
    RouteCacheCommand::class,
    RouteClearCommand::class,
    
    // App Commands
    SendEmailsCommand::class,
    PruneOldRecordsCommand::class
  ];
  
  /// Command schedules
  final Map<String, String> schedules = {
    'emails:send': '0 * * * *',
    'records:prune': '0 0 * * *'
  };
  
  ConsoleKernel(this._app);
  
  /// Handles console command
  Future<int> handle(List<String> args) async {
    try {
      var status = await _runCommand(args);
      return status ?? 0;
    } catch (e) {
      _handleError(e);
      return 1;
    }
  }
  
  /// Runs console command
  Future<int?> _runCommand(List<String> args) async {
    var command = _resolveCommand(args);
    if (command == null) return null;
    
    return await command.run(args);
  }
  
  /// Resolves command from arguments
  Command? _resolveCommand(List<String> args) {
    if (args.isEmpty) return null;
    
    var name = args.first;
    var command = commands.firstWhere(
      (c) => c.name == name,
      orElse: () => null
    );
    
    if (command == null) return null;
    return _app.make<Command>(command);
  }
  
  /// Handles error
  void _handleError(Object error) {
    stderr.writeln(error);
  }
}
```

### 5. Exception Handler

```dart
/// Exception handler
class ExceptionHandler {
  /// Application instance
  final Application _app;
  
  /// Exception renderers
  final Map<Type, Function> _renderers = {
    ValidationException: _renderValidationException,
    AuthenticationException: _renderAuthenticationException,
    AuthorizationException: _renderAuthorizationException,
    NotFoundException: _renderNotFoundException,
    HttpException: _renderHttpException
  };
  
  ExceptionHandler(this._app);
  
  /// Renders exception to response
  Response render(Object error, Request request) {
    var renderer = _renderers[error.runtimeType];
    if (renderer != null) {
      return renderer(error, request);
    }
    
    return _renderGenericException(error, request);
  }
  
  /// Renders validation exception
  Response _renderValidationException(
    ValidationException e,
    Request request
  ) {
    if (request.wantsJson) {
      return Response.json({
        'message': 'The given data was invalid.',
        'errors': e.errors
      }, 422);
    }
    
    return Response.redirect()
      .back()
      .withErrors(e.errors)
      .withInput(request.all());
  }
  
  /// Renders generic exception
  Response _renderGenericException(Object e, Request request) {
    if (_app.isProduction) {
      return Response('Server Error', 500);
    }
    
    return Response(e.toString(), 500);
  }
}
```

## Integration Examples

### 1. Application Bootstrap
```dart
void main() async {
  var container = Container();
  var app = Application(container)
    ..environment = 'production'
    ..basePath = Directory.current.path;
    
  await app.boot();
  
  var server = HttpServer(app);
  await server.start();
}
```

### 2. Service Provider
```dart
class AppServiceProvider extends ServiceProvider {
  @override
  void register() {
    container.singleton<UserRepository>((c) =>
      DatabaseUserRepository(c.make<Database>())
    );
  }
  
  @override
  Future<void> boot() async {
    var config = container.make<ConfigContract>();
    TimeZone.setDefault(config.get('app.timezone'));
  }
}
```

### 3. HTTP Request Handling
```dart
class Server {
  final HttpKernel kernel;
  
  Future<void> handle(HttpRequest request) async {
    var protevusRequest = await Request.fromHttpRequest(request);
    var response = await kernel.handle(protevusRequest);
    await response.send(request.response);
  }
}
```

## Testing

```dart
void main() {
  group('Application', () {
    test('boots providers', () async {
      var app = Application(Container());
      var provider = TestProvider();
      
      app.register(provider);
      await app.boot();
      
      expect(provider.booted, isTrue);
    });
    
    test('handles requests', () async {
      var app = Application(Container());
      await app.boot();
      
      var request = Request('GET', '/');
      var response = await app.handle(request);
      
      expect(response.statusCode, equals(200));
    });
  });
  
  group('Service Provider', () {
    test('registers services', () async {
      var app = Application(Container());
      var provider = TestProvider();
      
      app.register(provider);
      
      expect(app.make<TestService>(), isNotNull);
    });
  });
}
```

## Next Steps

1. Implement core application
2. Add service providers
3. Add HTTP kernel
4. Add console kernel
5. Write tests
6. Add benchmarks

## Development Guidelines

### 1. Getting Started
Before implementing core features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Container Package Specification](container_package_specification.md)
6. Review [Events Package Specification](events_package_specification.md)

### 2. Implementation Process
For each core feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following framework patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Follow framework patterns
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Support dependency injection (see [Container Package Specification](container_package_specification.md))
5. Support event system (see [Events Package Specification](events_package_specification.md))

### 4. Integration Considerations
When implementing core features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Use framework patterns consistently
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)

### 5. Performance Guidelines
Core system must:
1. Boot efficiently
2. Handle requests quickly
3. Manage memory usage
4. Scale horizontally
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Core tests must:
1. Cover all core features
2. Test application lifecycle
3. Verify service providers
4. Check error handling
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Core documentation must:
1. Explain framework patterns
2. Show lifecycle examples
3. Cover error handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
