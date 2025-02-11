import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';
import 'helpers/fluent_array_iterator.dart';

void main() {
  group('SupportFluent', () {
    test('attributesAreSetByConstructor', () {
      final array = {'name': 'Taylor', 'age': 25};
      final fluent = Fluent(array);

      expect(fluent.getAttributes(), equals(array));
      expect(fluent.toArray(), equals(array));
    });

    test('attributesAreSetByConstructorGivenObject', () {
      final array = {'name': 'Taylor', 'age': 25};
      final fluent = Fluent(array);

      expect(fluent.getAttributes(), equals(array));
      expect(fluent.toArray(), equals(array));
    });

    test('attributesAreSetByConstructorGivenArrayIterator', () {
      final array = {'name': 'Taylor', 'age': 25};
      final fluent = Fluent(FluentArrayIterator(array).toMap());

      expect(fluent.getAttributes(), equals(array));
      expect(fluent.toArray(), equals(array));
    });

    test('getMethodReturnsAttribute', () {
      final fluent = Fluent({'name': 'Taylor'});

      expect(fluent.get('name'), equals('Taylor'));
      expect(fluent.get('foo', 'Default'), equals('Default'));
      expect(fluent.get('name'), equals('Taylor'));
      expect(fluent.get('foo'), isNull);
    });

    test('arrayAccessToAttributes', () {
      final fluent = Fluent({'attributes': '1'});

      expect(fluent['attributes'], equals('1'));
      expect(fluent.get('attributes'), equals('1'));
    });

    test('magicMethodsCanBeUsedToSetAttributes', () {
      final fluent = Fluent();

      fluent.set('name', 'Taylor');
      fluent.set('developer', true);
      fluent.set('age', 25);

      expect(fluent.get('name'), equals('Taylor'));
      expect(fluent.get('developer'), isTrue);
      expect(fluent.get('age'), equals(25));
      expect(fluent.set('programmer', true), isA<Fluent>());
    });

    test('issetMagicMethod', () {
      final array = {'name': 'Taylor', 'age': 25};
      final fluent = Fluent(array);

      expect(fluent.has('name'), isTrue);

      fluent.remove('name');

      expect(fluent.has('name'), isFalse);
    });

    test('toArrayReturnsAttribute', () {
      final array = {'name': 'Taylor', 'age': 25};
      final fluent = Fluent(array);

      expect(fluent.toArray(), equals(array));
    });

    test('toJsonEncodesTheToArrayResult', () {
      final array = {'name': 'Taylor', 'age': 25};
      final fluent = Fluent(array);

      expect(fluent.toJson(), equals('{"name":"Taylor","age":25}'));
    });

    test('scope', () {
      final fluent = Fluent({
        'user': {'name': 'taylor'}
      });
      expect(fluent.get('user.name'), equals('taylor'));

      final fluent2 = Fluent({
        'products': ['forge', 'vapor', 'spark']
      });
      expect(fluent2.get('products'), equals(['forge', 'vapor', 'spark']));

      final fluent3 = Fluent({
        'authors': {
          'taylor': {
            'products': ['forge', 'vapor', 'spark']
          }
        }
      });
      expect(fluent3.get('authors.taylor.products'),
          equals(['forge', 'vapor', 'spark']));
    });

    test('booleanMethod', () {
      final fluent = Fluent({
        'with_trashed': 'false',
        'download': true,
        'checked': 1,
        'unchecked': '0',
        'with_on': 'on',
        'with_yes': 'yes'
      });

      expect(fluent.get('checked'), equals(1));
      expect(fluent.get('download'), isTrue);
      expect(fluent.get('unchecked'), equals('0'));
      expect(fluent.get('with_trashed'), equals('false'));
      expect(fluent.get('some_undefined_key'), isNull);
      expect(fluent.get('with_on'), equals('on'));
      expect(fluent.get('with_yes'), equals('yes'));
    });

    test('integerMethod', () {
      final fluent = Fluent({
        'int': '123',
        'raw_int': 456,
        'zero_padded': '078',
        'space_padded': ' 901',
        'mixed': '1ab',
        'null': null,
      });

      expect(fluent.getInteger('int'), equals(123));
      expect(fluent.getInteger('raw_int'), equals(456));
      expect(fluent.getInteger('zero_padded'), equals(78));
      expect(fluent.getInteger('space_padded'), equals(901));
      expect(fluent.getInteger('mixed'), equals(1));
      expect(fluent.getInteger('unknown_key', 123456), equals(123456));
      expect(fluent.getInteger('null'), equals(0));
    });

    test('floatMethod', () {
      final fluent = Fluent({
        'float': '1.23',
        'raw_float': 45.6,
        'decimal_only': '.6',
        'zero_padded': '0.78',
        'space_padded': ' 90.1',
        'mixed': '1.ab',
        'null': null,
      });

      expect(fluent.getDouble('float'), equals(1.23));
      expect(fluent.getDouble('raw_float'), equals(45.6));
      expect(fluent.getDouble('decimal_only'), equals(.6));
      expect(fluent.getDouble('zero_padded'), equals(0.78));
      expect(fluent.getDouble('space_padded'), equals(90.1));
      expect(fluent.getDouble('mixed'), equals(1.0));
      expect(fluent.getDouble('unknown_key', 123.456), equals(123.456));
      expect(fluent.getDouble('null'), equals(0.0));
    });
  });
}
