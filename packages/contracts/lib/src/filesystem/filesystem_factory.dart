import 'filesystem.dart';

/// Interface for filesystem factory.
abstract class FilesystemFactory {
  /// Get a filesystem implementation.
  Filesystem disk([String? name]);
}
