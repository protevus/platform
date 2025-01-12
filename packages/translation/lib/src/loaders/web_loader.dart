import 'dart:convert';
import '../contracts/loader.dart';

/// Loads translations for web environments.
class WebLoader implements Loader {
  /// The loaded translations.
  final Map<String, Map<String, dynamic>> _translations = {};

  /// Create a new web loader instance.
  WebLoader();

  @override
  Map<String, dynamic> load(String locale, String group, [String? namespace]) {
    return _translations[locale] ?? {};
  }

  @override
  void addNamespace(String namespace, String hint) {
    // Not used in web environment
  }

  @override
  void addJsonPath(String path) {
    // Not used in web environment
  }

  /// Add translation data directly.
  void addTranslations(String locale, Map<String, dynamic> data) {
    _translations[locale] = data;
  }

  @override
  Map<String, String> namespaces() {
    return {};
  }

  @override
  List<String> jsonPaths() {
    return [];
  }
}
