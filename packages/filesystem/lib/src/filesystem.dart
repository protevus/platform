import 'dart:io';

import 'package:platform_contracts/contracts.dart';
import 'package:platform_macroable/platform_macroable.dart';
import 'package:platform_conditionable/platform_conditionable.dart';

import 'utilities.dart';

/// The Filesystem class provides a fluent API for interacting with the filesystem.
///
/// This is a pure Dart implementation that maintains API compatibility with Laravel's
/// Filesystem class while following Dart idioms and best practices.
class Filesystem with Macroable, Conditionable implements FilesystemContract {
  /// Get the full path to the file that exists at the given relative path.
  @override
  String path(String path) => path;

  /// Determine if a file exists.
  @override
  bool exists(String path) {
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }

  /// Get the contents of a file.
  @override
  String? get(String path) {
    try {
      if (!isFile(path)) return null;
      return File(path).readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  /// Get a resource to read the file.
  @override
  Stream<List<int>>? readStream(String path) {
    try {
      if (!isFile(path)) return null;
      return File(path).openRead();
    } catch (e) {
      return null;
    }
  }

  /// Write the contents of a file.
  @override
  bool put(String path, dynamic contents, [dynamic options]) {
    try {
      final file = File(path);

      if (contents is Stream<List<int>>) {
        // We can't handle streams synchronously in a clean way
        // Convert to a file first if it's a stream
        return false;
      }

      if (contents is List<int>) {
        file.writeAsBytesSync(contents);
        return true;
      }

      file.writeAsStringSync(contents.toString());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Store the uploaded file on the disk.
  @override
  String? putFile(dynamic path, [dynamic file, dynamic options]) {
    try {
      if (file == null) {
        file = path;
        path = file.path;
      }

      if (file is File) {
        final bytes = file.readAsBytesSync();
        return put(path, bytes, options) ? path : null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Store the uploaded file on the disk with a given name.
  @override
  String? putFileAs(dynamic path, dynamic file,
      [String? name, dynamic options]) {
    try {
      if (file == null) return null;

      final fileName = name ?? path_basename(file.path);
      final fullPath = path_join(path, fileName);

      return putFile(fullPath, file, options);
    } catch (e) {
      return null;
    }
  }

  /// Write a new file using a stream.
  @override
  bool writeStream(String path, Stream<List<int>> resource,
      [Map<String, dynamic> options = const {}]) {
    try {
      final file = File(path);
      final sink = file.openWrite();
      resource.listen(
        (data) => sink.add(data),
        onDone: () => sink.close(),
        onError: (e) => sink.close(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the visibility for the given path.
  @override
  String getVisibility(String path) {
    try {
      if (!exists(path)) {
        return FilesystemContract.visibilityPrivate;
      }

      final stat = FileStat.statSync(path);
      // Check if others have read permission (0o004)
      final worldReadable = (stat.mode & 0x004) != 0;
      // Check if group has read permission (0o040)
      final groupReadable = (stat.mode & 0x040) != 0;
      // Check if owner has write permission (0o200)
      final ownerWritable = (stat.mode & 0x200) != 0;

      // Public if world readable, group readable, and owner writable
      return (worldReadable && groupReadable && ownerWritable)
          ? FilesystemContract.visibilityPublic
          : FilesystemContract.visibilityPrivate;
    } catch (e) {
      return FilesystemContract.visibilityPrivate;
    }
  }

  /// Set the visibility for the given path.
  @override
  bool setVisibility(String path, String visibility) {
    try {
      if (!exists(path)) return false;

      final isPublic = visibility == FilesystemContract.visibilityPublic;
      if (Platform.isWindows) {
        // On Windows, use attrib command
        final attr = isPublic ? '-r' : '+r';
        final result = Process.runSync('attrib', [attr, path]);
        if (result.exitCode != 0) return false;
      } else {
        // On Unix-like systems, use chmod
        // 644 = owner rw, group r, others r (public)
        // 600 = owner rw, group -, others - (private)
        final mode = isPublic ? '0644' : '0600';
        final result = Process.runSync('chmod', [mode, path]);
        if (result.exitCode != 0) return false;

        // Wait for permissions to be updated and verify
        sleep(Duration(milliseconds: 100));
        final stat = FileStat.statSync(path);
        final worldReadable = (stat.mode & 0x004) != 0;
        final groupReadable = (stat.mode & 0x040) != 0;
        final ownerWritable = (stat.mode & 0x200) != 0;

        // Verify all permissions for public
        return (worldReadable && groupReadable && ownerWritable) == isPublic;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Prepend to a file.
  @override
  bool prepend(String path, String data) {
    try {
      final content = get(path);
      return put(path, data + (content ?? ''));
    } catch (e) {
      return false;
    }
  }

  /// Append to a file.
  @override
  bool append(String path, String data) {
    try {
      final content = get(path);
      return put(path, (content ?? '') + data);
    } catch (e) {
      return false;
    }
  }

  /// Delete the file at a given path.
  @override
  bool delete(dynamic paths) {
    try {
      final pathList = paths is List ? paths : [paths];
      var success = true;

      for (final path in pathList) {
        try {
          File(path).deleteSync();
        } catch (e) {
          success = false;
        }
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Copy a file to a new location.
  @override
  bool copy(String from, String to) {
    try {
      File(from).copySync(to);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Move a file to a new location.
  @override
  bool move(String from, String to) {
    try {
      File(from).renameSync(to);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the file size of a given file.
  @override
  int size(String path) {
    try {
      return File(path).lengthSync();
    } catch (e) {
      return 0;
    }
  }

  /// Get the file's last modification time.
  @override
  int lastModified(String path) {
    try {
      return File(path).lastModifiedSync().millisecondsSinceEpoch ~/ 1000;
    } catch (e) {
      return 0;
    }
  }

  /// Get an array of all files in a directory.
  @override
  List<String> files([String? directory, bool recursive = false]) {
    try {
      final dir = Directory(directory ?? '.');
      final files = <String>[];

      for (final entity in dir.listSync(recursive: recursive)) {
        if (entity is File) {
          files.add(entity.path);
        }
      }

      files.sort();
      return files;
    } catch (e) {
      return [];
    }
  }

  /// Get all of the files from the given directory (recursive).
  @override
  List<String> allFiles([String? directory]) {
    return files(directory, true);
  }

  /// Get all of the directories within a given directory.
  @override
  List<String> directories([String? directory, bool recursive = false]) {
    try {
      final dir = Directory(directory ?? '.');
      final dirs = <String>[];

      for (final entity in dir.listSync(recursive: recursive)) {
        if (entity is Directory) {
          dirs.add(entity.path);
        }
      }

      dirs.sort();
      return dirs;
    } catch (e) {
      return [];
    }
  }

  /// Get all (recursive) of the directories within a given directory.
  @override
  List<String> allDirectories([String? directory]) {
    return directories(directory, true);
  }

  /// Create a directory.
  @override
  bool makeDirectory(String path) {
    try {
      Directory(path).createSync(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Recursively delete a directory.
  @override
  bool deleteDirectory(String directory) {
    try {
      Directory(directory).deleteSync(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Determine if the given path is a file.
  bool isFile(String path) {
    try {
      return FileSystemEntity.typeSync(path) == FileSystemEntityType.file;
    } catch (e) {
      return false;
    }
  }
}
