import 'package:test/test.dart';
import '../../lib/src/utils/constructor_utils.dart';

void main() {
  group('ConstructorUtils', () {
    test('generates required parameters for non-default properties', () {
      final properties = [
        {
          'name': 'model_name',
          'type': 'String',
          'has_default': false,
        }
      ];

      final params = ConstructorUtils.generateParameters(properties);
      expect(params, contains('required String model_name'));
    });

    test('generates optional parameters for default properties', () {
      final properties = [
        {
          'name': 'is_ready',
          'type': 'bool',
          'has_default': true,
        }
      ];

      final params = ConstructorUtils.generateParameters(properties);
      expect(params, contains('bool? is_ready'));
    });

    test('generates property initializers', () {
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

      final inits = ConstructorUtils.generateInitializers(properties);
      expect(inits, contains('_model_name = model_name;'));
      expect(inits, contains('_is_ready = is_ready ?? false;'));
    });

    test('identifies constructor methods', () {
      final initMethod = {
        'name': '__init__',
        'return_type': 'None',
        'arguments': [],
      };

      final regularMethod = {
        'name': 'process',
        'return_type': 'String',
        'arguments': [],
      };

      expect(ConstructorUtils.isConstructor(initMethod), isTrue);
      expect(ConstructorUtils.isConstructor(regularMethod), isFalse);
    });
  });
}
