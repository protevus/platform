# Platform Collections

A Dart implementation of Laravel-inspired collections, providing a fluent, convenient wrapper for working with arrays of data.

## Features

- Chainable methods for manipulating collections of data
- Type-safe operations
- Null-safe implementation
- Inspired by Laravel's collection methods

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  platform_collections: ^1.0.0
```

Then run `dart pub get` or `flutter pub get` to install the package.

## Usage

Here's a simple example of how to use the `Collection` class:

```dart
import 'package:platform_collections/platform_collections.dart';

void main() {
  final numbers = Collection([1, 2, 3, 4, 5]);

  // Using various collection methods
  final result = numbers
      .whereCustom((n) => n % 2 == 0)
      .mapCustom((n) => n * 2)
      .toList();

  print(result); // [4, 8]

  // Chaining methods
  final sum = numbers
      .whereCustom((n) => n > 2)
      .fold(0, (prev, curr) => prev + curr);

  print(sum); // 12
}
```

## Available Methods

- `all()`: Returns all items in the collection
- `avg()`: Calculates the average of the collection
- `chunk()`: Chunks the collection into smaller collections
- `collapse()`: Collapses a collection of arrays into a single collection
- `concat()`: Concatenates the given array or collection
- `contains()`: Determines if the collection contains a given item
- `count()`: Returns the total number of items in the collection
- `each()`: Iterates over the items in the collection
- `everyNth()`: Creates a new collection consisting of every n-th element
- `except()`: Returns all items except for those with the specified keys
- `filter()` / `whereCustom()`: Filters the collection using a callback
- `first()` / `firstWhere()`: Returns the first element that passes the given truth test
- `flatten()`: Flattens a multi-dimensional collection
- `flip()`: Flips the items in the collection
- `fold()`: Reduces the collection to a single value
- `groupBy()`: Groups the collection's items by a given key
- `join()`: Joins the items in a collection
- `last()` / `lastOrNull()`: Returns the last element in the collection
- `map()` / `mapCustom()`: Runs a map over each of the items
- `mapSpread()`: Runs a map over each nested chunk of items
- `max()`: Returns the maximum value in the collection
- `merge()`: Merges the given array into the collection
- `min()`: Returns the minimum value in the collection
- `only()`: Returns only the items from the collection with the specified keys
- `pluck()`: Retrieves all of the collection values for a given key
- `random()`: Returns a random item from the collection
- `reverse()`: Reverses the order of the collection's items
- `search()`: Searches the collection for a given value
- `shuffle()`: Shuffles the items in the collection
- `slice()`: Returns a slice of the collection
- `sort()` / `sortCustom()`: Sorts the collection
- `take()`: Takes the first or last {n} items

## Additional Information

For more detailed examples, please refer to the `example/collections_example.dart` file in the package.

If you encounter any issues or have feature requests, please file them on the [issue tracker](https://github.com/yourusername/platform_collections/issues).

Contributions are welcome! Please read our [contributing guidelines](https://github.com/yourusername/platform_collections/blob/main/CONTRIBUTING.md) before submitting a pull request.
