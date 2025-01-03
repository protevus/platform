import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:platform_contracts/contracts.dart';
import 'package:platform_macroable/platform_macroable.dart';
import 'package:platform_conditionable/platform_conditionable.dart';

import 'utilities.dart';

/// The FilesystemAdapter provides a fluent API for working with files using Flysystem.
class FilesystemAdapter
    with Macroable, Conditionable
    implements CloudFilesystemContract {
  /// The Flysystem filesystem implementation.
  final dynamic driver;

  /// The Flysystem adapter implementation.
  final dynamic adapter;

  /// The filesystem configuration.
  final Map<String, dynamic> config;

  /// The temporary URL builder callback.
  Function? _temporaryUrlCallback;

  /// Create a new filesystem adapter instance.
  FilesystemAdapter(this.driver, this.adapter, [this.config = const {}]);

  @override
  String path(String path) {
    var prefixedPath = path;
    if (config.containsKey('root')) {
      prefixedPath = '${config['root']}/$path';
    }
    if (config.containsKey('prefix')) {
      prefixedPath = '${config['prefix']}/$prefixedPath';
    }
    return prefixedPath;
  }

  @override
  bool exists(String path) {
    try {
      return driver.has(path);
    } catch (e) {
      return false;
    }
  }

  @override
  String? get(String path) {
    try {
      return driver.read(path);
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return null;
    }
  }

  @override
  Stream<List<int>>? readStream(String path) {
    try {
      return driver.readStream(path);
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return null;
    }
  }

  @override
  bool put(String path, dynamic contents, [dynamic options]) {
    try {
      if (contents is Stream<List<int>>) {
        return writeStream(
            path, contents, options as Map<String, dynamic>? ?? {});
      }

      driver.write(path, contents, options ?? {});
      return true;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

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
      if (_throwsExceptions) rethrow;
      return null;
    }
  }

  @override
  String? putFileAs(dynamic path, dynamic file,
      [String? name, dynamic options]) {
    try {
      if (file == null) return null;

      final fileName = name ?? path_basename(file.path);
      final fullPath = path_join(path, fileName);

      return putFile(fullPath, file, options);
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return null;
    }
  }

  @override
  bool writeStream(String path, Stream<List<int>> resource,
      [Map<String, dynamic> options = const {}]) {
    try {
      driver.writeStream(path, resource, options);
      return true;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  String getVisibility(String path) {
    try {
      final visibility = driver.visibility(path);
      return visibility == 'public'
          ? FilesystemContract.visibilityPublic
          : FilesystemContract.visibilityPrivate;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return FilesystemContract.visibilityPrivate;
    }
  }

  @override
  bool setVisibility(String path, String visibility) {
    try {
      driver.setVisibility(path, _parseVisibility(visibility));
      return true;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  bool prepend(String path, String data) {
    try {
      final content = get(path);
      return put(path, data + (content ?? ''));
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  bool append(String path, String data) {
    try {
      final content = get(path);
      return put(path, (content ?? '') + data);
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  bool delete(dynamic paths) {
    try {
      final pathList = paths is List ? paths : [paths];
      var success = true;

      for (final path in pathList) {
        try {
          driver.delete(path);
        } catch (e) {
          success = false;
          if (_throwsExceptions) rethrow;
        }
      }

      return success;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  bool copy(String from, String to) {
    try {
      driver.copy(from, to);
      return true;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  bool move(String from, String to) {
    try {
      driver.move(from, to);
      return true;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  int size(String path) {
    try {
      return driver.fileSize(path);
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return 0;
    }
  }

  @override
  int lastModified(String path) {
    try {
      return driver.lastModified(path);
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return 0;
    }
  }

  @override
  List<String> files([String? directory, bool recursive = false]) {
    try {
      return driver
          .listContents(directory ?? '', recursive)
          .where((attrs) => attrs.isFile)
          .map<String>((attrs) => attrs.path)
          .toList()
        ..sort();
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return [];
    }
  }

  @override
  List<String> allFiles([String? directory]) {
    return files(directory, true);
  }

  @override
  List<String> directories([String? directory, bool recursive = false]) {
    try {
      return driver
          .listContents(directory ?? '', recursive)
          .where((attrs) => attrs.isDir)
          .map<String>((attrs) => attrs.path)
          .toList()
        ..sort();
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return [];
    }
  }

  @override
  List<String> allDirectories([String? directory]) {
    return directories(directory, true);
  }

  @override
  bool makeDirectory(String path) {
    try {
      driver.createDirectory(path);
      return true;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  bool deleteDirectory(String directory) {
    try {
      driver.deleteDirectory(directory);
      return true;
    } catch (e) {
      if (_throwsExceptions) rethrow;
      return false;
    }
  }

  @override
  String url(String path) {
    if (config.containsKey('prefix')) {
      path = _concatPathToUrl(config['prefix'], path);
    }

    if (adapter != null && adapter.getUrl != null) {
      return adapter.getUrl(path);
    }

    if (driver.getUrl != null) {
      return driver.getUrl(path);
    }

    throw UnsupportedError('This driver does not support retrieving URLs.');
  }

  /// Parse the given visibility value.
  String _parseVisibility(String visibility) {
    switch (visibility) {
      case FilesystemContract.visibilityPublic:
        return 'public';
      case FilesystemContract.visibilityPrivate:
        return 'private';
      default:
        throw ArgumentError('Unknown visibility: $visibility');
    }
  }

  /// Concatenate a path to a URL.
  String _concatPathToUrl(String url, String path) {
    return '${url.replaceAll(RegExp(r'/+$'), '')}/${path.replaceAll(RegExp(r'^/+'), '')}';
  }

  /// Determine if Flysystem exceptions should be thrown.
  bool get _throwsExceptions => config['throw'] ?? false;
}
