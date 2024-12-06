# Platform Reflection

A powerful cross-platform reflection system for Dart that provides runtime type introspection and manipulation. This implementation offers a carefully balanced approach between functionality and performance, providing reflection capabilities without the limitations of `dart:mirrors`.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Core Components](#core-components)
- [Usage Guide](#usage-guide)
- [Advanced Usage](#advanced-usage)
- [Performance Considerations](#performance-considerations)
- [Migration Guide](#migration-guide)
- [API Reference](#api-reference)
- [Limitations](#limitations)
- [Contributing](#contributing)
- [License](#license)

## Features

### Core Features
- ✅ Platform independent reflection system
- ✅ No dependency on `dart:mirrors`
- ✅ Pure runtime reflection
- ✅ Library scanning and reflection
- ✅ Explicit registration for performance
- ✅ Type-safe operations
- ✅ Comprehensive error handling

### Reflection Capabilities
- ✅ Class reflection with inheritance
- ✅ Method invocation with named parameters
- ✅ Property access/mutation
- ✅ Constructor resolution and invocation
- ✅ Type introspection and relationships
- ✅ Library dependency tracking
- ✅ Parameter inspection and validation
- ✅ Top-level variable support

### Performance Features
- ✅ Cached class mirrors
- ✅ Optimized type compatibility checking
- ✅ Efficient parameter resolution
- ✅ Smart library scanning
- ✅ Memory-efficient design
- ✅ Lazy initialization support

## Architecture

### Core Components

```
platform_reflection/
├── core/
│   ├── library_scanner.dart  # Library scanning and analysis
│   ├── reflector.dart       # Central reflection registry
│   ├── runtime_reflector.dart # Runtime reflection implementation
│   └── scanner.dart         # Type scanning and analysis
├── mirrors/
│   ├── base_mirror.dart     # Base mirror implementations
│   ├── class_mirror_impl.dart # Class reflection
│   ├── instance_mirror_impl.dart # Instance reflection
│   ├── library_mirror_impl.dart # Library reflection
│   ├── method_mirror_impl.dart # Method reflection
│   └── ... (other mirrors)
├── annotations.dart         # Reflection annotations
├── exceptions.dart         # Error handling
├── metadata.dart          # Metadata definitions
└── types.dart            # Special type implementations
```

### Design Principles

1. **Explicit Registration**
   - Clear registration of reflectable types
   - Controlled reflection surface
   - Optimized runtime performance

2. **Type Safety**
   - Strong type checking
   - Compile-time validations
   - Runtime type verification

3. **Performance First**
   - Minimal runtime overhead
   - Efficient metadata storage
   - Optimized lookup mechanisms

4. **Platform Independence**
   - Cross-platform compatibility
   - No platform-specific dependencies
   - Consistent behavior

## Installation

```yaml
dependencies:
  platform_reflection: ^0.1.0
```

## Core Components

### Reflector

Central management class for reflection operations:

```dart
class Reflector {
  // Type registration
  static void register(Type type);
  static void registerProperty(Type type, String name, Type propertyType);
  static void registerMethod(Type type, String name, List<Type> parameterTypes);
  static void registerConstructor(Type type, String name, {Function? creator});
  
  // Metadata access
  static TypeMetadata? getTypeMetadata(Type type);
  static Map<String, PropertyMetadata>? getPropertyMetadata(Type type);
  static Map<String, MethodMetadata>? getMethodMetadata(Type type);
  
  // Utility methods
  static void reset();
  static bool isReflectable(Type type);
}
```

### RuntimeReflector

Runtime reflection implementation:

```dart
class RuntimeReflector {
  // Instance creation
  InstanceMirror createInstance(Type type, {
    List<dynamic>? positionalArgs,
    Map<String, dynamic>? namedArgs,
    String? constructorName,
  });
  
  // Reflection operations
  InstanceMirror reflect(Object object);
  ClassMirror reflectClass(Type type);
  TypeMirror reflectType(Type type);
  LibraryMirror reflectLibrary(Uri uri);
}
```

### LibraryScanner

Library scanning and analysis:

```dart
class LibraryScanner {
  // Library scanning
  static LibraryInfo scanLibrary(Uri uri);
  
  // Analysis methods
  static List<FunctionInfo> getTopLevelFunctions(Uri uri);
  static List<VariableInfo> getTopLevelVariables(Uri uri);
  static List<DependencyInfo> getDependencies(Uri uri);
}
```

## Usage Guide

### Basic Registration

```dart
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
    return '$greeting $name!';
  }
}

// Register class and members
void registerUser() {
  Reflector.register(User);
  
  // Register properties
  Reflector.registerProperty(User, 'name', String);
  Reflector.registerProperty(User, 'age', int);
  Reflector.registerProperty(User, 'id', String, isWritable: false);
  
  // Register methods
  Reflector.registerMethod(
    User,
    'birthday',
    [],
    true,
    parameterNames: [],
    isRequired: [],
  );
  
  Reflector.registerMethod(
    User,
    'greet',
    [String],
    false,
    parameterNames: ['greeting'],
    isRequired: [true],
  );
  
  // Register constructor
  Reflector.registerConstructor(
    User,
    '',
    parameterTypes: [String, int, String],
    parameterNames: ['name', 'age', 'id'],
    isRequired: [true, true, true],
    isNamed: [false, false, true],
    creator: (String name, int age, {required String id}) => 
        User(name, age, id: id),
  );
}
```

### Instance Manipulation

```dart
void manipulateInstance() {
  final reflector = RuntimeReflector.instance;
  
  // Create instance
  final user = reflector.createInstance(
    User,
    positionalArgs: ['John', 30],
    namedArgs: {'id': '123'},
  ) as User;
  
  // Get mirror
  final mirror = reflector.reflect(user);
  
  // Property access
  final name = mirror.getField(const Symbol('name')).reflectee as String;
  final age = mirror.getField(const Symbol('age')).reflectee as int;
  
  // Property modification
  mirror.setField(const Symbol('name'), 'Jane');
  mirror.setField(const Symbol('age'), 31);
  
  // Method invocation
  mirror.invoke(const Symbol('birthday'), []);
  final greeting = mirror.invoke(
    const Symbol('greet'),
    ['Hello'],
  ).reflectee as String;
}
```

### Library Reflection

```dart
void reflectLibrary() {
  final reflector = RuntimeReflector.instance;
  
  // Get library mirror
  final library = reflector.reflectLibrary(
    Uri.parse('package:myapp/src/models.dart')
  );
  
  // Access top-level function
  final result = library.invoke(
    const Symbol('utilityFunction'),
    [arg1, arg2],
  ).reflectee;
  
  // Access top-level variable
  final value = library.getField(const Symbol('constant')).reflectee;
  
  // Get library dependencies
  final dependencies = library.libraryDependencies;
  for (final dep in dependencies) {
    print('Import: ${dep.targetLibrary.uri}');
    print('Is deferred: ${dep.isDeferred}');
  }
}
```

### Type Relationships

```dart
void checkTypes() {
  final reflector = RuntimeReflector.instance;
  
  // Get class mirrors
  final userMirror = reflector.reflectClass(User);
  final baseMirror = reflector.reflectClass(BaseClass);
  
  // Check inheritance
  final isSubclass = userMirror.isSubclassOf(baseMirror);
  
  // Check type compatibility
  final isCompatible = userMirror.isAssignableTo(baseMirror);
  
  // Get superclass
  final superclass = userMirror.superclass;
  
  // Get interfaces
  final interfaces = userMirror.interfaces;
}
```

## Advanced Usage

### Generic Type Handling

```dart
@reflectable
class Container<T> {
  T value;
  Container(this.value);
}

void handleGenericType() {
  Reflector.register(Container);
  
  // Register with specific type
  final stringContainer = reflector.createInstance(
    Container,
    positionalArgs: ['Hello'],
  ) as Container<String>;
  
  final mirror = reflector.reflect(stringContainer);
  final value = mirror.getField(const Symbol('value')).reflectee as String;
}
```

### Error Handling

```dart
void demonstrateErrorHandling() {
  try {
    // Attempt to reflect unregistered type
    reflector.reflect(UnregisteredClass());
  } on NotReflectableException catch (e) {
    print('Type not registered: $e');
  }
  
  try {
    // Attempt to access non-existent member
    final mirror = reflector.reflect(user);
    mirror.getField(const Symbol('nonexistent'));
  } on MemberNotFoundException catch (e) {
    print('Member not found: $e');
  }
  
  try {
    // Attempt invalid method invocation
    final mirror = reflector.reflect(user);
    mirror.invoke(const Symbol('greet'), [42]); // Wrong argument type
  } on InvalidArgumentsException catch (e) {
    print('Invalid arguments: $e');
  }
}
```

## Performance Considerations

### Registration Impact

- Explicit registration adds startup cost
- Improved runtime performance
- Reduced memory usage
- Controlled reflection surface

### Optimization Techniques

1. **Lazy Loading**
   ```dart
   // Only register when needed
   if (Reflector.getTypeMetadata(User) == null) {
     registerUser();
   }
   ```

2. **Metadata Caching**
   ```dart
   // Cache metadata access
   final metadata = Reflector.getTypeMetadata(User);
   final properties = metadata.properties;
   final methods = metadata.methods;
   ```

3. **Instance Reuse**
   ```dart
   // Reuse instance mirrors
   final mirror = reflector.reflect(user);
   // Store mirror for repeated use
   ```

### Memory Management

- Cached class mirrors
- Efficient parameter resolution
- Smart library scanning
- Minimal metadata storage

## Migration Guide

### From dart:mirrors

```dart
// Old dart:mirrors code
import 'dart:mirrors';

final mirror = reflect(instance);
final value = mirror.getField(#propertyName).reflectee;

// New platform_reflection code
import 'package:platform_reflection/reflection.dart';

final mirror = reflector.reflect(instance);
final value = mirror.getField(const Symbol('propertyName')).reflectee;
```

### Registration Requirements

```dart
// Add registration code
void registerTypes() {
  Reflector.register(MyClass);
  Reflector.registerProperty(MyClass, 'property', String);
  Reflector.registerMethod(MyClass, 'method', [int]);
}
```

## API Reference

### Core Classes

- `Reflector`: Central reflection management
- `RuntimeReflector`: Runtime reflection operations
- `LibraryScanner`: Library scanning and analysis

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

- `NotReflectableException`
- `ReflectionException`
- `InvalidArgumentsException`
- `MemberNotFoundException`

## Limitations

Current Implementation Gaps:

1. **Type System**
   - Limited generic variance support
   - Basic type relationship checking

2. **Reflection Features**
   - No extension method support
   - Limited annotation metadata
   - No cross-package private member access

3. **Language Features**
   - No operator overloading reflection
   - No dynamic code generation
   - Limited mixin support

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.
