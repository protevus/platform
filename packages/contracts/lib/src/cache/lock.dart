/// Interface for cache locks.
///
/// This contract defines how cache locks should behave, providing methods
/// for acquiring, releasing, and managing locks.
abstract class Lock {
  /// Attempt to acquire the lock.
  ///
  /// Example:
  /// ```dart
  /// if (await lock.acquire()) {
  ///   try {
  ///     // Process that requires locking
  ///   } finally {
  ///     await lock.release();
  ///   }
  /// }
  /// ```
  Future<bool> acquire();

  /// Release the lock.
  ///
  /// Example:
  /// ```dart
  /// await lock.release();
  /// ```
  Future<bool> release();

  /// Get the owner value of the lock.
  ///
  /// Example:
  /// ```dart
  /// var owner = lock.owner();
  /// ```
  String? owner();

  /// Attempt to acquire the lock for the given number of seconds.
  ///
  /// Example:
  /// ```dart
  /// if (await lock.block(5)) {
  ///   // Lock was acquired
  /// }
  /// ```
  Future<bool> block(int seconds);
}
