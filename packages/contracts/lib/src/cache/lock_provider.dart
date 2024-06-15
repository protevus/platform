import 'lock.dart';
abstract class LockProvider {
  /// Get a lock instance.
  ///
  /// @param  String  name
  /// @param  int  seconds
  /// @param  String|null  owner
  /// @return Lock
  Lock lock(String name, {int seconds = 0, String? owner});

  /// Restore a lock instance using the owner identifier.
  ///
  /// @param  String  name
  /// @param  String  owner
  /// @return Lock
  Lock restoreLock(String name, String owner);
}
