import 'package:test/test.dart';
import '../../lib/pdo.dart';
import '../../lib/src/core/pdo_param.dart';

void main() {
  group('PDOParam', () {
    test('initializes with correct values', () {
      final param = PDOParam(
        name: ':username',
        position: 0,
        value: 'john',
        type: PDO.PARAM_STR,
        length: 255,
        driverOptions: {'encoding': 'utf8'},
      );

      expect(param.name, equals(':username'));
      expect(param.position, equals(0));
      expect(param.value, equals('john'));
      expect(param.type, equals(PDO.PARAM_STR));
      expect(param.length, equals(255));
      expect(param.driverOptions, equals({'encoding': 'utf8'}));
    });

    test('handles null values', () {
      final param = PDOParam(
        position: -1,
        type: PDO.PARAM_NULL,
      );

      expect(param.name, isNull);
      expect(param.position, equals(-1));
      expect(param.value, isNull);
      expect(param.type, equals(PDO.PARAM_NULL));
      expect(param.length, isNull);
      expect(param.driverOptions, isNull);
    });

    group('type conversion', () {
      test('converts to boolean', () {
        final param = PDOParam(
          position: 0,
          type: PDO.PARAM_BOOL,
        );

        // Test various values that should convert to true
        param.value = true;
        expect(param.getTypedValue(), isTrue);

        param.value = 1;
        expect(param.getTypedValue(), isTrue);

        param.value = 'true';
        expect(param.getTypedValue(), isTrue);

        param.value = 'yes';
        expect(param.getTypedValue(), isTrue);

        // Test various values that should convert to false
        param.value = false;
        expect(param.getTypedValue(), isFalse);

        param.value = 0;
        expect(param.getTypedValue(), isFalse);

        param.value = '';
        expect(param.getTypedValue(), isFalse);

        param.value = 'false';
        expect(param.getTypedValue(), isFalse);
      });

      test('converts to integer', () {
        final param = PDOParam(
          position: 0,
          type: PDO.PARAM_INT,
        );

        // Test integer values
        param.value = 42;
        expect(param.getTypedValue(), equals(42));

        // Test string conversion
        param.value = '123';
        expect(param.getTypedValue(), equals(123));

        // Test float conversion
        param.value = 3.14;
        expect(param.getTypedValue(), equals(3));

        // Test invalid string
        param.value = 'not a number';
        expect(param.getTypedValue(), equals(0));

        // Test null
        param.value = null;
        expect(param.getTypedValue(), isNull);
      });

      test('converts to string', () {
        final param = PDOParam(
          position: 0,
          type: PDO.PARAM_STR,
        );

        // Test string value
        param.value = 'hello';
        expect(param.getTypedValue(), equals('hello'));

        // Test number conversion
        param.value = 42;
        expect(param.getTypedValue(), equals('42'));

        // Test boolean conversion
        param.value = true;
        expect(param.getTypedValue(), equals('true'));

        // Test null
        param.value = null;
        expect(param.getTypedValue(), isNull);
      });

      test('handles LOB data', () {
        final param = PDOParam(
          position: 0,
          type: PDO.PARAM_LOB,
          value: [1, 2, 3], // Simulating binary data
        );

        // LOB data should be passed through without conversion
        expect(param.getTypedValue(), equals([1, 2, 3]));
      });
    });

    test('creates copy with modified values', () {
      final original = PDOParam(
        name: ':param',
        position: 0,
        value: 'original',
        type: PDO.PARAM_STR,
        length: 100,
        driverOptions: {'key': 'value'},
      );

      final copy = original.copyWith(
        name: ':new_param',
        value: 'modified',
        type: PDO.PARAM_INT,
      );

      // Changed values
      expect(copy.name, equals(':new_param'));
      expect(copy.value, equals('modified'));
      expect(copy.type, equals(PDO.PARAM_INT));

      // Unchanged values
      expect(copy.position, equals(original.position));
      expect(copy.length, equals(original.length));
      expect(copy.driverOptions, equals(original.driverOptions));

      // Original should remain unchanged
      expect(original.name, equals(':param'));
      expect(original.value, equals('original'));
      expect(original.type, equals(PDO.PARAM_STR));
    });

    test('provides string representation', () {
      final param = PDOParam(
        name: ':test',
        position: 1,
        value: 'value',
        type: PDO.PARAM_STR,
        length: 50,
      );

      final str = param.toString();
      expect(str, contains(':test'));
      expect(str, contains('1'));
      expect(str, contains('value'));
      expect(str, contains('50'));
    });
  });
}
