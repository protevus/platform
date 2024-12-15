import 'package:platform_collections/platform_collections.dart';
import 'package:test/test.dart';

void main() {
  group('Collection', () {
    test('creates a collection from a list', () {
      final collection = Collection([1, 2, 3]);
      expect(collection.all(), equals([1, 2, 3]));
    });

    test('avg calculates the average', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      expect(collection.avg(), equals(3));
    });

    test('chunk splits the collection into smaller collections', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      final chunked = collection.chunk(2);
      expect(
          chunked.map((c) => c.all()),
          equals([
            [1, 2],
            [3, 4],
            [5]
          ]));
    });

    test('whereCustom filters the collection', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      final filtered = collection.whereCustom((n) => n % 2 == 0);
      expect(filtered.all(), equals([2, 4]));
    });

    test('mapCustom transforms the collection', () {
      final collection = Collection([1, 2, 3]);
      final mapped = collection.mapCustom((n) => n * 2);
      expect(mapped.all(), equals([2, 4, 6]));
    });

    test('fold reduces the collection', () {
      final collection = Collection([1, 2, 3, 4, 5]);
      final sum = collection.fold<int>(0, (prev, curr) => prev + (curr as int));
      expect(sum, equals(15));
    });

    test('sortCustom sorts the collection', () {
      final collection = Collection([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]);
      final sorted = collection.sortCustom((a, b) => a.compareTo(b));
      expect(sorted.all(), equals([1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9]));
    });

    test('flatten flattens nested collections', () {
      final collection = Collection([
        [1, 2],
        [3, 4],
        [5, 6]
      ]);
      final flattened = collection.flatten();
      expect(flattened.all(), equals([1, 2, 3, 4, 5, 6]));
    });

    test('groupBy groups collection items', () {
      final collection = Collection([
        {'name': 'Alice', 'age': 25},
        {'name': 'Bob', 'age': 30},
        {'name': 'Charlie', 'age': 25},
        {'name': 'David', 'age': 30},
      ]);
      final grouped = collection.groupBy((item) => item['age']);
      expect(
          grouped,
          equals({
            25: [
              {'name': 'Alice', 'age': 25},
              {'name': 'Charlie', 'age': 25}
            ],
            30: [
              {'name': 'Bob', 'age': 30},
              {'name': 'David', 'age': 30}
            ]
          }));
    });
  });
}
