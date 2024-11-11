import 'package:test/test.dart';
import '../../lib/src/utils/name_utils.dart';

void main() {
  group('NameUtils', () {
    test('converts snake_case to camelCase', () {
      expect(NameUtils.toDartName('hello_world'), equals('helloWorld'));
      expect(NameUtils.toDartName('get_model_name'), equals('getModelName'));
      expect(NameUtils.toDartName('set_memory'), equals('setMemory'));
    });

    test('handles single word correctly', () {
      expect(NameUtils.toDartName('hello'), equals('hello'));
      expect(NameUtils.toDartName('test'), equals('test'));
    });

    test('preserves existing camelCase', () {
      expect(NameUtils.toDartName('helloWorld'), equals('helloWorld'));
      expect(NameUtils.toDartName('getModelName'), equals('getModelName'));
    });

    test('handles empty string', () {
      expect(NameUtils.toDartName(''), equals(''));
    });

    test('handles special method names', () {
      expect(NameUtils.toDartName('__init__'), equals('new'));
      expect(NameUtils.toDartName('__str__'), equals('str'));
      expect(NameUtils.toDartName('__repr__'), equals('repr'));
    });

    test('handles consecutive underscores', () {
      expect(NameUtils.toDartName('hello__world'), equals('helloWorld'));
      expect(NameUtils.toDartName('test___name'), equals('testName'));
    });
  });
}
