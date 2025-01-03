import 'package:platform_container/container.dart';

/// Interface for reflection operations.
abstract class Reflection {
  /// Get a field value from a reflected instance.
  dynamic getFieldValue(String field);

  /// Set a field value on a reflected instance.
  void setFieldValue(String field, dynamic value);

  /// Check if a field exists.
  bool hasField(String field);

  /// Call a method on the reflected instance.
  dynamic invoke(String method, List args);

  /// Get the type name of the reflected instance.
  String get typeName;

  /// Get the declarations of the reflected instance.
  List<ReflectedDeclaration> get declarations;

  /// Check if this type is assignable to another type.
  bool isAssignableTo(Type type);

  /// Clone this instance.
  dynamic clone();
}

/// Implementation of [Reflection] using Container's reflection system.
class ContainerReflection implements Reflection {
  final Container _container;
  final ReflectedInstance? _instance;
  final ReflectedClass? _class;

  ContainerReflection(this._container, dynamic object)
      : _instance = _container.reflector.reflectInstance(object),
        _class = object is Type
            ? _container.reflector.reflectClass(object)
            : _container.reflector.reflectInstance(object)?.clazz;

  @override
  dynamic getFieldValue(String field) {
    final fieldInstance = _instance?.getField(field);
    return fieldInstance?.reflectee;
  }

  @override
  void setFieldValue(String field, dynamic value) {
    // Since we can't directly set fields, we need to use a setter method
    invoke('set${field[0].toUpperCase()}${field.substring(1)}', [value]);
  }

  @override
  bool hasField(String field) {
    try {
      _instance?.getField(field);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  dynamic invoke(String method, List args) {
    if (_instance == null) return null;

    final function = _class?.declarations
        .where((d) => d.name == method && d.function != null)
        .map((d) => d.function)
        .firstOrNull;

    if (function == null) return null;

    final invocation = Invocation.method(Symbol(method), args);
    final result = function.invoke(invocation);
    return result.reflectee;
  }

  @override
  String get typeName => _class?.name ?? 'Unknown';

  @override
  List<ReflectedDeclaration> get declarations => _class?.declarations ?? [];

  @override
  bool isAssignableTo(Type type) {
    if (_class == null) return false;
    final otherType = _container.reflector.reflectClass(type);
    if (otherType == null) return false;
    return _class!.isAssignableTo(otherType);
  }

  @override
  dynamic clone() {
    // Since we can't directly clone, create a new instance and copy fields
    if (_class == null) return null;
    final newInstance = _class!.newInstance('', []);
    if (newInstance == null) return null;

    final reflection = ContainerReflection(_container, newInstance.reflectee);
    for (final declaration in declarations) {
      if (!declaration.isStatic && declaration.function == null) {
        final value = getFieldValue(declaration.name);
        reflection.setFieldValue(declaration.name, value);
      }
    }
    return newInstance.reflectee;
  }

  /// Create a new instance of a class by name.
  static dynamic createInstance(Container container, String className) {
    final type = container.reflector.findTypeByName(className);
    if (type == null) return null;

    final classReflection = container.reflector.reflectClass(type);
    if (classReflection == null) return null;

    final instance = classReflection.newInstance('', []);
    return instance?.reflectee;
  }

  /// Get parameter types from a function.
  static List<Type> getParameterTypes(Container container, Function function) {
    final reflected = container.reflector.reflectFunction(function);
    if (reflected == null) return [];
    return reflected.parameters
        .map((p) => p.type.reflectedType)
        .whereType<Type>()
        .toList();
  }

  /// Create a reflection for a class type.
  static ContainerReflection? forClass(Container container, Type type) {
    final classReflection = container.reflector.reflectClass(type);
    if (classReflection == null) return null;
    return ContainerReflection(container, type);
  }

  /// Create a reflection for an instance.
  static ContainerReflection? forInstance(
      Container container, dynamic instance) {
    if (instance == null) return null;
    return ContainerReflection(container, instance);
  }
}
