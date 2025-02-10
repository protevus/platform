import 'package:test/test.dart';
import 'package:illuminate_collections/collections.dart';

void main() {
  group('Collection', () {
    test('can be instantiated', () {
      expect(Collection([]), isA<Collection>());
    });

    test('can be instantiated with null', () {
      expect(Collection(), isA<Collection>());
    });

    test('can be instantiated with items', () {
      final collection = Collection([1, 2, 3]);
      expect(collection.length, equals(3));
    });

    test('can get all items', () {
      final collection = Collection([1, 2, 3]);
      expect(collection.all(), equals([1, 2, 3]));
    });

    test('can calculate average', () {
      final collection = Collection<int>([1, 2, 3]);
      expect(collection.avg((int x) => x), equals(2.0));
    });

    test('returns 0 for empty average', () {
      final collection = Collection<int>([]);
      expect(collection.avg((int x) => x), equals(0.0));
    });

    test('can chunk items', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      final chunks = collection.chunk(2);
      expect(chunks[0], equals([1, 2]));
      expect(chunks[1], equals([3, 4]));
      expect(chunks[2], equals([5]));
    });

    test('can collapse nested collections', () {
      final collection = Collection([
        [1, 2],
        [3, 4],
        [5]
      ]);
      expect(collection.collapse(), equals([1, 2, 3, 4, 5]));
    });

    test('can cross join collections', () {
      final collection = Collection([1, 2]);
      final other = [3, 4];
      final result = collection.crossJoin(other);
      expect(
          result,
          equals([
            [1, 3],
            [1, 4],
            [2, 3],
            [2, 4]
          ]));
    });

    test('can get difference of collections', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      final other = [2, 4, 6];
      expect(collection.diff(other), equals([1, 3, 5]));
    });

    test('can filter items', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      expect(collection.filter((x) => x > 3), equals([4, 5]));
    });

    test('can group items by key', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      final groups = collection.groupBy((x) => x % 2);
      expect(groups[1]?.toList(), equals([1, 3, 5]));
      expect(groups[0]?.toList(), equals([2, 4]));
    });

    test('can get maximum value', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      expect(collection.max(), equals(5));
    });

    test('can get minimum value', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      expect(collection.min(), equals(1));
    });

    test('can get random item', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      final random = collection.random();
      expect(collection.contains(random), isTrue);
    });

    test('can get unique items', () {
      final collection = Collection([1, 2, 2, 3, 3, 3]);
      expect(collection.unique(), equals([1, 2, 3]));
    });

    test('can modify items', () {
      final collection = Collection([1, 2, 3]);
      collection[1] = 5;
      collection.removeAt(0);
      expect(collection.toList(), equals([5, 3]));
    });

    test('can remove range', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      collection.removeRange(1, 3);
      expect(collection.toList(), equals([1, 4, 5]));
    });

    test('can map to dictionary', () {
      final collection = Collection([1, 2, 3]);
      final dict = collection.mapToDictionary((x) => MapEntry(x, x * 2));
      expect(dict, equals({1: 2, 2: 4, 3: 6}));
    });

    test('can map with keys', () {
      final collection = Collection([1, 2, 3]);
      final map = collection.mapWithKeys((x) => x * 2);
      expect(map, equals({2: 1, 4: 2, 6: 3}));
    });

    test('can pluck values', () {
      final collection = Collection<Map<String, dynamic>>([
        <String, dynamic>{'id': 1, 'name': 'one'},
        <String, dynamic>{'id': 2, 'name': 'two'},
      ]);
      expect(collection.pluck<String>('name'), equals(['one', 'two']));
    });

    test('can key by value', () {
      final collection = Collection([1, 2, 3]);
      final keyed = collection.keyBy((x) => 'key$x');
      expect(
          keyed,
          equals({
            'key1': 1,
            'key2': 2,
            'key3': 3,
          }));
    });

    test('can check contains', () {
      final collection = Collection([1, 2, 3]);
      expect(collection.contains(2), isTrue);
      expect(collection.contains(4), isFalse);
    });

    test('can check strict contains', () {
      final a = Object();
      final b = Object();
      final collection = Collection([a]);
      expect(collection.containsStrict(a), isTrue);
      expect(collection.containsStrict(b), isFalse);
    });

    test('can check doesnt contain', () {
      final collection = Collection([1, 2, 3]);
      expect(collection.doesntContain(4), isTrue);
      expect(collection.doesntContain(2), isFalse);
    });

    test('can get first or fail', () {
      final collection = Collection([1, 2, 3]);
      expect(collection.firstOrFail(), equals(1));
      expect(() => Collection().firstOrFail(), throwsStateError);
    });

    test('can get sole item', () {
      final collection = Collection([1]);
      expect(collection.sole(), equals(1));
      expect(() => Collection().sole(), throwsStateError);
      expect(collection.sole((x) => x == 1), equals(1));
    });

    test('can get items before value', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      expect(collection.before(3), equals([1, 2]));
      expect(collection.before(1), equals([]));
    });

    test('can get items after value', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      expect(collection.after(3), equals([4, 5]));
      expect(collection.after(5), equals([]));
    });

    test('can multiply items', () {
      final collection = Collection([1, 2]);
      expect(collection.multiply(2), equals([1, 2, 1, 2]));
    });

    test('can combine collections', () {
      final collection = Collection([1, 2]);
      expect(collection.combine([3, 4]), equals([1, 2, 3, 4]));
    });

    test('can count by value', () {
      final collection = Collection([1, 1, 2, 2, 2, 3]);
      expect(collection.countBy((x) => x), equals({1: 2, 2: 3, 3: 1}));
    });

    test('can get or put value', () {
      final collection = Collection([1, 2, 3]);
      expect(collection.getOrPut(2, () => 5), equals(2));
      expect(collection.getOrPut(4, () => 5), equals(5));
      expect(collection.toList(), equals([1, 2, 3, 5]));
    });

    test('can split collection', () {
      final collection = Collection([1, 2, 3, 0, 4, 5, 0, 6]);
      final split = collection.split(0);
      expect(split[0], equals([1, 2, 3]));
      expect(split[1], equals([4, 5]));
      expect(split[2], equals([6]));
    });

    test('can split into groups', () {
      final collection = Collection([1, 2, 3, 4, 5, 6]);
      final groups = collection.splitIn(3);
      expect(groups[0], equals([1, 2]));
      expect(groups[1], equals([3, 4]));
      expect(groups[2], equals([5, 6]));
    });

    test('can chunk while condition', () {
      final collection = Collection([1, 2, 2, 3, 3, 3]);
      final chunks = collection.chunkWhile((a, b) => a == b);
      expect(chunks[0], equals([1]));
      expect(chunks[1], equals([2, 2]));
      expect(chunks[2], equals([3, 3, 3]));
    });

    test('can get range', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      expect(collection.range(1, 3), equals([2, 3]));
    });

    test('can convert to map', () {
      final collection = Collection<MapEntry<String, int>>([
        MapEntry('one', 1),
        MapEntry('two', 2),
      ]);
      expect(collection.toMap<String, int>(), equals({'one': 1, 'two': 2}));
    });
  });
}
