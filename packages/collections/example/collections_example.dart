import 'package:platform_collections/platform_collections.dart';

void main() {
  // Create a new collection
  final numbers = Collection([1, 2, 3, 4, 5]);

  print('Original collection: ${numbers.all()}');

  // Demonstrate some collection methods
  print('Average: ${numbers.avg()}');
  print('Chunks of 2: ${numbers.chunk(2).map((chunk) => chunk.all())}');
  print('Every 2nd item: ${numbers.everyNth(2).all()}');
  print('Except indices [1, 3]: ${numbers.except([1, 3]).all()}');
  print('First even number: ${numbers.firstWhere((n) => n % 2 == 0)}');
  print('Reversed: ${numbers.reverse().all()}');

  // Demonstrate map and filter operations
  final doubled = numbers.mapCustom((n) => n * 2);
  print('Doubled: ${doubled.all()}');

  final evenNumbers = numbers.whereCustom((n) => n % 2 == 0);
  print('Even numbers: ${evenNumbers.all()}');

  // Demonstrate reduce operation
  final sum = numbers.fold<int>(0, (prev, curr) => prev + curr);
  print('Sum: $sum');

  // Demonstrate sorting
  final sortedDesc = numbers.sortCustom((a, b) => b.compareTo(a));
  print('Sorted descending: ${sortedDesc.all()}');

  // Demonstrate search
  final searchResult = numbers.search(3);
  print('Index of 3: $searchResult');

  // Demonstrate JSON conversion
  print('JSON representation: ${numbers.toJson()}');

  // Demonstrate operations with non-numeric collections
  final fruits = Collection(['apple', 'banana', 'cherry', 'date']);
  print('\nFruits: ${fruits.all()}');
  print(
      'Fruits starting with "b": ${fruits.whereCustom((f) => f.startsWith('b')).all()}');
  print(
      'Fruit names in uppercase: ${fruits.mapCustom((f) => f.toUpperCase()).all()}');

  // Demonstrate nested collections
  final nested = Collection([
    [1, 2],
    [3, 4],
    [5, 6],
  ]);
  print('\nNested collection: ${nested.all()}');
  print('Flattened: ${nested.flatten().all()}');

  // Demonstrate grouping
  final people = Collection([
    {'name': 'Alice', 'age': 25},
    {'name': 'Bob', 'age': 30},
    {'name': 'Charlie', 'age': 25},
    {'name': 'David', 'age': 30},
  ]);
  final groupedByAge = people.groupBy((person) => person['age']);
  print('\nPeople grouped by age: $groupedByAge');
}
