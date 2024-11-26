# Route Package Specification

## Overview

The Route package provides a robust routing system that matches Laravel's routing functionality. It supports route registration, middleware, parameter binding, and route groups while integrating with our Pipeline and Container packages.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Pipeline Package Specification](pipeline_package_specification.md) for middleware pipeline
> - See [Container Package Specification](container_package_specification.md) for dependency injection

## Core Features

### 1. Router

```dart
/// Core router implementation
class Router implements RouterContract {
  /// Container instance
  final Container _container;
  
  /// Route collection
  final RouteCollection _routes;
  
  /// Current route
  Route? _current;
  
  /// Global middleware
  final List<dynamic> _middleware = [];
  
  Router(this._container)
      : _routes = RouteCollection();
  
  /// Gets current route
  Route? get current => _current;
  
  /// Gets global middleware
  List<dynamic> get middleware => List.from(_middleware);
  
  /// Adds global middleware
  void pushMiddleware(dynamic middleware) {
    _middleware.add(middleware);
  }
  
  /// Registers GET route
  Route get(String uri, dynamic action) {
    return addRoute(['GET', 'HEAD'], uri, action);
  }
  
  /// Registers POST route
  Route post(String uri, dynamic action) {
    return addRoute(['POST'], uri, action);
  }
  
  /// Registers PUT route
  Route put(String uri, dynamic action) {
    return addRoute(['PUT'], uri, action);
  }
  
  /// Registers DELETE route
  Route delete(String uri, dynamic action) {
    return addRoute(['DELETE'], uri, action);
  }
  
  /// Registers PATCH route
  Route patch(String uri, dynamic action) {
    return addRoute(['PATCH'], uri, action);
  }
  
  /// Registers OPTIONS route
  Route options(String uri, dynamic action) {
    return addRoute(['OPTIONS'], uri, action);
  }
  
  /// Adds route to collection
  Route addRoute(List<String> methods, String uri, dynamic action) {
    var route = Route(methods, uri, action);
    _routes.add(route);
    return route;
  }
  
  /// Creates route group
  void group(Map<String, dynamic> attributes, Function callback) {
    var group = RouteGroup(attributes);
    
    _routes.pushGroup(group);
    callback();
    _routes.popGroup();
  }
  
  /// Matches request to route
  Route? match(Request request) {
    _current = _routes.match(request);
    return _current;
  }
  
  /// Dispatches request to route
  Future<Response> dispatch(Request request) async {
    var route = match(request);
    if (route == null) {
      throw RouteNotFoundException();
    }
    
    return await _runRoute(route, request);
  }
  
  /// Runs route through middleware
  Future<Response> _runRoute(Route route, Request request) async {
    var pipeline = _container.make<MiddlewarePipeline>();
    
    return await pipeline
      .send(request)
      .through([
        ..._middleware,
        ...route.gatherMiddleware()
      ])
      .then((request) => route.run(request));
  }
}
```

### 2. Route Collection

```dart
/// Route collection
class RouteCollection {
  /// Routes by method
  final Map<String, List<Route>> _routes = {};
  
  /// Route groups
  final List<RouteGroup> _groups = [];
  
  /// Adds route to collection
  void add(Route route) {
    for (var method in route.methods) {
      _routes.putIfAbsent(method, () => []).add(route);
    }
    
    if (_groups.isNotEmpty) {
      route.group = _groups.last;
    }
  }
  
  /// Pushes route group
  void pushGroup(RouteGroup group) {
    if (_groups.isNotEmpty) {
      group.parent = _groups.last;
    }
    _groups.add(group);
  }
  
  /// Pops route group
  void popGroup() {
    _groups.removeLast();
  }
  
  /// Matches request to route
  Route? match(Request request) {
    var routes = _routes[request.method] ?? [];
    
    for (var route in routes) {
      if (route.matches(request)) {
        return route;
      }
    }
    
    return null;
  }
}
```

### 3. Route

```dart
/// Route definition
class Route {
  /// HTTP methods
  final List<String> methods;
  
  /// URI pattern
  final String uri;
  
  /// Route action
  final dynamic action;
  
  /// Route group
  RouteGroup? group;
  
  /// Route middleware
  final List<dynamic> _middleware = [];
  
  /// Route parameters
  final Map<String, dynamic> _parameters = {};
  
  Route(this.methods, this.uri, this.action);
  
  /// Adds middleware
  Route middleware(List<dynamic> middleware) {
    _middleware.addAll(middleware);
    return this;
  }
  
  /// Gets route name
  String? get name => _parameters['as'];
  
  /// Sets route name
  Route name(String name) {
    _parameters['as'] = name;
    return this;
  }
  
  /// Gets route domain
  String? get domain => _parameters['domain'];
  
  /// Sets route domain
  Route domain(String domain) {
    _parameters['domain'] = domain;
    return this;
  }
  
  /// Gets route prefix
  String get prefix {
    var prefix = '';
    var group = this.group;
    
    while (group != null) {
      if (group.prefix != null) {
        prefix = '${group.prefix}/$prefix';
      }
      group = group.parent;
    }
    
    return prefix.isEmpty ? '' : prefix;
  }
  
  /// Gets full URI
  String get fullUri => '${prefix.isEmpty ? "" : "$prefix/"}$uri';
  
  /// Gathers middleware
  List<dynamic> gatherMiddleware() {
    var middleware = [..._middleware];
    var group = this.group;
    
    while (group != null) {
      middleware.addAll(group.middleware);
      group = group.parent;
    }
    
    return middleware;
  }
  
  /// Matches request
  bool matches(Request request) {
    return _matchesMethod(request.method) &&
           _matchesUri(request.uri) &&
           _matchesDomain(request.host);
  }
  
  /// Matches HTTP method
  bool _matchesMethod(String method) {
    return methods.contains(method);
  }
  
  /// Matches URI pattern
  bool _matchesUri(Uri uri) {
    var pattern = RegExp(_compilePattern());
    return pattern.hasMatch(uri.path);
  }
  
  /// Matches domain pattern
  bool _matchesDomain(String? host) {
    if (domain == null) return true;
    if (host == null) return false;
    
    var pattern = RegExp(_compileDomainPattern());
    return pattern.hasMatch(host);
  }
  
  /// Compiles URI pattern
  String _compilePattern() {
    return fullUri
      .replaceAll('/', '\\/')
      .replaceAllMapped(
        RegExp(r'{([^}]+)}'),
        (match) => '(?<${match[1]}>[^/]+)'
      );
  }
  
  /// Compiles domain pattern
  String _compileDomainPattern() {
    return domain!
      .replaceAll('.', '\\.')
      .replaceAllMapped(
        RegExp(r'{([^}]+)}'),
        (match) => '(?<${match[1]}>[^.]+)'
      );
  }
  
  /// Runs route action
  Future<Response> run(Request request) async {
    var action = _resolveAction();
    var parameters = _resolveParameters(request);
    
    if (action is Function) {
      return await Function.apply(action, parameters);
    }
    
    if (action is Controller) {
      return await action.callAction(
        action.runtimeType.toString(),
        parameters
      );
    }
    
    throw RouteActionNotFoundException();
  }
  
  /// Resolves route action
  dynamic _resolveAction() {
    if (action is String) {
      var parts = action.split('@');
      var controller = _container.make(parts[0]);
      controller.method = parts[1];
      return controller;
    }
    
    return action;
  }
  
  /// Resolves route parameters
  List<dynamic> _resolveParameters(Request request) {
    var pattern = RegExp(_compilePattern());
    var match = pattern.firstMatch(request.uri.path);
    
    if (match == null) return [];
    
    return match.groupNames.map((name) {
      return _resolveParameter(name, match.namedGroup(name)!);
    }).toList();
  }
  
  /// Resolves route parameter
  dynamic _resolveParameter(String name, String value) {
    if (_parameters.containsKey(name)) {
      return _parameters[name](value);
    }
    
    return value;
  }
}
```

### 4. Route Groups

```dart
/// Route group
class RouteGroup {
  /// Group attributes
  final Map<String, dynamic> attributes;
  
  /// Parent group
  RouteGroup? parent;
  
  RouteGroup(this.attributes);
  
  /// Gets group prefix
  String? get prefix => attributes['prefix'];
  
  /// Gets group middleware
  List<dynamic> get middleware => attributes['middleware'] ?? [];
  
  /// Gets group domain
  String? get domain => attributes['domain'];
  
  /// Gets group name prefix
  String? get namePrefix => attributes['as'];
  
  /// Gets merged attributes
  Map<String, dynamic> get mergedAttributes {
    var merged = Map.from(attributes);
    var parent = this.parent;
    
    while (parent != null) {
      for (var entry in parent.attributes.entries) {
        if (!merged.containsKey(entry.key)) {
          merged[entry.key] = entry.value;
        }
      }
      parent = parent.parent;
    }
    
    return merged;
  }
}
```

## Integration Examples

### 1. Basic Routing
```dart
// Register routes
router.get('/', HomeController);
router.post('/users', UsersController);
router.get('/users/{id}', (String id) {
  return User.find(id);
});

// Match and dispatch
var route = router.match(request);
var response = await router.dispatch(request);
```

### 2. Route Groups
```dart
router.group({
  'prefix': 'api',
  'middleware': ['auth'],
  'namespace': 'Api'
}, () {
  router.get('users', UsersController);
  router.get('posts', PostsController);
  
  router.group({
    'prefix': 'admin',
    'middleware': ['admin']
  }, () {
    router.get('stats', StatsController);
  });
});
```

### 3. Route Parameters
```dart
// Required parameters
router.get('users/{id}', (String id) {
  return User.find(id);
});

// Optional parameters
router.get('posts/{id?}', (String? id) {
  return id != null ? Post.find(id) : Post.all();
});

// Regular expression constraints
router.get('users/{id}', UsersController)
  .where('id', '[0-9]+');
```

## Testing

```dart
void main() {
  group('Router', () {
    test('matches routes', () {
      var router = Router(container);
      router.get('/users/{id}', UsersController);
      
      var request = Request('GET', '/users/1');
      var route = router.match(request);
      
      expect(route, isNotNull);
      expect(route!.action, equals(UsersController));
    });
    
    test('handles route groups', () {
      var router = Router(container);
      
      router.group({
        'prefix': 'api',
        'middleware': ['auth']
      }, () {
        router.get('users', UsersController);
      });
      
      var route = router.match(Request('GET', '/api/users'));
      expect(route, isNotNull);
      expect(route!.gatherMiddleware(), contains('auth'));
    });
  });
}
```

## Next Steps

1. Implement core routing
2. Add route groups
3. Add route parameters
4. Add middleware support
5. Write tests
6. Add benchmarks

## Development Guidelines

### 1. Getting Started
Before implementing routing features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Pipeline Package Specification](pipeline_package_specification.md)
6. Review [Container Package Specification](container_package_specification.md)

### 2. Implementation Process
For each routing feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Support middleware (see [Pipeline Package Specification](pipeline_package_specification.md))
5. Support dependency injection (see [Container Package Specification](container_package_specification.md))

### 4. Integration Considerations
When implementing routing features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)

### 5. Performance Guidelines
Routing system must:
1. Match routes efficiently
2. Handle complex patterns
3. Support caching
4. Scale with route count
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Route tests must:
1. Cover all route types
2. Test pattern matching
3. Verify middleware
4. Check parameter binding
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Route documentation must:
1. Explain routing patterns
2. Show group examples
3. Cover parameter binding
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
