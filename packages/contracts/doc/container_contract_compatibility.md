# Container Contracts Compatibility Report

## 1. Container Interface: 95% Compatible

### Base Interface Alignment
```dart
// Current:
abstract class Container implements ContainerInterface {
  // Methods
}

// Correct - matches Laravel's approach of extending PSR-11 ContainerInterface
```

### Method Compatibility
```dart
// Needs alignment:
bind(String abstract, [dynamic concrete, bool shared = false])
make<T>(String abstract, [List<dynamic> parameters = const []])
call(dynamic callback, [List<dynamic> parameters = const [], String? defaultMethod])
```

## 2. ContextualBindingBuilder Interface: 50% Compatible

### Missing Methods
```dart
// Need to add:
void giveTagged(String tag)
void giveConfig(String key, [dynamic default])
```

## 3. Exception Contracts

### BindingResolutionException: Needs Alignment

Current:
```dart
class BindingResolutionException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;
}
```

Should be:
```dart
class BindingResolutionException implements Exception, ContainerExceptionInterface {
  final String message;
  
  // Optional - our additional features can stay
  final Object? originalError;
  final StackTrace? stackTrace;
}
```

### CircularDependencyException: Missing

Need to add:
```dart
class CircularDependencyException implements Exception, ContainerExceptionInterface {
  final String message;
  final List<Type> dependencyChain;

  const CircularDependencyException(this.message, this.dependencyChain);

  @override
  String toString() {
    return 'CircularDependencyException: $message\nDependency chain: ${dependencyChain.join(' -> ')}';
  }
}
```

## Required Changes

### 1. Update Exception Contracts

1. Update BindingResolutionException:
```dart
import 'package:psr_container/container_exception_interface.dart';

class BindingResolutionException implements Exception, ContainerExceptionInterface {
  // Existing implementation can stay
}
```

2. Add CircularDependencyException:
```dart
import 'package:psr_container/container_exception_interface.dart';

class CircularDependencyException implements Exception, ContainerExceptionInterface {
  final String message;
  final List<Type> dependencyChain;

  const CircularDependencyException(this.message, this.dependencyChain);
}
```

### 2. Update ContextualBindingBuilder

```dart
abstract class ContextualBindingBuilder {
  /// Define the abstract target that is being contextualized.
  ContextualBindingBuilder needs(dynamic abstract);

  /// Define the concrete implementation that should be used.
  void give(dynamic implementation);

  /// Define tagged services to be used as the implementation.
  void giveTagged(String tag);

  /// Specify the configuration item to bind as a primitive.
  void giveConfig(String key, [dynamic default]);
}
```

### 3. Update Container Method Signatures

```dart
abstract class Container implements ContainerInterface {
  // Update parameter types
  T make<T>(String abstract, [List<dynamic> parameters = const []]);
  
  // Update callback signatures
  void resolving(dynamic abstract, [Function? callback]);
  void beforeResolving(dynamic abstract, [Function? callback]);
  void afterResolving(dynamic abstract, [Function? callback]);
}
```

## Implementation Impact

### Breaking Changes

1. Exception Handling:
- Add PSR ContainerExceptionInterface
- Add CircularDependencyException
- Update exception catching code

2. ContextualBindingBuilder:
- Add new required methods
- Update implementations

3. Container:
- Update parameter types
- Update callback signatures

### Migration Path

1. Exception Updates:
```dart
// Step 1: Add PSR dependency
dependencies:
  psr_container: ^1.0.0

// Step 2: Update exceptions
class BindingResolutionException implements ContainerExceptionInterface {
  // Implementation
}

// Step 3: Add circular dependency detection
class Container {
  final List<Type> _resolutionStack = [];
  
  void _checkCircular(Type type) {
    if (_resolutionStack.contains(type)) {
      throw CircularDependencyException(
        'Circular dependency detected',
        List.from(_resolutionStack)..add(type),
      );
    }
    _resolutionStack.add(type);
  }
}
```

2. ContextualBindingBuilder Updates:
```dart
class ContextualBindingBuilderImpl implements ContextualBindingBuilder {
  // Implement new methods
  @override
  void giveTagged(String tag) {
    // Implementation
  }

  @override
  void giveConfig(String key, [dynamic default]) {
    // Implementation
  }
}
```

## Verification Checklist

### Exception Contracts
- [ ] Implement ContainerExceptionInterface
- [ ] Add CircularDependencyException
- [ ] Update exception handling code

### ContextualBindingBuilder
- [ ] Add giveTagged method
- [ ] Add giveConfig method
- [ ] Update implementations

### Container Interface
- [ ] Update parameter types
- [ ] Update callback signatures
- [ ] Add circular dependency detection

## Next Steps

1. Add PSR Container Dependency:
- Add to pubspec.yaml
- Import in contracts

2. Update Exceptions:
- Implement ContainerExceptionInterface
- Add CircularDependencyException
- Update exception handling

3. Enhance ContextualBindingBuilder:
- Add missing methods
- Implement tag support
- Add config integration

4. Update Documentation:
- Document new exceptions
- Update migration guide
- Add examples
