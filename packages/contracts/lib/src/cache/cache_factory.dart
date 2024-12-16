import 'repository.dart';

/// Interface for creating cache store instances.
///
/// This contract defines how cache store instances should be created and managed.
/// It provides methods for getting cache store instances by name.
abstract class CacheFactory {
  /// Get a cache store instance by name.
  ///
  /// Example:
  /// ```dart
  /// // Get the default store
  /// var store = factory.store();
  ///
  /// // Get a specific store
  /// var redisStore = factory.store('redis');
  /// ```
  Future<CacheRepository> store([String? name]);
}
