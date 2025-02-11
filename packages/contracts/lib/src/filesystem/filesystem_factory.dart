import 'filesystem.dart';

/// Interface for filesystem factory.
abstract class FilesystemFactory {
  /// Get a filesystem implementation.
  FilesystemContract disk([String? name]);
}
