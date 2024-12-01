/// PSR-16 Cache Interface.
///
/// This is a Dart implementation of the PSR-16 CacheInterface.
/// It provides a simple caching interface for storing and retrieving values
/// by key.
abstract class CacheInterface {
  /// Fetches a value from the cache.
  ///
  /// Example:
  /// ```dart
  /// var value = await cache.get('key', defaultValue: 'default');
  /// ```
  Future<T?> get<T>(String key, {T? defaultValue});

  /// Persists data in the cache, uniquely referenced by a key.
  ///
  /// Example:
  /// ```dart
  /// await cache.set('key', 'value', ttl: Duration(minutes: 10));
  /// ```
  Future<bool> set(String key, dynamic value, {Duration? ttl});

  /// Delete an item from the cache by its unique key.
  ///
  /// Example:
  /// ```dart
  /// await cache.delete('key');
  /// ```
  Future<bool> delete(String key);

  /// Wipes clean the entire cache's keys.
  ///
  /// Example:
  /// ```dart
  /// await cache.clear();
  /// ```
  Future<bool> clear();

  /// Obtains multiple cache items by their unique keys.
  ///
  /// Example:
  /// ```dart
  /// var values = await cache.getMultiple(['key1', 'key2']);
  /// ```
  Future<Map<String, T?>> getMultiple<T>(Iterable<String> keys);

  /// Persists a set of key => value pairs in the cache.
  ///
  /// Example:
  /// ```dart
  /// await cache.setMultiple({
  ///   'key1': 'value1',
  ///   'key2': 'value2',
  /// });
  /// ```
  Future<bool> setMultiple(Map<String, dynamic> values, {Duration? ttl});

  /// Deletes multiple cache items in a single operation.
  ///
  /// Example:
  /// ```dart
  /// await cache.deleteMultiple(['key1', 'key2']);
  /// ```
  Future<bool> deleteMultiple(Iterable<String> keys);

  /// Determines whether an item is present in the cache.
  ///
  /// Example:
  /// ```dart
  /// if (await cache.has('key')) {
  ///   print('Cache has key');
  /// }
  /// ```
  Future<bool> has(String key);
}
