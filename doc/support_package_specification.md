# Support Package Specification

## Overview

The Support package provides fundamental utilities, helper functions, and common abstractions used throughout the framework. It aims to match Laravel's Support package functionality while leveraging Dart's strengths.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Contracts Package Specification](contracts_package_specification.md) for support contracts

## Core Features

### 1. Collections

```dart
/// Provides Laravel-like collection operations
class Collection<T> {
  final List<T> _items;
  
  Collection(this._items);
  
  /// Creates a collection from an iterable
  factory Collection.from(Iterable<T> items) {
    return Collection(items.toList());
  }
  
  /// Maps items while maintaining collection type
  Collection<R> map<R>(R Function(T) callback) {
    return Collection(_items.map(callback).toList());
  }
  
  /// Filters items
  Collection<T> where(bool Function(T) test) {
    return Collection(_items.where(test).toList());
  }
  
  /// Reduces collection to single value
  R reduce<R>(R Function(R, T) callback, R initial) {
    return _items.fold(initial, callback);
  }
  
  /// Groups items by key
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    return _items.fold({}, (map, item) {
      var key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
      return map;
    });
  }
}
```

### 2. String Manipulation

```dart
/// Provides Laravel-like string manipulation
extension StringHelpers on String {
  /// Converts string to camelCase
  String camelCase() {
    var words = split(RegExp(r'[\s_-]+'));
    return words.first + 
           words.skip(1)
                .map((w) => w[0].toUpperCase() + w.substring(1))
                .join();
  }
  
  /// Converts string to snake_case
  String snakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m[0]!.toLowerCase()}'
    ).replaceAll(RegExp(r'^_'), '');
  }
  
  /// Converts string to kebab-case
  String kebabCase() {
    return snakeCase().replaceAll('_', '-');
  }
  
  /// Converts string to StudlyCase
  String studlyCase() {
    return split(RegExp(r'[\s_-]+'))
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join();
  }
}
```

### 3. Array/List Helpers

```dart
/// Provides Laravel-like array manipulation
extension ArrayHelpers<T> on List<T> {
  /// Gets first item matching predicate
  T? firstWhere(bool Function(T) test, {T? orElse()}) {
    try {
      return super.firstWhere(test);
    } catch (e) {
      return orElse?.call();
    }
  }
  
  /// Plucks single field from list of maps
  List<V> pluck<V>(String key) {
    return map((item) => 
      (item as Map<String, dynamic>)[key] as V
    ).toList();
  }
  
  /// Groups items by key
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    return fold({}, (map, item) {
      var key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
      return map;
    });
  }
}
```

### 4. Service Provider Support

```dart
/// Base class for service providers
abstract class ServiceProvider {
  /// The container instance
  late final Container container;
  
  /// Register bindings with the container
  void register();
  
  /// Bootstrap any application services
  void boot() {}
  
  /// Determines if provider is deferred
  bool get isDeferred => false;
  
  /// Gets services provided
  List<Type> get provides => [];
}

/// Marks a provider as deferred
abstract class DeferredServiceProvider extends ServiceProvider {
  @override
  bool get isDeferred => true;
  
  /// Gets events that trigger loading
  List<String> get when => [];
}
```

### 5. Fluent Interface

```dart
/// Provides fluent interface building
class Fluent {
  final Map<String, dynamic> _attributes;
  
  Fluent([Map<String, dynamic>? attributes]) 
      : _attributes = attributes ?? {};
      
  /// Gets attribute value
  T? get<T>(String key) => _attributes[key] as T?;
  
  /// Sets attribute value
  Fluent set(String key, dynamic value) {
    _attributes[key] = value;
    return this;
  }
  
  /// Gets all attributes
  Map<String, dynamic> toMap() => Map.from(_attributes);
}
```

### 6. Optional Type

```dart
/// Provides Laravel-like Optional type
class Optional<T> {
  final T? _value;
  
  const Optional(this._value);
  
  /// Creates Optional from nullable value
  factory Optional.of(T? value) => Optional(value);
  
  /// Gets value or default
  T get(T defaultValue) => _value ?? defaultValue;
  
  /// Maps value if present
  Optional<R> map<R>(R Function(T) mapper) {
    return Optional(_value == null ? null : mapper(_value!));
  }
  
  /// Returns true if value is present
  bool get isPresent => _value != null;
}
```

### 7. High Order Message Proxies

```dart
/// Provides Laravel-like high order messaging
class HigherOrderProxy<T> {
  final T _target;
  
  HigherOrderProxy(this._target);
  
  /// Invokes method on target
  R call<R>(String method, [List<dynamic>? args]) {
    return Function.apply(
      _target.runtimeType.getMethod(method),
      args ?? []
    ) as R;
  }
}
```

## Integration with Container

```dart
/// Register support services
class SupportServiceProvider extends ServiceProvider {
  @override
  void register() {
    // Register collection factory
    container.bind<CollectionFactory>((c) => CollectionFactory());
    
    // Register string helpers
    container.bind<StringHelpers>((c) => StringHelpers());
    
    // Register array helpers
    container.bind<ArrayHelpers>((c) => ArrayHelpers());
  }
}
```

## Usage Examples

### Collections
```dart
// Create collection
var collection = Collection([1, 2, 3, 4, 5]);

// Chain operations
var result = collection
    .where((n) => n.isEven)
    .map((n) => n * 2)
    .reduce((sum, n) => sum + n, 0);

// Group items
var users = Collection([
  User('John', 'Admin'),
  User('Jane', 'User'),
  User('Bob', 'Admin')
]);

var byRole = users.groupBy((u) => u.role);
```

### String Helpers
```dart
// Convert cases
'user_name'.camelCase();      // userName
'userName'.snakeCase();       // user_name
'user name'.studlyCase();     // UserName
'UserName'.kebabCase();       // user-name

// Other operations
'hello'.padLeft(10);          // '     hello'
'HELLO'.toLowerCase();        // 'hello'
'  text  '.trim();           // 'text'
```

### Service Providers
```dart
class UserServiceProvider extends ServiceProvider {
  @override
  void register() {
    container.bind<UserRepository>((c) => UserRepositoryImpl());
  }
  
  @override
  void boot() {
    var repo = container.make<UserRepository>();
    repo.initialize();
  }
}

class CacheServiceProvider extends DeferredServiceProvider {
  @override
  List<String> get when => ['cache.needed'];
  
  @override
  List<Type> get provides => [CacheManager];
  
  @override
  void register() {
    container.bind<CacheManager>((c) => CacheManagerImpl());
  }
}
```

## Testing

```dart
void main() {
  group('Collection Tests', () {
    test('should map values', () {
      var collection = Collection([1, 2, 3]);
      var result = collection.map((n) => n * 2);
      expect(result.toList(), equals([2, 4, 6]));
    });
    
    test('should filter values', () {
      var collection = Collection([1, 2, 3, 4]);
      var result = collection.where((n) => n.isEven);
      expect(result.toList(), equals([2, 4]));
    });
  });
  
  group('String Helper Tests', () {
    test('should convert to camelCase', () {
      expect('user_name'.camelCase(), equals('userName'));
      expect('first name'.camelCase(), equals('firstName'));
    });
    
    test('should convert to snakeCase', () {
      expect('userName'.snakeCase(), equals('user_name'));
      expect('FirstName'.snakeCase(), equals('first_name'));
    });
  });
}
```

## Performance Considerations

1. **Collection Operations**
```dart
// Use lazy evaluation when possible
collection
    .where((n) => n.isEven)  // Lazy
    .map((n) => n * 2)       // Lazy
    .toList();               // Eager
```

2. **String Manipulations**
```dart
// Cache regex patterns
final _camelCasePattern = RegExp(r'[\s_-]+');
final _snakeCasePattern = RegExp(r'[A-Z]');

// Use StringBuffer for concatenation
final buffer = StringBuffer();
for (var word in words) {
  buffer.write(word);
}
```

3. **Service Provider Loading**
```dart
// Defer provider loading when possible
class HeavyServiceProvider extends DeferredServiceProvider {
  @override
  List<String> get when => ['heavy.needed'];
}
```

## Next Steps

1. Implement core features
2. Add comprehensive tests
3. Create integration examples
4. Add performance benchmarks

Would you like me to continue with documentation for the Pipeline or Contracts package?

## Development Guidelines

### 1. Getting Started
Before implementing support features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Understand [Contracts Package Specification](contracts_package_specification.md)

### 2. Implementation Process
For each support feature:
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
When implementing support features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)
5. Implement all contracts from [Contracts Package Specification](contracts_package_specification.md)

### 5. Performance Guidelines
Support utilities must:
1. Handle large collections efficiently
2. Optimize string operations
3. Minimize memory allocations
4. Support async operations where appropriate
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Support tests must:
1. Cover all utility functions
2. Test edge cases
3. Verify error handling
4. Check performance characteristics
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Support documentation must:
1. Explain utility patterns
2. Show usage examples
3. Cover error handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
