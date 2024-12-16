import 'filesystem.dart';

/// Interface for cloud filesystem operations.
abstract class Cloud extends Filesystem {
  /// Get the URL for the file at the given path.
  String url(String path);
}
