import 'dart:core';
import 'package:platform_mirrors/mirrors.dart';

/// Runtime scanner that analyzes libraries and extracts their metadata.
class RuntimeLibraryDiscoverer {
  // Private constructor to prevent instantiation
  RuntimeLibraryDiscoverer._();

  // Cache for library metadata
  static final Map<Uri, LibraryInfo> _libraryCache = {};

  /// Scans a library and extracts its metadata.
  static LibraryInfo scanLibrary(Uri uri) {
    if (_libraryCache.containsKey(uri)) {
      return _libraryCache[uri]!;
    }

    final libraryInfo = LibraryAnalyzer.analyze(uri);
    _libraryCache[uri] = libraryInfo;
    return libraryInfo;
  }
}
