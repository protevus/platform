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

/// A cast operation that accepts and returns any dynamic value without modification.
///
/// This class extends [Cast<dynamic>] and provides a no-op cast operation.
/// It's useful when you want to allow any type to pass through without
/// performing any type checking or transformation.
///
/// The [safeCast] method simply returns the input value as-is, regardless of its type.
///
/// Example usage:
/// ```dart
/// final anyCast = AnyCast();
/// final result = anyCast.cast(someValue); // Returns someValue unchanged
/// ```
class AnyCast extends Cast<dynamic> {
  const AnyCast();
  @override
  dynamic safeCast(dynamic from, core.String context, dynamic key) => from;
}

/// A cast operation for converting dynamic values to [core.Map<K, V>] with specific key-value casts.
///
/// This class extends [Cast<core.Map<K, V>>] and implements the [safeCast] method
/// to perform type checking and conversion to [core.Map<K, V>] based on a predefined
/// map of key-specific casts.
///
/// The class uses a [core.Map<K, Cast<V>>] to define custom casts for specific keys.
/// Keys not present in this map will be cast as-is.
///
/// The [keys] getter provides access to the keys of the internal cast map.
///
/// The [safeCast] method checks if the input [from] is a [core.Map]. If it is,
/// it creates a new map, applying the specific casts for keys present in [_map]
/// and preserving other key-value pairs as-is. If not, it throws a [FailedCast]
/// exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final keyedCast = Keyed<String, dynamic>({
///   'age': IntCast(),
///   'name': StringCast(),
/// });
/// final result = keyedCast.cast({'age': 30, 'name': 'John', 'city': 'New York'});
/// // Returns Map<String, dynamic> with 'age' as int, 'name' as String, and 'city' preserved as-is
/// ```
class Keyed<K, V> extends Cast<core.Map<K, V>> {
  Iterable<K> get keys => _map.keys;
  final core.Map<K, Cast<V>> _map;
  const Keyed(core.Map<K, Cast<V>> map) : _map = map;
  @override
  core.Map<K, V> safeCast(dynamic from, core.String context, dynamic key) {
    final core.Map<K, V> result = {};
    if (from is core.Map) {
      for (final K key in from.keys as core.Iterable<K>) {
        if (_map.containsKey(key)) {
          result[key] = _map[key]!.safeCast(from[key], "map entry", key);
        } else {
          result[key] = from[key] as V;
        }
      }
      return result;
    }
    throw FailedCast(context, key, "not a map");
  }
}
