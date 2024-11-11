import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import '../lib/src/utils/yaml_utils.dart';
import '../lib/src/utils/type_utils.dart';

void main() {
  group('YAML Type Casting', () {
    test('converts YAML data to properly typed maps and lists', () {
      final yamlStr = '''
classes:
  - name: TestClass
    properties:
      - name: model_name
        type: String
        has_default: false
      - name: is_ready
        type: bool
        has_default: true
    methods:
      - name: process
        return_type: String
        arguments:
          - name: input
            type: String
            is_optional: false
''';

      final yamlDoc = loadYaml(yamlStr) as YamlMap;
      final data = YamlUtils.convertYamlToMap(yamlDoc);

      final classes = data['classes'] as List;
      final firstClass = classes.first as Map<String, dynamic>;

      // Test properties casting
      final properties =
          TypeUtils.castToMapList(firstClass['properties'] as List?);
      expect(properties, isA<List<Map<String, dynamic>>>());
      expect(properties.first['name'], equals('model_name'));
      expect(properties.first['type'], equals('String'));
      expect(properties.first['has_default'], isFalse);

      // Test methods casting
      final methods = TypeUtils.castToMapList(firstClass['methods'] as List?);
      expect(methods, isA<List<Map<String, dynamic>>>());
      expect(methods.first['name'], equals('process'));
      expect(methods.first['return_type'], equals('String'));

      // Test nested arguments casting
      final arguments =
          TypeUtils.castToMapList(methods.first['arguments'] as List?);
      expect(arguments, isA<List<Map<String, dynamic>>>());
      expect(arguments.first['name'], equals('input'));
      expect(arguments.first['type'], equals('String'));
      expect(arguments.first['is_optional'], isFalse);
    });
  });
}
