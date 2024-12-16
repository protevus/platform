/// A cache item interface representing a single cache entry.
abstract class CacheItemInterface {
  /// The key for this cache item.
  String get key;

  /// Retrieves the value of the item from the cache.
  ///
  /// Returns null if the item does not exist or has expired.
  dynamic get();

  /// Confirms if the cache item lookup resulted in a cache hit.
  bool get isHit;

  /// Sets the value represented by this cache item.
  ///
  /// [value] The serializable value to be stored.
  /// Returns the invoked object.
  CacheItemInterface set(dynamic value);

  /// Sets the expiration time for this cache item.
  ///
  /// [expiration] The point in time after which the item MUST be considered expired.
  /// Returns the invoked object.
  CacheItemInterface expiresAt(DateTime? expiration);

  /// Sets the expiration time for this cache item relative to the current time.
  ///
  /// [time] The period of time from now after which the item MUST be considered expired.
  /// Returns the invoked object.
  CacheItemInterface expiresAfter(Duration? time);
}
