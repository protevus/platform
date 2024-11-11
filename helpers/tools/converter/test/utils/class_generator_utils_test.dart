import 'package:test/test.dart';
import '../../lib/src/utils/class_generator_utils.dart';

void main() {
  group('ClassGeneratorUtils', () {
    test('generates constructor with property initialization', () {
      final properties = [
        {
          'name': 'model_name',
          'type': 'String',
          'has_default': false,
        },
        {
          'name': 'is_ready',
          'type': 'bool',
          'has_default': true,
        }
      ];

      final code =
          ClassGeneratorUtils.generateConstructor('TestClass', properties);
      expect(code, contains('TestClass({'));
      expect(code, contains('required String modelName,'));
      expect(code, contains('bool? isReady,'));
      expect(code, contains('_modelName = modelName;'));
      expect(code, contains('_isReady = isReady ?? false;'));
    });

    test('generates properties with getters and setters', () {
      final properties = [
        {
          'name': 'model_name',
          'type': 'String',
          'is_readonly': true,
        },
        {
          'name': 'is_ready',
          'type': 'bool',
          'is_readonly': false,
        }
      ];

      final code = ClassGeneratorUtils.generateProperties(properties);
      expect(code, contains('late String _modelName;'));
      expect(code, contains('String get modelName => _modelName;'));
      expect(code, contains('late bool _isReady;'));
      expect(code, contains('bool get isReady => _isReady;'));
      expect(code, contains('set isReady(bool value)'));
      expect(code, isNot(contains('set modelName')));
    });

    test('generates async method correctly', () {
      final method = {
        'name': 'process_input',
        'return_type': 'String',
        'arguments': [
          {
            'name': 'input',
            'type': 'String',
            'is_optional': false,
          }
        ],
        'docstring': 'Process the input.',
        'is_async': true,
      };

      final code = ClassGeneratorUtils.generateMethod(method);
      expect(code, contains('Future<String> processInput('));
      expect(code, contains('String input'));
      expect(code, contains('async {'));
      expect(code, contains('/// Process the input.'));
    });

    test('skips generating constructor method', () {
      final method = {
        'name': '__init__',
        'return_type': 'void',
        'arguments': [],
      };

      final code = ClassGeneratorUtils.generateMethod(method);
      expect(code, isEmpty);
    });
  });
}
