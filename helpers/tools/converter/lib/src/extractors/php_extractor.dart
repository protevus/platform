import 'dart:io';
import 'base_extractor.dart';

/// Extracts contract information from PHP source files
class PhpExtractor extends LanguageExtractor {
  @override
  String get fileExtension => '.php';

  @override
  Future<Map<String, dynamic>> parseFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();

    return {
      'name': filePath.split('/').last.split('.').first,
      'class_comment': extractClassComment(content),
      'dependencies': extractDependencies(content),
      'properties': extractProperties(content),
      'methods': extractMethods(content),
      'traits': extractTraits(content),
      'interfaces': extractInterfaces(content),
    };
  }

  @override
  String? extractClassComment(String content) {
    final regex =
        RegExp(r'/\*\*(.*?)\*/\s*class', multiLine: true, dotAll: true);
    final match = regex.firstMatch(content);
    return formatComment(match?.group(1));
  }

  @override
  List<Map<String, String>> extractDependencies(String content) {
    final regex = RegExp(r'use\s+([\w\\]+)(?:\s+as\s+(\w+))?;');
    final matches = regex.allMatches(content);

    return matches.map((match) {
      final fullName = match.group(1)!;
      final alias = match.group(2);
      return {
        'name': alias ?? fullName.split('\\').last,
        'type': 'class', // Assuming class for now
        'source': fullName,
      };
    }).toList();
  }

  @override
  List<Map<String, dynamic>> extractProperties(String content) {
    final regex = RegExp(
      r'(?:/\*\*(.*?)\*/\s*)?(public|protected|private)\s+(?:readonly\s+)?(?:static\s+)?(?:[\w|]+\s+)?\$(\w+)(?:\s*=\s*[^;]+)?;',
      multiLine: true,
      dotAll: true,
    );
    final matches = regex.allMatches(content);

    return matches.map((match) {
      return {
        'name': match.group(3), // Property name without $
        'visibility': match.group(2),
        'comment': formatComment(match.group(1)),
      };
    }).toList();
  }

  @override
  List<Map<String, dynamic>> extractMethods(String content) {
    final regex = RegExp(
      r'(?:/\*\*(.*?)\*/\s*)?(public|protected|private)\s+(?:static\s+)?function\s+(\w+)\s*\((.*?)\)(?:\s*:\s*(?:[\w|\\]+))?\s*{',
      multiLine: true,
      dotAll: true,
    );
    final matches = regex.allMatches(content);

    return matches.map((match) {
      return {
        'name': match.group(3),
        'visibility': match.group(2),
        'parameters': _parseMethodParameters(match.group(4) ?? ''),
        'comment': formatComment(match.group(1)),
      };
    }).toList();
  }

  List<Map<String, String>> _parseMethodParameters(String params) {
    if (params.trim().isEmpty) return [];

    final parameters = <Map<String, String>>[];
    final paramList = params.split(',');

    for (var param in paramList) {
      param = param.trim();
      if (param.isEmpty) continue;

      final paramInfo = <String, String>{};

      // Handle type declaration and parameter name
      final typeAndName = param.split(RegExp(r'\$'));
      if (typeAndName.length > 1) {
        // Has type declaration
        final type = typeAndName[0].trim();
        if (type.isNotEmpty) {
          paramInfo['type'] = type;
        }

        // Handle parameter name and default value
        final nameAndDefault = typeAndName[1].split('=');
        paramInfo['name'] = nameAndDefault[0].trim();

        if (nameAndDefault.length > 1) {
          paramInfo['default'] = nameAndDefault[1].trim();
        }
      } else {
        // No type declaration, just name and possibly default value
        final nameAndDefault = param.replaceAll(r'$', '').split('=');
        paramInfo['name'] = nameAndDefault[0].trim();

        if (nameAndDefault.length > 1) {
          paramInfo['default'] = nameAndDefault[1].trim();
        }
      }

      parameters.add(paramInfo);
    }

    return parameters;
  }

  @override
  List<String> extractTraits(String content) {
    final regex = RegExp(r'use\s+([\w\\]+(?:\s*,\s*[\w\\]+)*)\s*;');
    final matches = regex.allMatches(content);
    final traits = <String>[];

    for (final match in matches) {
      final traitList = match.group(1)!.split(',');
      traits.addAll(traitList.map((t) => t.trim()));
    }

    return traits;
  }

  @override
  List<String> extractInterfaces(String content) {
    final regex = RegExp(r'implements\s+([\w\\]+(?:\s*,\s*[\w\\]+)*)');
    final matches = regex.allMatches(content);
    final interfaces = <String>[];

    for (final match in matches) {
      final interfaceList = match.group(1)!.split(',');
      interfaces.addAll(interfaceList.map((i) => i.trim()));
    }

    return interfaces;
  }
}
