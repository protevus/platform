import 'package:test/test.dart';
import '../tools/generate_dart_code.dart';

void main() {
  group('Code Generator Name Handling', () {
    test('converts Python method names to Dart style in interfaces', () {
      final interface = {
        'name': 'TestInterface',
        'docstring': 'Test interface.',
        'methods': [
          {
            'name': 'get_model_name',
            'return_type': 'str',
            'arguments': [],
            'docstring': 'Get model name.',
          },
          {
            'name': '__init__',
            'return_type': 'None',
            'arguments': [
              {
                'name': 'model_path',
                'type': 'str',
                'is_optional': false,
                'has_default': false,
              }
            ],
            'docstring': 'Initialize.',
          }
        ],
        'properties': [],
      };

      final code = generateInterface(interface);
      expect(code, contains('String getModelName();'));
      expect(code, contains('void new(String modelPath);'));
    });

    test('converts Python property names to Dart style in classes', () {
      final classContract = {
        'name': 'TestClass',
        'docstring': 'Test class.',
        'properties': [
          {
            'name': 'model_name',
            'type': 'str',
            'has_default': false,
          },
          {
            'name': 'is_initialized',
            'type': 'bool',
            'has_default': true,
          }
        ],
        'methods': [],
      };

      final code = generateClass(classContract);
      expect(code, contains('String get modelName'));
      expect(code, contains('bool get isInitialized'));
    });
  });
}
