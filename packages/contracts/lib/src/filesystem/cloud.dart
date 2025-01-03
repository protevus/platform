import 'filesystem.dart';

/// Interface for cloud filesystem operations.
abstract class CloudFilesystemContract extends FilesystemContract {
  /// Get the URL for the file at the given path.
  ///
  /// @param path The path to the file
  /// @return The URL to access the file
  String url(String path);
}
