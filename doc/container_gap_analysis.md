# Container Package Gap Analysis

## Overview

This document analyzes the gaps between our Container package's actual implementation and our documentation, identifying areas that need implementation or documentation updates. It also outlines the migration strategy to achieve full Laravel compatibility.

> **Related Documentation**
> - See [Container Package Specification](container_package_specification.md) for current implementation
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for overall status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing requirements

## Implementation Status

> **Status Note**: This status aligns with our [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#implementation-status). See there for overall framework status.

### 1. Core Features

#### Implemented
```dart
✓ Basic dependency injection
✓ Service location
✓ Auto-wiring
✓ Parent/child containers
✓ Named singletons
✓ Lazy singleton registration
✓ Async dependency resolution
```

#### Partially Implemented
```dart
~ Contextual binding (basic structure)
~ Method injection (basic reflection)
~ Tagged bindings (basic tagging)
```

#### Not Implemented
```dart
- Advanced contextual binding features
  * Instance-based context
  * Multiple contexts
  * Context inheritance

- Advanced method injection features
  * Parameter validation
  * Optional parameters
  * Named parameters

- Advanced tagged binding features
  * Tag inheritance
  * Tag groups
  * Tag conditions
```

## Migration Strategy

> **Integration Note**: This migration strategy follows patterns from [Foundation Integration Guide](foundation_integration_guide.md). See there for detailed integration examples.

### Phase 1: Internal Restructuring (No Breaking Changes)

1. **Extract Binding Logic**
```dart
// Move from current implementation:
class Container {
  final Map<Type, Object> _bindings = {};
  void bind<T>(T instance) => _bindings[T] = instance;
}

// To new implementation:
class Container {
  final Map<Type, Binding> _bindings = {};
  
  void bind<T>(T Function(Container) concrete) {
    _bindings[T] = Binding(
      concrete: concrete,
      shared: false,
      implementedType: T
    );
  }
}
```

2. **Add Resolution Context**
```dart
class Container {
  T make<T>([dynamic context]) {
    var resolutionContext = ResolutionContext(
      resolvingType: T,
      context: context,
      container: this,
      resolutionStack: {}
    );
    
    return _resolve(T, resolutionContext);
  }
}
```

### Phase 2: Add New Features (Backward Compatible)

1. **Contextual Binding**
```dart
class Container {
  final Map<Type, Map<Type, Binding>> _contextualBindings = {};
  
  ContextualBindingBuilder when(Type concrete) {
    return ContextualBindingBuilder(this, concrete);
  }
}
```

2. **Method Injection**
```dart
class Container {
  dynamic call(
    Object instance,
    String methodName, [
    Map<String, dynamic>? parameters
  ]) {
    var method = reflector.reflectInstance(instance)
      .type
      .declarations[Symbol(methodName)];
      
    var resolvedParams = _resolveMethodParameters(
      method,
      parameters
    );
    
    return Function.apply(
      instance.runtimeType.getMethod(methodName),
      resolvedParams
    );
  }
}
```

3. **Tagged Bindings**
```dart
class Container {
  final Map<String, Set<Type>> _tags = {};
  
  void tag(List<Type> types, String tag) {
    _tags.putIfAbsent(tag, () => {}).addAll(types);
  }
  
  List<T> taggedAs<T>(String tag) {
    return _tags[tag]?.map((t) => make<T>(t)).toList() ?? [];
  }
}
```

### Phase 3: Performance Optimization

> **Performance Note**: These optimizations align with our [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks) performance targets.

1. **Add Resolution Cache**
```dart
class Container {
  final ResolutionCache _cache = ResolutionCache();
  
  T make<T>([dynamic context]) {
    var cached = _cache.get<T>(context);
    if (cached != null) return cached;
    
    var instance = _resolve<T>(T, context);
    _cache.cache(instance, context);
    return instance;
  }
}
```

2. **Add Reflection Cache**
```dart
class Container {
  final ReflectionCache _reflectionCache = ReflectionCache();
  
  dynamic call(Object instance, String methodName, [Map<String, dynamic>? parameters]) {
    var methodMirror = _reflectionCache.getMethod(
      instance.runtimeType,
      methodName
    ) ?? _cacheMethod(instance, methodName);
    
    return _invokeMethod(instance, methodMirror, parameters);
  }
}
```

## Backward Compatibility Requirements

> **Note**: These requirements ensure compatibility while following [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) guidelines.

1. **Maintain Existing APIs**
```dart
// These must continue to work:
container.make<T>();
container.makeAsync<T>();
container.has<T>();
container.hasNamed();
container.registerFactory<T>();
container.registerSingleton<T>();
container.registerNamedSingleton<T>();
container.registerLazySingleton<T>();
```

2. **Preserve Behavior**
```dart
// Parent/child resolution
var parent = Container(reflector);
var child = parent.createChild();
parent.registerSingleton<Service>(service);
var resolved = child.make<Service>();  // Must work

// Named singletons
container.registerNamedSingleton('key', service);
var found = container.findByName('key');  // Must work

// Async resolution
var future = container.makeAsync<Service>();  // Must work
```

## Implementation Priority

> **Priority Note**: These priorities align with our [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#implementation-priorities).

### 1. High Priority
- Complete contextual binding implementation
- Add parameter validation to method injection
- Implement tag inheritance

### 2. Medium Priority
- Add cache integration
- Improve error handling
- Add event system integration

### 3. Low Priority
- Add helper methods
- Add debugging tools
- Add performance monitoring

## Development Guidelines

### 1. Getting Started
Before implementing features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Container Package Specification](container_package_specification.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)

### 2. Implementation Process
For each feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

## Next Steps

Would you like me to:
1. Start implementing Phase 1 changes?
2. Create detailed specifications for Phase 2?
3. Design the caching system for Phase 3?
