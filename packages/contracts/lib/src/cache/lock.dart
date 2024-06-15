abstract class Lock {
  /// Attempt to acquire the lock.
  ///
  /// @param Function? callback
  /// @return dynamic
  Future<dynamic> get([Function? callback]);

  /// Attempt to acquire the lock for the given number of seconds.
  ///
  /// @param int seconds
  /// @param Function? callback
  /// @return dynamic
  Future<dynamic> block(int seconds, [Function? callback]);

  /// Release the lock.
  ///
  /// @return bool
  Future<bool> release();

  /// Returns the current owner of the lock.
  ///
  /// @return String
  Future<String> owner();

  /// Releases this lock in disregard of ownership.
  ///
  /// @return void
  Future<void> forceRelease();
}
