import 'package:meta/meta.dart';

/// Contract for loading translation messages.
@immutable
abstract class Loader {
  /// Load the messages for the given locale and group.
  ///
  /// [locale] The locale to load messages for (e.g. 'en', 'es')
  /// [group] The translation group to load (e.g. 'messages', 'validation')
  /// [namespace] Optional namespace for package/vendor translations
  ///
  /// Returns a Map of translation keys to their values
  Map<String, dynamic> load(String locale, String group, [String? namespace]);

  /// Add a new namespace to the loader.
  ///
  /// [namespace] The namespace name (e.g. 'package-name')
  /// [path] The path to the namespace translations
  void addNamespace(String namespace, String path);

  /// Add a new JSON path to the loader.
  ///
  /// [path] The path to JSON translation files
  void addJsonPath(String path);

  /// Get all registered namespaces.
  ///
  /// Returns a Map of namespace names to their paths
  Map<String, String> namespaces();

  /// Get all registered JSON paths.
  ///
  /// Returns a List of paths to JSON translation files
  List<String> jsonPaths();
}
