/// Interface for filesystem operations.
abstract class FilesystemContract {
  /// The public visibility setting.
  static const String visibilityPublic = 'public';

  /// The private visibility setting.
  static const String visibilityPrivate = 'private';

  /// Get the full path to the file that exists at the given relative path.
  ///
  /// @param path The relative path to the file
  /// @return The full path to the file
  String path(String path);

  /// Determine if a file exists.
  ///
  /// @param path The path to check
  /// @return True if file exists, false otherwise
  bool exists(String path);

  /// Get the contents of a file.
  ///
  /// @param path The path to the file
  /// @return The contents of the file or null on failure
  String? get(String path);

  /// Get a resource to read the file.
  ///
  /// @param path The path to the file
  /// @return A Stream to read the file or null on failure
  Stream<List<int>>? readStream(String path);

  /// Write the contents of a file.
  ///
  /// @param path The path to write to
  /// @param contents The contents to write (Stream, File, String, etc)
  /// @param options Additional options
  /// @return True on success, false on failure
  bool put(String path, dynamic contents, [dynamic options]);

  /// Store the uploaded file on the disk.
  ///
  /// @param path The path or file to store
  /// @param file The file to store (optional if path is the file)
  /// @param options Additional options
  /// @return The path where the file was stored, or false on failure
  String? putFile(dynamic path, [dynamic file, dynamic options]);

  /// Store the uploaded file on the disk with a given name.
  ///
  /// @param path The path to store in
  /// @param file The file to store
  /// @param name The name to give the file
  /// @param options Additional options
  /// @return The path where the file was stored, or false on failure
  String? putFileAs(dynamic path, dynamic file,
      [String? name, dynamic options]);

  /// Write a new file using a stream.
  ///
  /// @param path The path to write to
  /// @param resource The stream to write from
  /// @param options Additional options
  /// @return True on success, false on failure
  bool writeStream(String path, Stream<List<int>> resource,
      [Map<String, dynamic> options = const {}]);

  /// Get the visibility for the given path.
  ///
  /// @param path The path to check
  /// @return The visibility (public or private)
  String getVisibility(String path);

  /// Set the visibility for the given path.
  ///
  /// @param path The path to set
  /// @param visibility The visibility to set
  /// @return True on success, false on failure
  bool setVisibility(String path, String visibility);

  /// Prepend to a file.
  ///
  /// @param path The path to the file
  /// @param data The data to prepend
  /// @return True on success, false on failure
  bool prepend(String path, String data);

  /// Append to a file.
  ///
  /// @param path The path to the file
  /// @param data The data to append
  /// @return True on success, false on failure
  bool append(String path, String data);

  /// Delete the file at a given path.
  ///
  /// @param paths The path(s) to delete
  /// @return True on success, false on failure
  bool delete(dynamic paths);

  /// Copy a file to a new location.
  ///
  /// @param from Source path
  /// @param to Destination path
  /// @return True on success, false on failure
  bool copy(String from, String to);

  /// Move a file to a new location.
  ///
  /// @param from Source path
  /// @param to Destination path
  /// @return True on success, false on failure
  bool move(String from, String to);

  /// Get the file size of a given file.
  ///
  /// @param path The path to check
  /// @return The size in bytes
  int size(String path);

  /// Get the file's last modification time.
  ///
  /// @param path The path to check
  /// @return The modification timestamp
  int lastModified(String path);

  /// Get an array of all files in a directory.
  ///
  /// @param directory The directory to scan
  /// @param recursive Whether to scan recursively
  /// @return List of file paths
  List<String> files([String? directory, bool recursive = false]);

  /// Get all of the files from the given directory (recursive).
  ///
  /// @param directory The directory to scan
  /// @return List of file paths
  List<String> allFiles([String? directory]);

  /// Get all of the directories within a given directory.
  ///
  /// @param directory The directory to scan
  /// @param recursive Whether to scan recursively
  /// @return List of directory paths
  List<String> directories([String? directory, bool recursive = false]);

  /// Get all (recursive) of the directories within a given directory.
  ///
  /// @param directory The directory to scan
  /// @return List of directory paths
  List<String> allDirectories([String? directory]);

  /// Create a directory.
  ///
  /// @param path The path to create
  /// @return True on success, false on failure
  bool makeDirectory(String path);

  /// Recursively delete a directory.
  ///
  /// @param directory The directory to delete
  /// @return True on success, false on failure
  bool deleteDirectory(String directory);
}
