import 'lock.dart';

/// Interface for creating lock instances.
///
/// This contract defines how lock instances should be created and restored,
/// providing methods for getting new locks and restoring existing ones.
abstract class LockProvider {
  /// Get a lock instance.
  ///
  /// Example:
  /// ```dart
  /// var lock = provider.lock(
  ///   'processing-order-1',
  ///   seconds: 60,
  ///   owner: 'worker-1',
  /// );
  /// ```
  Lock lock(String name, {int seconds = 0, String? owner});

  /// Restore a lock instance using the owner identifier.
  ///
  /// Example:
  /// ```dart
  /// var lock = provider.restoreLock(
  ///   'processing-order-1',
  ///   'worker-1',
  /// );
  /// ```
  Lock restoreLock(String name, String owner);
}
