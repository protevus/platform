import 'cache_item_interface.dart';

/// A cache pool interface for managing cache items.
abstract class CacheItemPoolInterface {
  /// Returns a Cache Item representing the specified key.
  ///
  /// [key] The key for which to return the corresponding Cache Item.
  /// Returns The corresponding Cache Item.
  /// Throws InvalidArgumentException if the [key] string is not valid.
  CacheItemInterface getItem(String key);

  /// Returns a list of Cache Items keyed by the cache keys provided.
  ///
  /// [keys] A list of keys that can be obtained in a single operation.
  /// Returns A list of Cache Items indexed by the cache keys.
  /// Throws InvalidArgumentException if any of the keys in [keys] is not valid.
  Map<String, CacheItemInterface> getItems(List<String> keys);

  /// Confirms if the cache contains specified cache item.
  ///
  /// [key] The key for which to check existence.
  /// Returns true if item exists in the cache and false otherwise.
  /// Throws InvalidArgumentException if the [key] string is not valid.
  bool hasItem(String key);

  /// Deletes all items in the pool.
  ///
  /// Returns true if the pool was successfully cleared. False if there was an error.
  bool clear();

  /// Removes the item from the pool.
  ///
  /// [key] The key to delete.
  /// Returns true if the item was successfully removed. False if there was an error.
  /// Throws InvalidArgumentException if the [key] string is not valid.
  bool deleteItem(String key);

  /// Removes multiple items from the pool.
  ///
  /// [keys] A list of keys that should be removed.
  /// Returns true if the items were successfully removed. False if there was an error.
  /// Throws InvalidArgumentException if any of the keys in [keys] is not valid.
  bool deleteItems(List<String> keys);

  /// Persists a cache item immediately.
  ///
  /// [item] The cache item to save.
  /// Returns true if the item was successfully persisted. False if there was an error.
  bool save(CacheItemInterface item);

  /// Persists multiple cache items immediately.
  ///
  /// [items] A list of cache items to save.
  /// Returns true if all items were successfully persisted. False if there was an error.
  bool saveDeferred(CacheItemInterface item);

  /// Persists any deferred cache items.
  ///
  /// Returns true if all not-yet-saved items were successfully persisted. False if there was an error.
  bool commit();
}
