# Container Migration Plan

## Overview

Migrate from implementing `ContainerContract` to implementing the new `Container` interface, focusing on:
1. Laravel-compatible string-based dependency injection
2. Performance optimization (< 0.1ms per operation)
3. Service provider support
4. Level 0 (Core Foundation) package requirements

## Implementation Phases

### Phase 1: Core Interface Migration (Week 1)

1. String-Based Resolution System
```dart
class IlluminateContainer implements Container {
  final Map<String, _Binding> _bindings = {};
  final ResolutionCache _cache = ResolutionCache();

  @override
  T make<T>(String abstract, {Map<String, dynamic>? parameters}) {
    // Fast path: check cache first
    final cached = _cache.get<T>(abstract, parameters);
    if (cached != null) return cached;

    // Resolve and cache
    final instance = _resolve<T>(abstract, parameters);
    _cache.set(abstract, parameters, instance);
    return instance;
  }

  @override
  void bind(String abstract, dynamic concrete, {bool shared = false}) {
    _bindings[abstract] = _Binding(
      concrete: concrete,
      shared: shared,
    );
  }
}

class _Binding {
  final dynamic concrete;
  final bool shared;
  dynamic instance;

  _Binding({
    required this.concrete,
    required this.shared,
  });
}
```

2. Service Provider Support
```dart
abstract class ServiceProvider {
  final Container container;
  
  ServiceProvider(this.container);

  void register();
  void boot() {}
}

class IlluminateContainer implements Container {
  final List<ServiceProvider> _providers = [];
  bool _booted = false;

  void register(ServiceProvider provider) {
    _providers.add(provider);
    provider.register();
  }

  void boot() {
    if (_booted) return;
    for (var provider in _providers) {
      provider.boot();
    }
    _booted = true;
  }
}
```

### Phase 2: Advanced Features (Week 1-2)

1. Contextual Binding with Performance
```dart
class IlluminateContainer implements Container {
  final Map<String, Map<String, dynamic>> _contextualBindings = {};
  final ContextualBindingCache _contextCache = ContextualBindingCache();

  @override
  ContextualBindingBuilder when(dynamic concrete) {
    return _FastContextualBindingBuilder(
      container: this,
      concrete: _getAbstractName(concrete),
    );
  }

  @override
  void addContextualBinding(
    String concrete,
    String abstract,
    dynamic implementation,
  ) {
    _contextualBindings
      .putIfAbsent(concrete, () => {})
      [abstract] = implementation;
    
    // Clear relevant cache entries
    _contextCache.invalidate(concrete, abstract);
  }
}

class _FastContextualBindingBuilder implements ContextualBindingBuilder {
  final IlluminateContainer container;
  final String concrete;
  String? _needsAbstract;

  // Fast implementation avoiding reflection where possible
}
```

2. Optimized Tag System
```dart
class IlluminateContainer implements Container {
  final Map<String, Set<String>> _tags = {};
  final TagResolutionCache _tagCache = TagResolutionCache();

  @override
  void tag(dynamic abstracts, List<String> tags) {
    final abstractList = abstracts is List ? abstracts : [abstracts];
    for (var tag in tags) {
      final tagSet = _tags.putIfAbsent(tag, () => {});
      for (var abstract in abstractList) {
        tagSet.add(_getAbstractName(abstract));
      }
      // Invalidate tag cache
      _tagCache.invalidate(tag);
    }
  }

  @override
  Iterable<dynamic> tagged(String tag) {
    // Check cache first
    final cached = _tagCache.get(tag);
    if (cached != null) return cached;

    // Resolve and cache
    final results = _tags[tag]
        ?.map((abstract) => make(abstract))
        .toList() ?? [];
    
    _tagCache.set(tag, results);
    return results;
  }
}
```

### Phase 3: Performance Optimization (Week 2)

1. Resolution Cache System
```dart
class ResolutionCache {
  final Map<String, Map<String, dynamic>> _cache = {};
  final ExpirationPolicy _expiration;

  void set(String abstract, Map<String, dynamic>? parameters, dynamic value) {
    final key = _getCacheKey(abstract, parameters);
    _cache.putIfAbsent(abstract, () => {})[key] = value;
  }

  T? get<T>(String abstract, Map<String, dynamic>? parameters) {
    final key = _getCacheKey(abstract, parameters);
    return _cache[abstract]?[key] as T?;
  }
}
```

2. Binding Optimization
```dart
class IlluminateContainer implements Container {
  // Fast path for singleton resolution
  final Map<String, dynamic> _singletons = {};
  
  @override
  void singleton(String abstract, [dynamic concrete]) {
    if (_singletons.containsKey(abstract)) {
      return;
    }

    if (concrete == null) {
      concrete = abstract;
    }

    final instance = concrete is Type 
        ? _buildInstance(concrete)
        : (concrete is Function 
            ? concrete(this) 
            : concrete);

    _singletons[abstract] = instance;
  }
}
```

## Migration Path for Users

### 1. Update Service Registration
```dart
// Old
container.bind<Logger>((c) => FileLogger());

// New
container.bind('logger', (c) => FileLogger());

// Even better: Use service provider
class LoggingServiceProvider extends ServiceProvider {
  @override
  void register() {
    container.singleton('logger', FileLogger());
  }
}
```

### 2. Update Service Resolution
```dart
// Old
final logger = container.make<Logger>();

// New
final logger = container.make<Logger>('logger');

// With parameters
final logger = container.make<Logger>('logger', 
  parameters: {'path': 'logs/app.log'});
```

### 3. Update Contextual Bindings
```dart
// Old
container.when(UserController).needs<Logger>().give(FileLogger);

// New
container.when(UserController)
  .needs('logger')
  .give(FileLogger);
```

## Performance Targets

1. Resolution Performance:
- Singleton resolution: < 0.05ms
- Contextual binding: < 0.1ms
- Tagged resolution: < 0.15ms

2. Memory Usage:
- Base container: < 5MB
- Per-binding overhead: < 1KB
- Cache size: Configurable, default 10MB

3. Cache Hit Rates:
- Singleton cache: > 95%
- Resolution cache: > 80%
- Contextual cache: > 70%

## Testing Strategy

1. Unit Tests:
- Interface compliance
- Performance benchmarks
- Memory usage
- Cache behavior

2. Integration Tests:
- Service provider integration
- Cross-package compatibility
- Real-world usage patterns

3. Performance Tests:
- Resolution benchmarks
- Memory profiling
- Cache effectiveness

## Next Steps

1. Implementation:
- Start with core interface migration
- Add service provider support
- Implement caching system

2. Documentation:
- Update API documentation
- Create migration guide
- Document performance tips

3. Testing:
- Create benchmark suite
- Add performance tests
- Verify Laravel compatibility
