import 'dart:async';

/// Interface for filesystem operations.
abstract class Filesystem {
  /// The public visibility setting.
  static const String visibilityPublic = 'public';

  /// The private visibility setting.
  static const String visibilityPrivate = 'private';

  /// Get the full path to the file at the given relative path.
  String path(String path);

  /// Determine if a file exists.
  Future<bool> exists(String path);

  /// Get the contents of a file.
  Future<String?> get(String path);

  /// Get a resource to read the file.
  Future<Stream<List<int>>?> readStream(String path);

  /// Write the contents of a file.
  Future<bool> put(String path, dynamic contents,
      [Map<String, dynamic> options = const {}]);

  /// Store the uploaded file on the disk.
  Future<String?> putFile(String path,
      [dynamic file, Map<String, dynamic> options = const {}]);

  /// Store the uploaded file on the disk with a given name.
  Future<String?> putFileAs(String path, dynamic file,
      [String? name, Map<String, dynamic> options = const {}]);

  /// Write a new file using a stream.
  Future<bool> writeStream(String path, Stream<List<int>> resource,
      [Map<String, dynamic> options = const {}]);

  /// Get the visibility for the given path.
  Future<String> getVisibility(String path);

  /// Set the visibility for the given path.
  Future<bool> setVisibility(String path, String visibility);

  /// Prepend to a file.
  Future<bool> prepend(String path, String data);

  /// Append to a file.
  Future<bool> append(String path, String data);

  /// Delete the file at a given path.
  Future<bool> delete(dynamic paths);

  /// Copy a file to a new location.
  Future<bool> copy(String from, String to);

  /// Move a file to a new location.
  Future<bool> move(String from, String to);

  /// Get the file size of a given file.
  Future<int> size(String path);

  /// Get the file's last modification time.
  Future<int> lastModified(String path);

  /// Get an array of all files in a directory.
  Future<List<String>> files([String? directory, bool recursive = false]);

  /// Get all of the files from the given directory (recursive).
  Future<List<String>> allFiles([String? directory]);

  /// Get all of the directories within a given directory.
  Future<List<String>> directories([String? directory, bool recursive = false]);

  /// Get all (recursive) of the directories within a given directory.
  Future<List<String>> allDirectories([String? directory]);

  /// Create a directory.
  Future<bool> makeDirectory(String path);

  /// Recursively delete a directory.
  Future<bool> deleteDirectory(String directory);
}
