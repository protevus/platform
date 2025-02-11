import 'dart:async';

/// A lock for ensuring job uniqueness.
///
/// This class provides methods for acquiring and releasing locks to ensure
/// that only one instance of a job is running at a time.
class UniqueLock {
  /// The locks currently held.
  static final Map<String, DateTime> _locks = {};

  /// Acquire a lock for a job.
  ///
  /// [key] The unique key for the job.
  /// [expiration] The duration after which the lock should expire.
  ///
  /// Returns true if the lock was acquired, false otherwise.
  static bool acquire(String key, Duration expiration) {
    final now = DateTime.now();

    // Check if lock exists and hasn't expired
    if (_locks.containsKey(key)) {
      final lockTime = _locks[key]!;
      if (now.difference(lockTime) < expiration) {
        return false;
      }
    }

    _locks[key] = now;
    return true;
  }

  /// Release a lock for a job.
  ///
  /// [key] The unique key for the job.
  static void release(String key) {
    _locks.remove(key);
  }

  /// Get the expiration time for a lock.
  ///
  /// [key] The unique key for the job.
  ///
  /// Returns the expiration time if the lock exists, null otherwise.
  static DateTime? expiresAt(String key) {
    return _locks[key];
  }

  /// Check if a lock exists and hasn't expired.
  ///
  /// [key] The unique key for the job.
  /// [expiration] The duration after which the lock should expire.
  ///
  /// Returns true if the lock exists and hasn't expired, false otherwise.
  static bool exists(String key, Duration expiration) {
    if (!_locks.containsKey(key)) {
      return false;
    }

    final lockTime = _locks[key]!;
    final now = DateTime.now();
    return now.difference(lockTime) < expiration;
  }

  /// Clear all locks.
  ///
  /// This is mainly useful for testing purposes.
  static void clear() {
    _locks.clear();
  }

  /// Clear all expired locks.
  ///
  /// [expiration] The duration after which locks should be considered expired.
  static void clearExpired(Duration expiration) {
    final now = DateTime.now();
    _locks.removeWhere((key, time) => now.difference(time) >= expiration);
  }
}
