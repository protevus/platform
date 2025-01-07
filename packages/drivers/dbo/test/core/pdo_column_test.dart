import 'package:platform_dbo/src/core/pdo_column.dart';
import 'package:test/test.dart';

void main() {
  group('PDOColumn', () {
    test('initializes with required values', () {
      final column = PDOColumn(
        name: 'id',
        position: 0,
      );

      expect(column.name, equals('id'));
      expect(column.position, equals(0));
      expect(column.length, isNull);
      expect(column.precision, isNull);
      expect(column.type, isNull);
      expect(column.flags, isNull);
    });

    test('initializes with all values', () {
      final column = PDOColumn(
        name: 'price',
        position: 1,
        length: 10,
        precision: 2,
        type: 'DECIMAL',
        flags: ['NOT_NULL', 'UNSIGNED'],
      );

      expect(column.name, equals('price'));
      expect(column.position, equals(1));
      expect(column.length, equals(10));
      expect(column.precision, equals(2));
      expect(column.type, equals('DECIMAL'));
      expect(column.flags, equals(['NOT_NULL', 'UNSIGNED']));
    });

    test('creates copy with modified values', () {
      final original = PDOColumn(
        name: 'old_name',
        position: 0,
        length: 100,
        precision: 0,
        type: 'VARCHAR',
        flags: ['NOT_NULL'],
      );

      final copy = original.copyWith(
        name: 'new_name',
        type: 'TEXT',
        flags: ['NOT_NULL', 'UNIQUE'],
      );

      // Changed values
      expect(copy.name, equals('new_name'));
      expect(copy.type, equals('TEXT'));
      expect(copy.flags, equals(['NOT_NULL', 'UNIQUE']));

      // Unchanged values
      expect(copy.position, equals(original.position));
      expect(copy.length, equals(original.length));
      expect(copy.precision, equals(original.precision));

      // Original should remain unchanged
      expect(original.name, equals('old_name'));
      expect(original.type, equals('VARCHAR'));
      expect(original.flags, equals(['NOT_NULL']));
    });

    test('provides string representation', () {
      final column = PDOColumn(
        name: 'email',
        position: 2,
        length: 255,
        type: 'VARCHAR',
        flags: ['NOT_NULL', 'UNIQUE'],
      );

      final str = column.toString();
      expect(str, contains('email'));
      expect(str, contains('2'));
      expect(str, contains('255'));
      expect(str, contains('VARCHAR'));
      expect(str, contains('NOT_NULL'));
      expect(str, contains('UNIQUE'));
    });

    test('implements value equality', () {
      final col1 = PDOColumn(
        name: 'id',
        position: 0,
        type: 'INTEGER',
        flags: ['PRIMARY_KEY'],
      );

      final col2 = PDOColumn(
        name: 'id',
        position: 0,
        type: 'INTEGER',
        flags: ['PRIMARY_KEY'],
      );

      final col3 = PDOColumn(
        name: 'id',
        position: 1, // Different position
        type: 'INTEGER',
        flags: ['PRIMARY_KEY'],
      );

      // Same values should be equal
      expect(col1, equals(col2));
      expect(col1.hashCode, equals(col2.hashCode));

      // Different values should not be equal
      expect(col1, isNot(equals(col3)));
      expect(col1.hashCode, isNot(equals(col3.hashCode)));

      // Test with different flags order
      final col4 = PDOColumn(
        name: 'status',
        position: 0,
        flags: ['NOT_NULL', 'UNIQUE'],
      );

      final col5 = PDOColumn(
        name: 'status',
        position: 0,
        flags: ['UNIQUE', 'NOT_NULL'], // Different order
      );

      // Flags order shouldn't matter for equality
      expect(col4, equals(col5));
      expect(col4.hashCode, equals(col5.hashCode));
    });

    test('handles null values in equality', () {
      final col1 = PDOColumn(
        name: 'id',
        position: 0,
      );

      final col2 = PDOColumn(
        name: 'id',
        position: 0,
        length: null,
        precision: null,
        type: null,
        flags: null,
      );

      // Explicit nulls should equal implicit nulls
      expect(col1, equals(col2));
      expect(col1.hashCode, equals(col2.hashCode));
    });

    test('validates required fields', () {
      expect(
        () => PDOColumn(name: '', position: 0),
        throwsA(isA<AssertionError>()),
        reason: 'Name should not be empty',
      );

      expect(
        () => PDOColumn(name: 'id', position: -1),
        throwsA(isA<AssertionError>()),
        reason: 'Position should not be negative',
      );
    });
  });
}
