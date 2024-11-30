# Platform Reflection Quick Start Guide

This guide covers the most common use cases for Platform Reflection to help you get started quickly.

## Installation

```yaml
dependencies:
  platform_reflection: ^0.1.0
```

## Basic Usage

### 1. Simple Class Reflection

```dart
import 'package:platform_reflection/reflection.dart';

// 1. Define your class
@reflectable
class User {
  String name;
  int age;
  
  User(this.name, this.age);
  
  void birthday() => age++;
}

// 2. Register for reflection
void main() {
  // Register class
  Reflector.register(User);
  
  // Register properties
  Reflector.registerProperty(User, 'name', String);
  Reflector.registerProperty(User, 'age', int);
  
  // Register methods
  Reflector.registerMethod(
    User,
    'birthday',
    [],
    true,
  );
  
  // Register constructor
  Reflector.registerConstructor(
    User,
    '',
    parameterTypes: [String, int],
    parameterNames: ['name', 'age'],
    creator: (String name, int age) => User(name, age),
  );
  
  // Use reflection
  final user = reflector.createInstance(
    User,
    positionalArgs: ['John', 30],
  ) as User;
  
  final mirror = reflector.reflect(user);
  print(mirror.getField(const Symbol('name')).reflectee); // John
  mirror.invoke(const Symbol('birthday'), []);
  print(mirror.getField(const Symbol('age')).reflectee); // 31
}
```

### 2. Property Access

```dart
// Get property value
final mirror = reflector.reflect(instance);
final name = mirror.getField(const Symbol('name')).reflectee as String;

// Set property value
mirror.setField(const Symbol('name'), 'Jane');

// Check if property exists
final metadata = Reflector.getPropertyMetadata(User);
if (metadata?.containsKey('name') ?? false) {
  // Property exists
}
```

### 3. Method Invocation

```dart
// Invoke method without arguments
mirror.invoke(const Symbol('birthday'), []);

// Invoke method with arguments
final result = mirror.invoke(
  const Symbol('greet'),
  ['Hello'],
).reflectee as String;

// Invoke method with named arguments
final result = mirror.invoke(
  const Symbol('update'),
  [],
  {const Symbol('value'): 42},
).reflectee;
```

### 4. Constructor Usage

```dart
// Default constructor
final instance = reflector.createInstance(
  User,
  positionalArgs: ['John', 30],
) as User;

// Named constructor
final instance = reflector.createInstance(
  User,
  constructorName: 'guest',
) as User;

// Constructor with named arguments
final instance = reflector.createInstance(
  User,
  positionalArgs: ['John'],
  namedArgs: {const Symbol('age'): 30},
) as User;
```

### 5. Type Information

```dart
// Get type metadata
final metadata = Reflector.getTypeMetadata(User);

// Check properties
for (var property in metadata.properties.values) {
  print('${property.name}: ${property.type}');
}

// Check methods
for (var method in metadata.methods.values) {
  print('${method.name}(${method.parameterTypes.join(', ')})');
}
```

### 6. Error Handling

```dart
try {
  // Attempt reflection
  final mirror = reflector.reflect(instance);
  mirror.invoke(const Symbol('method'), []);
} on NotReflectableException catch (e) {
  print('Type not registered: $e');
} on MemberNotFoundException catch (e) {
  print('Member not found: $e');
} on InvalidArgumentsException catch (e) {
  print('Invalid arguments: $e');
} on ReflectionException catch (e) {
  print('Reflection error: $e');
}
```

## Common Patterns

### 1. Registration Helper

```dart
void registerType<T>(Type type) {
  Reflector.register(type);
  
  final scanner = Scanner();
  final metadata = scanner.scanType(type);
  
  // Register properties
  for (var property in metadata.properties.values) {
    Reflector.registerProperty(
      type,
      property.name,
      property.type,
      isWritable: property.isWritable,
    );
  }
  
  // Register methods
  for (var method in metadata.methods.values) {
    Reflector.registerMethod(
      type,
      method.name,
      method.parameterTypes,
      method.returnsVoid,
      parameterNames: method.parameters.map((p) => p.name).toList(),
      isRequired: method.parameters.map((p) => p.isRequired).toList(),
    );
  }
}
```

### 2. Property Observer

```dart
class PropertyObserver {
  final InstanceMirror mirror;
  final Symbol propertyName;
  final void Function(dynamic oldValue, dynamic newValue) onChange;
  
  PropertyObserver(this.mirror, this.propertyName, this.onChange);
  
  void observe() {
    var lastValue = mirror.getField(propertyName).reflectee;
    
    Timer.periodic(Duration(milliseconds: 100), (_) {
      final currentValue = mirror.getField(propertyName).reflectee;
      if (currentValue != lastValue) {
        onChange(lastValue, currentValue);
        lastValue = currentValue;
      }
    });
  }
}
```

### 3. Method Interceptor

```dart
class MethodInterceptor {
  final InstanceMirror mirror;
  final Symbol methodName;
  final void Function(List args, Map<Symbol, dynamic> named) beforeInvoke;
  final void Function(dynamic result) afterInvoke;
  
  MethodInterceptor(
    this.mirror,
    this.methodName,
    {this.beforeInvoke = _noOp,
    this.afterInvoke = _noOp});
    
  static void _noOp([dynamic _]) {}
  
  dynamic invoke(List args, [Map<Symbol, dynamic>? named]) {
    beforeInvoke(args, named ?? {});
    final result = mirror.invoke(methodName, args, named).reflectee;
    afterInvoke(result);
    return result;
  }
}
```

## Best Practices

1. **Register Early**
   ```dart
   void main() {
     // Register all types at startup
     registerType<User>();
     registerType<Order>();
     registerType<Product>();
     
     // Start application
     runApp();
   }
   ```

2. **Cache Mirrors**
   ```dart
   class UserService {
     final Map<User, InstanceMirror> _mirrors = {};
     
     InstanceMirror getMirror(User user) {
       return _mirrors.putIfAbsent(
         user,
         () => reflector.reflect(user),
       );
     }
   }
   ```

3. **Handle Errors**
   ```dart
   T reflectSafely<T>(Function() operation, T defaultValue) {
     try {
       return operation() as T;
     } on ReflectionException catch (e) {
       print('Reflection failed: $e');
       return defaultValue;
     }
   }
   ```

4. **Validate Registration**
   ```dart
   bool isFullyRegistered(Type type) {
     final metadata = Reflector.getTypeMetadata(type);
     if (metadata == null) return false;
     
     // Check properties
     if (metadata.properties.isEmpty) return false;
     
     // Check methods
     if (metadata.methods.isEmpty) return false;
     
     // Check constructors
     if (metadata.constructors.isEmpty) return false;
     
     return true;
   }
   ```

## Common Issues

1. **Type Not Registered**
   ```dart
   // Wrong
   reflector.reflect(unregisteredInstance);
   
   // Right
   Reflector.register(UnregisteredType);
   reflector.reflect(instance);
   ```

2. **Missing Property/Method Registration**
   ```dart
   // Wrong
   Reflector.register(User);
   
   // Right
   Reflector.register(User);
   Reflector.registerProperty(User, 'name', String);
   Reflector.registerMethod(User, 'greet', [String]);
   ```

3. **Wrong Argument Types**
   ```dart
   // Wrong
   mirror.invoke(const Symbol('greet'), [42]);
   
   // Right
   mirror.invoke(const Symbol('greet'), ['Hello']);
   ```

## Performance Tips

1. **Cache Metadata**
   ```dart
   final metadata = Reflector.getTypeMetadata(User);
   final properties = metadata.properties;
   final methods = metadata.methods;
   ```

2. **Reuse Mirrors**
   ```dart
   final mirror = reflector.reflect(instance);
   // Reuse mirror for multiple operations
   ```

3. **Batch Registration**
   ```dart
   void registerAll() {
     for (var type in types) {
       registerType(type);
     }
   }
   ```

## Next Steps

- Read the [Technical Specification](technical_specification.md) for detailed implementation information
- Check the [API Reference](../README.md#api-reference) for complete API documentation
- See the [Mirrors Comparison](mirrors_comparison.md) for differences from dart:mirrors
