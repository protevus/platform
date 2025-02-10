# Dart Mirrors vs Platform Reflection Comparison

This document compares our Platform Reflection library with Dart's built-in `dart:mirrors` package, highlighting key differences, trade-offs, and migration paths.

## Core Features Comparison

| Feature | dart:mirrors | Platform Reflection | Notes |
|---------|--------------|---------------------|-------|
| Class Reflection | ✅ Full | ✅ Full | Requires registration in Platform Reflection |
| Method Invocation | ✅ Full | ✅ Full | Complete parity |
| Property Access | ✅ Full | ✅ Full | Complete parity |
| Constructor Invocation | ✅ Full | ✅ Full | Requires registration in Platform Reflection |
| Type Information | ✅ Full | ✅ Full | Complete parity |
| Metadata | ✅ Full | ⚠️ Limited | Basic metadata support in Platform Reflection |
| Generic Types | ✅ Full | ⚠️ Limited | Basic generic support in Platform Reflection |
| AOT Compilation | ❌ No | ✅ Yes | Platform Reflection supports AOT compilation |

## Key Implementation Differences

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
Reflector.registerConstructor(MyClass, '', parameterTypes: []);
```

### Reflection Usage

```dart
// dart:mirrors
import 'dart:mirrors';

final instance = MyClass();
final mirror = reflect(instance);
final value = mirror.getField(#prop).reflectee;
mirror.invoke(#method, [42]);

// Platform Reflection
import 'package:illuminate_mirrors/mirrors.dart';

final reflector = RuntimeReflector.instance;
final instance = reflector.createInstance(MyClass, positionalArgs: []) as MyClass;
final mirror = reflector.reflect(instance);
final value = mirror.getField(const Symbol('prop')).reflectee;
mirror.invoke(const Symbol('method'), [42]);
```

## Performance Characteristics

| Aspect | dart:mirrors | Platform Reflection | Winner |
|--------|--------------|---------------------|--------|
| Startup time | ❌ Slower | ✅ Faster | Platform Reflection |
| Runtime performance | ❌ Slower | ✅ Faster | Platform Reflection |
| Memory usage | ❌ Higher | ✅ Lower | Platform Reflection |
| Tree shaking | ❌ Poor | ✅ Good | Platform Reflection |

## Platform Support

| Platform | dart:mirrors | Platform Reflection | Winner |
|----------|--------------|---------------------|--------|
| VM | ✅ Yes | ✅ Yes | Tie |
| Web | ❌ No | ✅ Yes | Platform Reflection |
| Flutter | ❌ No | ✅ Yes | Platform Reflection |
| AOT | ❌ No | ✅ Yes | Platform Reflection |

## Use Cases

| Use Case | dart:mirrors | Platform Reflection | Better Choice |
|----------|--------------|---------------------|---------------|
| Dependency injection | ✅ Simpler | ⚠️ More setup | Depends on platform needs |
| Serialization | ✅ Simpler | ⚠️ More setup | Depends on platform needs |
| Testing/Mocking | ✅ More flexible | ✅ More controlled | Depends on needs |
| Production apps | ❌ Limited platforms | ✅ All platforms | Platform Reflection |

## Migration Path

To migrate from dart:mirrors to Platform Reflection:

1. Replace imports:
   ```dart
   // Before
   import 'dart:mirrors';
   
   // After
   import 'package:illuminate_mirrors/mirrors.dart';
   ```

2. Add registration for each reflectable class:
   ```dart
   void registerReflectables() {
     Reflector.register(MyClass);
     Reflector.registerProperty(MyClass, 'prop', String);
     Reflector.registerMethod(MyClass, 'method', [int]);
     Reflector.registerConstructor(MyClass, '', parameterTypes: []);
   }
   ```

3. Update reflection calls:
   ```dart
   // Before
   final mirror = reflect(instance);
   final value = mirror.getField(#prop).reflectee;

   // After
   final reflector = RuntimeReflector.instance;
   final mirror = reflector.reflect(instance);
   final value = mirror.getField(const Symbol('prop')).reflectee;
   ```

4. Replace MirrorSystem usage:
   ```dart
   // Before
   final classMirror = reflectClass(MyClass);

   // After
   final classMirror = RuntimeReflector.instance.reflectClass(MyClass);
   ```

5. Update your build process to ensure registration functions are called at startup.

## Trade-offs

### Advantages of Platform Reflection
1. Works on all platforms (VM, Web, Flutter, AOT)
2. Better performance and smaller code size
3. Supports AOT compilation
4. More controlled reflection surface

### Advantages of dart:mirrors
1. No registration needed
2. More dynamic capabilities
3. Simpler API for some use cases
4. Better for certain development tools

## Conclusion

Platform Reflection offers a production-ready alternative to dart:mirrors with cross-platform support, better performance, and AOT compilation compatibility. The main trade-off is the need for explicit registration, which provides more control but requires more setup.

Choose Platform Reflection when:
- You need cross-platform or AOT compilation support
- Performance and code size are critical
- You want more control over the reflection surface

Consider dart:mirrors when:
- You're only targeting the Dart VM
- You need maximum runtime flexibility
- You're building certain types of development tools

Remember, the choice between Platform Reflection and dart:mirrors often comes down to your specific platform requirements and performance needs.
