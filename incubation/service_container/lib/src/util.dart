import 'package:platform_contracts/contracts.dart';
import 'package:platform_mirrors/mirrors.dart';

/// Utility class for container-related operations.
class Util {
  /// If the given value is not an array and not null, wrap it in one.
  static List<dynamic> arrayWrap(dynamic value) {
    if (value == null) {
      return [];
    }
    return value is List ? value : [value];
  }

  /// Return the default value of the given value.
  static dynamic unwrapIfClosure(dynamic value,
      [List<dynamic> args = const []]) {
    return value is Function ? Function.apply(value, args) : value;
  }

  /// Get the class name of the given parameter's type, if possible.
  static String? getParameterClassName(ParameterMirror parameter) {
    var type = parameter.type;
    if (type is! ClassMirror || type.isEnum) {
      return null;
    }

    var name = type.simpleName.toString();

    var declaringClass = parameter.owner as ClassMirror?;
    if (declaringClass != null) {
      if (name == 'self') {
        return declaringClass.simpleName.toString();
      }

      if (name == 'parent' && declaringClass.superclass != null) {
        return declaringClass.superclass!.simpleName.toString();
      }
    }

    return name;
  }

  /// Get a contextual attribute from a dependency.
  static ContextualAttribute? getContextualAttributeFromDependency(
      ParameterMirror dependency) {
    return dependency.metadata.whereType<ContextualAttribute>().firstOrNull;
  }

  /// Gets the class name from a given type or object.
  static String getClassName(dynamic class_or_object) {
    if (class_or_object is Type) {
      return reflectClass(class_or_object).simpleName.toString();
    } else {
      return reflect(class_or_object).type.simpleName.toString();
    }
  }

  /// Retrieves contextual attributes for a given reflection.
  static List<ContextualAttribute> getContextualAttributes(
      ClassMirror reflection) {
    return reflection.metadata.whereType<ContextualAttribute>().toList();
  }

  /// Checks if a given type has a specific attribute.
  static bool hasAttribute(Type type, Type attributeType) {
    return reflectClass(type)
        .metadata
        .any((metadata) => metadata.type.reflectedType == attributeType);
  }

  /// Gets all attributes of a specific type for a given type.
  static List<T> getAttributes<T>(Type type) {
    return reflectClass(type).metadata.whereType<T>().toList();
  }
}

/// Placeholder for ContextualAttribute if it's not defined in the contracts package
// class ContextualAttribute {
//   const ContextualAttribute();
// }
