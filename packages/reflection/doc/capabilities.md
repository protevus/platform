# Platform Reflection Capabilities

This document outlines the key capabilities of the Platform Reflection library, demonstrating its features and usage patterns.

## Core Reflection Features

### 1. Class Reflection
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
  void addTag(String tag) => tags.add(tag);
  String getName() => name;
}

// Registration
Reflector.register(User);
Reflector.registerProperty(User, 'name', String);
Reflector.registerProperty(User, 'age', int);
Reflector.registerProperty(User, 'id', String, isWritable: false);
Reflector.registerProperty(User, 'tags', List<String>, isWritable: false);
Reflector.registerMethod(User, 'greet', [], false);
Reflector.registerMethod(User, 'addTag', [String], true);
Reflector.registerMethod(User, 'getName', [], false);
Reflector.registerConstructor(User, '', 
  parameterTypes: [String, int, String, List<String>],
  parameterNames: ['name', 'age', 'id', 'tags'],
  isRequired: [true, true, true, false],
  isNamed: [false, false, true, true],
);
```

### 2. Instance Creation and Manipulation
```dart
final reflector = RuntimeReflector.instance;

// Create instance
final user = reflector.createInstance(
  User,
  positionalArgs: ['John Doe', 30],
  namedArgs: {'id': 'user1', 'tags': ['admin', 'user']},
) as User;

// Get mirror
final mirror = reflector.reflect(user);

// Property access and modification
print('Name: ${mirror.getField(const Symbol('name')).reflectee}');
mirror.setField(const Symbol('name'), 'Jane Doe');

// Method invocation
final greeting = mirror.invoke(const Symbol('greet'), []).reflectee as String;
mirror.invoke(const Symbol('addTag'), ['vip']);
```

### 3. Type Information
```dart
final classMirror = reflector.reflectClass(User);

print('Type name: ${classMirror.name}');

// Properties
classMirror.declarations.values
    .whereType<VariableMirror>()
    .forEach((prop) {
  print('Property: ${prop.name}: ${prop.type.name}');
  if (!prop.isFinal && !prop.isWritable) print('  (read-only)');
});

// Methods
classMirror.declarations.values
    .whereType<MethodMirror>()
    .where((method) => !method.isConstructor)
    .forEach((method) {
  print('Method: ${method.name}');
});

// Constructors
classMirror.declarations.values
    .whereType<MethodMirror>()
    .where((method) => method.isConstructor)
    .forEach((constructor) {
  print('Constructor: ${constructor.name}');
});
```

## Error Handling

```dart
try {
  final mirror = reflector.reflect(unregisteredInstance);
} on ReflectionException catch (e) {
  print('Reflection error: ${e.message}');
}
```

## Platform Support

- ✅ VM (Full support)
- ✅ Web (Full support)
- ✅ Flutter (Full support)
- ✅ AOT compilation (Full support)

## Performance Considerations

1. **Registration Impact**
   - One-time registration cost
   - Optimized runtime performance
   - Minimal memory overhead

2. **Metadata Caching**
   - Efficient metadata storage
   - Fast lookup mechanisms
   - Memory-conscious design

## Best Practices

1. **Early Registration**
   ```dart
   void main() {
     registerReflectableTypes();
     runApp();
   }
   ```

2. **Caching Mirrors**
   ```dart
   class UserService {
     final Map<User, InstanceMirror> _mirrors = {};
     
     InstanceMirror getMirror(User user) {
       return _mirrors.putIfAbsent(user, () => reflector.reflect(user));
     }
   }
   ```

3. **Comprehensive Error Handling**
   ```dart
   try {
     final result = mirror.invoke(const Symbol('method'), args);
   } on ReflectionException catch (e) {
     handleReflectionError(e);
   }
   ```

This document provides an overview of the Platform Reflection library's capabilities. For detailed API documentation, please refer to the [API Reference](../README.md#api-reference).
