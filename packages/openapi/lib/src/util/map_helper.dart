/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Removes null values from a map and converts its type.
///
/// This function takes a nullable [Map] with potentially nullable values
/// and returns a new [Map] with the following characteristics:
/// - All entries with null values are removed.
/// - The resulting map is non-nullable (both for the map itself and its values).
/// - If the input map is null, an empty map is returned.
///
/// Parameters:
///   [map]: The input map of type `Map<K, V?>?` where `K` is the key type
///          and `V` is the value type.
///
/// Returns:
///   A new `Map<K, V>` with null values removed and non-nullable types.
Map<K, V> removeNullsFromMap<K, V>(Map<K, V?>? map) {
  if (map == null) return <K, V>{};

  final fixed = <K, V>{};

  // Iterate through all keys in the input map
  for (final key in map.keys) {
    // Get the value associated with the current key
    final value = map[key];
    // Check if the value is not null
    if (value != null) {
      // If the value is not null, add it to the 'fixed' map
      // This effectively removes all null values from the original map
      fixed[key] = value;
    }
  }

  return fixed;
}
