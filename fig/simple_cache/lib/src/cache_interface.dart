import 'exceptions.dart';

/// Interface for caching libraries.
///
/// The key of the cache item must be a string with max length 64 characters,
/// containing only A-Z, a-z, 0-9, _, and .
abstract class CacheInterface {
  /// Fetches a value from the cache.
  ///
  /// [key] The unique key of this item in the cache.
  /// [defaultValue] Default value to return if the key does not exist.
  ///
  /// Returns the value of the item from the cache, or [defaultValue] if not found.
  ///
  /// Throws [InvalidArgumentException] if the [key] is not a legal value.
  dynamic get(String key, [dynamic defaultValue]);

  /// Persists data in the cache, uniquely referenced by a key.
  ///
  /// [key] The key of the item to store.
  /// [value] The value of the item to store. Must be serializable.
  /// [ttl] Optional. The TTL value of this item.
  ///
  /// Returns true on success and false on failure.
  ///
  /// Throws [InvalidArgumentException] if the [key] is not a legal value.
  bool set(String key, dynamic value, [Duration? ttl]);

  /// Delete an item from the cache by its unique key.
  ///
  /// [key] The unique cache key of the item to delete.
  ///
  /// Returns true if the item was successfully removed.
  /// Returns false if there was an error.
  ///
  /// Throws [InvalidArgumentException] if the [key] is not a legal value.
  bool delete(String key);

  /// Wipes clean the entire cache's keys.
  ///
  /// Returns true on success and false on failure.
  bool clear();

  /// Obtains multiple cache items by their unique keys.
  ///
  /// [keys] A list of keys that can be obtained in a single operation.
  ///
  /// Returns a Map of key => value pairs. Cache keys that do not exist or are
  /// stale will have a null value.
  ///
  /// Throws [InvalidArgumentException] if any of the [keys] are not legal values.
  Map<String, dynamic> getMultiple(Iterable<String> keys,
      [dynamic defaultValue]);

  /// Persists a set of key => value pairs in the cache.
  ///
  /// [values] A map of key => value pairs for a multiple-set operation.
  /// [ttl] Optional. The TTL value of this item.
  ///
  /// Returns true on success and false on failure.
  ///
  /// Throws [InvalidArgumentException] if any of the [values] keys are not
  /// legal values.
  bool setMultiple(Map<String, dynamic> values, [Duration? ttl]);

  /// Deletes multiple cache items in a single operation.
  ///
  /// [keys] A list of keys to be deleted.
  ///
  /// Returns true if the items were successfully removed.
  /// Returns false if there was an error.
  ///
  /// Throws [InvalidArgumentException] if any of the [keys] are not legal values.
  bool deleteMultiple(Iterable<String> keys);

  /// Determines whether an item is present in the cache.
  ///
  /// [key] The cache item key.
  ///
  /// Returns true if cache item exists, false otherwise.
  ///
  /// Throws [InvalidArgumentException] if the [key] is not a legal value.
  bool has(String key);
}
