import 'dart:io';
import 'package:args/args.dart';
import 'python_parser.dart';

/// Represents a Python class or interface contract
class ContractDefinition {
  final String name;
  final List<String> bases;
  final List<MethodDefinition> methods;
  final List<PropertyDefinition> properties;
  final String? docstring;
  final List<Map<String, dynamic>> decorators;
  final bool isInterface;

  ContractDefinition({
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

  /// Create ContractDefinition from PythonClass
  factory ContractDefinition.fromPythonClass(PythonClass pythonClass) {
    return ContractDefinition(
      name: pythonClass.name,
      bases: pythonClass.bases,
      methods: pythonClass.methods
          .map((m) => MethodDefinition(
                name: m.name,
                arguments: m.parameters
                    .map((p) => ArgumentDefinition(
                          name: p.name,
                          type: p.type,
                          isOptional: p.isOptional,
                          hasDefault: p.hasDefault,
                        ))
                    .toList(),
                returnType: m.returnType,
                docstring: m.docstring,
                decorators: m.decorators.map((d) => {'name': d}).toList(),
                isAbstract: m.isAbstract,
              ))
          .toList(),
      properties: pythonClass.properties
          .map((p) => PropertyDefinition(
                name: p.name,
                type: p.type,
                hasDefault: p.hasDefault,
              ))
          .toList(),
      docstring: pythonClass.docstring,
      decorators: pythonClass.decorators.map((d) => {'name': d}).toList(),
      isInterface: pythonClass.isInterface,
    );
  }
}

/// Represents a method in a contract
class MethodDefinition {
  final String name;
  final List<ArgumentDefinition> arguments;
  final String returnType;
  final String? docstring;
  final List<Map<String, dynamic>> decorators;
  final bool isAbstract;

  MethodDefinition({
    required this.name,
    required this.arguments,
    required this.returnType,
    this.docstring,
    required this.decorators,
    required this.isAbstract,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'arguments': arguments.map((a) => a.toJson()).toList(),
        'return_type': returnType,
        if (docstring != null) 'docstring': docstring,
        'decorators': decorators,
        'is_abstract': isAbstract,
      };
}

/// Represents a method argument
class ArgumentDefinition {
  final String name;
  final String type;
  final bool isOptional;
  final bool hasDefault;

  ArgumentDefinition({
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

/// Represents a class property
class PropertyDefinition {
  final String name;
  final String type;
  final bool hasDefault;

  PropertyDefinition({
    required this.name,
    required this.type,
    required this.hasDefault,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'has_default': hasDefault,
      };
}

/// Main contract extractor class
class ContractExtractor {
  final List<ContractDefinition> interfaces = [];
  final List<ContractDefinition> classes = [];

  /// Process a Python source file and extract contracts
  Future<void> processFile(File file) async {
    try {
      final pythonClasses = await PythonParser.parseFile(file);

      for (final pythonClass in pythonClasses) {
        final contract = ContractDefinition.fromPythonClass(pythonClass);
        if (pythonClass.isInterface) {
          interfaces.add(contract);
        } else {
          classes.add(contract);
        }
      }
    } catch (e) {
      print('Error processing file ${file.path}: $e');
    }
  }

  /// Process all Python files in a directory recursively
  Future<void> processDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.py')) {
        await processFile(entity);
      }
    }
  }

  /// Generate YAML output
  Future<void> generateYaml(String outputPath) async {
    final output = {
      'interfaces': interfaces.map((i) => i.toJson()).toList(),
      'classes': classes.map((c) => c.toJson()).toList(),
    };

    final yamlString = mapToYaml(output);
    final file = File(outputPath);
    await file.writeAsString(yamlString);
  }
}

/// Converts a Map to YAML string with proper formatting
String mapToYaml(Map<String, dynamic> map, {int indent = 0}) {
  final buffer = StringBuffer();
  final indentStr = ' ' * indent;

  map.forEach((key, value) {
    if (value is Map) {
      buffer.writeln('$indentStr$key:');
      buffer
          .write(mapToYaml(value as Map<String, dynamic>, indent: indent + 2));
    } else if (value is List) {
      buffer.writeln('$indentStr$key:');
      for (var item in value) {
        if (item is Map) {
          buffer.writeln('$indentStr- ');
          buffer.write(
              mapToYaml(item as Map<String, dynamic>, indent: indent + 4));
        } else {
          buffer.writeln('$indentStr- $item');
        }
      }
    } else {
      if (value == null) {
        buffer.writeln('$indentStr$key: null');
      } else if (value is String) {
        // Handle multi-line strings
        if (value.contains('\n')) {
          buffer.writeln('$indentStr$key: |');
          value.split('\n').forEach((line) {
            buffer.writeln('$indentStr  $line');
          });
        } else {
          buffer.writeln('$indentStr$key: "$value"');
        }
      } else {
        buffer.writeln('$indentStr$key: $value');
      }
    }
  });

  return buffer.toString();
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('source',
        abbr: 's',
        help: 'Source directory containing Python LangChain implementation',
        mandatory: true)
    ..addOption('output',
        abbr: 'o', help: 'Output YAML file path', mandatory: true);

  try {
    final results = parser.parse(arguments);
    final sourceDir = results['source'] as String;
    final outputFile = results['output'] as String;

    final extractor = ContractExtractor();
    await extractor.processDirectory(sourceDir);
    await extractor.generateYaml(outputFile);

    print('Contract extraction completed successfully.');
    print('Interfaces found: ${extractor.interfaces.length}');
    print('Classes found: ${extractor.classes.length}');
  } catch (e) {
    print('Error: $e');
    print('Usage: dart extract_contracts.dart --source <dir> --output <file>');
    exit(1);
  }
}
