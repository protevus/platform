import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/reflection.dart';

/// Internal utility functions for the container.
///
/// @internal
class Util {
  /// If the given value is not a list and not null, wrap it in one.
  ///
  /// @param value The value to wrap
  /// @return The wrapped value
  static List<T> arrayWrap<T>(T? value) {
    if (value == null) {
      return <T>[];
    }

    if (value is List<T>) {
      return value;
    }

    if (value is List) {
      return value.cast<T>();
    }

    return <T>[value];
  }

  /// Return the default value of the given value.
  ///
  /// @param value The value to unwrap
  /// @param args Optional arguments to pass to the closure
  /// @return The unwrapped value
  static dynamic unwrapIfClosure(dynamic value,
      [List<dynamic> args = const []]) {
    return value is Function ? Function.apply(value, args) : value;
  }

  /// Get the class name of the given parameter's type if possible.
  ///
  /// @param parameter The parameter to get the class name from
  /// @return The class name or null if not available
  static String? getParameterClassName(ParameterMirror parameter) {
    final type = parameter.type;

    // Skip if not a class type
    if (type is! ClassMirror) {
      return null;
    }

    // Get the type name
    final name = type.simpleName.toString().replaceAll('"', '');

    // Handle special cases for 'self' and 'parent'
    if (parameter.owner is ClassMirror) {
      final declaringClass = parameter.owner as ClassMirror;

      if (name == 'self') {
        return declaringClass.simpleName.toString().replaceAll('"', '');
      }

      if (name == 'parent' && declaringClass.superclass != null) {
        return declaringClass.superclass!.simpleName
            .toString()
            .replaceAll('"', '');
      }
    }

    return name;
  }

  /// Get a contextual attribute from a dependency.
  ///
  /// @param dependency The dependency parameter to check
  /// @return The contextual attribute instance if found, null otherwise
  static InstanceMirror? getContextualAttributeFromDependency(
      ParameterMirror dependency) {
    try {
      final reflector = RuntimeReflector.instance;

      // Get metadata annotations
      final metadata = dependency.metadata;
      if (metadata.isEmpty) return null;

      // Find first annotation that implements ContextualAttribute
      for (final annotation in metadata) {
        final instance = annotation.reflectee;
        if (instance is ContextualAttribute) {
          return annotation;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get an attribute of the specified type from an object.
  ///
  /// @param attributeType The type name of the attribute to find
  /// @param object The object to check for attributes
  /// @return The attribute instance if found, null otherwise
  static dynamic getAttributeFromType(String attributeType, dynamic object) {
    try {
      final reflector = RuntimeReflector.instance;
      final mirror = reflector.reflectClass(object.runtimeType);

      // Check if object directly implements the attribute type
      if (mirror.hasReflectedType &&
          mirror.reflectedType.toString() == attributeType) {
        return object;
      }

      // Check superclass chain
      var currentMirror = mirror;
      while (currentMirror.superclass != null) {
        currentMirror = currentMirror.superclass!;
        if (currentMirror.reflectedType.toString() == attributeType) {
          return object;
        }
      }

      // Check metadata
      for (final metadata in mirror.metadata) {
        final instance = metadata.reflectee;
        if (instance.runtimeType.toString() == attributeType ||
            instance is ContextualAttribute) {
          return instance;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Private constructor to prevent instantiation.
  Util._();
}
