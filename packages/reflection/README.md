# Platform Reflection

A lightweight, cross-platform reflection system for Dart that provides runtime type introspection and manipulation with an API similar to `dart:mirrors` but without its limitations.

## Features

- ✅ Works on all platforms (Web, Mobile, Desktop)
- ✅ No dependency on `dart:mirrors`
- ✅ Pure runtime reflection
- ✅ No code generation required
- ✅ No manual registration needed
- ✅ Complete mirror-based API
- ✅ Type-safe property access
- ✅ Method invocation with argument validation
- ✅ Constructor invocation support
- ✅ Library and isolate reflection
- ✅ Full MirrorSystem implementation
- ✅ Comprehensive error handling

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  platform_reflection: ^0.1.0
```

## Usage

### Basic Reflection

Simply mark your class with `@reflectable`:

```dart
import 'package:platform_reflection/reflection.dart';

@reflectable
class User {
  String name;
  int age;
  final String id;

  User(this.name, this.age, {required this.id});

  void birthday() {
    age++;
  }

  String greet(String greeting) {
    return '$greeting, $name!';
  }
}
```

Then use reflection directly:

```dart
// Get the reflector instance
final reflector = RuntimeReflector.instance;

// Create instance using reflection
final user = reflector.createInstance(
  User,
  positionalArgs: ['John', 30],
  namedArgs: {'id': '123'},
) as User;

// Get instance mirror
final mirror = reflector.reflect(user);

// Access properties
print(mirror.getField(const Symbol('name')).reflectee); // John
print(mirror.getField(const Symbol('age')).reflectee); // 30

// Modify properties
mirror.setField(const Symbol('name'), 'Jane');
mirror.setField(const Symbol('age'), 25);

// Invoke methods
mirror.invoke(const Symbol('birthday'), []);
final greeting = mirror.invoke(const Symbol('greet'), ['Hello']).reflectee;
print(greeting); // Hello, Jane!
```

### Type Information

```dart
// Get mirror system
final mirrors = reflector.currentMirrorSystem;

// Get type mirror
final typeMirror = mirrors.reflectType(User);

// Access type information
print(typeMirror.name); // User
print(typeMirror.properties); // {name: PropertyMetadata(...), age: PropertyMetadata(...)}
print(typeMirror.methods); // {birthday: MethodMetadata(...), greet: MethodMetadata(...)}

// Check type relationships
if (typeMirror.isSubtypeOf(otherType)) {
  print('User is a subtype');
}

// Get declarations
final declarations = typeMirror.declarations;
for (var member in declarations.values) {
  if (member is MethodMirror) {
    print('Method: ${member.simpleName}');
  } else if (member is VariableMirror) {
    print('Variable: ${member.simpleName}');
  }
}

// Access special types
print(mirrors.dynamicType.name); // dynamic
print(mirrors.voidType.name); // void
print(mirrors.neverType.name); // Never
```

### Library Reflection

```dart
// Get a library
final library = mirrors.findLibrary(const Symbol('package:myapp/src/models.dart'));

// Access library members
final declarations = library.declarations;
for (var decl in declarations.values) {
  print('Declaration: ${decl.simpleName}');
}

// Check imports
for (var dep in library.libraryDependencies) {
  if (dep.isImport) {
    print('Imports: ${dep.targetLibrary?.uri}');
  }
}
```

### Isolate Reflection

```dart
// Get current isolate
final currentIsolate = mirrors.isolate;
print('Current isolate: ${currentIsolate.debugName}');

// Reflect on another isolate
final isolate = await Isolate.spawn(workerFunction, message);
final isolateMirror = reflector.reflectIsolate(isolate, 'worker');

// Control isolate
await isolateMirror.pause();
await isolateMirror.resume();
await isolateMirror.kill();
```

## Error Handling

The package provides specific exceptions for different error cases:

- `NotReflectableException`: Thrown when attempting to reflect on a non-reflectable type
- `ReflectionException`: Base class for reflection-related errors
- `InvalidArgumentsException`: Thrown when providing invalid arguments to a method or constructor
- `MemberNotFoundException`: Thrown when a property or method is not found

```dart
try {
  reflect(NonReflectableClass());
} catch (e) {
  print(e); // NotReflectableException: Type NonReflectableClass is not reflectable
}
```

## Design Philosophy

This package provides a reflection API that closely mirrors the design of `dart:mirrors` while being:

- Platform independent
- Lightweight
- Type-safe
- Performant
- Easy to use

The implementation uses pure Dart runtime scanning to provide reflection capabilities across all platforms without requiring code generation or manual registration.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
