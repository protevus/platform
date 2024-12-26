import 'dart:io';
import 'package:path/path.dart' as path;
import '../metadata/type_metadata.dart';
import '../metadata/constructor_metadata.dart';
import '../metadata/method_metadata.dart';
import '../metadata/parameter_metadata.dart';
import '../metadata/property_metadata.dart';
import '../registry/reflection_registry.dart';
import '../reflector/runtime_reflector.dart';
import 'proxy_type.dart';

/// Discovers and analyzes types in a package automatically.
class PackageAnalyzer {
  // Private constructor to prevent instantiation
  PackageAnalyzer._();

  // Cache of discovered types and mappings
  static final Map<String, Set<Type>> _packageTypes = {};
  static final Map<String, Type> _typeCache = {};
  static final Map<Type, String> _typeNameCache = {};

  // The runtime reflector instance
  static final _reflector = RuntimeReflector.instance;

  /// Gets or creates a Type instance for a type name.
  static Type _getTypeForName(String name) {
    // Remove any generic type parameters and whitespace
    name = name.split('<')[0].trim();

    return _typeCache.putIfAbsent(name, () {
      // For built-in types, return the actual type
      switch (name) {
        case 'String':
          return String;
        case 'int':
          return int;
        case 'double':
          return double;
        case 'bool':
          return bool;
        case 'List':
          return List;
        case 'Map':
          return Map;
        case 'Set':
          return Set;
        case 'Object':
          return Object;
        case 'dynamic':
          return Object; // Use Object as fallback for dynamic
        case 'void':
          return Object; // Use Object as fallback for void
        case 'Null':
          return Object; // Use Object as fallback for Null
        default:
          // For user-defined types, create a proxy type
          final type = ProxyType(name);
          _typeNameCache[type] = name;
          ReflectionRegistry.register(type);
          return type;
      }
    });
  }

  /// Gets the name of a Type.
  static String? getTypeName(Type type) {
    if (type == String) return 'String';
    if (type == int) return 'int';
    if (type == double) return 'double';
    if (type == bool) return 'bool';
    if (type == List) return 'List';
    if (type == Map) return 'Map';
    if (type == Set) return 'Set';
    if (type == Object) return _typeNameCache[type] ?? 'Object';
    return _typeNameCache[type];
  }

  /// Discovers all types in a package.
  static Set<Type> discoverTypes(String packagePath) {
    if (_packageTypes.containsKey(packagePath)) {
      return _packageTypes[packagePath]!;
    }

    final types = _scanPackage(packagePath);
    _packageTypes[packagePath] = types;
    return types;
  }

  /// Scans a package directory for Dart files and extracts type information.
  static Set<Type> _scanPackage(String packagePath) {
    final types = <Type>{};
    final libDir = Directory(path.join(packagePath, 'lib'));

    if (!libDir.existsSync()) {
      return types;
    }

    // Get all .dart files recursively
    final dartFiles = libDir
        .listSync(recursive: true)
        .where((f) => f.path.endsWith('.dart'))
        .cast<File>();

    for (final file in dartFiles) {
      try {
        // Parse file and extract type information
        final fileTypes = _analyzeFile(file.path);
        types.addAll(fileTypes);
      } catch (e) {
        print('Warning: Failed to analyze ${file.path}: $e');
      }
    }

    return types;
  }

  /// Analyzes a Dart file and extracts type information.
  static Set<Type> _analyzeFile(String filePath) {
    final types = <Type>{};
    final source = File(filePath).readAsStringSync();

    // Extract class declarations using regex
    final classRegex = RegExp(
        r'(?:abstract\s+)?class\s+(\w+)(?:<[^>]+>)?(?:\s+extends\s+(\w+)(?:<[^>]+>)?)?(?:\s+implements\s+([^{]+))?\s*{',
        multiLine: true);
    final matches = classRegex.allMatches(source);

    for (final match in matches) {
      final className = match.group(1)!;
      final superclass = match.group(2);
      final interfaces = match.group(3);

      // Extract class content for further analysis
      final classContent = _extractClassContent(source, className);

      // Extract properties
      final properties = _extractProperties(classContent, className);

      // Extract methods
      final methods = _extractMethods(classContent, className);

      // Extract constructors
      final constructors = _extractConstructors(classContent, className);

      // Register with reflection system
      _registerType(
        className,
        properties,
        methods,
        constructors,
        superclass,
        interfaces,
        source.contains('abstract class $className'),
      );

      // Add to discovered types
      types.add(_getTypeForName(className));
    }

    return types;
  }

  /// Registers a type with the reflection system.
  static void _registerType(
    String className,
    Map<String, PropertyMetadata> properties,
    Map<String, MethodMetadata> methods,
    List<ConstructorMetadata> constructors,
    String? superclass,
    String? interfaces,
    bool isAbstract,
  ) {
    final type = _getTypeForName(className);

    // Register properties
    properties.forEach((name, metadata) {
      ReflectionRegistry.registerProperty(
        type,
        name,
        metadata.type,
        isWritable: metadata.isWritable,
      );
    });

    // Register methods
    methods.forEach((name, metadata) {
      // Get parameter names for named parameters only
      final parameterNames = metadata.parameters
          .where((p) => p.isNamed)
          .map((p) => p.name)
          .toList();

      // Get required flags for named parameters only
      final isRequired = metadata.parameters
          .where((p) => p.isNamed)
          .map((p) => p.isRequired)
          .toList();

      // Get isNamed flags for all parameters
      final isNamed = metadata.parameters.map((p) => p.isNamed).toList();

      ReflectionRegistry.registerMethod(
        type,
        name,
        metadata.parameterTypes,
        metadata.returnsVoid,
        returnType: metadata.returnType,
        parameterNames: parameterNames.isNotEmpty ? parameterNames : null,
        isRequired: isRequired.isNotEmpty ? isRequired : null,
        isNamed: isNamed.isNotEmpty ? isNamed : null,
        isStatic: metadata.isStatic,
      );
    });

    // Register constructors
    for (final constructor in constructors) {
      // Get parameter names for named parameters
      final parameterNames = constructor.parameters
          .where((p) => p.isNamed)
          .map((p) => p.name)
          .toList();

      ReflectionRegistry.registerConstructor(
        type,
        constructor.name,
        parameterTypes: constructor.parameterTypes,
        parameterNames: parameterNames.isNotEmpty ? parameterNames : null,
      );
    }

    // Create type metadata
    final metadata = TypeMetadata(
      type: type,
      name: className,
      properties: properties,
      methods: methods,
      constructors: constructors,
      supertype: superclass != null
          ? TypeMetadata(
              type: _getTypeForName(superclass),
              name: superclass,
              properties: const {},
              methods: const {},
              constructors: const [],
            )
          : null,
      interfaces: interfaces
              ?.split(',')
              .map((i) => i.trim())
              .where((i) => i.isNotEmpty)
              .map((i) => TypeMetadata(
                    type: _getTypeForName(i),
                    name: i,
                    properties: const {},
                    methods: const {},
                    constructors: const [],
                  ))
              .toList() ??
          const [],
    );

    // Register metadata with reflection system
    ReflectionRegistry.registerTypeMetadata(type, metadata);
  }

  /// Extracts property information from a class.
  static Map<String, PropertyMetadata> _extractProperties(
      String classContent, String className) {
    final properties = <String, PropertyMetadata>{};

    // Extract field declarations using regex
    final fieldRegex = RegExp(
      r'(?:final|const)?\s*(\w+(?:<[^>]+>)?)\s+(\w+)(?:\s*\?)?(?:\s*=\s*[^;]+)?;',
      multiLine: true,
    );

    // Extract nullable field declarations
    final nullableFieldRegex = RegExp(
      r'(?:final|const)?\s*(\w+(?:<[^>]+>)?)\s*\?\s*(\w+)(?:\s*=\s*[^;]+)?;',
      multiLine: true,
    );

    // Extract field declarations from initializer lists
    final initializerRegex = RegExp(
      r':\s*([^{]+)',
      multiLine: true,
    );

    // Extract constructor declarations
    final constructorRegex = RegExp(
      r'$className\s*\(((?:[^)]|\n)*)\)',
      multiLine: true,
    );

    // Process regular field declarations
    final fieldMatches = fieldRegex.allMatches(classContent);
    for (final match in fieldMatches) {
      final type = match.group(1)!;
      final name = match.group(2)!;
      final fullDecl = classContent.substring(match.start, match.end);

      properties[name] = PropertyMetadata(
        name: name,
        type: _getTypeForName(type),
        isReadable: true,
        isWritable: !fullDecl.contains('final $type') &&
            !fullDecl.contains('const $type'),
      );
    }

    // Process nullable field declarations
    final nullableMatches = nullableFieldRegex.allMatches(classContent);
    for (final match in nullableMatches) {
      final type = match.group(1)!;
      final name = match.group(2)!;
      final fullDecl = classContent.substring(match.start, match.end);

      properties[name] = PropertyMetadata(
        name: name,
        type: _getTypeForName(type),
        isReadable: true,
        isWritable: !fullDecl.contains('final $type') &&
            !fullDecl.contains('const $type'),
      );
    }

    // Process initializer list assignments
    final initializerMatch = initializerRegex.firstMatch(classContent);
    if (initializerMatch != null) {
      final initializers = initializerMatch.group(1)!;

      // Extract assignments in initializer list
      final assignmentRegex = RegExp(
        r'(\w+)\s*=\s*([^,{]+)(?:,|\s*{)',
        multiLine: true,
      );

      final assignmentMatches = assignmentRegex.allMatches(initializers);
      for (final match in assignmentMatches) {
        final name = match.group(1)!;
        if (!properties.containsKey(name)) {
          // Find type from field declaration or parameter
          final typeMatch = RegExp(
            r'(?:final|const)?\s*(\w+(?:<[^>]+>)?)\s+' +
                name +
                r'(?:\s*\?)?[;=]',
          ).firstMatch(classContent);

          if (typeMatch != null) {
            final type = typeMatch.group(1)!;
            properties[name] = PropertyMetadata(
              name: name,
              type: _getTypeForName(type),
              isReadable: true,
              isWritable: !classContent.contains('final $type $name') &&
                  !classContent.contains('const $type $name'),
            );
          }
        }
      }
    }

    // Process constructor parameters
    final constructorMatch = constructorRegex.firstMatch(classContent);
    if (constructorMatch != null) {
      final paramList = constructorMatch.group(1)!;

      // Extract positional parameters
      final positionalRegex = RegExp(
        r'(?:required\s+)?(\w+(?:<[^>]+>)?)\s+(?:this\.)?(\w+)(?:\s*\?)?(?=\s*,|\s*\{|\s*\))',
        multiLine: true,
      );

      final positionalMatches = positionalRegex.allMatches(paramList);
      for (final match in positionalMatches) {
        final type = match.group(1)!;
        final name = match.group(2)!;
        final fullParam = paramList.substring(match.start, match.end);
        final isNullable = fullParam.contains('$type?') ||
            fullParam.contains('$type ?') ||
            fullParam.contains('this.$name?');

        if (!properties.containsKey(name)) {
          properties[name] = PropertyMetadata(
            name: name,
            type: _getTypeForName(type),
            isReadable: true,
            isWritable: !classContent.contains('final $type $name') &&
                !classContent.contains('const $type $name'),
          );
        }
      }

      // Extract named parameters section
      final namedParamsMatch = RegExp(r'{([^}]*)}').firstMatch(paramList);
      if (namedParamsMatch != null) {
        final namedParams = namedParamsMatch.group(1)!;

        // Extract named parameters
        final namedRegex = RegExp(
          r'(?:required\s+)?(\w+(?:<[^>]+>)?)\s+(?:this\.)?(\w+)(?:\s*\?)?(?:\s*=\s*[^,}]+)?(?:\s*,|\s*$)',
          multiLine: true,
        );

        final namedMatches = namedRegex.allMatches(namedParams);
        for (final match in namedMatches) {
          final type = match.group(1)!;
          final name = match.group(2)!;
          final fullParam = namedParams.substring(match.start, match.end);
          final isNullable = fullParam.contains('$type?') ||
              fullParam.contains('$type ?') ||
              fullParam.contains('this.$name?');

          if (!properties.containsKey(name)) {
            properties[name] = PropertyMetadata(
              name: name,
              type: _getTypeForName(type),
              isReadable: true,
              isWritable: !classContent.contains('final $type $name') &&
                  !classContent.contains('const $type $name'),
            );
          }
        }
      }
    }

    // Extract getter declarations
    final getterRegex = RegExp(
      r'(?:get|set)\s+(\w+)(?:\s*=>|\s*{)',
      multiLine: true,
    );

    final getterMatches = getterRegex.allMatches(classContent);
    for (final match in getterMatches) {
      final name = match.group(1)!;
      if (!properties.containsKey(name)) {
        // Try to find the return type from the getter implementation
        final getterImpl = RegExp(
          r'get\s+' + name + r'\s*(?:=>|\{)\s*(?:return\s+)?(\w+)',
        ).firstMatch(classContent);
        final type = getterImpl?.group(1) ?? 'dynamic';

        properties[name] = PropertyMetadata(
          name: name,
          type: _getTypeForName(type),
          isReadable: true,
          isWritable: classContent.contains('set $name'),
        );
      }
    }

    return properties;
  }

  /// Extracts method information from a class.
  static Map<String, MethodMetadata> _extractMethods(
      String classContent, String className) {
    final methods = <String, MethodMetadata>{};

    // Extract method declarations using regex
    final methodRegex = RegExp(
      r'(?:static\s+)?(\w+(?:<[^>]+>)?)\s+(\w+)\s*\((.*?)\)',
      multiLine: true,
    );

    final matches = methodRegex.allMatches(classContent);

    for (final match in matches) {
      final returnType = match.group(1)!;
      final name = match.group(2)!;
      final params = match.group(3)!;

      if (name != className) {
        // Skip constructors
        methods[name] = MethodMetadata(
          name: name,
          parameterTypes: _extractParameterTypes(params),
          parameters: _extractParameters(params),
          returnsVoid: returnType == 'void',
          returnType: _getTypeForName(returnType),
          isStatic: classContent.contains('static $returnType $name'),
        );
      }
    }

    return methods;
  }

  /// Extracts constructor information from a class.
  static List<ConstructorMetadata> _extractConstructors(
      String classContent, String className) {
    final constructors = <ConstructorMetadata>[];

    // Find the class declaration
    final classRegex = RegExp(
      '(?:abstract\\s+)?class\\s+' + RegExp.escape(className) + '[^{]*\\{',
    );
    final classMatch = classRegex.firstMatch(classContent);
    if (classMatch == null) return constructors;

    print('Class content for $className:');
    print(classContent);

    // Extract all constructor declarations using regex
    final constructorPattern = '(?:const\\s+)?(?:factory\\s+)?' +
        RegExp.escape(className) +
        '(?:\\.([\\w.]+))?\\s*\\(([^)]*)\\)(?:\\s*:[^{;]*?)?(?:\\s*(?:=>|{|;))';
    print('Constructor pattern: $constructorPattern');

    final constructorRegex =
        RegExp(constructorPattern, multiLine: true, dotAll: true);
    final matches = constructorRegex.allMatches(classContent);

    print('Found ${matches.length} constructor matches:');
    for (final match in matches) {
      final fullMatch = classContent.substring(match.start, match.end);
      print('Full match: $fullMatch');
      print('Group 1 (name): ${match.group(1)}');
      print('Group 2 (params): ${match.group(2)}');

      // Get the line containing this match
      final lineStart = classContent.lastIndexOf('\n', match.start) + 1;
      final lineEnd = classContent.indexOf('\n', match.start);
      final line = classContent.substring(
          lineStart, lineEnd > 0 ? lineEnd : classContent.length);

      // Skip if this is part of a static method or return statement
      if (line.trim().startsWith('static') ||
          line.trim().startsWith('return')) {
        continue;
      }

      final name = match.group(1) ?? '';
      final params = match.group(2) ?? '';
      final isFactory = line.trim().startsWith('factory');

      // For factory constructors without a name, use 'create'
      final constructorName = isFactory && name.isEmpty ? 'create' : name;

      // Parse parameters
      final parameterTypes = _extractParameterTypes(params);
      final parameters = _extractParameters(params);

      // Add constructor
      constructors.add(ConstructorMetadata(
        name: constructorName,
        parameterTypes: parameterTypes,
        parameters: parameters,
      ));
    }

    print('Returning ${constructors.length} constructors');
    return constructors;
  }

  /// Extracts parameter types from a parameter list string.
  static List<Type> _extractParameterTypes(String params) {
    final types = <Type>[];
    final paramRegex = RegExp(
      r'(?:required\s+)?(\w+(?:<[^>]+>)?)\s+(?:this\.)?(\w+)(?:\s*\?)?',
      multiLine: true,
    );

    // Split parameters by commas, handling both positional and named parameters
    final parts =
        params.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);
    for (final part in parts) {
      if (part.startsWith('{') || part.endsWith('}')) {
        // Handle named parameter section
        final namedParams = part.replaceAll(RegExp(r'[{}]'), '').trim();
        if (namedParams.isNotEmpty) {
          final namedParts = namedParams
              .split(',')
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty);
          for (final namedPart in namedParts) {
            final match = paramRegex.firstMatch(namedPart);
            if (match != null) {
              types.add(_getTypeForName(match.group(1)!));
            }
          }
        }
      } else {
        // Handle positional parameter
        final match = paramRegex.firstMatch(part);
        if (match != null) {
          types.add(_getTypeForName(match.group(1)!));
        }
      }
    }

    return types;
  }

  /// Extracts parameters from a parameter list string.
  static List<ParameterMetadata> _extractParameters(String params) {
    final parameters = <ParameterMetadata>[];
    final paramRegex = RegExp(
      r'(?:required\s+)?(\w+(?:<[^>]+>)?)\s+(?:this\.)?(\w+)(?:\s*\?)?(?:\s*=\s*([^,}]+))?',
      multiLine: true,
    );

    // Split parameters by commas, handling both positional and named parameters
    final parts =
        params.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);
    for (final part in parts) {
      if (part.startsWith('{') || part.endsWith('}')) {
        // Handle named parameter section
        final namedParams = part.replaceAll(RegExp(r'[{}]'), '').trim();
        if (namedParams.isNotEmpty) {
          final namedParts = namedParams
              .split(',')
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty);
          for (final namedPart in namedParts) {
            final match = paramRegex.firstMatch(namedPart);
            if (match != null) {
              final type = match.group(1)!;
              final name = match.group(2)!;
              final defaultValue = match.group(3);
              final isRequired = namedPart.contains('required');

              parameters.add(ParameterMetadata(
                name: name,
                type: _getTypeForName(type),
                isRequired: isRequired,
                isNamed: true,
                defaultValue: defaultValue != null
                    ? _parseDefaultValue(defaultValue)
                    : null,
              ));
            }
          }
        }
      } else {
        // Handle positional parameter
        final match = paramRegex.firstMatch(part);
        if (match != null) {
          final type = match.group(1)!;
          final name = match.group(2)!;

          parameters.add(ParameterMetadata(
            name: name,
            type: _getTypeForName(type),
            isRequired: true,
            isNamed: false,
          ));
        }
      }
    }

    return parameters;
  }

  /// Extracts the content of a class from source code.
  static String _extractClassContent(String source, String className) {
    // Find the class declaration
    final classRegex = RegExp(
      '(?:abstract\\s+)?class\\s+' + RegExp.escape(className) + '[^{]*\\{',
    );
    final match = classRegex.firstMatch(source);
    if (match == null) return '';

    // Find the matching closing brace
    var bracketCount = 0;
    var inString = false;
    var stringChar = '';
    var endIndex = source.length;

    for (var i = match.start; i < source.length; i++) {
      final char = source[i];

      // Handle string literals to avoid counting braces inside strings
      if ((char == '"' || char == "'") && (i == 0 || source[i - 1] != '\\')) {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (stringChar == char) {
          inString = false;
        }
      }

      if (!inString) {
        if (char == '{') {
          bracketCount++;
        } else if (char == '}') {
          bracketCount--;
          if (bracketCount == 0 && i > match.end) {
            endIndex = i + 1;
            break;
          }
        }
      }
    }

    // Include the class declaration and its content
    final content = source.substring(match.start, endIndex);
    return content;
  }

  /// Parses a default value string into an actual value.
  static dynamic _parseDefaultValue(String value) {
    // Basic parsing of common default values
    if (value == 'null') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (value.startsWith("'") && value.endsWith("'")) {
      return value.substring(1, value.length - 1);
    }
    if (int.tryParse(value) != null) return int.parse(value);
    if (double.tryParse(value) != null) return double.parse(value);
    return value;
  }
}
