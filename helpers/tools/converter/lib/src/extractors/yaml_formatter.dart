/// Handles YAML formatting with proper comment preservation
class YamlFormatter {
  /// Format a value for YAML output
  static String format(dynamic value, {int indent = 0}) {
    if (value == null) return 'null';

    final indentStr = ' ' * indent;

    if (value is String) {
      if (value.startsWith('#')) {
        // Handle comments - preserve only actual comment content
        return value
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .map((line) => '$indentStr$line')
            .join('\n');
      }
      // Escape special characters and handle multiline strings
      if (value.contains('\n') || value.contains('"')) {
        return '|\n${value.split('\n').map((line) => '$indentStr  ${line.trim()}').join('\n')}';
      }
      return value.contains(' ') ? '"$value"' : value;
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    if (value is List) {
      if (value.isEmpty) return '[]';
      final buffer = StringBuffer('\n');
      for (final item in value) {
        buffer.writeln(
            '$indentStr- ${format(item, indent: indent + 2).trimLeft()}');
      }
      return buffer.toString().trimRight();
    }

    if (value is Map) {
      if (value.isEmpty) return '{}';
      final buffer = StringBuffer('\n');
      value.forEach((key, val) {
        if (val != null) {
          final formattedValue = format(val, indent: indent + 2);
          if (formattedValue.contains('\n')) {
            buffer.writeln('$indentStr$key:$formattedValue');
          } else {
            buffer.writeln('$indentStr$key: $formattedValue');
          }
          // Add extra newline between top-level sections
          if (indent == 0) {
            buffer.writeln();
          }
        }
      });
      return buffer.toString().trimRight();
    }

    return value.toString();
  }

  /// Extract the actual documentation from a comment block
  static String _extractDocumentation(String comment) {
    return comment
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where(
            (line) => !line.contains('class ') && !line.contains('function '))
        .where((line) => !line.startsWith('@'))
        .where((line) => !line.contains('use ') && !line.contains('protected '))
        .where((line) => !line.contains('];') && !line.contains('['))
        .where((line) => !line.contains("'"))
        .where(
            (line) => !line.contains('private ') && !line.contains('public '))
        .where((line) => !line.contains('\$'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  /// Format method documentation
  static String formatMethodDoc(Map<String, dynamic> method) {
    final buffer = StringBuffer();

    // Add main comment
    if (method['comment'] != null) {
      final mainComment = _extractDocumentation(method['comment'].toString());
      if (mainComment.isNotEmpty) {
        buffer.writeln(
            mainComment.split('\n').map((line) => '# $line').join('\n'));
      }
    }

    // Add parameter documentation
    final params = method['parameters'] as List<Map<String, String>>?;
    if (params != null && params.isNotEmpty) {
      buffer.writeln('# Parameters:');
      for (final param in params) {
        final name = param['name'];
        final type = param['type'] ?? 'mixed';
        final defaultValue = param['default'];
        if (defaultValue != null) {
          buffer.writeln('#   $name ($type = $defaultValue)');
        } else {
          buffer.writeln('#   $name ($type)');
        }
      }
    }

    return buffer.toString().trimRight();
  }

  /// Format property documentation
  static String formatPropertyDoc(Map<String, dynamic> property) {
    final buffer = StringBuffer();

    // Add main comment
    if (property['comment'] != null) {
      final mainComment = _extractDocumentation(property['comment'].toString());
      if (mainComment.isNotEmpty) {
        buffer.writeln(
            mainComment.split('\n').map((line) => '# $line').join('\n'));
      }
    }

    // Add visibility
    if (property['visibility'] != null) {
      buffer.writeln('# Visibility: ${property["visibility"]}');
    }

    return buffer.toString().trimRight();
  }

  /// Convert a contract to YAML format
  static String toYaml(Map<String, dynamic> contract) {
    final formatted = <String, dynamic>{};

    // Format class documentation
    if (contract['class_comment'] != null) {
      final doc = _extractDocumentation(contract['class_comment'] as String);
      if (doc.isNotEmpty) {
        formatted['documentation'] =
            doc.split('\n').map((line) => '# $line').join('\n');
      }
    }

    // Format dependencies (remove duplicates)
    if (contract['dependencies'] != null) {
      final deps = contract['dependencies'] as List;
      final uniqueDeps = <String, Map<String, String>>{};
      for (final dep in deps) {
        final source = dep['source'] as String;
        if (!uniqueDeps.containsKey(source)) {
          uniqueDeps[source] = dep as Map<String, String>;
        }
      }
      formatted['dependencies'] = uniqueDeps.values.toList();
    }

    // Format properties with documentation
    if (contract['properties'] != null) {
      formatted['properties'] = (contract['properties'] as List).map((prop) {
        final doc = formatPropertyDoc(prop as Map<String, dynamic>);
        return {
          'name': prop['name'],
          'visibility': prop['visibility'],
          'documentation': doc,
        };
      }).toList();
    }

    // Format methods with documentation
    if (contract['methods'] != null) {
      formatted['methods'] = (contract['methods'] as List).map((method) {
        final doc = formatMethodDoc(method as Map<String, dynamic>);
        return {
          'name': method['name'],
          'visibility': method['visibility'],
          'parameters': method['parameters'],
          'documentation': doc,
        };
      }).toList();
    }

    // Format interfaces (remove duplicates)
    if (contract['interfaces'] != null) {
      formatted['interfaces'] =
          (contract['interfaces'] as List).toSet().toList();
    }

    // Format traits (remove duplicates and filter out interfaces)
    if (contract['traits'] != null) {
      final traits = (contract['traits'] as List)
          .where((t) {
            // Filter out duplicates from dependencies
            if (contract['dependencies'] != null) {
              final deps = contract['dependencies'] as List;
              if (deps.any((d) => d['source'] == t)) {
                return false;
              }
            }
            // Filter out interfaces
            if (formatted['interfaces'] != null) {
              final interfaces = formatted['interfaces'] as List;
              if (interfaces.contains(t)) {
                return false;
              }
            }
            return true;
          })
          .toSet()
          .toList();

      if (traits.isNotEmpty) {
        formatted['traits'] = traits;
      }
    }

    return format(formatted);
  }
}
