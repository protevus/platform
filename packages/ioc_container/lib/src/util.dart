import 'dart:mirrors';
import 'package:platform_contracts/contracts.dart';

/// @internal
class Util {
  /// If the given value is not an array and not null, wrap it in one.
  static List arrayWrap(dynamic value) {
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

    if (type.reflectedType == dynamic ||
        type.isSubtypeOf(reflectType(num)) ||
        type.isSubtypeOf(reflectType(String)) ||
        type.isSubtypeOf(reflectType(bool))) {
      return null;
    }

    var name = MirrorSystem.getName(type.simpleName);

    var declaringClass = parameter.owner as ClassMirror?;
    if (declaringClass != null) {
      if (name == 'self') {
        return MirrorSystem.getName(declaringClass.simpleName);
      }

      if (name == 'parent' && declaringClass.superclass != null) {
        return MirrorSystem.getName(declaringClass.superclass!.simpleName);
      }
    }

    return name;
  }

  /// Get a contextual attribute from a dependency.
  static InstanceMirror? getContextualAttributeFromDependency(
      ParameterMirror dependency) {
    var contextualAttributes = dependency.metadata.where(
        (attr) => attr.type.isSubtypeOf(reflectType(ContextualAttribute)));

    return contextualAttributes.isNotEmpty ? contextualAttributes.first : null;
  }
}
