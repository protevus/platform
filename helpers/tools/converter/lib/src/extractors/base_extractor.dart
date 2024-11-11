import 'dart:io';
import 'package:path/path.dart' as path;
import 'yaml_formatter.dart';

/// Base class for all language extractors
abstract class LanguageExtractor {
  /// File extension this extractor handles (e.g., '.php', '.py')
  String get fileExtension;

  /// Parse a source file and extract its components
  Future<Map<String, dynamic>> parseFile(String filePath);

  /// Extract class-level documentation
  String? extractClassComment(String content);

  /// Extract dependencies (imports, use statements, etc.)
  List<Map<String, String>> extractDependencies(String content);

  /// Extract class properties/fields
  List<Map<String, dynamic>> extractProperties(String content);

  /// Extract class methods
  List<Map<String, dynamic>> extractMethods(String content);

  /// Extract implemented interfaces
  List<String> extractInterfaces(String content);

  /// Extract used traits/mixins
  List<String> extractTraits(String content);

  /// Convert extracted data to YAML format
  String convertToYaml(Map<String, dynamic> data) {
    return YamlFormatter.toYaml(data);
  }

  /// Process a directory of source files
  Future<void> processDirectory(String sourceDir, String destDir) async {
    final sourceDirectory = Directory(sourceDir);

    await for (final entity in sourceDirectory.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith(fileExtension)) continue;

      final relativePath = path.relative(entity.path, from: sourceDir);
      final destPath = path.join(destDir, path.dirname(relativePath));

      await Directory(destPath).create(recursive: true);

      final data = await parseFile(entity.path);
      final yamlContent = convertToYaml(data);

      final yamlFile = File(path.join(
          destPath, '${path.basenameWithoutExtension(entity.path)}.yaml'));

      await yamlFile.writeAsString(yamlContent);
    }
  }

  /// Parse method parameters from a parameter string
  List<Map<String, String>> parseParameters(String paramsStr) {
    final params = <Map<String, String>>[];
    if (paramsStr.trim().isEmpty) return params;

    for (final param in paramsStr.split(',')) {
      final parts = param.trim().split('=');
      final paramInfo = <String, String>{
        'name': parts[0].trim(),
      };

      if (parts.length > 1) {
        paramInfo['default'] = parts[1].trim();
      }

      params.add(paramInfo);
    }

    return params;
  }

  /// Format a comment by removing common comment markers and whitespace
  String? formatComment(String? comment) {
    if (comment == null || comment.isEmpty) return null;

    return comment
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          // Remove common comment markers
          line = line.replaceAll(RegExp(r'^/\*+|\*+/$'), '');
          line = line.replaceAll(RegExp(r'^\s*\*\s*'), '');
          line = line.replaceAll(RegExp(r'^//\s*'), '');
          return line.trim();
        })
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  /// Extract type information from a type string
  Map<String, dynamic> extractTypeInfo(String typeStr) {
    // Handle nullable types
    final isNullable = typeStr.endsWith('?');
    if (isNullable) {
      typeStr = typeStr.substring(0, typeStr.length - 1);
    }

    // Handle generics
    final genericMatch = RegExp(r'^([\w\d_]+)<(.+)>$').firstMatch(typeStr);
    if (genericMatch != null) {
      return {
        'base_type': genericMatch.group(1),
        'generic_params':
            genericMatch.group(2)!.split(',').map((t) => t.trim()).toList(),
        'nullable': isNullable,
      };
    }

    return {
      'type': typeStr,
      'nullable': isNullable,
    };
  }
}
