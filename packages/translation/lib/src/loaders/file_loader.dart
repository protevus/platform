import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import '../contracts/loader.dart';

/// Loads translations from the filesystem.
class FileLoader implements Loader {
  /// The filesystem paths to look for translations.
  final List<String> _paths;

  /// The registered JSON file paths.
  final List<String> _jsonPaths = [];

  /// The registered namespace hints.
  final Map<String, String> _hints = {};

  /// Create a new file loader instance.
  ///
  /// [paths] One or more base paths to look for translations
  FileLoader(List<String> paths) : _paths = paths;

  @override
  Map<String, dynamic> load(String locale, String group, [String? namespace]) {
    // Handle JSON translations
    if (group == '*' && namespace == '*') {
      return _loadJsonPaths(locale);
    }

    // Handle default/fallback translations
    if (namespace == null || namespace == '*') {
      return _loadPaths(_paths, locale, group);
    }

    // Handle namespaced translations
    return _loadNamespaced(locale, group, namespace);
  }

  /// Load translations from JSON files.
  Map<String, dynamic> _loadJsonPaths(String locale) {
    final Map<String, dynamic> translations = {};

    for (final basePath in [..._jsonPaths, ..._paths]) {
      // Try locale.json first (e.g., en.json)
      var jsonFile = File('$basePath/$locale.json');

      // If not found, try locale/messages.json (e.g., en/messages.json)
      if (!jsonFile.existsSync()) {
        jsonFile = File('$basePath/$locale/messages.json');
      }

      if (jsonFile.existsSync()) {
        try {
          final Map<String, dynamic> decoded =
              json.decode(jsonFile.readAsStringSync());
          translations.addAll(decoded);
        } catch (e) {
          throw FormatException(
            'Translation file [${jsonFile.path}] contains an invalid JSON structure.',
            e,
          );
        }
      }
    }

    return translations;
  }

  /// Load translations from YAML files in the given paths.
  Map<String, dynamic> _loadPaths(
      List<String> paths, String locale, String group) {
    final Map<String, dynamic> translations = {};

    for (final basePath in paths) {
      final yamlFile = File('$basePath/$locale/$group.yaml');
      if (yamlFile.existsSync()) {
        try {
          final dynamic decoded = loadYaml(yamlFile.readAsStringSync());
          if (decoded is Map) {
            translations.addAll(Map<String, dynamic>.from(decoded));
          }
        } catch (e) {
          throw FormatException(
            'Translation file [${yamlFile.path}] contains an invalid YAML structure.',
            e,
          );
        }
      }
    }

    return translations;
  }

  /// Load namespaced translations.
  Map<String, dynamic> _loadNamespaced(
      String locale, String group, String namespace) {
    if (!_hints.containsKey(namespace)) {
      return {};
    }

    final translations = _loadPaths([_hints[namespace]!], locale, group);
    return _loadNamespaceOverrides(translations, locale, group, namespace);
  }

  /// Load any namespace overrides.
  Map<String, dynamic> _loadNamespaceOverrides(
    Map<String, dynamic> translations,
    String locale,
    String group,
    String namespace,
  ) {
    for (final basePath in _paths) {
      final vendorFile =
          File('$basePath/vendor/$namespace/$locale/$group.yaml');
      if (vendorFile.existsSync()) {
        try {
          final dynamic decoded = loadYaml(vendorFile.readAsStringSync());
          if (decoded is Map) {
            translations = Map<String, dynamic>.from(translations)
              ..addAll(Map<String, dynamic>.from(decoded));
          }
        } catch (e) {
          throw FormatException(
            'Translation file [${vendorFile.path}] contains an invalid YAML structure.',
            e,
          );
        }
      }
    }

    return translations;
  }

  @override
  void addNamespace(String namespace, String hint) {
    _hints[namespace] = hint;
  }

  @override
  void addJsonPath(String path) {
    _jsonPaths.add(path);
  }

  @override
  Map<String, String> namespaces() {
    return Map<String, String>.from(_hints);
  }

  @override
  List<String> jsonPaths() {
    return List<String>.from(_jsonPaths);
  }
}
