import 'package:illuminate_collections/platform_collections.dart';
import 'package:illuminate_collections/src/helpers.dart';

void main() {
  // Regular Collection Examples
  print('Regular Collection Examples:');
  final numbers = Collection([1, 2, 3, 4, 5]);
  print('Original: $numbers');
  print('Average: ${numbers.avg((x) => x)}');
  print('Max: ${numbers.max()}');
  print('Min: ${numbers.min()}');
  print('---\n');

  // Collection Operations
  print('Collection Operations:');
  print('Contains 3: ${numbers.contains(3)}');
  print('Contains 6: ${numbers.contains(6)}');

  final other = Collection([4, 5, 6]);
  print('Diff with [4, 5, 6]: ${numbers.diff(other)}');

  print('Before 3: ${numbers.before(3)}');
  print('After 3: ${numbers.after(3)}');

  print('Multiplied by 2: ${numbers.multiply(2)}');

  final keys = Collection(['a', 'b', 'c']);
  final values = Collection([1, 2, 3]);
  print('Combined: ${keys.combine(values as Iterable<String>)}');

  print(
      'Count by even/odd: ${numbers.countBy((n) => n.isEven ? 'even' : 'odd')}');
  print('---\n');

  // Transformation Methods
  print('Transformation Methods:');
  final chunks = numbers.chunk(2);
  print('Chunks of 2: $chunks');

  final filtered = numbers.filter((n) => n.isEven);
  print('Even numbers: $filtered');

  final mapped = numbers.mapItems((n) => n * 2);
  print('Doubled: $mapped');

  print('Split in 2: ${numbers.splitIn(2)}');
  print(
      'Split by condition: ${numbers.chunkWhile((curr, next) => curr < next)}');
  print('---\n');

  // Working with Objects
  print('Working with Objects:');
  final users = Collection([
    {'id': 1, 'name': 'John', 'role': 'admin', 'active': true},
    {'id': 2, 'name': 'Jane', 'role': 'user', 'active': true},
    {'id': 3, 'name': 'Bob', 'role': 'admin', 'active': false},
  ]);

  // Higher Order Messages
  print('Names: ${users.mapItems((user) => user['name'])}');
  print('Active users: ${users.filter((user) => user['active'] == true)}');
  print(
      'Sum of IDs: ${users.mapItems((user) => user['id'] as int).avg((x) => x)}');
  print('---\n');

  // Dot Notation Examples
  print('Dot Notation Examples:');
  final data = <String, dynamic>{
    'users': [
      {
        'name': 'John',
        'profile': {'age': 30, 'email': 'john@example.com'},
        'roles': ['admin', 'user']
      },
      {
        'name': 'Jane',
        'profile': {'age': 25, 'email': 'jane@example.com'},
        'roles': ['user']
      }
    ],
    'settings': {'theme': 'dark', 'notifications': true}
  };

  print('First user name: ${dataGet(data, 'users.0.name')}');
  print('All user names: ${dataGet(data, 'users.*.name')}');
  print('First user: ${dataGet(data, 'users.{first}.name')}');
  print('Last user: ${dataGet(data, 'users.{last}.name')}');

  dataSet(data, 'users.*.verified', true);
  print('After setting verified: ${dataGet(data, 'users.*.verified')}');

  dataFill(data, 'users.0.country', 'USA');
  print('After filling country: ${dataGet(data, 'users.0.country')}');

  dataForget(data, 'users.0.roles');
  print(
      'After forgetting roles: ${(data['users'] as List)[0].containsKey('roles')}');
  print('---\n');

  // Helper Functions
  print('Helper Functions:');
  print('Head of numbers: ${head(numbers)}');
  print('Last of numbers: ${last(numbers)}');
  print('Collected: ${collect([1, 2, 3])}');

  var counter = 0;
  final factoryResult = value(() {
    counter++;
    return counter;
  });
  print('Value from factory: $factoryResult');
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

  final evenNumbers = lazyNumbers.filter((n) => n.isEven).take(3);
  print('First 3 even numbers:');
  print(evenNumbers.toList());
  print('---\n');

  // Example 4: Working with Objects Lazily
  print('Working with Objects Lazily:');
  final lazyUsers = LazyCollection([
    {'id': 1, 'name': 'John', 'role': 'admin'},
    {'id': 2, 'name': 'Jane', 'role': 'user'},
    {'id': 3, 'name': 'Bob', 'role': 'admin'},
    {'id': 4, 'name': 'Alice', 'role': 'user'},
  ]);

  final admins = lazyUsers
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
  final skipTakeResult = sequence.skip(2).take(3);
  print(skipTakeResult.toList());
  print('---\n');

  // Example 7: FlatMap Operation
  print('FlatMap Operation:');
  final nested = LazyCollection([1, 2, 3]);
  final flattened = nested.flatMap((n) => [n, n * 2]);
  print('Flattened doubles: ${flattened.toList()}');
}
