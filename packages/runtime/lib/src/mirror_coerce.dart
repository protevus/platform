/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:mirrors';
import 'package:protevus_runtime/runtime.dart';

/// Attempts to cast an object to a specified type at runtime.
///
/// This function uses Dart's mirror system to perform runtime type checking
/// and casting. It handles casting to List and Map types, including their
/// generic type arguments.
///
/// Parameters:
/// - [object]: The object to be cast.
/// - [intoType]: A [TypeMirror] representing the type to cast into.
///
/// Returns:
/// The object cast to the specified type.
///
/// Throws:
/// - [TypeCoercionException] if the casting fails.
Object runtimeCast(Object object, TypeMirror intoType) {
  final exceptionToThrow =
      TypeCoercionException(intoType.reflectedType, object.runtimeType);

  try {
    final objectType = reflect(object).type;
    if (objectType.isAssignableTo(intoType)) {
      return object;
    }

    if (intoType.isSubtypeOf(reflectType(List))) {
      if (object is! List) {
        throw exceptionToThrow;
      }

      final elementType = intoType.typeArguments.first;
      final elements = object.map((e) => runtimeCast(e, elementType));
      return (intoType as ClassMirror).newInstance(#from, [elements]).reflectee;
    } else if (intoType.isSubtypeOf(reflectType(Map, [String, dynamic]))) {
      if (object is! Map<String, dynamic>) {
        throw exceptionToThrow;
      }

      final output = (intoType as ClassMirror)
          .newInstance(Symbol.empty, []).reflectee as Map<String, dynamic>;
      final valueType = intoType.typeArguments.last;
      object.forEach((key, val) {
        output[key] = runtimeCast(val, valueType);
      });
      return output;
    }
  } on TypeError {
    throw exceptionToThrow;
  } on TypeCoercionException {
    throw exceptionToThrow;
  }

  throw exceptionToThrow;
}

/// Determines if a given type is fully primitive.
///
/// A type is considered fully primitive if it's a basic type (num, String, bool),
/// dynamic, or a collection (List, Map) where all nested types are also primitive.
///
/// Parameters:
/// - [type]: A [TypeMirror] representing the type to check.
///
/// Returns:
/// true if the type is fully primitive, false otherwise.
bool isTypeFullyPrimitive(TypeMirror type) {
  if (type == reflectType(dynamic)) {
    return true;
  }

  if (type.isSubtypeOf(reflectType(List))) {
    return isTypeFullyPrimitive(type.typeArguments.first);
  } else if (type.isSubtypeOf(reflectType(Map))) {
    return isTypeFullyPrimitive(type.typeArguments.first) &&
        isTypeFullyPrimitive(type.typeArguments.last);
  }

  if (type.isSubtypeOf(reflectType(num))) {
    return true;
  }

  if (type.isSubtypeOf(reflectType(String))) {
    return true;
  }

  if (type.isSubtypeOf(reflectType(bool))) {
    return true;
  }

  return false;
}
