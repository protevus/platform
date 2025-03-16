/// Contract for the View Engine implementation.
abstract class ViewEngine {
  /// Get the name of the engine.
  String get name;

  /// Get the supported file extensions.
  List<String> get extensions;

  /// Get the evaluated contents of the view.
  Future<String> get(String path, Map<String, dynamic> data);

  /// Check if a given view exists.
  bool exists(String view);

  /// Get the path to the view file.
  String? find(String view);

  /// Register a view creator.
  void creator(dynamic views, Function callback);

  /// Register multiple view creators via an array.
  void creators(Map<Function, List<String>> creators);

  /// Register a view composer.
  void composer(dynamic views, Function callback);

  /// Register multiple view composers via an array.
  void composers(Map<Function, List<String>> composers);

  /// Add a piece of shared data to the environment.
  void share(String key, dynamic value);

  /// Get all of the shared data for the environment.
  Map<String, dynamic> get shared;

  /// Determine if a view path is cached.
  bool isCached(String view);

  /// Get the cached path to a view.
  String? getCachedPath(String view);

  /// Clear the view cache.
  void flushCache();
}
