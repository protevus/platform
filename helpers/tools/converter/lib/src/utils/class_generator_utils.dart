import 'name_utils.dart';
import 'type_conversion_utils.dart';

/// Utility class for generating Dart class code
class ClassGeneratorUtils {
  /// Generate a constructor for a class
  static String generateConstructor(
      String className, List<Map<String, dynamic>> properties) {
    final buffer = StringBuffer();

    // Constructor signature
    buffer.writeln('  $className({');
    final params = <String>[];
    for (final prop in properties) {
      final propName = NameUtils.toDartName(prop['name'] as String);
      final propType =
          TypeConversionUtils.pythonToDartType(prop['type'] as String);
      final hasDefault = prop['has_default'] == true;

      if (hasDefault) {
        params.add('    $propType? $propName,');
      } else {
        params.add('    required $propType $propName,');
      }
    }
    buffer.writeln(params.join('\n'));
    buffer.writeln('  }) {');

    // Initialize properties in constructor body
    for (final prop in properties) {
      final propName = NameUtils.toDartName(prop['name'] as String);
      final propType =
          TypeConversionUtils.pythonToDartType(prop['type'] as String);
      final hasDefault = prop['has_default'] == true;

      if (hasDefault) {
        final defaultValue = TypeConversionUtils.getDefaultValue(propType);
        buffer.writeln('    _$propName = $propName ?? $defaultValue;');
      } else {
        buffer.writeln('    _$propName = $propName;');
      }
    }
    buffer.writeln('  }');
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate property declarations and accessors
  static String generateProperties(List<Map<String, dynamic>> properties) {
    final buffer = StringBuffer();

    for (final prop in properties) {
      final propName = NameUtils.toDartName(prop['name'] as String);
      final propType =
          TypeConversionUtils.pythonToDartType(prop['type'] as String);
      buffer.writeln('  late $propType _$propName;');

      // Generate getter
      buffer.writeln('  $propType get $propName => _$propName;');

      // Generate setter if not readonly
      final isReadonly = prop['is_readonly'];
      if (isReadonly != null && !isReadonly) {
        buffer.writeln('  set $propName($propType value) {');
        buffer.writeln('    _$propName = value;');
        buffer.writeln('  }');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Generate a method implementation
  static String generateMethod(Map<String, dynamic> method) {
    if (method['name'] == '__init__') return '';

    final buffer = StringBuffer();
    final methodName = NameUtils.toDartName(method['name'] as String);
    final returnType =
        TypeConversionUtils.pythonToDartType(method['return_type'] as String);
    final methodDoc = method['docstring'] as String?;
    final isAsync = method['is_async'] == true;

    if (methodDoc != null) {
      buffer.writeln('  /// ${methodDoc.replaceAll('\n', '\n  /// ')}');
    }

    // Method signature
    if (isAsync) {
      buffer.write('  Future<$returnType> $methodName(');
    } else {
      buffer.write('  $returnType $methodName(');
    }

    // Parameters
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

    buffer.write(')');
    if (isAsync) buffer.write(' async');
    buffer.writeln(' {');
    buffer.writeln('    // TODO: Implement $methodName');
    if (returnType == 'void') {
      buffer.writeln('    throw UnimplementedError();');
    } else {
      buffer.writeln('    throw UnimplementedError();');
    }
    buffer.writeln('  }');
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate required interface implementations
  static String generateRequiredImplementations(
      List<String> bases, Map<String, dynamic> classContract) {
    final buffer = StringBuffer();

    // Generate BaseChain implementations
    if (bases.contains('BaseChain')) {
      buffer.writeln('  late Map<String, dynamic>? _memory;');
      buffer.writeln('  Map<String, dynamic>? get memory => _memory;');
      buffer.writeln();
      buffer.writeln('  late bool _verbose;');
      buffer.writeln('  bool get verbose => _verbose;');
      buffer.writeln();

      // Constructor with required properties
      buffer.writeln('  ${classContract['name']}({');
      buffer.writeln('    Map<String, dynamic>? memory,');
      buffer.writeln('    bool? verbose,');
      buffer.writeln('  }) {');
      buffer.writeln('    _memory = memory ?? {};');
      buffer.writeln('    _verbose = verbose ?? false;');
      buffer.writeln('  }');
      buffer.writeln();

      // Required methods
      buffer.writeln('  @override');
      buffer.writeln('  void setMemory(Map<String, dynamic> memory) {');
      buffer.writeln('    // TODO: Implement setMemory');
      buffer.writeln('    throw UnimplementedError();');
      buffer.writeln('  }');
      buffer.writeln();
    }

    return buffer.toString();
  }
}
