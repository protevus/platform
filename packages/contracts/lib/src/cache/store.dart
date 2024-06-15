abstract class Store {
  /// Retrieve an item from the cache by key.
  ///
  /// @param  String  key
  /// @return dynamic
  dynamic get(String key);

  /// Retrieve multiple items from the cache by key.
  ///
  /// Items not found in the cache will have a null value.
  ///
  /// @param  List<String>  keys
  /// @return Map<String, dynamic>
  Map<String, dynamic> many(List<String> keys);

  /// Store an item in the cache for a given number of seconds.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @param  int  seconds
  /// @return bool
  bool put(String key, dynamic value, int seconds);

  /// Store multiple items in the cache for a given number of seconds.
  ///
  /// @param  Map<String, dynamic>  values
  /// @param  int  seconds
  /// @return bool
  bool putMany(Map<String, dynamic> values, int seconds);

  /// Increment the value of an item in the cache.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @return int|bool
  dynamic increment(String key, {dynamic value = 1});

  /// Decrement the value of an item in the cache.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @return int|bool
  dynamic decrement(String key, {dynamic value = 1});

  /// Store an item in the cache indefinitely.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @return bool
  bool forever(String key, dynamic value);

  /// Remove an item from the cache.
  ///
  /// @param  String  key
  /// @return bool
  bool forget(String key);

  /// Remove all items from the cache.
  ///
  /// @return bool
  bool flush();

  /// Get the cache key prefix.
  ///
  /// @return String
  String getPrefix();
}
