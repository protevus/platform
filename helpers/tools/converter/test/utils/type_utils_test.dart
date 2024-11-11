import 'package:test/test.dart';
import '../../lib/src/utils/type_utils.dart';

void main() {
  group('TypeUtils', () {
    test('castToMapList handles null input', () {
      expect(TypeUtils.castToMapList(null), isEmpty);
    });

    test('castToMapList converts List<dynamic> to List<Map<String, dynamic>>',
        () {
      final input = [
        {'name': 'test', 'value': 1},
        {'type': 'string', 'optional': true}
      ];
      final result = TypeUtils.castToMapList(input);
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.first['name'], equals('test'));
      expect(result.last['type'], equals('string'));
    });

    test('castToMap handles null input', () {
      expect(TypeUtils.castToMap(null), isEmpty);
    });

    test('castToMap converts dynamic to Map<String, dynamic>', () {
      final input = {'name': 'test', 'value': 1};
      final result = TypeUtils.castToMap(input);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['name'], equals('test'));
      expect(result['value'], equals(1));
    });

    test('castToStringList handles null input', () {
      expect(TypeUtils.castToStringList(null), isEmpty);
    });

    test('castToStringList converts List<dynamic> to List<String>', () {
      final input = ['test', 1, true];
      final result = TypeUtils.castToStringList(input);
      expect(result, isA<List<String>>());
      expect(result, equals(['test', '1', 'true']));
    });
  });
}
