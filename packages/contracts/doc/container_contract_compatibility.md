# Container Migration Plan - File Changes

## 1. packages/contracts/lib/src/container/container.dart

Current:
```dart
abstract class Container implements ContainerInterface {
  T make<T>(String abstract, {Map<String, dynamic>? parameters});
  
  dynamic call(
    dynamic callback, {
    Map<String, dynamic>? parameters,
    String? defaultMethod,
  });

  void beforeResolving(
    dynamic abstract, [
    void Function(Container container, String abstract)? callback,
  ]);
  
  void resolving(
    dynamic abstract, [
    void Function(dynamic instance, Container container)? callback,
  ]);
  
  void afterResolving(
    dynamic abstract, [
    void Function(dynamic instance, Container container)? callback,
  ]);

  void tag(dynamic abstracts, List<String> tags);
}
```

Changes Needed:
```dart
abstract class Container implements ContainerInterface {
  // 1. Update make signature
  T make<T>(String abstract, [List<dynamic> parameters = const []]);
  
  // 2. Add makeWith method
  T makeWith<T>(String abstract, List<dynamic> parameters);
  
  // 3. Update call signature
  dynamic call(
    dynamic callback, [
    List<dynamic> parameters = const [],
    String? defaultMethod,
  ]);
  
  // 4. Simplify callback signatures
  void beforeResolving(dynamic abstract, [Function? callback]);
  void resolving(dynamic abstract, [Function? callback]);
  void afterResolving(dynamic abstract, [Function? callback]);
  
  // 5. Update tag signature
  void tag(dynamic abstracts, String tag, [List<String> additionalTags = const []]);
}
```

## 2. packages/container/lib/src/container.dart

Current:
```dart
class Container implements ContainerBase {
  T make<T>(String abstract, {Map<String, dynamic>? parameters}) {
    // Current implementation
  }

  dynamic call(
    dynamic callback, {
    Map<String, dynamic>? parameters,
    String? defaultMethod,
  }) {
    // Current implementation
  }

  void tag(dynamic abstracts, List<String> tags) {
    // Current implementation
  }
}
```

Changes Needed:
```dart
class Container implements ContainerBase {
  // 1. Update make implementation
  T make<T>(String abstract, [List<dynamic> parameters = const []]) {
    try {
      // Implementation using list parameters
    } catch (e) {
      if (e is ContainerException || e is NotFoundException) {
        rethrow;
      }
      throw ContainerException('Failed to resolve $abstract: ${e.toString()}');
    }
  }

  // 2. Add makeWith implementation
  T makeWith<T>(String abstract, List<dynamic> parameters) {
    return make<T>(abstract, parameters);
  }

  // 3. Update call implementation
  dynamic call(
    dynamic callback, [
    List<dynamic> parameters = const [],
    String? defaultMethod,
  ]) {
    // Implementation using list parameters
  }

  // 4. Update tag implementation
  void tag(dynamic abstracts, String tag, [List<String> additionalTags = const []]) {
    final tags = [tag, ...additionalTags];
    final abstractList = abstracts is List ? abstracts : [abstracts];
    _tags.putIfAbsent(tag, () => []).addAll(abstractList);
  }

  // 5. Update exception handling
  void _throwIfNotFound(String id) {
    if (!has(id)) {
      throw NotFoundException(id);
    }
  }

  void _throwIfInvalid(String message) {
    throw ContainerException(message);
  }
}
```

## 3. packages/contracts/lib/src/container/contextual_binding_builder.dart

Current:
```dart
abstract class ContextualBindingBuilder {
  ContextualBindingBuilder needs<T>();
  void give(dynamic implementation);
}
```

Changes Needed:
```dart
abstract class ContextualBindingBuilder {
  ContextualBindingBuilder needs<T>();
  void give(dynamic implementation);
  
  // Add new methods
  void giveTagged(String tag);
  void giveConfig(String key, [dynamic defaultValue = null]);
}
```

## 4. packages/container/lib/src/contextual_binding_builder.dart

Current:
```dart
class _ContextualBindingBuilder implements ContextualBindingBuilder {
  // Current implementation
}
```

Changes Needed:
```dart
class _ContextualBindingBuilder implements ContextualBindingBuilder {
  // Keep existing implementation

  // Add new methods
  @override
  void giveTagged(String tag) {
    if (_needsType == null) {
      throw ContainerException('Must call needs() before giveTagged()');
    }
    final tagged = _container.tagged(tag);
    _container.addContextualBinding(_concrete, _needsType!, tagged);
  }

  @override
  void giveConfig(String key, [dynamic defaultValue = null]) {
    if (_needsType == null) {
      throw ContainerException('Must call needs() before giveConfig()');
    }
    // TODO: Implement config integration
    throw ContainerException('Config integration not implemented');
  }
}
```

## Migration Steps

1. Phase 1: Interface Updates
   - Update Container interface in contracts
   - Update ContextualBindingBuilder interface
   - Add new method definitions

2. Phase 2: Implementation Updates
   - Update Container implementation
   - Update parameter handling
   - Add new method implementations
   - Update exception handling

3. Phase 3: Tests
   - Update existing tests for new signatures
   - Add tests for new methods
   - Add tests for error cases

4. Phase 4: Documentation
   - Update API documentation
   - Add migration guide
   - Document breaking changes

## Breaking Changes Impact

1. Code Using Map Parameters:
```dart
// Old code
container.make<Service>(abstract, parameters: {'id': 1});

// New code
container.make<Service>(abstract, [1]);
```

2. Code Using Named Parameters:
```dart
// Old code
container.call(callback, parameters: {'id': 1});

// New code
container.call(callback, [1]);
```

3. Code Using Tag Lists:
```dart
// Old code
container.tag([ServiceA, ServiceB], ['tag1', 'tag2']);

// New code
container.tag([ServiceA, ServiceB], 'tag1', ['tag2']);
```

## Verification Steps

1. Run existing tests with old signatures
2. Update tests for new signatures
3. Add tests for new methods
4. Verify exception handling
5. Check backward compatibility
6. Update documentation

Would you like me to start with any particular file or phase?
