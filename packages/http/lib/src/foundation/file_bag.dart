import 'dart:io';
import 'dart:collection';
import 'package:protevus_http/foundation.dart';
import 'package:protevus_http/foundation_file.dart';
import 'package:protevus_mime/mime_exception.dart';
//import 'package:http/http.dart' as http;

/// FileBag is a container for uploaded files.
///
/// This class is ported from Symfony's HttpFoundation component.
class FileBag extends ParameterBag
    with IterableMixin<MapEntry<String, dynamic>> {
  static const List<String> _fileKeys = [
    'error',
    'full_path',
    'name',
    'size',
    'tmp_name',
    'type'
  ];

  /// Constructs a FileBag instance.
  ///
  /// [parameters] is an array of HTTP files.
  FileBag([Map<String, dynamic> parameters = const {}]) {
    replace(parameters);
  }

  /// Replaces the current files with a new set.
  @override
  void replace(Map<String, dynamic> files) {
    parameters.clear();
    add(files);
  }

  /// Sets a file in the bag.
  @override
  void set(String key, dynamic value) {
    if (value is! Map<String, dynamic> && value is! UploadedFile) {
      throw InvalidArgumentException(
          'An uploaded file must be a Map or an instance of UploadedFile.');
    }

    super.set(key, _convertFileInformation(value));
  }

  /// Adds multiple files to the bag.
  @override
  void add(Map<String, dynamic> files) {
    files.forEach((key, file) {
      set(key, file);
    });
  }

  /// Converts uploaded files to UploadedFile instances.
  dynamic _convertFileInformation(dynamic file) {
    if (file is UploadedFile) {
      return file;
    }

    if (file is Map<String, dynamic>) {
      file = _fixDartFilesMap(file);
      List<String> keys = (file.keys.toList()..add('full_path'))..sort();

      if (listEquals(_fileKeys, keys)) {
        if (file['error'] == HttpStatus.noContent) {
          return null;
        } else {
          return UploadedFile(
            file['tmp_name'],
            file['full_path'] ?? file['name'],
            file['type'],
            file['error'],
            false,
          );
        }
      } else {
        return file.map((key, value) {
          if (value is UploadedFile || value is Map<String, dynamic>) {
            return MapEntry(key, _convertFileInformation(value));
          }
          return MapEntry(key, value);
        });
      }
    }

    return file;
  }

  /// Fixes a malformed Dart file upload map.
  ///
  /// This method is equivalent to PHP's fixPhpFilesArray.
  Map<String, dynamic> _fixDartFilesMap(Map<String, dynamic> data) {
    List<String> keys = (data.keys.toList()..add('full_path'))..sort();

    if (!listEquals(_fileKeys, keys) ||
        !data.containsKey('name') ||
        data['name'] is! Map) {
      return data;
    }

    Map<String, dynamic> files = Map.from(data);
    for (String k in _fileKeys) {
      files.remove(k);
    }

    (data['name'] as Map).forEach((key, name) {
      files[key] = _fixDartFilesMap({
        'error': data['error'][key],
        'name': name,
        'type': data['type'][key],
        'tmp_name': data['tmp_name'][key],
        'size': data['size'][key],
        if (data.containsKey('full_path') && data['full_path'].containsKey(key))
          'full_path': data['full_path'][key],
      });
    });

    return files;
  }
}

/// Utility function to compare two lists for equality.
bool listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
