import 'package:test/test.dart';
import 'package:platform_collections/platform_collections.dart';

void main() {
  group('LazyCollection', () {
    test('can be created from iterable', () {
      final lazy = LazyCollection([1, 2, 3]);
      expect(lazy.toList(), equals([1, 2, 3]));
    });

    test('can be created from generator', () {
      final lazy = LazyCollection.from(() sync* {
        yield 1;
        yield 2;
        yield 3;
      });
      expect(lazy.toList(), equals([1, 2, 3]));
    });

    group('lazy evaluation', () {
      test('only evaluates items when needed', () {
        var count = 0;
        final lazy = LazyCollection.from(() sync* {
          for (var i = 1; i <= 5; i++) {
            count++;
            yield i;
          }
        });

        expect(count, equals(0)); // Nothing evaluated yet
        final first = lazy.tryFirst();
        expect(count, equals(1)); // Only first item evaluated
        expect(first, equals(1));
      });

      test('evaluates items multiple times when accessed multiple times', () {
        var count = 0;
        final lazy = LazyCollection.from(() sync* {
          count++;
          yield 1;
        });

        lazy.toList(); // First evaluation
        lazy.toList(); // Second evaluation
        expect(count, equals(2));
      });
    });

    group('transformation methods', () {
      test('filter evaluates lazily', () {
        var count = 0;
        final lazy = LazyCollection.from(() sync* {
          for (var i = 1; i <= 5; i++) {
            count++;
            yield i;
          }
        });

        final filtered = lazy.filter((n) => n.isEven);
        expect(count, equals(0)); // Nothing evaluated yet
        expect(filtered.toList(), equals([2, 4]));
        expect(count, equals(5)); // All items evaluated for filtering
      });

      test('chunk creates lazy chunks', () {
        var count = 0;
        final lazy = LazyCollection.from(() sync* {
          for (var i = 1; i <= 5; i++) {
            count++;
            yield i;
          }
        });

        final chunks = lazy.chunk(2);
        expect(count, equals(0)); // Nothing evaluated yet
        expect(
            chunks.toList(),
            equals([
              [1, 2],
              [3, 4],
              [5]
            ]));
        expect(count, equals(5));
      });

      test('takeUntil stops at condition', () {
        final lazy = LazyCollection.from(() sync* {
          for (var i = 1; i <= 5; i++) {
            yield i;
          }
        });

        final result = lazy.takeUntil((n) => n > 3);
        expect(result.toList(), equals([1, 2, 3]));
      });

      test('takeWhileCondition continues while condition is true', () {
        final lazy = LazyCollection.from(() sync* {
          for (var i = 1; i <= 5; i++) {
            yield i;
          }
        });

        final result = lazy.takeWhileCondition((n) => n < 4);
        expect(result.toList(), equals([1, 2, 3]));
      });

      test('skipUntil starts at condition', () {
        final lazy = LazyCollection.from(() sync* {
          for (var i = 1; i <= 5; i++) {
            yield i;
          }
        });

        final result = lazy.skipUntil((n) => n > 2);
        expect(result.toList(), equals([3, 4, 5]));
      });

      test('skipWhileCondition skips while condition is true', () {
        final lazy = LazyCollection.from(() sync* {
          for (var i = 1; i <= 5; i++) {
            yield i;
          }
        });

        final result = lazy.skipWhileCondition((n) => n < 3);
        expect(result.toList(), equals([3, 4, 5]));
      });

      test('flatMap transforms and flattens', () {
        final lazy = LazyCollection([1, 2, 3]);
        final result = lazy.flatMap((n) => [n, n * 2]);
        expect(result.toList(), equals([1, 2, 2, 4, 3, 6]));
      });
    });

    group('aggregation methods', () {
      test('avg calculates average', () {
        final lazy = LazyCollection([1, 2, 3, 4, 5]);
        expect(lazy.avg(), equals(3.0));
      });

      test('max finds maximum value', () {
        final lazy = LazyCollection([1, 5, 3, 2, 4]);
        expect(lazy.max(), equals(5));
      });

      test('min finds minimum value', () {
        final lazy = LazyCollection([1, 5, 3, 2, 4]);
        expect(lazy.min(), equals(1));
      });
    });

    group('helper methods', () {
      test('unique returns unique items', () {
        final lazy = LazyCollection([1, 2, 2, 3, 3, 3]);
        expect(lazy.unique().toList(), equals([1, 2, 3]));
      });

      test('unique with callback', () {
        final lazy = LazyCollection([
          {'id': 1, 'name': 'A'},
          {'id': 2, 'name': 'B'},
          {'id': 1, 'name': 'C'},
        ]);
        final unique = lazy.unique((item) => item['id']);
        expect(unique.toList(), hasLength(2));
      });

      test('random returns random items', () {
        final lazy = LazyCollection(List.generate(100, (i) => i));
        final random1 = lazy.random();
        final random2 = lazy.random();
        expect(random1.toList(), hasLength(1));
        expect(random2.toList(), hasLength(1));
        expect(random1.toList(),
            isNot(equals(random2.toList()))); // Could theoretically fail
      });

      test('random with count returns multiple items', () {
        final lazy = LazyCollection(List.generate(100, (i) => i));
        final random = lazy.random(5);
        expect(random.toList(), hasLength(5));
        expect(random.toList().toSet().length,
            equals(5)); // All items should be unique
      });
    });
  });
}
