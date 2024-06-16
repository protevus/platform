abstract class Loader {
  /// Load the messages for the given locale.
  ///
  /// [locale] is the locale to load messages for.
  /// [group] is the message group to load.
  /// [namespace] is the optional namespace to load messages from.
  /// Returns a list of messages.
  List<dynamic> load(String locale, String group, [String? namespace]);

  /// Add a new namespace to the loader.
  ///
  /// [namespace] is the name of the namespace.
  /// [hint] is the path hint for the namespace.
  void addNamespace(String namespace, String hint);

  /// Add a new JSON path to the loader.
  ///
  /// [path] is the path to the JSON file.
  void addJsonPath(String path);

  /// Get an array of all the registered namespaces.
  ///
  /// Returns a map of all registered namespaces and their hints.
  Map<String, String> namespaces();
}
