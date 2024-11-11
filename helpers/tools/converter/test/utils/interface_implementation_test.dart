import 'package:test/test.dart';
import '../../lib/src/utils/class_generator_utils.dart';

void main() {
  group('Interface Implementation Generation', () {
    test('generates required BaseChain implementations', () {
      final bases = ['BaseChain'];
      final classContract = {
        'name': 'SimpleChain',
        'docstring': 'A simple implementation of a chain.',
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

      final code = ClassGeneratorUtils.generateRequiredImplementations(
          bases, classContract);

      // Should include memory property
      expect(code, contains('late Map<String, dynamic>? _memory;'));
      expect(code, contains('Map<String, dynamic>? get memory => _memory;'));

      // Should include verbose property
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
    });

    test('handles multiple interface implementations', () {
      final bases = ['BaseChain', 'Serializable'];
      final classContract = {
        'name': 'SimpleChain',
        'docstring': 'A simple implementation of a chain.',
        'methods': [],
      };

      final code = ClassGeneratorUtils.generateRequiredImplementations(
          bases, classContract);

      // Should include BaseChain implementations
      expect(code, contains('Map<String, dynamic>? get memory'));
      expect(code, contains('bool get verbose'));

      // Should include constructor with all required properties
      expect(code, contains('SimpleChain({'));
      expect(code, contains('Map<String, dynamic>? memory,'));
      expect(code, contains('bool? verbose,'));
    });

    test('handles no interface implementations', () {
      final bases = <String>[];
      final classContract = {
        'name': 'SimpleClass',
        'docstring': 'A simple class.',
        'methods': [],
      };

      final code = ClassGeneratorUtils.generateRequiredImplementations(
          bases, classContract);
      expect(code, isEmpty);
    });
  });
}
