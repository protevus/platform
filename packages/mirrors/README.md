# Platform Reflection

A powerful cross-platform reflection system for Dart that serves as a drop-in replacement for `dart:mirrors`. This implementation offers a carefully balanced approach between functionality and performance, providing reflection capabilities with AOT compilation support.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Performance Considerations](#performance-considerations)
- [Limitations](#limitations)
- [Migration from dart:mirrors](#migration-from-dartmirrors)
- [Contributing](#contributing)
- [License](#license)

## Features

- ✅ Platform independent reflection system
- ✅ AOT compilation support
- ✅ No dependency on `dart:mirrors`
- ✅ Class reflection with inheritance
- ✅ Method invocation with named parameters
- ✅ Property access and mutation
- ✅ Constructor resolution and invocation
- ✅ Type introspection and relationships
- ✅ Explicit registration for performance
- ✅ Basic generic type support
- ✅ Comprehensive error handling

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  platform_reflection: ^0.1.0
```

## Usage

### Registration

Unlike `dart:mirrors`, Platform Reflection requires explicit registration of classes and their members. This enables AOT compilation support and fine-grained control over reflection.

```dart
@reflectable
class User {
  String name;
  int age;
  final String id;
  List<String> tags;

  User(this.name, this.age, {required this.id, List<String>? tags})
      : tags = tags ?? [];

  String greet() => "Hi $name!";
  
  void addTag(String tag) {
    tags.add(tag);
  }

  String getName() => name;
}

void registerUser() {
  Reflector.register(User);
  Reflector.registerProperty(User, 'name', String);
  Reflector.registerProperty(User, 'age', int);
  Reflector.registerProperty(User, 'id', String, isWritable: false);
  Reflector.registerProperty(User, 'tags', List<String>, isWritable: false);
  
  Reflector.registerMethod(User, 'greet', [], false);
  Reflector.registerMethod(User, 'addTag', [String], true);
  Reflector.registerMethod(User, 'getName', [], false);
  
  Reflector.registerConstructor(
    User,
    '',
    parameterTypes: [String, int, String, List<String>],
    parameterNames: ['name', 'age', 'id', 'tags'],
    isRequired: [true, true, true, false],
    isNamed: [false, false, true, true],
  );
}
```

### Reflection Operations

```dart
void demonstrateReflection() {
  final reflector = RuntimeReflector.instance;
  
  // Create instance
  final user = reflector.createInstance(
    User,
    positionalArgs: ['John Doe', 30],
    namedArgs: {'id': 'user1', 'tags': ['admin', 'user']},
  ) as User;
  
  // Get mirror
  final mirror = reflector.reflect(user);
  
  // Property access
  final name = mirror.getField(const Symbol('name')).reflectee as String;
  
  // Property modification
  mirror.setField(const Symbol('age'), 25);
  
  // Method invocation
  final greeting = mirror.invoke(const Symbol('greet'), []).reflectee as String;
  
  // Type information
  final classMirror = reflector.reflectClass(User);
  print('Type name: ${classMirror.name}');
  
  // Type relationships
  final entityType = reflector.reflectType(Entity);
  print('User is subtype of Entity: ${classMirror.isSubclassOf(entityType)}');
}
```

## API Reference

### Core Classes

- `Reflector`: Static class for registration and metadata management
- `RuntimeReflector`: Runtime reflection operations

### Mirrors

- `InstanceMirror`: Instance reflection
- `ClassMirror`: Class reflection
- `MethodMirror`: Method reflection
- `LibraryMirror`: Library reflection
- `TypeMirror`: Type reflection

### Metadata

- `TypeMetadata`: Type information
- `PropertyMetadata`: Property information
- `MethodMetadata`: Method information
- `ConstructorMetadata`: Constructor information

### Exceptions

- `ReflectionException`: Base exception for reflection errors
- `NotReflectableException`: Thrown when attempting to reflect on an unregistered type

## Performance Considerations

- Explicit registration adds startup cost but improves runtime performance
- Cached class mirrors for efficient repeated use
- Minimal metadata storage for reduced memory footprint
- AOT compilation support allows for better optimization

## Limitations

- Requires explicit registration of reflectable types and members
- Limited support for complex generic types
- No support for extension methods
- No cross-package private member access

## Migration from dart:mirrors

To migrate from `dart:mirrors` to Platform Reflection:

1. Replace `import 'dart:mirrors'` with `import 'package:platform_reflection/mirrors.dart'`.
2. Add `@reflectable` annotation to classes you want to reflect on.
3. Implement a registration function for each reflectable class.
4. Call registration functions at the start of your application.
5. Replace `MirrorSystem.reflect()` with `RuntimeReflector.instance.reflect()`.
6. Update any code that relies on automatic discovery of classes or members.

## Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
