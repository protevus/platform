/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_runtime/runtime.dart';

/// Prefix string for List types in type checking.
const String _listPrefix = "List<";

/// Prefix string for Map types in type checking.
const String _mapPrefix = "Map<String,";

/// Casts a dynamic input to a specified type T.
///
/// This function attempts to cast the input to the specified type T.
/// It handles nullable types, Lists, and Maps with various element types.
///
/// Parameters:
/// - input: The dynamic value to be cast.
///
/// Returns:
/// The input cast to type T.
///
/// Throws:
/// - [TypeCoercionException] if the casting fails.
T cast<T>(dynamic input) {
  try {
    var typeString = T.toString();

    // Handle nullable types
    if (typeString.endsWith('?')) {
      if (input == null) {
        return null as T;
      } else {
        typeString = typeString.substring(0, typeString.length - 1);
      }
    }

    // Handle List types
    if (typeString.startsWith(_listPrefix)) {
      if (input is! List) {
        throw TypeError();
      }

      // Cast List to various element types
      if (typeString.startsWith("List<int>")) {
        return List<int>.from(input) as T;
      } else if (typeString.startsWith("List<num>")) {
        return List<num>.from(input) as T;
      } else if (typeString.startsWith("List<double>")) {
        return List<double>.from(input) as T;
      } else if (typeString.startsWith("List<String>")) {
        return List<String>.from(input) as T;
      } else if (typeString.startsWith("List<bool>")) {
        return List<bool>.from(input) as T;
      } else if (typeString.startsWith("List<int?>")) {
        return List<int?>.from(input) as T;
      } else if (typeString.startsWith("List<num?>")) {
        return List<num?>.from(input) as T;
      } else if (typeString.startsWith("List<double?>")) {
        return List<double?>.from(input) as T;
      } else if (typeString.startsWith("List<String?>")) {
        return List<String?>.from(input) as T;
      } else if (typeString.startsWith("List<bool?>")) {
        return List<bool?>.from(input) as T;
      } else if (typeString.startsWith("List<Map<String, dynamic>>")) {
        return List<Map<String, dynamic>>.from(input) as T;
      }
    }
    // Handle Map types
    else if (typeString.startsWith(_mapPrefix)) {
      if (input is! Map) {
        throw TypeError();
      }

      final inputMap = input as Map<String, dynamic>;

      // Cast Map to various value types
      if (typeString.startsWith("Map<String, int>")) {
        return Map<String, int>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, num>")) {
        return Map<String, num>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, double>")) {
        return Map<String, double>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, String>")) {
        return Map<String, String>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, bool>")) {
        return Map<String, bool>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, int?>")) {
        return Map<String, int?>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, num?>")) {
        return Map<String, num?>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, double?>")) {
        return Map<String, double?>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, String?>")) {
        return Map<String, String?>.from(inputMap) as T;
      } else if (typeString.startsWith("Map<String, bool?>")) {
        return Map<String, bool?>.from(inputMap) as T;
      }
    }

    // If no specific casting is needed, return the input as T
    return input as T;
  } on TypeError {
    // If a TypeError occurs during casting, throw a TypeCoercionException
    throw TypeCoercionException(T, input.runtimeType);
  }
}
