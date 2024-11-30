# Dart Mirrors vs Platform Reflection Comparison

## Core Features Comparison

| Feature | dart:mirrors | Platform Reflection | Notes |
|---------|-------------|-------------------|--------|
| **Library Reflection** |
| Top-level functions | ✅ Full | ✅ Full | Complete parity |
| Top-level variables | ✅ Full | ✅ Full | Complete parity |
| Library dependencies | ✅ Full | ✅ Full | Complete parity |
| URI resolution | ✅ Full | ✅ Full | Complete parity |

| Feature | dart:mirrors | Platform Reflection | Notes |
|---------|-------------|-------------------|--------|
| **Isolate Support** |
| Current isolate | ✅ Full | ✅ Full | Complete parity |
| Other isolates | ✅ Full | ✅ Full | Complete parity |
| Isolate control | ✅ Full | ✅ Full | Pause/Resume/Kill |
| Error handling | ✅ Full | ✅ Full | Error/Exit listeners |

| Feature | dart:mirrors | Platform Reflection | Notes |
|---------|-------------|-------------------|--------|
| **Type System** |
| Special types | ✅ Full | ✅ Full | void/dynamic/never |
| Type relationships | ✅ Full | ✅ Full | Complete type checking |
| Generic types | ✅ Full | ⚠️ Limited | Basic generic support |
| Type parameters | ✅ Full | ⚠️ Limited | Basic parameter support |

| Feature | dart:mirrors | Platform Reflection | Notes |
|---------|-------------|-------------------|--------|
| **Metadata System** |
| Class metadata | ✅ Full | ✅ Full | Complete parity |
| Method metadata | ✅ Full | ✅ Full | Complete parity |
| Property metadata | ✅ Full | ✅ Full | Complete parity |
| Parameter metadata | ✅ Full | ✅ Full | Complete parity |
| Custom attributes | ✅ Full | ✅ Full | Complete parity |

## Implementation Differences

### Registration System

```dart
// dart:mirrors
// No registration needed
@reflectable
class MyClass {}

// Platform Reflection
@reflectable
class MyClass {}

// Requires explicit registration
Reflector.register(MyClass);
Reflector.registerProperty(MyClass, 'prop', String);
Reflector.registerMethod(MyClass, 'method', [int]);
```

### Library Access

```dart
// dart:mirrors
final lib = MirrorSystem.findLibrary('my_lib');

// Platform Reflection
final lib = LibraryMirrorImpl.withDeclarations(
  name: 'my_lib',
  uri: Uri.parse('package:my_package/my_lib.dart'),
);
```

### Isolate Handling

```dart
// dart:mirrors
final mirror = reflect(isolate);
await mirror.invoke(#method, []);

// Platform Reflection
final mirror = IsolateMirrorImpl.other(isolate, 'name', lib);
mirror.addErrorListener((error, stack) {
  // Handle error
});
```

### Type System

```dart
// dart:mirrors
final type = reflectType(MyClass);
final isSubtype = type.isSubtypeOf(otherType);

// Platform Reflection
final type = TypeMetadata(
  type: MyClass,
  name: 'MyClass',
  // ...
);
final isSubtype = type.supertype == otherType;
```

## Performance Characteristics

| Aspect | dart:mirrors | Platform Reflection | Winner |
|--------|-------------|-------------------|---------|
| Startup time | ❌ Slower | ✅ Faster | Platform Reflection |
| Runtime performance | ❌ Slower | ✅ Faster | Platform Reflection |
| Memory usage | ❌ Higher | ✅ Lower | Platform Reflection |
| Tree shaking | ❌ Poor | ✅ Good | Platform Reflection |

## Platform Support

| Platform | dart:mirrors | Platform Reflection | Winner |
|----------|-------------|-------------------|---------|
| VM | ✅ Yes | ✅ Yes | Tie |
| Web | ❌ No | ✅ Yes | Platform Reflection |
| Flutter | ❌ No | ✅ Yes | Platform Reflection |
| AOT | ❌ No | ✅ Yes | Platform Reflection |

## Use Cases

| Use Case | dart:mirrors | Platform Reflection | Better Choice |
|----------|-------------|-------------------|---------------|
| Dependency injection | ✅ Simpler | ⚠️ More setup | dart:mirrors |
| Serialization | ✅ Simpler | ⚠️ More setup | dart:mirrors |
| Testing/Mocking | ✅ More flexible | ✅ More controlled | Depends on needs |
| Production apps | ❌ Limited platforms | ✅ All platforms | Platform Reflection |

## Migration Path

### From dart:mirrors

1. Add registration:
```dart
// Before
@reflectable
class MyClass {}

// After
@reflectable
class MyClass {}

void register() {
  Reflector.register(MyClass);
  // Register members...
}
```

2. Update reflection calls:
```dart
// Before
final mirror = reflect(instance);
final value = mirror.getField(#prop);

// After
final mirror = reflector.reflect(instance);
final value = mirror.getField(const Symbol('prop'));
```

3. Handle libraries:
```dart
// Before
final lib = MirrorSystem.findLibrary('my_lib');

// After
final lib = LibraryMirrorImpl.withDeclarations(
  name: 'my_lib',
  uri: uri,
);
```

## Trade-offs

### Advantages of Platform Reflection
1. Works everywhere
2. Better performance
3. Smaller code size
4. Better tree shaking
5. Full isolate support
6. Production-ready

### Advantages of dart:mirrors
1. No registration needed
2. Simpler API
3. More dynamic capabilities
4. Better for development tools
5. More flexible

## Conclusion

Platform Reflection offers a more production-ready alternative to dart:mirrors with:
- Full cross-platform support
- Better performance characteristics
- More controlled reflection surface
- Full isolate support
- Production-ready features

The main trade-off is the need for explicit registration, but this brings benefits in terms of performance, code size, and tree shaking.

Choose Platform Reflection when:
- You need cross-platform support
- Performance is critical
- Code size matters
- You want production-ready reflection

Choose dart:mirrors when:
- You're only targeting the VM
- Development time is critical
- You need maximum flexibility
- You're building development tools
