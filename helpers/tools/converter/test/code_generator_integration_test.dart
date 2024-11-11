import 'package:test/test.dart';
import '../tools/generate_dart_code.dart';
import '../lib/src/utils/class_generator_utils.dart';

void main() {
  group('Code Generator Integration', () {
    test('generates complete class with properties and methods', () {
      final classContract = {
        'name': 'TestModel',
        'docstring': 'A test model implementation.',
        'bases': ['BaseModel'],
        'properties': [
          {
            'name': 'model_name',
            'type': 'String',
            'has_default': false,
          },
          {
            'name': 'is_loaded',
            'type': 'bool',
            'has_default': true,
          }
        ],
        'methods': [
          {
            'name': '__init__',
            'return_type': 'None',
            'arguments': [
              {
                'name': 'model_name',
                'type': 'String',
                'is_optional': false,
                'has_default': false,
              }
            ],
            'docstring': 'Initialize the model.',
          },
          {
            'name': 'process_input',
            'return_type': 'String',
            'arguments': [
              {
                'name': 'input_text',
                'type': 'String',
                'is_optional': false,
                'has_default': false,
              }
            ],
            'docstring': 'Process input text.',
            'is_async': true,
          }
        ],
      };

      final code = generateClass(classContract);

      // Class definition
      expect(code, contains('class TestModel implements BaseModel {'));
      expect(code, contains('/// A test model implementation.'));

      // Properties
      expect(code, contains('late String _modelName;'));
      expect(code, contains('String get modelName => _modelName;'));
      expect(code, contains('late bool _isLoaded;'));
      expect(code, contains('bool get isLoaded => _isLoaded;'));

      // Constructor
      expect(code, contains('TestModel({'));
      expect(code, contains('required String modelName,'));
      expect(code, contains('bool? isLoaded,'));
      expect(code, contains('_modelName = modelName;'));
      expect(code, contains('_isLoaded = isLoaded ?? false;'));

      // Methods
      expect(code,
          contains('Future<String> processInput(String inputText) async {'));
      expect(code, contains('/// Process input text.'));

      // No __init__ method
      expect(code, isNot(contains('__init__')));
      expect(code, isNot(contains('void new(')));
    });
  });
}
