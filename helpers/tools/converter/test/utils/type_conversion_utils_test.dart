import 'package:test/test.dart';
import '../../lib/src/utils/type_conversion_utils.dart';

void main() {
  group('TypeConversionUtils', () {
    group('pythonToDartType', () {
      test('converts basic Python types to Dart types', () {
        expect(TypeConversionUtils.pythonToDartType('str'), equals('String'));
        expect(TypeConversionUtils.pythonToDartType('int'), equals('int'));
        expect(TypeConversionUtils.pythonToDartType('bool'), equals('bool'));
        expect(TypeConversionUtils.pythonToDartType('None'), equals('void'));
        expect(TypeConversionUtils.pythonToDartType('dict'),
            equals('Map<String, dynamic>'));
      });

      test('converts List types correctly', () {
        expect(TypeConversionUtils.pythonToDartType('List[str]'),
            equals('List<String>'));
        expect(TypeConversionUtils.pythonToDartType('List[int]'),
            equals('List<int>'));
        expect(TypeConversionUtils.pythonToDartType('List[dict]'),
            equals('List<Map<String, dynamic>>'));
      });

      test('converts Dict types correctly', () {
        expect(TypeConversionUtils.pythonToDartType('Dict[str, Any]'),
            equals('Map<String, dynamic>'));
        expect(TypeConversionUtils.pythonToDartType('Dict[str, int]'),
            equals('Map<String, int>'));
        expect(TypeConversionUtils.pythonToDartType('dict'),
            equals('Map<String, dynamic>'));
      });

      test('converts Optional types correctly', () {
        expect(TypeConversionUtils.pythonToDartType('Optional[str]'),
            equals('String?'));
        expect(TypeConversionUtils.pythonToDartType('Optional[int]'),
            equals('int?'));
        expect(TypeConversionUtils.pythonToDartType('Optional[dict]'),
            equals('Map<String, dynamic>?'));
        expect(TypeConversionUtils.pythonToDartType('Optional[List[str]]'),
            equals('List<String>?'));
      });

      test('handles nested generic types', () {
        expect(TypeConversionUtils.pythonToDartType('List[Optional[str]]'),
            equals('List<String?>'));
        expect(TypeConversionUtils.pythonToDartType('Dict[str, List[int]]'),
            equals('Map<String, List<int>>'));
        expect(
            TypeConversionUtils.pythonToDartType(
                'Optional[Dict[str, List[int]]]'),
            equals('Map<String, List<int>>?'));
      });
    });

    group('getDefaultValue', () {
      test('returns correct default values for basic types', () {
        expect(TypeConversionUtils.getDefaultValue('bool'), equals('false'));
        expect(TypeConversionUtils.getDefaultValue('int'), equals('0'));
        expect(TypeConversionUtils.getDefaultValue('double'), equals('0.0'));
        expect(TypeConversionUtils.getDefaultValue('String'), equals("''"));
      });

      test('returns correct default values for nullable types', () {
        expect(TypeConversionUtils.getDefaultValue('bool?'), equals('false'));
        expect(TypeConversionUtils.getDefaultValue('int?'), equals('0'));
        expect(TypeConversionUtils.getDefaultValue('double?'), equals('0.0'));
        expect(TypeConversionUtils.getDefaultValue('String?'), equals("''"));
      });

      test('returns correct default values for collection types', () {
        expect(TypeConversionUtils.getDefaultValue('List'), equals('[]'));
        expect(
            TypeConversionUtils.getDefaultValue('List<String>'), equals('[]'));
        expect(TypeConversionUtils.getDefaultValue('Map<String, dynamic>'),
            equals('{}'));
        expect(TypeConversionUtils.getDefaultValue('Map<String, int>'),
            equals('{}'));
      });

      test('returns null for unknown types', () {
        expect(
            TypeConversionUtils.getDefaultValue('CustomType'), equals('null'));
        expect(TypeConversionUtils.getDefaultValue('UnknownType?'),
            equals('null'));
      });
    });
  });
}
