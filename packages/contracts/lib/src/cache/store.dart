/// Interface for cache store implementations.
///
/// This contract defines how cache stores should handle low-level cache operations.
/// It provides methods for storing, retrieving, and managing cached items at the
/// storage level.
abstract class CacheStore {
  /// Retrieve an item from the cache by key.
  ///
  /// Example:
  /// ```dart
  /// var value = await store.get('key');
  /// ```
  Future<dynamic> get(String key);

  /// Retrieve multiple items from the cache by key.
  ///
  /// Items not found in the cache will have a null value.
  ///
  /// Example:
  /// ```dart
  /// var values = await store.many(['key1', 'key2']);
  /// ```
  Future<Map<String, dynamic>> many(List<String> keys);

  /// Store an item in the cache for a given number of seconds.
  ///
  /// Example:
  /// ```dart
  /// await store.put('key', 'value', 600); // 10 minutes
  /// ```
  Future<bool> put(String key, dynamic value, int seconds);

  /// Store multiple items in the cache for a given number of seconds.
  ///
  /// Example:
  /// ```dart
  /// await store.putMany({
  ///   'key1': 'value1',
  ///   'key2': 'value2',
  /// }, 600); // 10 minutes
  /// ```
  Future<bool> putMany(Map<String, dynamic> values, int seconds);

  /// Increment the value of an item in the cache.
  ///
  /// Example:
  /// ```dart
  /// var newValue = await store.increment('visits');
  /// ```
  Future<int?> increment(String key, [int value = 1]);

  /// Decrement the value of an item in the cache.
  ///
  /// Example:
  /// ```dart
  /// var newValue = await store.decrement('remaining');
  /// ```
  Future<int?> decrement(String key, [int value = 1]);

  /// Store an item in the cache indefinitely.
  ///
  /// Example:
  /// ```dart
  /// await store.forever('key', 'value');
  /// ```
  Future<bool> forever(String key, dynamic value);

  /// Remove an item from the cache.
  ///
  /// Example:
  /// ```dart
  /// await store.forget('key');
  /// ```
  Future<bool> forget(String key);

  /// Remove all items from the cache.
  ///
  /// Example:
  /// ```dart
  /// await store.flush();
  /// ```
  Future<bool> flush();

  /// Get the cache key prefix.
  ///
  /// Example:
  /// ```dart
  /// var prefix = store.getPrefix();
  /// ```
  String getPrefix();
}
