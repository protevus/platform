import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

/// A class to manage Dart package dependencies.
class Composer {
  /// The path to the pubspec.yaml file.
  final String _pubspecPath;

  /// The current pubspec content.
  late Map<String, dynamic> _pubspec;

  /// Creates a new composer instance.
  Composer([String? pubspecPath])
      : _pubspecPath = pubspecPath ?? 'pubspec.yaml' {
    _loadPubspec();
  }

  /// Load the pubspec.yaml file.
  void _loadPubspec() {
    final file = File(_pubspecPath);
    if (!file.existsSync()) {
      throw FileSystemException('Pubspec file not found', _pubspecPath);
    }
    final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
    _pubspec = _convertYamlToMap(yaml);
  }

  /// Convert YamlMap to a modifiable Map.
  Map<String, dynamic> _convertYamlToMap(YamlMap yaml) {
    final json = jsonEncode(yaml);
    return jsonDecode(json) as Map<String, dynamic>;
  }

  /// Get the package name.
  String get name => _pubspec['name'] as String;

  /// Get the package version.
  String get version => _pubspec['version'] as String;

  /// Get the package description.
  String? get description => _pubspec['description'] as String?;

  /// Get the package dependencies.
  Map<String, String> get dependencies {
    final deps = _pubspec['dependencies'] as Map<String, dynamic>?;
    return deps?.map((key, value) => MapEntry(key, value.toString())) ?? {};
  }

  /// Get the package dev dependencies.
  Map<String, String> get devDependencies {
    final deps = _pubspec['dev_dependencies'] as Map<String, dynamic>?;
    return deps?.map((key, value) => MapEntry(key, value.toString())) ?? {};
  }

  /// Add a dependency.
  Future<void> require(
    String package, {
    String? version,
    bool dev = false,
  }) async {
    final dependencies = dev ? 'dev_dependencies' : 'dependencies';
    _pubspec[dependencies] ??= <String, dynamic>{};
    (_pubspec[dependencies] as Map<String, dynamic>)[package] =
        version ?? 'any';
    await _writePubspec(_pubspec);
    await _runPubGet();
  }

  /// Remove a dependency.
  Future<void> remove(String package, {bool dev = false}) async {
    final dependencies = dev ? 'dev_dependencies' : 'dependencies';
    if (_pubspec[dependencies] != null) {
      (_pubspec[dependencies] as Map<String, dynamic>).remove(package);
      await _writePubspec(_pubspec);
      await _runPubGet();
    }
  }

  /// Update dependencies.
  Future<void> update([List<String>? packages]) async {
    if (packages == null || packages.isEmpty) {
      await _runPubUpgrade();
      return;
    }

    for (final package in packages) {
      await _runPubUpgrade(package);
    }
  }

  /// Install dependencies.
  Future<void> install() async {
    await _runPubGet();
  }

  /// Check if a package is installed.
  bool hasPackage(String package, {bool dev = false}) {
    final deps = dev ? devDependencies : dependencies;
    return deps.containsKey(package);
  }

  /// Get the installed version of a package.
  Future<String?> getInstalledVersion(String package) async {
    final lockFile = File('pubspec.lock');
    if (!lockFile.existsSync()) {
      return null;
    }

    final lockContent = loadYaml(lockFile.readAsStringSync()) as YamlMap;
    final packages = lockContent['packages'] as YamlMap?;
    return packages?[package]?['version'] as String?;
  }

  /// Check if a package needs to be updated.
  Future<bool> needsUpdate(String package) async {
    final currentVersion = await getInstalledVersion(package);
    if (currentVersion == null) return false;

    final constraint = dependencies[package] ?? devDependencies[package];
    if (constraint == null) return false;

    try {
      final version = Version.parse(currentVersion);
      final range = VersionConstraint.parse(constraint);
      return !range.allows(version);
    } catch (_) {
      return false;
    }
  }

  /// Get outdated packages.
  Future<Map<String, Map<String, String>>> getOutdated() async {
    final result = await Process.run('dart', ['pub', 'outdated', '--json']);
    if (result.exitCode != 0) {
      throw ProcessException(
        'dart',
        ['pub', 'outdated'],
        result.stderr.toString(),
        result.exitCode,
      );
    }

    final output = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
    final packages = output['packages'] as List<dynamic>;

    final outdated = <String, Map<String, String>>{};
    for (final package in packages) {
      final name = package['name'] as String;
      final current = package['current'] as String?;
      final latest = package['latest'] as String?;

      if (current != null && latest != null && current != latest) {
        outdated[name] = {
          'current': current,
          'latest': latest,
        };
      }
    }

    return outdated;
  }

  /// Write the pubspec.yaml file.
  Future<void> _writePubspec(Map<String, dynamic> content) async {
    final file = File(_pubspecPath);
    final yaml = _toYaml(content);
    await file.writeAsString(yaml);
    _loadPubspec(); // Reload the pubspec
  }

  /// Convert a map to YAML format.
  String _toYaml(Map<String, dynamic> map) {
    final buffer = StringBuffer();
    _writeYamlNode(map, buffer, 0);
    return buffer.toString();
  }

  /// Write a YAML node with proper indentation.
  void _writeYamlNode(dynamic node, StringBuffer buffer, int indent) {
    final spaces = ' ' * indent;

    if (node is Map) {
      if (indent > 0) buffer.writeln();
      for (final entry in node.entries) {
        buffer.write('$spaces${entry.key}:');
        if (entry.value is Map || entry.value is List) {
          _writeYamlNode(entry.value, buffer, indent + 2);
        } else {
          final value = _formatYamlValue(entry.value, entry.key);
          buffer.write(' $value\n');
        }
      }
    } else if (node is List) {
      if (indent > 0) buffer.writeln();
      for (final item in node) {
        buffer.write('$spaces- ');
        _writeYamlNode(item, buffer, indent + 2);
      }
    } else {
      final value = _formatYamlValue(node, null);
      buffer.write('$value\n');
    }
  }

  /// Format a value for YAML output.
  String _formatYamlValue(dynamic value, String? key) {
    if (value == null) return '';
    if (value is num) return value.toString();
    if (value is bool) return value.toString();

    final stringValue = value.toString();

    // Special cases for known keys
    if (key == 'sdk') return '"$stringValue"';
    if (key == 'version' && _isSimpleVersion(stringValue)) return stringValue;

    if (_needsQuotes(stringValue)) {
      return '"${_escapeYamlString(stringValue)}"';
    }
    return stringValue;
  }

  /// Check if a string is a simple version number.
  bool _isSimpleVersion(String value) {
    return RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value);
  }

  /// Check if a string needs quotes in YAML.
  bool _needsQuotes(String value) {
    // Quote strings that contain special characters
    return value.contains(RegExp(r'[:{}[\],&*#?|\-<>=!%@`]')) ||
        value.contains('\n') ||
        value.contains('"') ||
        value.contains("'") ||
        value.trim().isEmpty ||
        value == 'true' ||
        value == 'false' ||
        value == 'null' ||
        value == 'yes' ||
        value == 'no' ||
        value == 'on' ||
        value == 'off';
  }

  /// Escape special characters in a string for YAML.
  String _escapeYamlString(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n');
  }

  /// Run dart pub get.
  Future<void> _runPubGet() async {
    final result = await Process.run('dart', ['pub', 'get']);
    if (result.exitCode != 0) {
      throw ProcessException(
        'dart',
        ['pub', 'get'],
        result.stderr.toString(),
        result.exitCode,
      );
    }
  }

  /// Run dart pub upgrade.
  Future<void> _runPubUpgrade([String? package]) async {
    final args = ['pub', 'upgrade'];
    if (package != null) {
      args.add(package);
    }

    final result = await Process.run('dart', args);
    if (result.exitCode != 0) {
      throw ProcessException(
        'dart',
        args,
        result.stderr.toString(),
        result.exitCode,
      );
    }
  }
}
