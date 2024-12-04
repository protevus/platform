import 'package:platform_collections/platform_collections.dart';

void main() {
  // Regular Collection Examples
  print('Regular Collection Examples:');
  final numbers = Collection([1, 2, 3, 4, 5]);
  print('Original: $numbers');
  print('Average: ${numbers.avg()}');
  print('Max: ${numbers.max()}');
  print('Min: ${numbers.min()}');
  print('---\n');

  // Transformation Methods
  print('Transformation Methods:');
  final chunks = numbers.chunk(2);
  print('Chunks of 2: $chunks');

  final filtered = numbers.filter((n) => n.isEven);
  print('Even numbers: $filtered');

  final mapped = numbers.mapItems((n) => n * 2);
  print('Doubled: $mapped');
  print('---\n');

  // Lazy Collection Examples
  print('Lazy Collection Examples:');

  // Example 1: Basic Lazy Evaluation
  print('Basic Lazy Evaluation:');
  var count = 0;
  final lazy = LazyCollection.from(() sync* {
    for (var i = 1; i <= 5; i++) {
      count++;
      yield i;
    }
  });
  print('Count before evaluation: $count');
  print('First number: ${lazy.tryFirst()}');
  print('Count after getting first: $count');
  print('All numbers: ${lazy.toList()}');
  print('Count after getting all: $count');
  print('---\n');

  // Example 2: Infinite Sequence with Lazy Evaluation
  print('Infinite Sequence with Lazy Evaluation:');
  final fibonacci = LazyCollection.from(() sync* {
    var prev = 0, current = 1;
    while (true) {
      yield current;
      final next = prev + current;
      prev = current;
      current = next;
    }
  });

  print('First 10 Fibonacci numbers:');
  final firstTenFib = fibonacci.take(10);
  print(firstTenFib.toList());
  print('---\n');

  // Example 3: Lazy Transformations
  print('Lazy Transformations:');
  final lazyNumbers = LazyCollection.from(() sync* {
    print('Generating numbers...');
    for (var i = 1; i <= 10; i++) {
      yield i;
    }
  });

  final evenNumbers =
      lazyNumbers.filter((n) => n.isEven).take(3); // Take first 3 even numbers

  print('First 3 even numbers:');
  print(evenNumbers.toList());
  print('---\n');

  // Example 4: Working with Objects
  print('Working with Objects:');
  final users = LazyCollection([
    {'id': 1, 'name': 'John', 'role': 'admin'},
    {'id': 2, 'name': 'Jane', 'role': 'user'},
    {'id': 3, 'name': 'Bob', 'role': 'admin'},
    {'id': 4, 'name': 'Alice', 'role': 'user'},
  ]);

  final admins = users
      .filter((user) => user['role'] == 'admin')
      .mapItems((user) => user['name']);

  print('Admin names: ${admins.toList()}');
  print('---\n');

  // Example 5: Chunking with Lazy Evaluation
  print('Chunking with Lazy Evaluation:');
  final stream = LazyCollection.from(() sync* {
    for (var i = 1; i <= 10; i++) {
      print('Generating number $i');
      yield i;
    }
  });

  final chunks2 = stream.chunk(3);
  print('First chunk:');
  print(chunks2.tryFirst());
  print('All chunks:');
  print(chunks2.toList());
  print('---\n');

  // Example 6: Skip and Take Operations
  print('Skip and Take Operations:');
  final sequence = LazyCollection.from(() sync* {
    for (var i = 1; i <= 10; i++) {
      yield i * i;
    }
  });

  print('Skip 2, take 3 of squares:');
  final result = sequence.skip(2).take(3);
  print(result.toList());
  print('---\n');

  // Example 7: FlatMap Operation
  print('FlatMap Operation:');
  final nested = LazyCollection([1, 2, 3]);
  final flattened = nested.flatMap((n) => [n, n * 2]);
  print('Flattened doubles: ${flattened.toList()}');
}
