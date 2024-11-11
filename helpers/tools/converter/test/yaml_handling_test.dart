import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import '../lib/src/utils/yaml_utils.dart';

void main() {
  group('YamlUtils', () {
    test('converts simple YAML to Map correctly', () {
      final yamlStr = '''
interfaces:
  - name: TestInterface
    methods:
      - name: testMethod
        arguments:
          - name: arg1
            type: str
        return_type: str
''';

      final yaml = loadYaml(yamlStr) as YamlMap;
      final map = YamlUtils.convertYamlToMap(yaml);

      expect(map, isA<Map<String, dynamic>>());
      expect(map['interfaces'], isA<List>());
      expect(map['interfaces'][0]['name'], equals('TestInterface'));
      expect(map['interfaces'][0]['methods'][0]['arguments'][0]['type'],
          equals('str'));
    });

    test('handles nested YAML structures', () {
      final yamlStr = '''
interfaces:
  - name: TestInterface
    properties:
      - name: prop1
        type: List[str]
        has_default: true
    methods:
      - name: testMethod
        arguments:
          - name: arg1
            type: Dict[str, Any]
            is_optional: true
        return_type: Optional[int]
''';

      final yaml = loadYaml(yamlStr) as YamlMap;
      final map = YamlUtils.convertYamlToMap(yaml);

      expect(
          map['interfaces'][0]['properties'][0]['type'], equals('List[str]'));
      expect(map['interfaces'][0]['methods'][0]['arguments'][0]['type'],
          equals('Dict[str, Any]'));
    });

    test('converts actual contract YAML correctly', () {
      final yamlStr = '''
interfaces:
  - name: LLMProtocol
    bases:
      - Protocol
    methods:
      - name: generate
        arguments:
          - name: prompts
            type: List[str]
            is_optional: false
            has_default: false
        return_type: List[str]
        docstring: Generate completions for the prompts.
        decorators:
          - name: abstractmethod
        is_abstract: true
    properties: []
    docstring: Protocol for language models.
    is_interface: true
''';

      final yaml = loadYaml(yamlStr) as YamlMap;
      final map = YamlUtils.convertYamlToMap(yaml);

      expect(map['interfaces'][0]['name'], equals('LLMProtocol'));
      expect(map['interfaces'][0]['bases'][0], equals('Protocol'));
      expect(map['interfaces'][0]['methods'][0]['name'], equals('generate'));
      expect(map['interfaces'][0]['methods'][0]['arguments'][0]['type'],
          equals('List[str]'));
      expect(map['interfaces'][0]['docstring'],
          equals('Protocol for language models.'));
    });
  });
}
