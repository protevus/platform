import 'package:platform_reflection/reflection.dart';
import 'package:platform_contracts/contracts.dart';
import 'container.dart';
import 'entry_not_found_exception.dart';

/// Export the annotation for use in other files
export 'reflection.dart' show ContainerReflectable;

/// Annotation to mark classes as reflectable for container resolution
class ContainerReflectable {
  final bool reflectable;
  const ContainerReflectable({this.reflectable = true});
}

/// Initialize reflection for the container
void initializeReflection() {
  final reflector = RuntimeReflector.instance;

  // Register container types first
  _registeredTypes.add(Container);
  _registeredTypes.add(ContainerContract);
  _registeredTypes.add(BindingResolutionException);
  _registeredTypes.add(CircularDependencyException);
  _registeredTypes.add(EntryNotFoundException);
  _registeredTypes.add(ContainerReflectable);

  // Register all types
  for (final type in _registeredTypes) {
    try {
      reflector.reflectClass(type);
    } catch (_) {}
  }
}

/// Extension to make a class reflectable
extension ContainerReflectableExtension on Type {
  /// Make this type reflectable
  void makeReflectable() {
    RuntimeReflector.instance.reflectClass(this);
    _registeredTypes.add(this);
  }
}

/// Check if a type is reflectable
bool isReflectable(Type type) {
  // Handle primitive types
  if (_primitiveTypes.contains(type)) {
    return true;
  }

  try {
    final reflector = RuntimeReflector.instance;
    final mirror = reflector.reflectClass(type);
    return mirror.hasReflectedType;
  } catch (e) {
    return false;
  }
}

/// Convert a string identifier to a reflectable type
Type? stringToType(String id) {
  // Handle method calls
  if (id.contains('@')) {
    final parts = id.split('@');
    return stringToType(parts[0]);
  }
  if (id.contains('::')) {
    final parts = id.split('::');
    return stringToType(parts[0]);
  }

  // Handle primitive types
  switch (id.toLowerCase()) {
    case 'string':
      return String;
    case 'bool':
      return bool;
    case 'int':
      return int;
    case 'double':
      return double;
    case 'num':
      return num;
    case 'object':
      return Object;
    case 'function':
      return Function;
    case 'type':
      return Type;
    case 'list':
      return List;
    case 'map':
      return Map;
    case 'set':
      return Set;
    case 'iterable':
      return Iterable;
    case 'null':
      return Null;
  }

  // Try to find a registered type with a matching type name
  for (final type in _registeredTypes) {
    try {
      if (type.toString() == id) {
        return type;
      }
    } catch (_) {}
  }

  // Try to find a registered type with a matching type() method
  for (final type in _registeredTypes) {
    try {
      final reflector = RuntimeReflector.instance;
      final mirror = reflector.reflectClass(type);
      if (mirror.hasReflectedType) {
        final typeMethod = mirror.declarations['type'];
        if (typeMethod != null) {
          return type;
        }
      }
    } catch (_) {}
  }

  return null;
}

/// Convert a type to a string identifier
String typeToString(Type type) {
  // Handle primitive types
  if (_primitiveTypes.contains(type)) {
    return type.toString();
  }

  try {
    final reflector = RuntimeReflector.instance;
    final mirror = reflector.reflectClass(type);

    // Try to get type() method result
    try {
      final typeMethod = mirror.declarations['type'];
      if (typeMethod != null) {
        return type.toString();
      }
    } catch (_) {}

    return mirror.simpleName.toString().replaceAll('"', '');
  } catch (_) {
    return type.toString();
  }
}

/// Register a type for reflection
void registerType(Type type) {
  // Don't register primitive types
  if (!_primitiveTypes.contains(type)) {
    _registeredTypes.add(type);
  }
}

/// Register multiple types for reflection
void registerTypes(List<Type> types) {
  // Don't register primitive types
  for (final type in types) {
    if (!_primitiveTypes.contains(type)) {
      _registeredTypes.add(type);
    }
  }
}

/// Keep track of registered types for lookup
final Set<Type> _registeredTypes = {};

/// Keep track of primitive types that don't need reflection
final Set<Type> _primitiveTypes = {
  String,
  bool,
  int,
  double,
  num,
  Object,
  Function,
  Type,
  List,
  Map,
  Set,
  Iterable,
  Null,
};

/// Handle method reflection
class MethodReflector {
  static dynamic invoke(Object target, String methodName, List<dynamic> args) {
    try {
      final reflector = RuntimeReflector.instance;
      final mirror = reflector.reflectClass(target.runtimeType);
      final method = mirror.declarations[methodName];
      if (method == null) {
        throw BindingResolutionException('Method $methodName not found');
      }
      return Function.apply(method as Function, args);
    } catch (e) {
      throw BindingResolutionException('Failed to invoke method: $e');
    }
  }

  static dynamic invokeStatic(
      Type type, String methodName, List<dynamic> args) {
    try {
      final reflector = RuntimeReflector.instance;
      final mirror = reflector.reflectClass(type);
      final method = mirror.declarations[methodName];
      if (method == null) {
        throw BindingResolutionException('Static method $methodName not found');
      }
      return Function.apply(method as Function, args);
    } catch (e) {
      throw BindingResolutionException('Failed to invoke static method: $e');
    }
  }
}
