/// Utility class for converting Python types to Dart types
class TypeConversionUtils {
  /// Convert a Python type string to its Dart equivalent
  static String pythonToDartType(String pythonType) {
    final typeMap = {
      'str': 'String',
      'int': 'int',
      'float': 'double',
      'bool': 'bool',
      'List': 'List',
      'Dict': 'Map',
      'dict': 'Map<String, dynamic>',
      'Any': 'dynamic',
      'None': 'void',
      'Optional': 'dynamic',
      'Union': 'dynamic',
      'Callable': 'Function',
    };

    // Handle generic types
    if (pythonType.contains('[')) {
      final match = RegExp(r'(\w+)\[(.*)\]').firstMatch(pythonType);
      if (match != null) {
        final baseType = match.group(1)!;
        final genericType = match.group(2)!;

        if (baseType == 'List') {
          return 'List<${pythonToDartType(genericType)}>';
        } else if (baseType == 'Dict' || baseType == 'dict') {
          final types = genericType.split(',');
          if (types.length == 2) {
            return 'Map<${pythonToDartType(types[0].trim())}, ${pythonToDartType(types[1].trim())}>';
          }
          return 'Map<String, dynamic>';
        } else if (baseType == 'Optional') {
          final innerType = pythonToDartType(genericType);
          if (innerType == 'Map<String, dynamic>') {
            return 'Map<String, dynamic>?';
          }
          return '${innerType}?';
        }
      }
    }

    // Handle raw types
    if (pythonType == 'dict') {
      return 'Map<String, dynamic>';
    } else if (pythonType == 'None') {
      return 'void';
    }

    return typeMap[pythonType] ?? pythonType;
  }

  /// Get a default value for a Dart type
  static String getDefaultValue(String dartType) {
    switch (dartType) {
      case 'bool':
      case 'bool?':
        return 'false';
      case 'int':
      case 'int?':
        return '0';
      case 'double':
      case 'double?':
        return '0.0';
      case 'String':
      case 'String?':
        return "''";
      case 'Map<String, dynamic>':
      case 'Map<String, dynamic>?':
        return '{}';
      case 'List':
      case 'List?':
        return '[]';
      default:
        if (dartType.startsWith('List<')) {
          return '[]';
        } else if (dartType.startsWith('Map<')) {
          return '{}';
        } else if (dartType.endsWith('?')) {
          return 'null';
        }
        return 'null';
    }
  }
}
