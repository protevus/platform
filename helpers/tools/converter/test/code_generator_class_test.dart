import 'package:test/test.dart';
import '../tools/generate_dart_code.dart';

void main() {
  group('Class Generation', () {
    test('generates class with interface implementations', () {
      final classContract = {
        'name': 'SimpleChain',
        'docstring': 'A simple implementation of a chain.',
        'bases': ['BaseChain'],
        'methods': [
          {
            'name': 'run',
            'return_type': 'dict',
            'arguments': [
              {
                'name': 'inputs',
                'type': 'dict',
                'is_optional': false,
              }
            ],
            'docstring': 'Execute the chain logic.',
          }
        ],
      };

      final code = generateClass(classContract);

      // Should include BaseChain implementations
      expect(code, contains('late Map<String, dynamic>? _memory;'));
      expect(code, contains('Map<String, dynamic>? get memory => _memory;'));
      expect(code, contains('late bool _verbose;'));
      expect(code, contains('bool get verbose => _verbose;'));

      // Should include constructor with required properties
      expect(code, contains('SimpleChain({'));
      expect(code, contains('Map<String, dynamic>? memory,'));
      expect(code, contains('bool? verbose,'));
      expect(code, contains('_memory = memory ?? {};'));
      expect(code, contains('_verbose = verbose ?? false;'));

      // Should include required method implementations
      expect(code, contains('@override'));
      expect(code, contains('void setMemory(Map<String, dynamic> memory)'));

      // Should include additional methods
      expect(code, contains('Map<String, dynamic> run('));
      expect(code, contains('Map<String, dynamic> inputs'));
      expect(code, contains('/// Execute the chain logic.'));
    });

    test('generates class with own properties and methods', () {
      final classContract = {
        'name': 'CustomClass',
        'docstring': 'A custom class.',
        'properties': [
          {
            'name': 'model_name',
            'type': 'String',
            'has_default': false,
          }
        ],
        'methods': [
          {
            'name': 'process',
            'return_type': 'String',
            'arguments': [
              {
                'name': 'input',
                'type': 'String',
                'is_optional': false,
              }
            ],
            'docstring': 'Process input.',
          }
        ],
      };

      final code = generateClass(classContract);

      // Should include properties
      expect(code, contains('late String _modelName;'));
      expect(code, contains('String get modelName => _modelName;'));

      // Should include constructor
      expect(code, contains('CustomClass({'));
      expect(code, contains('required String modelName'));
      expect(code, contains('_modelName = modelName;'));

      // Should include methods
      expect(code, contains('String process(String input)'));
      expect(code, contains('/// Process input.'));
    });
  });
}
