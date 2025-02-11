import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('Fluent', () {
    test('can be instantiated with no arguments', () {
      final fluent = Fluent();
      expect(fluent.toArray(), isEmpty);
    });

    test('can be instantiated with initial attributes', () {
      final fluent = Fluent({'name': 'John', 'age': 30});
      expect(fluent.get('name'), equals('John'));
      expect(fluent.get('age'), equals(30));
    });

    test('can get and set attributes', () {
      final fluent = Fluent()
        ..set('name', 'John')
        ..set('age', 30);

      expect(fluent.get('name'), equals('John'));
      expect(fluent.get('age'), equals(30));
    });

    test('can check if attribute exists', () {
      final fluent = Fluent({'name': 'John'});
      expect(fluent.has('name'), isTrue);
      expect(fluent.has('age'), isFalse);
    });

    test('can remove attributes', () {
      final fluent = Fluent({'name': 'John', 'age': 30})..remove('age');

      expect(fluent.has('name'), isTrue);
      expect(fluent.has('age'), isFalse);
    });

    test('can clear all attributes', () {
      final fluent = Fluent({'name': 'John', 'age': 30})..clear();

      expect(fluent.toArray(), isEmpty);
    });

    test('can merge attributes', () {
      final fluent = Fluent({'name': 'John'})
        ..merge({'age': 30, 'city': 'New York'});

      expect(fluent.get('name'), equals('John'));
      expect(fluent.get('age'), equals(30));
      expect(fluent.get('city'), equals('New York'));
    });

    test('implements Arrayable correctly', () {
      final fluent = Fluent({'name': 'John', 'age': 30});
      final array = fluent.toArray();

      expect(array, isA<Map<String, dynamic>>());
      expect(array['name'], equals('John'));
      expect(array['age'], equals(30));
    });

    test('implements Jsonable correctly', () {
      final fluent = Fluent({'name': 'John', 'age': 30});
      final json = fluent.toJson();

      expect(json, equals('{"name":"John","age":30}'));
    });

    test('equals works correctly', () {
      final fluent1 = Fluent({'name': 'John', 'age': 30});
      final fluent2 = Fluent({'name': 'John', 'age': 30});
      final fluent3 = Fluent({'name': 'Jane', 'age': 25});

      expect(fluent1, equals(fluent2));
      expect(fluent1, isNot(equals(fluent3)));
    });

    test('toString returns JSON representation', () {
      final fluent = Fluent({'name': 'John', 'age': 30});
      expect(fluent.toString(), equals('{"name":"John","age":30}'));
    });
  });
}
