import 'package:test/test.dart';
import 'package:platform_collections/collections.dart';

void main() {
  group('Collection', () {
    test('can be created empty', () {
      final collection = Collection();
      expect(collection, isEmpty);
    });

    test('can be created with items', () {
      final collection = Collection([1, 2, 3]);
      expect(collection, hasLength(3));
      expect(collection, equals([1, 2, 3]));
    });

    group('basic operations', () {
      test('all() returns all items', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.all(), equals([1, 2, 3]));
      });

      test('avg() calculates average', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.avg(), equals(2.0));
      });

      test('avg() with callback', () {
        final collection = Collection(['a', 'bb', 'ccc']);
        expect(collection.avg((e) => e.length), equals(2.0));
      });

      test('chunk() splits collection into chunks', () {
        final collection = Collection([1, 2, 3, 4, 5]);
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
          [5]
        ]);
        expect(collection.collapse(), equals([1, 2, 3, 4, 5]));
      });

      test('crossJoin() creates all combinations', () {
        final collection = Collection([1, 2]);
        final result = collection.crossJoin([
          ['a', 'b'],
          ['x', 'y']
        ]);
        expect(result, hasLength(8));

        // Helper function to check if a list contains another list with same elements
        bool containsList(List<List<dynamic>> lists, List<dynamic> target) {
          return lists.any((list) =>
              list.length == target.length &&
              list
                  .asMap()
                  .entries
                  .every((entry) => entry.value == target[entry.key]));
        }

        final resultList = result.toList();
        expect(containsList(resultList, [1, 'a', 'x']), isTrue);
        expect(containsList(resultList, [1, 'a', 'y']), isTrue);
        expect(containsList(resultList, [1, 'b', 'x']), isTrue);
        expect(containsList(resultList, [1, 'b', 'y']), isTrue);
        expect(containsList(resultList, [2, 'a', 'x']), isTrue);
        expect(containsList(resultList, [2, 'a', 'y']), isTrue);
        expect(containsList(resultList, [2, 'b', 'x']), isTrue);
        expect(containsList(resultList, [2, 'b', 'y']), isTrue);
      });

      test('diff() returns items not in other collection', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        final diff = collection.diff([2, 4]);
        expect(diff, equals([1, 3, 5]));
      });

      test('filter() returns matching items', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        final filtered = collection.filter((e) => e % 2 == 0);
        expect(filtered, equals([2, 4]));
      });
    });

    group('aggregation methods', () {
      test('groupBy() groups items by key', () {
        final collection = Collection(['one', 'two', 'three']);
        final grouped = collection.groupBy((e) => e.length);
        expect(grouped[3]!, equals(['one', 'two']));
        expect(grouped[5]!, equals(['three']));
      });

      test('max() finds maximum value', () {
        final collection = Collection([1, 5, 3, 2, 4]);
        expect(collection.max(), equals(5));
      });

      test('min() finds minimum value', () {
        final collection = Collection([5, 3, 1, 4, 2]);
        expect(collection.min(), equals(1));
      });
    });

    group('helper methods', () {
      test('random() returns random items', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        final random = collection.random();
        expect(random, hasLength(1));
        expect(collection, contains(random.first));
      });

      test('random() with count returns multiple items', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        final random = collection.random(3);
        expect(random, hasLength(3));
        expect(collection, containsAll(random));
      });

      test('unique() returns unique items', () {
        final collection = Collection([1, 2, 2, 3, 3, 3]);
        expect(collection.unique(), equals([1, 2, 3]));
      });

      test('unique() with callback', () {
        final collection = Collection(['a', 'aa', 'aaa', 'b', 'bb']);
        expect(collection.unique((e) => e.length), equals(['a', 'aa', 'aaa']));
      });
    });

    group('list operations', () {
      test('supports standard list operations', () {
        final collection = Collection([1, 2, 3]);
        collection.add(4);
        collection.addAll([5, 6]);
        collection[0] = 0;
        collection.removeAt(1);
        expect(collection, equals([0, 3, 4, 5, 6]));
      });

      test('supports range operations', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        collection.removeRange(1, 3);
        expect(collection, equals([1, 4, 5]));
      });
    });

    group('new methods', () {
      test('mapToDictionary() groups items by key-value pairs', () {
        final collection = Collection(['one', 'two', 'three']);
        final result = collection
            .mapToDictionary((e) => MapEntry(e.length, e.toUpperCase()));
        expect(result[3], equals(['ONE', 'TWO']));
        expect(result[5], equals(['THREE']));
      });

      test('mapWithKeys() creates associative array', () {
        final collection = Collection(['one', 'two', 'three']);
        final result =
            collection.mapWithKeys((e) => MapEntry(e.length, e.toUpperCase()));
        expect(result[3], equals('TWO')); // Last value wins
        expect(result[5], equals('THREE'));
      });

      test('pluck() extracts values', () {
        final collection = Collection(['one', 'two', 'three']);
        expect(collection.pluck((e) => e.length), equals([3, 3, 5]));
      });

      test('keyBy() creates map from collection', () {
        final collection = Collection(['one', 'two', 'three']);
        final result = collection.keyBy((e) => e.length);
        expect(result[3], equals('two')); // Last value wins
        expect(result[5], equals('three'));
      });

      test('contains() checks for item existence', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.contains(2), isTrue);
        expect(collection.contains(4), isFalse);
      });

      test('containsStrict() uses identical comparison', () {
        final a = Object();
        final b = Object();
        final collection = Collection([a]);
        expect(collection.contains(b), isFalse); // Different objects
        expect(collection.containsStrict(b), isFalse); // Not identical
        expect(collection.containsStrict(a), isTrue); // Identical
      });

      test('doesntContain() checks for item absence', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.doesntContain(4), isTrue);
        expect(collection.doesntContain(2), isFalse);
      });

      test('firstOrFail() returns first item or throws', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.firstOrFail(), equals(1));
        expect(() => Collection().firstOrFail(),
            throwsA(isA<ItemNotFoundException>()));
      });

      test('sole() returns single item or throws', () {
        final collection = Collection([1]);
        expect(collection.sole(), equals(1));
        expect(
            () => Collection().sole(), throwsA(isA<ItemNotFoundException>()));
        expect(() => Collection([1, 2]).sole(),
            throwsA(isA<MultipleItemsFoundException>()));
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
      });

      test('combine() pairs items with values', () {
        final collection = Collection(['a', 'b']);
        final result = collection.combine([1, 2]);
        expect(result.map((e) => e.key), equals(['a', 'b']));
        expect(result.map((e) => e.value), equals([1, 2]));
      });

      test('countBy() counts occurrences', () {
        final collection = Collection(['one', 'two', 'three']);
        final counts = collection.countBy((e) => e.length);
        expect(counts[3], equals(2)); // 'one', 'two'
        expect(counts[5], equals(1)); // 'three'
      });

      test('getOrPut() retrieves or adds item', () {
        final collection = Collection([1, 2, 3]);
        expect(collection.getOrPut(1, () => 42), equals(2));
        expect(collection.getOrPut(3, () => 42), equals(42));
        expect(collection, equals([1, 2, 3, 42]));
      });

      test('split() divides collection into groups', () {
        final collection = Collection([1, 2, 3, 4, 5]);
        final groups = collection.split(3);
        expect(groups, hasLength(3));
        expect(groups[0], equals([1, 2]));
        expect(groups[1], equals([3, 4]));
        expect(groups[2], equals([5]));
      });

      test('splitIn() divides collection into equal groups', () {
        final collection = Collection([1, 2, 3, 4, 5, 6]);
        final groups = collection.splitIn(3);
        expect(groups, hasLength(3));
        expect(groups[0], equals([1, 2]));
        expect(groups[1], equals([3, 4]));
        expect(groups[2], equals([5, 6]));
      });

      test('chunkWhile() chunks by condition', () {
        final collection = Collection([1, 2, 2, 3]);
        final chunks = collection.chunkWhile((curr, prev) => curr == prev);
        expect(chunks, hasLength(3));
        expect(chunks[0], equals([1]));
        expect(chunks[1], equals([2, 2]));
        expect(chunks[2], equals([3]));
      });
    });

    test('range() creates sequence', () {
      final collection = Collection.range(1, 5);
      expect(collection, equals([1, 2, 3, 4, 5]));
    });

    test('toMap() converts to map', () {
      final collection = Collection(['a', 'bb', 'ccc']);
      final map = collection.toMap(
        (e) => e.length,
        (e) => e.toUpperCase(),
      );
      expect(map[1], equals('A'));
      expect(map[2], equals('BB'));
      expect(map[3], equals('CCC'));
    });
  });
}
