import 'filesystem.dart';

abstract class Factory {
  /// Get a filesystem implementation.
  ///
  /// @param  String? name
  /// @return Filesystem
  Filesystem disk([String? name]);
}
