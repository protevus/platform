# Dart Pure Reflection

A lightweight, cross-platform reflection system for Dart that provides runtime type introspection and manipulation without using `dart:mirrors` or code generation.

## Features

- ✅ Works on all platforms (Web, Mobile, Desktop)
- ✅ No dependency on `dart:mirrors`
- ✅ No code generation required
- ✅ Pure runtime reflection
- ✅ Type-safe property access
- ✅ Method invocation with argument validation
- ✅ Constructor invocation support
- ✅ Comprehensive error handling

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  reflection: ^1.0.0
```

## Usage

### Basic Setup

1. Add the `@reflectable` annotation and `Reflector` mixin to your class:

```dart
import 'package:reflection/reflection.dart';

@reflectable
class User with Reflector {
  String name;
  int age;
  final String id;

  User(this.name, this.age, {required this.id});
}
```

2. Register your class and its constructors:

```dart
// Register the class
Reflector.register(User);

// Register constructors
Reflector.registerConstructor(
  User,
  '', // Default constructor
  (String name, int age, {String? id}) {
    if (id == null) throw ArgumentError.notNull('id');
    return User(name, age, id: id);
  },
);
```

### Reflecting on Types

```dart
final reflector = RuntimeReflector.instance;

// Get type metadata
final userType = reflector.reflectType(User);
print('Type name: ${userType.name}');
print('Properties: ${userType.properties.keys.join(', ')}');
print('Methods: ${userType.methods.keys.join(', ')}');
```

### Working with Instances

```dart
final user = User('john_doe', 30, id: 'usr_123');
final userReflector = reflector.reflect(user);

// Read properties
final name = userReflector.getField('name'); // john_doe
final age = userReflector.getField('age');   // 30

// Write properties
userReflector.setField('name', 'jane_doe');
userReflector.setField('age', 25);

// Invoke methods
userReflector.invoke('someMethod', ['arg1', 'arg2']);
```

### Creating Instances

```dart
// Using default constructor
final newUser = reflector.createInstance(
  User,
  positionalArgs: ['alice', 28],
  namedArgs: {'id': 'usr_456'},
) as User;

// Using named constructor
final specialUser = reflector.createInstance(
  User,
  constructorName: 'special',
  positionalArgs: ['bob'],
) as User;
```

## Error Handling

The package provides specific exceptions for different error cases:

- `NotReflectableException`: Thrown when attempting to reflect on a non-reflectable type
- `ReflectionException`: Base class for reflection-related errors
- `InvalidArgumentsException`: Thrown when providing invalid arguments to a method or constructor
- `MemberNotFoundException`: Thrown when a property or method is not found

```dart
try {
  reflector.reflect(NonReflectableClass());
} catch (e) {
  print(e); // NotReflectableException: Type "NonReflectableClass" is not marked as @reflectable
}
```

## Complete Example

See the [example](example/reflection_example.dart) for a complete working demonstration.

## Limitations

1. Type Discovery
   - Properties and methods must be registered explicitly
   - No automatic discovery of class members
   - Generic type information is limited

2. Performance
   - First access to a type involves metadata creation
   - Subsequent accesses use cached metadata

3. Private Members
   - Private fields and methods cannot be accessed
   - Reflection is limited to public API

## Design Philosophy

This package is inspired by:

- **dart:mirrors**: API design and metadata structure
- **fake_reflection**: Registration-based approach
- **mirrors.cc**: Runtime type handling

The goal is to provide a lightweight, cross-platform reflection system that:

- Works everywhere Dart runs
- Requires minimal setup
- Provides type-safe operations
- Maintains good performance
- Follows Dart best practices

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
