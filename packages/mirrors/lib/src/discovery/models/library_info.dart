import 'function_info.dart';
import 'variable_info.dart';
import 'dependency_info.dart';

/// Information about a library.
///
/// Contains metadata about a Dart library including:
/// - The library's URI
/// - Top-level functions defined in the library
/// - Top-level variables defined in the library
/// - Dependencies (imports) used by the library
/// - Exports exposed by the library
class LibraryInfo {
  /// The URI identifying this library
  final Uri uri;

  /// List of top-level functions defined in this library
  final List<FunctionInfo> topLevelFunctions;

  /// List of top-level variables defined in this library
  final List<VariableInfo> topLevelVariables;

  /// List of dependencies (imports) used by this library
  final List<DependencyInfo> dependencies;

  /// List of exports exposed by this library
  final List<DependencyInfo> exports;

  /// Creates a new [LibraryInfo] instance.
  ///
  /// All parameters are required:
  /// - [uri]: The URI identifying this library
  /// - [topLevelFunctions]: List of top-level functions
  /// - [topLevelVariables]: List of top-level variables
  /// - [dependencies]: List of dependencies (imports)
  /// - [exports]: List of exports
  const LibraryInfo({
    required this.uri,
    required this.topLevelFunctions,
    required this.topLevelVariables,
    required this.dependencies,
    required this.exports,
  });

  @override
  String toString() => 'LibraryInfo(uri: $uri)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LibraryInfo &&
        other.uri == uri &&
        _listEquals(other.topLevelFunctions, topLevelFunctions) &&
        _listEquals(other.topLevelVariables, topLevelVariables) &&
        _listEquals(other.dependencies, dependencies) &&
        _listEquals(other.exports, exports);
  }

  @override
  int get hashCode {
    return Object.hash(
      uri,
      Object.hashAll(topLevelFunctions),
      Object.hashAll(topLevelVariables),
      Object.hashAll(dependencies),
      Object.hashAll(exports),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
