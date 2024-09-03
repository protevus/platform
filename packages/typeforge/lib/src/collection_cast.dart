/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:core' as core;
import 'dart:core' hide Map, String, int;
import 'package:protevus_typeforge/cast.dart';

/// A cast operation for converting dynamic values to [core.Map<K, V>].
///
/// This class extends [Cast<core.Map<K, V>>] and implements the [safeCast] method
/// to perform type checking and conversion to [core.Map<K, V>].
///
/// The class uses two separate [Cast] instances:
/// - [_key] for casting the keys of the input map to type K
/// - [_value] for casting the values of the input map to type V
///
/// The [safeCast] method checks if the input [from] is already a [core.Map].
/// If it is, it creates a new map, casting each key-value pair using the
/// respective [_key] and [_value] casts. If not, it throws a [FailedCast]
/// exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final mapCast = Map(StringCast(), IntCast());
/// final result = mapCast.cast({"a": 1, "b": 2}); // Returns Map<String, int>
/// mapCast.cast("not a map"); // Throws FailedCast
/// ```
class Map<K, V> extends Cast<core.Map<K, V>> {
  final Cast<K> _key;
  final Cast<V> _value;
  const Map(Cast<K> key, Cast<V> value)
      : _key = key,
        _value = value;
  @override
  core.Map<K, V> safeCast(dynamic from, core.String context, dynamic key) {
    if (from is core.Map) {
      final result = <K, V>{};
      for (final key in from.keys) {
        final newKey = _key.safeCast(key, "map entry", key);
        result[newKey] = _value.safeCast(from[key], "map entry", key);
      }
      return result;
    }
    return throw FailedCast(context, key, "not a map");
  }
}

/// A cast operation for converting dynamic values to [core.Map<core.String, V>].
///
/// This class extends [Cast<core.Map<core.String, V>>] and implements the [safeCast] method
/// to perform type checking and conversion to [core.Map<core.String, V>].
///
/// The class uses a [Cast<V>] instance [_value] for casting the values of the input map to type V.
///
/// The [safeCast] method checks if the input [from] is already a [core.Map].
/// If it is, it creates a new map with [core.String] keys and values of type V,
/// casting each value using the [_value] cast. If not, it throws a [FailedCast]
/// exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final stringMapCast = StringMap(IntCast());
/// final result = stringMapCast.cast({"a": 1, "b": 2}); // Returns Map<String, int>
/// stringMapCast.cast("not a map"); // Throws FailedCast
/// ```
class StringMap<V> extends Cast<core.Map<core.String, V>> {
  final Cast<V> _value;
  const StringMap(Cast<V> value) : _value = value;
  @override
  core.Map<core.String, V> safeCast(
    dynamic from,
    core.String context,
    dynamic key,
  ) {
    if (from is core.Map) {
      final result = <core.String, V>{};
      for (final core.String key in from.keys as core.Iterable<core.String>) {
        result[key] = _value.safeCast(from[key], "map entry", key);
      }
      return result;
    }
    return throw FailedCast(context, key, "not a map");
  }
}

/// A cast operation for converting dynamic values to [core.List<E?>].
///
/// This class extends [Cast<core.List<E?>>] and implements the [safeCast] method
/// to perform type checking and conversion to [core.List<E?>].
///
/// The class uses a [Cast<E>] instance [_entry] for casting each element of the input list to type E.
///
/// The [safeCast] method checks if the input [from] is already a [core.List].
/// If it is, it creates a new list of nullable E elements, casting each non-null
/// element using the [_entry] cast and preserving null values. If not, it throws
/// a [FailedCast] exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final listCast = List(IntCast());
/// final result = listCast.cast([1, 2, null, 3]); // Returns List<int?>
/// listCast.cast("not a list"); // Throws FailedCast
/// ```
class List<E> extends Cast<core.List<E?>> {
  final Cast<E> _entry;
  const List(Cast<E> entry) : _entry = entry;
  @override
  core.List<E?> safeCast(dynamic from, core.String context, dynamic key) {
    if (from is core.List) {
      final length = from.length;
      final result = core.List<E?>.filled(length, null);
      for (core.int i = 0; i < length; ++i) {
        if (from[i] != null) {
          result[i] = _entry.safeCast(from[i], "list entry", i);
        } else {
          result[i] = null;
        }
      }
      return result;
    }
    return throw FailedCast(context, key, "not a list");
  }
}
