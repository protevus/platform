import 'filesystem.dart';
abstract class Cloud implements Filesystem {
  /// Get the URL for the file at the given path.
  ///
  /// @param  String path
  /// @return String
  String url(String path);
}