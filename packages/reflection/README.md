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
- ✅ Explicit registration for performance
- ✅ Type-safe operations
- ✅ Comprehensive error handling

### Reflection Capabilities
- ✅ Class reflection
- ✅ Method invocation
- ✅ Property access/mutation
- ✅ Constructor invocation
- ✅ Type introspection
- ✅ Basic metadata support
- ✅ Parameter inspection
- ✅ Type relationship checking

### Performance Features
- ✅ Optimized metadata storage
- ✅ Efficient lookup mechanisms
- ✅ Minimal runtime overhead
- ✅ Memory-efficient design
- ✅ Lazy initialization support

## Architecture

### Core Components

```
platform_reflection/
├── core/
│   ├── reflector.dart       # Central reflection management
│   ├── scanner.dart         # Type scanning and analysis
│   └── runtime_reflector.dart # Runtime reflection implementation
├── metadata/
│   ├── type_metadata.dart    # Type information storage
│   ├── method_metadata.dart  # Method metadata handling
│   └── property_metadata.dart # Property metadata handling
├── mirrors/
│   ├── class_mirror.dart     # Class reflection implementation
│   ├── instance_mirror.dart  # Instance reflection handling
│   └── method_mirror.dart    # Method reflection support
└── exceptions/
    └── reflection_exceptions.dart # Error handling
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

### Scanner

Automatic metadata extraction and analysis:

```dart
class Scanner {
  // Scanning operations
  static void scanType(Type type);
  static TypeMetadata getTypeMetadata(Type type);
  
  // Analysis methods
  static TypeInfo analyze(Type type);
  static List<PropertyInfo> analyzeProperties(Type type);
  static List<MethodInfo> analyzeMethods(Type type);
}
```

### RuntimeReflector

Runtime reflection implementation:

```dart
class RuntimeReflector {
  // Instance creation
  InstanceMirror createInstance(Type type, {
    List<dynamic>? positionalArgs,
    Map<Symbol, dynamic>? namedArgs,
    String? constructorName,
  });
  
  // Reflection operations
  InstanceMirror reflect(Object object);
  ClassMirror reflectClass(Type type);
  TypeMirror reflectType(Type type);
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
    namedArgs: {const Symbol('id'): '123'},
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

### Type Introspection

```dart
void inspectType() {
  final metadata = Reflector.getTypeMetadata(User);
  
  // Property inspection
  for (var property in metadata.properties.values) {
    print('Property: ${property.name}');
    print('  Type: ${property.type}');
    print('  Writable: ${property.isWritable}');
    print('  Static: ${property.isStatic}');
  }
  
  // Method inspection
  for (var method in metadata.methods.values) {
    print('Method: ${method.name}');
    print('  Return type: ${method.returnType}');
    print('  Parameters:');
    for (var param in method.parameters) {
      print('    ${param.name}: ${param.type}');
      print('    Required: ${param.isRequired}');
      print('    Named: ${param.isNamed}');
    }
  }
  
  // Constructor inspection
  for (var ctor in metadata.constructors) {
    print('Constructor: ${ctor.name}');
    print('  Parameters:');
    for (var param in ctor.parameters) {
      print('    ${param.name}: ${param.type}');
      print('    Required: ${param.isRequired}');
      print('    Named: ${param.isNamed}');
    }
  }
}
```

### Scanner Usage

```dart
void useScannerFeatures() {
  // Scan type
  Scanner.scanType(User);
  
  // Get scanned metadata
  final metadata = Scanner.getTypeMetadata(User);
  
  // Analyze type structure
  final typeInfo = Scanner.analyze(User);
  
  // Property analysis
  final properties = typeInfo.properties;
  for (var prop in properties) {
    print('Property: ${prop.name}');
    print('  Type: ${prop.type}');
    print('  Final: ${prop.isFinal}');
  }
  
  // Method analysis
  final methods = typeInfo.methods;
  for (var method in methods) {
    print('Method: ${method.name}');
    print('  Return type: ${method.returnType}');
    print('  Static: ${method.isStatic}');
    print('  Parameters: ${method.parameters}');
  }
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

- Metadata storage optimization
- Instance mirror lifecycle management
- Cache invalidation strategies

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
- `Scanner`: Metadata extraction
- `RuntimeReflector`: Runtime reflection operations

### Mirrors

- `InstanceMirror`: Instance reflection
- `ClassMirror`: Class reflection
- `MethodMirror`: Method reflection

### Metadata

- `TypeMetadata`: Type information
- `PropertyMetadata`: Property information
- `MethodMetadata`: Method information

### Exceptions

- `NotReflectableException`
- `ReflectionException`
- `InvalidArgumentsException`
- `MemberNotFoundException`

## Limitations

Current Implementation Gaps:

1. **Type System**
   - Limited generic support
   - No variance handling
   - Basic type relationship checking

2. **Reflection Features**
   - No cross-isolate reflection
   - No source location tracking
   - Limited metadata capabilities

3. **Language Features**
   - No extension method support
   - No mixin composition
   - No operator overloading reflection

4. **Advanced Features**
   - No dynamic proxy generation
   - No attribute-based reflection
   - Limited annotation processing

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.
