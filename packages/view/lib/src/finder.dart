import 'dart:io';
import 'package:path/path.dart' as path;
import 'exceptions.dart';

/// The view finder implementation
class ViewFinder {
  /// The paths to search for views
  final List<String> paths;

  /// The file extensions to search for
  final List<String> extensions;

  /// Cache of found views
  final Map<String, String> _cache = {};

  ViewFinder(this.paths, [this.extensions = const ['.blade.php', '.php', '.html']]);

  /// Find the given view in the filesystem
  String find(String name) {
    if (_cache.containsKey(name)) {
      return _cache[name]!;
    }

    String result = _findInPaths(name);
    _cache[name] = result;
    return result;
  }

  /// Find the given view in the filesystem paths
  String _findInPaths(String name) {
    for (String location in paths) {
      for (String extension in extensions) {
        String viewPath = path.join(location, '$name$extension');
        if (File(viewPath).existsSync()) {
          return viewPath;
        }
      }
    }

    throw ViewNotFoundException('View [$name] not found.');
  }

  /// Add a location to the finder
  void addLocation(String location) {
    paths.add(location);
  }

  /// Flush the cache of located views
  void flush() {
    _cache.clear();
  }
}
