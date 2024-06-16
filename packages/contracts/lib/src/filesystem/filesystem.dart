import 'dart:typed_data';
import 'dart:io';

abstract class Filesystem {
  /// The public visibility setting.
  static const String VISIBILITY_PUBLIC = 'public';

  /// The private visibility setting.
  static const String VISIBILITY_PRIVATE = 'private';

  /// Get the full path to the file that exists at the given relative path.
  ///
  /// @param  String  path
  /// @return String
  String path(String path);

  /// Determine if a file exists.
  ///
  /// @param  String  path
  /// @return bool
  bool exists(String path);

  /// Get the contents of a file.
  ///
  /// @param  String  path
  /// @return Uint8List? (null if file doesn't exist)
  Uint8List? get(String path);

  /// Get a resource to read the file.
  ///
  /// @param  String  path
  /// @return Stream<List<int>>? (null if file doesn't exist)
  Stream<List<int>>? readStream(String path);

  /// Write the contents of a file.
  ///
  /// @param  String  path
  /// @param  dynamic contents
  /// @param  Map<String, dynamic>? options
  /// @return bool
  bool put(String path, dynamic contents, [Map<String, dynamic>? options]);

  /// Store the uploaded file on the disk.
  ///
  /// @param  String  path
  /// @param  dynamic file
  /// @param  Map<String, dynamic>? options
  /// @return String|false
  dynamic putFile(String path, dynamic file, [Map<String, dynamic>? options]);

  /// Store the uploaded file on the disk with a given name.
  ///
  /// @param  String  path
  /// @param  dynamic file
  /// @param  String? name
  /// @param  Map<String, dynamic>? options
  /// @return String|false
  dynamic putFileAs(String path, dynamic file, [String? name, Map<String, dynamic>? options]);

  /// Write a new file using a stream.
  ///
  /// @param  String  path
  /// @param  Stream<List<int>>  resource
  /// @param  Map<String, dynamic>? options
  /// @return bool
  bool writeStream(String path, Stream<List<int>> resource, [Map<String, dynamic>? options]);

  /// Get the visibility for the given path.
  ///
  /// @param  String  path
  /// @return String
  String getVisibility(String path);

  /// Set the visibility for the given path.
  ///
  /// @param  String  path
  /// @param  String  visibility
  /// @return bool
  bool setVisibility(String path, String visibility);

  /// Prepend to a file.
  ///
  /// @param  String  path
  /// @param  String  data
  /// @return bool
  bool prepend(String path, String data);

  /// Append to a file.
  ///
  /// @param  String  path
  /// @param  String  data
  /// @return bool
  bool append(String path, String data);

  /// Delete the file at a given path.
  ///
  /// @param  dynamic  paths
  /// @return bool
  bool delete(dynamic paths);

  /// Copy a file to a new location.
  ///
  /// @param  String  from
  /// @param  String  to
  /// @return bool
  bool copy(String from, String to);

  /// Move a file to a new location.
  ///
  /// @param  String  from
  /// @param  String  to
  /// @return bool
  bool move(String from, String to);

  /// Get the file size of a given file.
  ///
  /// @param  String  path
  /// @return int
  int size(String path);

  /// Get the file's last modification time.
  ///
  /// @param  String  path
  /// @return DateTime
  DateTime lastModified(String path);

  /// Get an array of all files in a directory.
  ///
  /// @param  String?  directory
  /// @param  bool  recursive
  /// @return List<String>
  List<String> files([String? directory, bool recursive = false]);

  /// Get all of the files from the given directory (recursive).
  ///
  /// @param  String?  directory
  /// @return List<String>
  List<String> allFiles([String? directory]);

  /// Get all of the directories within a given directory.
  ///
  /// @param  String?  directory
  /// @param  bool  recursive
  /// @return List<String>
  List<String> directories([String? directory, bool recursive = false]);

  /// Get all (recursive) of the directories within a given directory.
  ///
  /// @param  String?  directory
  /// @return List<String>
  List<String> allDirectories([String? directory]);

  /// Create a directory.
  ///
  /// @param  String  path
  /// @return bool
  bool makeDirectory(String path);

  /// Recursively delete a directory.
  ///
  /// @param  String  directory
  /// @return bool
  bool deleteDirectory(String directory);
}
