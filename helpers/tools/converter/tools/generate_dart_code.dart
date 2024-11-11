import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';
import 'package:converter/src/utils/yaml_utils.dart';
import 'package:converter/src/utils/name_utils.dart';
import 'package:converter/src/utils/class_generator_utils.dart';
import 'package:converter/src/utils/type_utils.dart';
import 'package:converter/src/utils/type_conversion_utils.dart';

/// Generates a Dart interface from a contract
String generateInterface(Map<String, dynamic> interface) {
  final buffer = StringBuffer();
  final name = interface['name'] as String;
  final docstring = interface['docstring'] as String?;

  // Add documentation
  if (docstring != null) {
    buffer.writeln('/// ${docstring.replaceAll('\n', '\n/// ')}');
  }

  // Begin interface definition
  buffer.writeln('abstract class $name {');

  // Generate properties
  final properties = interface['properties'] as List?;
  if (properties != null) {
    for (final prop in properties) {
      final propName = NameUtils.toDartName(prop['name'] as String);
      final propType =
          TypeConversionUtils.pythonToDartType(prop['type'] as String);
      buffer.writeln('  $propType get $propName;');
      // Only generate setter if is_readonly is explicitly false
      final isReadonly = prop['is_readonly'];
      if (isReadonly != null && !isReadonly) {
        buffer.writeln('  set $propName($propType value);');
      }
    }
    if (properties.isNotEmpty) buffer.writeln();
  }

  // Generate methods
  final methods = interface['methods'] as List?;
  if (methods != null) {
    for (final method in methods) {
      final methodName = NameUtils.toDartName(method['name'] as String);
      final returnType =
          TypeConversionUtils.pythonToDartType(method['return_type'] as String);
      final methodDoc = method['docstring'] as String?;
      final decorators = TypeUtils.castToMapList(method['decorators'] as List?);
      final isProperty = decorators.any((d) => d['name'] == 'property');

      if (methodDoc != null) {
        buffer.writeln('  /// ${methodDoc.replaceAll('\n', '\n  /// ')}');
      }

      if (isProperty) {
        // Generate as a getter
        buffer.writeln('  $returnType get $methodName;');
      } else {
        // Generate as a method
        final isAsync = method['is_async'] == true;
        if (isAsync) {
          buffer.write('  Future<$returnType> $methodName(');
        } else {
          buffer.write('  $returnType $methodName(');
        }

        // Generate parameters
        final params = method['arguments'] as List?;
        if (params != null && params.isNotEmpty) {
          final paramStrings = <String>[];

          for (final param in params) {
            final paramName = NameUtils.toDartName(param['name'] as String);
            final paramType =
                TypeConversionUtils.pythonToDartType(param['type'] as String);
            final isOptional = param['is_optional'] == true;

            if (isOptional) {
              paramStrings.add('[$paramType $paramName]');
            } else {
              paramStrings.add('$paramType $paramName');
            }
          }

          buffer.write(paramStrings.join(', '));
        }

        buffer.writeln(');');
      }
    }
  }

  buffer.writeln('}');
  return buffer.toString();
}

/// Generates a Dart class implementation from a contract
String generateClass(Map<String, dynamic> classContract) {
  final buffer = StringBuffer();
  final name = classContract['name'] as String;
  final bases = TypeUtils.castToStringList(classContract['bases'] as List?);
  final docstring = classContract['docstring'] as String?;

  // Add documentation
  if (docstring != null) {
    buffer.writeln('/// ${docstring.replaceAll('\n', '\n/// ')}');
  }

  // Begin class definition
  buffer.write('class $name');
  if (bases.isNotEmpty) {
    final implementsStr = bases.join(', ');
    buffer.write(' implements $implementsStr');
  }
  buffer.writeln(' {');

  // Generate required interface implementations first
  if (bases.contains('BaseChain')) {
    buffer.write(ClassGeneratorUtils.generateRequiredImplementations(
        bases, classContract));
  }

  // Generate properties from contract properties
  final properties =
      TypeUtils.castToMapList(classContract['properties'] as List?);
  if (properties.isNotEmpty) {
    buffer.write(ClassGeneratorUtils.generateProperties(properties));
  }

  // Generate constructor
  if (properties.isNotEmpty || bases.contains('BaseChain')) {
    buffer.write(ClassGeneratorUtils.generateConstructor(name, properties));
  }

  // Generate additional methods
  final methods = TypeUtils.castToMapList(classContract['methods'] as List?);
  if (methods.isNotEmpty) {
    for (final method in methods) {
      if (method['name'] != '__init__') {
        buffer.write(ClassGeneratorUtils.generateMethod(method));
      }
    }
  }

  buffer.writeln('}');
  return buffer.toString();
}

/// Main code generator class
class DartCodeGenerator {
  final String outputDir;

  DartCodeGenerator(this.outputDir);

  Future<void> generateFromYaml(String yamlPath) async {
    final file = File(yamlPath);
    final content = await file.readAsString();
    final yamlDoc = loadYaml(content) as YamlMap;
    final contracts = YamlUtils.convertYamlToMap(yamlDoc);

    // Generate interfaces
    for (final interface in contracts['interfaces'] ?? []) {
      final code = generateInterface(interface as Map<String, dynamic>);
      final fileName = '${interface['name'].toString().toLowerCase()}.dart';
      final outputFile =
          File(path.join(outputDir, 'lib', 'src', 'interfaces', fileName));
      await outputFile.create(recursive: true);
      await outputFile.writeAsString(code);
    }

    // Generate classes
    for (final classContract in contracts['classes'] ?? []) {
      final code = generateClass(classContract as Map<String, dynamic>);
      final fileName = '${classContract['name'].toString().toLowerCase()}.dart';
      final outputFile =
          File(path.join(outputDir, 'lib', 'src', 'implementations', fileName));
      await outputFile.create(recursive: true);
      await outputFile.writeAsString(code);
    }
  }
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('contracts',
        abbr: 'c', help: 'Path to the YAML contracts file', mandatory: true)
    ..addOption('output',
        abbr: 'o',
        help: 'Output directory for generated Dart code',
        mandatory: true);

  try {
    final results = parser.parse(arguments);
    final contractsFile = results['contracts'] as String;
    final outputDir = results['output'] as String;

    final generator = DartCodeGenerator(outputDir);
    await generator.generateFromYaml(contractsFile);

    print('Code generation completed successfully.');
  } catch (e) {
    print('Error: $e');
    print(
        'Usage: dart generate_dart_code.dart --contracts <file> --output <dir>');
    exit(1);
  }
}
