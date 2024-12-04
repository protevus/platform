import 'package:test/test.dart';
import 'package:platform_collections/platform_collections.dart';

void main() {
  group('Collection', () {
    test('can be created empty', () {
      final collection = Collection<int>();
      expect(collection, isEmpty);
    });

    test('can be created with items', () {
      final collection = Collection([1, 2, 3]);
      expect(collection, hasLength(3));
      expect(collection, equals([1, 2, 3]));
    });

    group('basic operations', () {
      late Collection<int> collection;

      setUp(() {
        collection = Collection([1, 2, 3, 4, 5]);
      });

      test('all() returns all items', () {
        expect(collection.all(), equals([1, 2, 3, 4, 5]));
      });

      test('avg() calculates average', () {
        expect(collection.avg(), equals(3.0));
      });

      test('avg() with callback', () {
        final collection = Collection([
          {'value': 1},
          {'value': 2},
          {'value': 3},
        ]);
        expect(
          collection.avg((item) => item['value'] as num),
          equals(2.0),
        );
      });

      test('chunk() splits collection into chunks', () {
        final chunks = collection.chunk(2);
        expect(chunks, hasLength(3));
        expect(chunks[0], equals([1, 2]));
        expect(chunks[1], equals([3, 4]));
        expect(chunks[2], equals([5]));
      });
    });

    group('transformation methods', () {
      test('collapse() flattens nested collections', () {
        final collection = Collection([
          [1, 2],
          [3, 4],
          5,
        ]);
        expect(collection.collapse(), equals([1, 2, 3, 4, 5]));
      });

      test('crossJoin() creates all combinations', () {
        final collection = Collection([1, 2]);
        final result = collection.crossJoin([
          [3, 4],
          [5, 6]
        ]);
        expect(
            result,
            equals([
              [1, 3, 5],
              [1, 3, 6],
              [1, 4, 5],
              [1, 4, 6],
              [2, 3, 5],
              [2, 3, 6],
              [2, 4, 5],
              [2, 4, 6],
            ]));
      });

      test('diff() returns items not in other collection', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        final diff = collection.diff([2, 4]);
        expect(diff, equals([1, 3, 5]));
      });

      test('filter() returns matching items', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        final filtered = collection.filter((item) => item.isEven);
        expect(filtered, equals([2, 4]));
      });
    });

    group('aggregation methods', () {
      test('groupBy() groups items by key', () {
        final collection = Collection([
          {'category': 'A', 'value': 1},
          {'category': 'B', 'value': 2},
          {'category': 'A', 'value': 3},
        ]);

        final grouped = collection.groupBy((item) => item['category']);
        expect(grouped['A']?.length, equals(2));
        expect(grouped['B']?.length, equals(1));
      });

      test('max() finds maximum value', () {
        final collection = Collection([1, 5, 3, 2, 4]);
        expect(collection.max(), equals(5));
      });

      test('min() finds minimum value', () {
        final collection = Collection([1, 5, 3, 2, 4]);
        expect(collection.min(), equals(1));
      });
    });

    group('helper methods', () {
      test('random() returns random items', () {
        final collection = Collection(List.generate(100, (i) => i));
        final random1 = collection.random();
        final random2 = collection.random();
        expect(
            random1, isNot(equals(random2))); // Note: Could theoretically fail
      });

      test('random() with count returns multiple items', () {
        final collection = Collection(List.generate(100, (i) => i));
        final random = collection.random(5);
        expect(random, hasLength(5));
        expect(random.toSet().length, equals(5)); // All items should be unique
      });

      test('unique() returns unique items', () {
        final collection = Collection([1, 2, 2, 3, 3, 3]);
        expect(collection.unique(), equals([1, 2, 3]));
      });

      test('unique() with callback', () {
        final collection = Collection([
          {'id': 1, 'name': 'A'},
          {'id': 2, 'name': 'B'},
          {'id': 1, 'name': 'C'},
        ]);
        final unique = collection.unique((item) => item['id']);
        expect(unique, hasLength(2));
      });
    });

    group('list operations', () {
      test('supports standard list operations', () {
        final collection = Collection<int>();
        collection.add(1);
        collection.addAll([2, 3]);
        expect(collection, equals([1, 2, 3]));

        collection[1] = 4;
        expect(collection[1], equals(4));

        collection.removeAt(0);
        expect(collection, equals([4, 3]));
      });

      test('supports range operations', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        collection.removeRange(1, 3);
        expect(collection, equals([1, 4, 5]));

        collection.insertAll(1, [2, 3]);
        expect(collection, equals([1, 2, 3, 4, 5]));
      });
    });

    group('new methods', () {
      test('mapToDictionary() groups items by key-value pairs', () {
        final collection = Collection(['one', 'two', 'three']);
        final result = collection.mapToDictionary(
            (item) => MapEntry(item.length, item.toUpperCase()));
        expect(result[3], equals(['ONE', 'TWO']));
        expect(result[5], equals(['THREE']));
      });

      test('mapWithKeys() creates associative array', () {
        final collection = Collection(['a', 'bb', 'ccc']);
        final result =
            collection.mapWithKeys((item) => MapEntry(item.length, item));
        expect(result, equals({1: 'a', 2: 'bb', 3: 'ccc'}));
      });

      test('pluck() extracts values', () {
        final collection = Collection([
          {'name': 'John', 'age': 30},
          {'name': 'Jane', 'age': 25},
        ]);
        expect(
            collection.pluck((item) => item['name']), equals(['John', 'Jane']));
      });

      test('keyBy() creates map from collection', () {
        final collection = Collection([
          {'id': 1, 'name': 'John'},
          {'id': 2, 'name': 'Jane'},
        ]);
        final result = collection.keyBy((item) => item['id'] as int);
        expect(result[1]?['name'], equals('John'));
        expect(result[2]?['name'], equals('Jane'));
      });

      test('contains() checks for item existence', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.contains(2), isTrue);
        expect(collection.contains(4), isFalse);
      });

      test('containsStrict() uses identical comparison', () {
        final obj1 = {'id': 1};
        final obj2 = {'id': 1};
        final collection = Collection([obj1]);
        expect(collection.containsStrict(obj1), isTrue);
        expect(collection.containsStrict(obj2), isFalse);
      });

      test('doesntContain() checks for item absence', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.doesntContain(4), isTrue);
        expect(collection.doesntContain(2), isFalse);
      });

      test('firstOrFail() returns first item or throws', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.firstOrFail(), equals(1));
        expect(
          () => Collection().firstOrFail(),
          throwsStateError,
        );
      });

      test('sole() returns single item or throws', () {
        expect(Collection([1]).sole(), equals(1));
        expect(() => Collection().sole(), throwsStateError);
        expect(() => Collection([1, 2]).sole(), throwsStateError);
      });

      test('before() gets previous item', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.before(2), equals(1));
        expect(collection.before(1), isNull);
      });

      test('after() gets next item', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.after(2), equals(3));
        expect(collection.after(3), isNull);
      });

      test('multiply() repeats items', () {
        final collection = Collection([1, 2]);
        expect(collection.multiply(2), equals([1, 2, 1, 2]));
        expect(collection.multiply(0), isEmpty);
      });

      test('combine() pairs items with values', () {
        final collection = Collection(['a', 'b']);
        final result = collection.combine([1, 2]);
        expect(result.map((e) => e.key), equals(['a', 'b']));
        expect(result.map((e) => e.value), equals([1, 2]));
        expect(
          () => collection.combine([1]),
          throwsArgumentError,
        );
      });

      test('countBy() counts occurrences', () {
        final collection = Collection(['apple', 'banana', 'apple', 'cherry']);
        final result = collection.countBy((item) => item);
        expect(result['apple'], equals(2));
        expect(result['banana'], equals(1));
        expect(result['cherry'], equals(1));
      });

      test('getOrPut() retrieves or adds item', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.getOrPut(1, () => 42), equals(2));
        expect(collection.getOrPut(3, () => 42), equals(42));
        expect(collection, equals([1, 2, 3, 42]));
      });

      test('split() divides collection into groups', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        final result = collection.split(3);
        expect(result, hasLength(3));
        expect(result[0], equals([1, 2]));
        expect(result[1], equals([3, 4]));
        expect(result[2], equals([5]));
      });

      test('splitIn() divides collection into equal groups', () {
        final collection = Collection([1, 2, 3, 4, 5, 6]);
        final result = collection.splitIn(3);
        expect(result, hasLength(3));
        expect(result[0], equals([1, 2]));
        expect(result[1], equals([3, 4]));
        expect(result[2], equals([5, 6]));
      });

      test('chunkWhile() chunks by condition', () {
        final collection = Collection([1, 1, 2, 2, 3, 4, 4]);
        final result =
            collection.chunkWhile((value, previous) => value == previous);
        expect(result, hasLength(4));
        expect(result[0], equals([1, 1]));
        expect(result[1], equals([2, 2]));
        expect(result[2], equals([3]));
        expect(result[3], equals([4, 4]));
      });
    });

    test('range() creates sequence', () {
      final collection = Collection.range(1, 5);
      expect(collection, equals([1, 2, 3, 4, 5]));
    });

    test('toMap() converts to map', () {
      final collection = Collection(['a', 'bb', 'ccc']);
      final map = collection.toMap(
        (item) => item.length,
        (item) => item.toUpperCase(),
      );
      expect(
          map,
          equals({
            1: 'A',
            2: 'BB',
            3: 'CCC',
          }));
    });
  });
}
