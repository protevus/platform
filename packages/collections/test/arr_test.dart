import 'package:test/test.dart';
import 'package:platform_collections/src/arr.dart';

void main() {
  group('Arr', () {
    test('accessible() determines if value is array accessible', () {
      expect(Arr.accessible([]), isTrue);
      expect(Arr.accessible({}), isTrue);
      expect(Arr.accessible('string'), isFalse);
      expect(Arr.accessible(42), isFalse);
    });

    test('add() adds element using dot notation', () {
      final array = <String, dynamic>{};
      Arr.add(array, 'user.name', 'John');
      expect(array['user']['name'], equals('John'));
    });

    test('collapse() flattens array of arrays', () {
      final array = [
        [1, 2],
        [3, 4],
        [5, 6],
      ];
      expect(Arr.collapse(array), equals([1, 2, 3, 4, 5, 6]));
    });

    test('crossJoin() creates all possible permutations', () {
      final arrays = [
        [1, 2],
        ['a', 'b'],
      ];
      expect(
        Arr.crossJoin(arrays),
        equals([
          [1, 'a'],
          [1, 'b'],
          [2, 'a'],
          [2, 'b'],
        ]),
      );
    });

    test('divide() splits array into keys and values', () {
      final array = {'name': 'John', 'age': 30};
      final result = Arr.divide(array);
      expect(result['keys'], containsAll(['name', 'age']));
      expect(result['values'], containsAll(['John', 30]));
    });

    test('flatten() flattens multi-dimensional array', () {
      final array = [
        1,
        [
          2,
          3,
          [4, 5]
        ],
        6
      ];
      expect(Arr.flatten(array), equals([1, 2, 3, 4, 5, 6]));
    });

    test('flatten() respects depth parameter', () {
      final array = [
        1,
        [
          2,
          3,
          [4, 5]
        ],
        6
      ];
      expect(
          Arr.flatten(array, 1),
          equals([
            1,
            2,
            3,
            [4, 5],
            6
          ]));
    });

    test('forget() removes items using dot notation', () {
      final array = {
        'user': {'name': 'John', 'age': 30}
      };
      Arr.forget(array, 'user.name');
      expect(array['user'], equals({'age': 30}));
    });

    test('get() retrieves nested value using dot notation', () {
      final array = {
        'user': {'name': 'John', 'age': 30}
      };
      expect(Arr.get(array, 'user.name'), equals('John'));
      expect(Arr.get(array, 'user.email', 'default'), equals('default'));
    });

    test('has() checks existence using dot notation', () {
      final array = {
        'user': {'name': 'John', 'age': 30}
      };
      expect(Arr.has(array, 'user.name'), isTrue);
      expect(Arr.has(array, 'user.email'), isFalse);
    });

    test('isAssoc() determines if array is associative', () {
      expect(Arr.isAssoc({'key': 'value'}), isTrue);
      expect(Arr.isAssoc({0: 'value'}), isFalse);
    });

    test('only() gets subset of items', () {
      final array = {'name': 'John', 'age': 30, 'city': 'New York'};
      final result = Arr.only(array, ['name', 'age']);
      expect(result, equals({'name': 'John', 'age': 30}));
    });

    test('pluck() extracts values', () {
      final array = [
        {'name': 'John', 'age': 30},
        {'name': 'Jane', 'age': 25},
      ];
      expect(Arr.pluck(array, 'name'), equals(['John', 'Jane']));
    });

    test('prepend() adds item to beginning', () {
      final array = [2, 3, 4];
      Arr.prepend(array, 1);
      expect(array, equals([1, 2, 3, 4]));
    });

    test('prepend() with key adds keyed item to beginning', () {
      final array = <dynamic>[
        {'b': 2},
        {'c': 3},
      ];
      Arr.prepend(array, 1, 'a');
      expect(
          array,
          equals([
            {'a': 1},
            {'b': 2},
            {'c': 3},
          ]));
    });

    test('pull() retrieves and removes value', () {
      final array = {'name': 'John', 'age': 30};
      final value = Arr.pull(array, 'name');
      expect(value, equals('John'));
      expect(array.containsKey('name'), isFalse);
    });

    test('random() gets random value', () {
      final array = [1, 2, 3, 4, 5];
      final value = Arr.random(array);
      expect(value, hasLength(1));
      expect(array, contains(value.first));
    });

    test('random() with count gets multiple random values', () {
      final array = [1, 2, 3, 4, 5];
      final values = Arr.random(array, 3);
      expect(values, hasLength(3));
      expect(values.toSet().length, equals(3)); // All values should be unique
    });

    test('set() sets nested value using dot notation', () {
      final array = <String, dynamic>{};
      Arr.set(array, 'user.name', 'John');
      expect(array['user']['name'], equals('John'));
    });

    test('shuffle() randomizes array order', () {
      final array = [1, 2, 3, 4, 5];
      final shuffled = Arr.shuffle(array);
      expect(shuffled, isNot(equals(array))); // Note: Could theoretically fail
      expect(shuffled, unorderedEquals(array));
    });

    test('undot() expands dotted keys', () {
      final array = {
        'user.name': 'John',
        'user.age': 30,
      };
      final result = Arr.undot(array);
      expect(result['user'], equals({'name': 'John', 'age': 30}));
    });

    test('where() filters array', () {
      final array = [1, 2, 3, 4, 5];
      final result = Arr.where(array, (value) => value.isOdd);
      expect(result, equals([1, 3, 5]));
    });

    test('wrap() ensures value is array', () {
      expect(Arr.wrap(null), isEmpty);
      expect(Arr.wrap(1), equals([1]));
      expect(Arr.wrap([1, 2]), equals([1, 2]));
    });
  });
}
