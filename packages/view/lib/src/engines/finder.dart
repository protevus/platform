import 'dart:io';
import 'package:path/path.dart' as path;

/// Finds view files in the filesystem.
class ViewFinder {
  final List<String> _paths;
  final Map<String, String> _cache = {};
  final List<String> _extensions;

  ViewFinder(this._paths, this._extensions);

  /// Find a view by name.
  String? find(String name) {
    // Check cache first
    if (_cache.containsKey(name)) {
      return _cache[name];
    }

    // Check if name already has an extension
    if (_extensions.any((ext) => name.endsWith(ext))) {
      // Use name as-is
      for (var basePath in _paths) {
        final filePath = path.join(basePath, name);
        if (File(filePath).existsSync()) {
          _cache[name] = filePath;
          return filePath;
        }
      }
    } else {
      // Convert dots to directory separators
      final normalized = name.replaceAll('.', '/');

      // Search paths
      for (var basePath in _paths) {
        // Try each extension
        for (var ext in _extensions) {
          final filePath = path.join(basePath, '$normalized$ext');
          if (File(filePath).existsSync()) {
            _cache[name] = filePath;
            return filePath;
          }
        }
      }
    }

    return null;
  }

  /// Add a new path to search.
  void addPath(String location) {
    _paths.add(location);
    _cache.clear();
  }

  /// Add a new extension to search for.
  void addExtension(String extension) {
    _extensions.add(extension);
    _cache.clear();
  }

  /// Clear the finder cache.
  void flush() => _cache.clear();

  /// Get all registered paths.
  List<String> get paths => List.unmodifiable(_paths);

  /// Get all registered extensions.
  List<String> get extensions => List.unmodifiable(_extensions);
}
