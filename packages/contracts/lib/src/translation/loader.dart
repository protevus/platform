/// Interface for translation loaders.
abstract class Loader {
  /// Load the messages for the given locale.
  Map<String, dynamic> load(String locale, String group, [String? namespace]);

  /// Add a new namespace to the loader.
  void addNamespace(String namespace, String hint);

  /// Add a new JSON path to the loader.
  void addJsonPath(String path);

  /// Get an array of all the registered namespaces.
  Map<String, dynamic> namespaces();
}
