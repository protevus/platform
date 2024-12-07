# Container Interface Compatibility Report

## Interface Alignment Required

### 1. Parameter Types and Signatures

```dart
// Current Interface
abstract class Container implements ContainerInterface {
  T make<T>(String abstract, {Map<String, dynamic>? parameters});
  
  dynamic call(
    dynamic callback, {
    Map<String, dynamic>? parameters,
    String? defaultMethod,
  });
}

// Should Be
abstract class Container implements ContainerInterface {
  T make<T>(String abstract, [List<dynamic> parameters = const []]);
  
  dynamic call(
    dynamic callback, [
    List<dynamic> parameters = const [],
    String? defaultMethod,
  ]);
}
```

### 2. Callback Signatures

```dart
// Current - Too Specific
abstract class Container {
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
}

// Should Be - More Flexible
abstract class Container {
  void beforeResolving(dynamic abstract, [Function? callback]);
  void resolving(dynamic abstract, [Function? callback]);
  void afterResolving(dynamic abstract, [Function? callback]);
}
```

### 3. Missing Methods

```dart
// Need to Add
abstract class Container {
  /// An alias function name for make().
  T makeWith<T>(String abstract, List<dynamic> parameters);
}
```

### 4. Tag Parameters

```dart
// Current
abstract class Container {
  void tag(dynamic abstracts, List<String> tags);
}

// Should Be - Match Laravel's Variadic Style
abstract class Container {
  void tag(dynamic abstracts, String tag, [List<String> additionalTags = const []]);
}
```

## Required Changes

### 1. Update Method Signatures

```dart
abstract class Container implements ContainerInterface {
  // Change named parameters to positional
  T make<T>(String abstract, [List<dynamic> parameters = const []]);
  
  // Add makeWith alias
  T makeWith<T>(String abstract, List<dynamic> parameters);
  
  // Update call signature
  dynamic call(
    dynamic callback, [
    List<dynamic> parameters = const [],
    String? defaultMethod,
  ]);
  
  // Simplify callback signatures
  void beforeResolving(dynamic abstract, [Function? callback]);
  void resolving(dynamic abstract, [Function? callback]);
  void afterResolving(dynamic abstract, [Function? callback]);
  
  // Update tag signature
  void tag(dynamic abstracts, String tag, [List<String> additionalTags = const []]);
}
```

### 2. Update Exception Types

```dart
// Current
throw BindingResolutionException(message);

// Should Use DSR Exceptions
throw ContainerException(message);  // For general errors
throw NotFoundException(id);        // For missing bindings
```

## Impact Analysis

### Breaking Changes

1. Parameter Types:
- Map to List conversion
- Named to positional parameters
- New parameter handling

2. Method Signatures:
- Simplified callback types
- New tag method signature
- Added makeWith method

3. Exception Types:
- Using DSR exceptions
- More specific error cases
- Changed exception hierarchy

### Migration Path

1. Interface Updates:
```dart
// Step 1: Add new methods alongside existing
T makeWith<T>(String abstract, List<dynamic> parameters);

// Step 2: Mark old methods as deprecated
@Deprecated('Use positional parameters instead')
T make<T>(String abstract, {Map<String, dynamic>? parameters});

// Step 3: Replace with new signatures
T make<T>(String abstract, [List<dynamic> parameters = const []]);
```

2. Implementation Updates:
```dart
// Update internal parameter handling
List<dynamic> _convertParameters(dynamic parameters) {
  if (parameters is Map) {
    // Convert map to list for backward compatibility
    return parameters.values.toList();
  }
  return parameters as List<dynamic>;
}
```

## Next Steps

1. Update Container Interface:
- Change parameter types
- Add missing methods
- Update signatures

2. Update Implementation:
- Add parameter conversion
- Update exception handling
- Add makeWith implementation

3. Update Documentation:
- Document breaking changes
- Add migration examples
- Update API docs
