import 'dart:io';

/// Represents a Python method parameter
class Parameter {
  final String name;
  final String type;
  final bool isOptional;
  final bool hasDefault;

  Parameter({
    required this.name,
    required this.type,
    required this.isOptional,
    required this.hasDefault,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'is_optional': isOptional,
        'has_default': hasDefault,
      };
}

/// Represents a Python method
class Method {
  final String name;
  final List<Parameter> parameters;
  final String returnType;
  final String? docstring;
  final List<String> decorators;
  final bool isAsync;
  final bool isAbstract;
  final bool isProperty;

  Method({
    required this.name,
    required this.parameters,
    required this.returnType,
    this.docstring,
    required this.decorators,
    required this.isAsync,
    required this.isAbstract,
    required this.isProperty,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'parameters': parameters.map((p) => p.toJson()).toList(),
        'return_type': returnType,
        if (docstring != null) 'docstring': docstring,
        'decorators': decorators,
        'is_async': isAsync,
        'is_abstract': isAbstract,
        'is_property': isProperty,
      };
}

/// Represents a Python class property
class Property {
  final String name;
  final String type;
  final bool hasDefault;
  final String? defaultValue;

  Property({
    required this.name,
    required this.type,
    required this.hasDefault,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'has_default': hasDefault,
        if (defaultValue != null) 'default_value': defaultValue,
      };
}

/// Represents a Python class
class PythonClass {
  final String name;
  final List<String> bases;
  final List<Method> methods;
  final List<Property> properties;
  final String? docstring;
  final List<String> decorators;
  final bool isInterface;

  PythonClass({
    required this.name,
    required this.bases,
    required this.methods,
    required this.properties,
    this.docstring,
    required this.decorators,
    required this.isInterface,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'bases': bases,
        'methods': methods.map((m) => m.toJson()).toList(),
        'properties': properties.map((p) => p.toJson()).toList(),
        if (docstring != null) 'docstring': docstring,
        'decorators': decorators,
        'is_interface': isInterface,
      };
}

/// Parser for Python source code
class PythonParser {
  /// Check if a line looks like code
  static bool _isCodeLine(String line) {
    return line.startsWith('def ') ||
        line.startsWith('@') ||
        line.startsWith('class ') ||
        line.contains(' = ') ||
        line.contains('self.') ||
        line.contains('return ') ||
        line.contains('pass') ||
        line.contains('raise ') ||
        line.contains('yield ') ||
        line.contains('async ') ||
        line.contains('await ') ||
        (line.contains(':') && !line.startsWith('Note:')) ||
        line.trim().startsWith('"""') ||
        line.trim().endsWith('"""');
  }

  /// Parse a docstring from Python code lines
  static String? _parseDocstring(
      List<String> lines, int startIndex, int baseIndent) {
    if (startIndex >= lines.length) return null;

    final line = lines[startIndex].trim();
    if (!line.startsWith('"""')) return null;

    // Handle single-line docstring
    if (line.endsWith('"""') && line.length > 6) {
      return line.substring(3, line.length - 3).trim();
    }

    final docLines = <String>[];
    // Add first line content if it exists after the opening quotes
    var firstLineContent = line.substring(3).trim();
    if (firstLineContent.isNotEmpty && !_isCodeLine(firstLineContent)) {
      docLines.add(firstLineContent);
    }

    var i = startIndex + 1;
    while (i < lines.length) {
      final currentLine = lines[i].trim();

      // Stop at closing quotes
      if (currentLine.endsWith('"""')) {
        // Add the last line content if it exists before the closing quotes
        var lastLineContent =
            currentLine.substring(0, currentLine.length - 3).trim();
        if (lastLineContent.isNotEmpty && !_isCodeLine(lastLineContent)) {
          docLines.add(lastLineContent);
        }
        break;
      }

      // Only add non-code lines
      if (currentLine.isNotEmpty && !_isCodeLine(currentLine)) {
        docLines.add(currentLine);
      }

      i++;
    }

    return docLines.isEmpty ? null : docLines.join('\n').trim();
  }

  /// Get the indentation level of a line
  static int _getIndentation(String line) {
    return line.length - line.trimLeft().length;
  }

  /// Parse method parameters from a parameter string
  static List<Parameter> _parseParameters(String paramsStr) {
    if (paramsStr.trim().isEmpty) return [];

    final params = <Parameter>[];
    var depth = 0;
    var currentParam = StringBuffer();

    // Handle nested brackets in parameter types
    for (var i = 0; i < paramsStr.length; i++) {
      final char = paramsStr[i];
      if (char == '[') depth++;
      if (char == ']') depth--;
      if (char == ',' && depth == 0) {
        final param = currentParam.toString().trim();
        if (param.isNotEmpty && param != 'self' && !param.startsWith('**')) {
          final paramObj = _parseParameter(param);
          if (paramObj != null) {
            params.add(paramObj);
          }
        }
        currentParam.clear();
      } else {
        currentParam.write(char);
      }
    }

    final lastParam = currentParam.toString().trim();
    if (lastParam.isNotEmpty &&
        lastParam != 'self' &&
        !lastParam.startsWith('**')) {
      final paramObj = _parseParameter(lastParam);
      if (paramObj != null) {
        params.add(paramObj);
      }
    }

    return params;
  }

  /// Parse a single parameter
  static Parameter? _parseParameter(String param) {
    if (param.isEmpty) return null;

    var name = param;
    var type = 'Any';
    var hasDefault = false;
    var isOptional = false;

    // Check for type annotation
    if (param.contains(':')) {
      final parts = param.split(':');
      name = parts[0].trim();
      var typeStr = parts[1];

      // Handle default value
      if (typeStr.contains('=')) {
        final typeParts = typeStr.split('=');
        typeStr = typeParts[0];
        hasDefault = true;
        isOptional = true;
      }

      type = typeStr.trim();

      // Handle Optional type
      if (type.startsWith('Optional[')) {
        type = type.substring(9, type.length - 1);
        isOptional = true;
      }
    }

    // Check for default value without type annotation
    if (param.contains('=')) {
      hasDefault = true;
      isOptional = true;
      if (!param.contains(':')) {
        name = param.split('=')[0].trim();
      }
    }

    return Parameter(
      name: name,
      type: type,
      isOptional: isOptional,
      hasDefault: hasDefault,
    );
  }

  /// Parse a method definition
  static Method? _parseMethod(
      List<String> lines, int startIndex, List<String> decorators) {
    final line = lines[startIndex].trim();
    if (!line.startsWith('def ') && !line.startsWith('async def ')) return null;

    final methodMatch =
        RegExp(r'(?:async\s+)?def\s+(\w+)\s*\((.*?)\)(?:\s*->\s*(.+?))?\s*:')
            .firstMatch(line);
    if (methodMatch == null) return null;

    final name = methodMatch.group(1)!;
    final paramsStr = methodMatch.group(2) ?? '';
    var returnType = methodMatch.group(3) ?? 'None';
    returnType = returnType.trim();

    final isAsync = line.contains('async ');
    final isAbstract = decorators.contains('abstractmethod');
    final isProperty = decorators.contains('property');

    // Parse docstring if present
    var i = startIndex + 1;
    String? docstring;
    if (i < lines.length) {
      final nextLine = lines[i].trim();
      if (nextLine.startsWith('"""')) {
        docstring =
            _parseDocstring(lines, i, _getIndentation(lines[startIndex]));
      }
    }

    return Method(
      name: name,
      parameters: _parseParameters(paramsStr),
      returnType: returnType,
      docstring: docstring,
      decorators: decorators,
      isAsync: isAsync,
      isAbstract: isAbstract,
      isProperty: isProperty,
    );
  }

  /// Parse a property definition
  static Property? _parseProperty(String line) {
    if (!line.contains(':') || line.contains('def ')) return null;

    final propertyMatch =
        RegExp(r'(\w+)\s*:\s*(.+?)(?:\s*=\s*(.+))?$').firstMatch(line);
    if (propertyMatch == null) return null;

    final name = propertyMatch.group(1)!;
    final type = propertyMatch.group(2)!;
    final defaultValue = propertyMatch.group(3);

    return Property(
      name: name,
      type: type.trim(),
      hasDefault: defaultValue != null,
      defaultValue: defaultValue?.trim(),
    );
  }

  /// Parse Python source code into a list of classes
  static Future<List<PythonClass>> parseFile(File file) async {
    final content = await file.readAsString();
    final lines = content.split('\n');
    final classes = <PythonClass>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('class ')) {
        final classMatch =
            RegExp(r'class\s+(\w+)(?:\((.*?)\))?:').firstMatch(trimmedLine);
        if (classMatch != null) {
          final className = classMatch.group(1)!;
          final basesStr = classMatch.group(2);
          final bases =
              basesStr?.split(',').map((b) => b.trim()).toList() ?? [];
          final isInterface = bases.any((b) => b.contains('Protocol'));

          final classIndent = _getIndentation(line);
          var currentDecorators = <String>[];
          final methods = <Method>[];
          final properties = <Property>[];

          // Parse class docstring
          var j = i + 1;
          String? docstring;
          if (j < lines.length && lines[j].trim().startsWith('"""')) {
            docstring = _parseDocstring(lines, j, classIndent);
            // Skip past docstring
            while (j < lines.length && !lines[j].trim().endsWith('"""')) {
              j++;
            }
            j++;
          }

          // Parse class body
          while (j < lines.length) {
            final currentLine = lines[j];
            final currentIndent = _getIndentation(currentLine);
            final trimmedCurrentLine = currentLine.trim();

            // Check if we're still in the class
            if (trimmedCurrentLine.isNotEmpty && currentIndent <= classIndent) {
              break;
            }

            // Skip empty lines
            if (trimmedCurrentLine.isEmpty) {
              j++;
              continue;
            }

            // Parse decorators
            if (trimmedCurrentLine.startsWith('@')) {
              currentDecorators
                  .add(trimmedCurrentLine.substring(1).split('(')[0].trim());
              j++;
              continue;
            }

            // Parse methods
            if (trimmedCurrentLine.startsWith('def ') ||
                trimmedCurrentLine.startsWith('async def ')) {
              final method =
                  _parseMethod(lines, j, List.from(currentDecorators));
              if (method != null) {
                methods.add(method);
                currentDecorators = [];
                // Skip past method body
                while (j < lines.length - 1) {
                  final nextLine = lines[j + 1];
                  if (nextLine.trim().isEmpty ||
                      _getIndentation(nextLine) <= currentIndent) {
                    break;
                  }
                  j++;
                }
              }
            }

            // Parse properties
            final property = _parseProperty(trimmedCurrentLine);
            if (property != null) {
              properties.add(property);
            }

            j++;
          }

          i = j - 1;

          classes.add(PythonClass(
            name: className,
            bases: bases,
            methods: methods,
            properties: properties,
            docstring: docstring,
            decorators: [],
            isInterface: isInterface,
          ));
        }
      }
    }

    return classes;
  }
}
