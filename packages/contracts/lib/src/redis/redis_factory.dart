/// Interface for Redis factory.
abstract class RedisFactory {
  /// Get a Redis connection by name.
  dynamic connection([String? name]);
}
