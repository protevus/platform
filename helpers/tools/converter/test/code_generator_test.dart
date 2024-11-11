import 'package:test/test.dart';
import '../tools/generate_dart_code.dart';

void main() {
  group('Code Generator', () {
    test('generates constructor correctly', () {
      final classContract = {
        'name': 'TestClass',
        'docstring': 'Test class.',
        'properties': [
          {
            'name': 'name',
            'type': 'String',
            'has_default': false,
          },
          {
            'name': 'is_ready',
            'type': 'bool',
            'has_default': true,
          }
        ],
      };

      final code = generateClass(classContract);
      expect(code, contains('TestClass({'));
      expect(code, contains('required String name,'));
      expect(code, contains('bool? isReady,'));
      expect(code, contains('_name = name;'));
      expect(code, contains('_isReady = isReady ?? false;'));
    });

    test('handles async methods correctly', () {
      final classContract = {
        'name': 'TestClass',
        'docstring': 'Test class.',
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
            'is_async': true,
          }
        ],
      };

      final code = generateClass(classContract);
      expect(code, contains('Future<String> process(String input) async {'));
      expect(code, contains('/// Process input.'));
    });

    test('initializes properties in constructor', () {
      final classContract = {
        'name': 'TestClass',
        'docstring': 'Test class.',
        'properties': [
          {
            'name': 'name',
            'type': 'String',
            'has_default': false,
          },
          {
            'name': 'is_ready',
            'type': 'bool',
            'has_default': true,
          }
        ],
      };

      final code = generateClass(classContract);
      expect(code, contains('late String _name;'));
      expect(code, contains('late bool _isReady;'));
      expect(code, contains('_name = name;'));
      expect(code, contains('_isReady = isReady ?? false;'));
    });
  });
}
