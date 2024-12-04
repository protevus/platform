# Platform Collections

A Dart implementation of Laravel's Collection class, providing fluent wrappers for working with arrays of data.

## Features

- Fluent interface for array operations
- Rich set of collection manipulation methods
- Support for transformations and aggregations
- List interface implementation
- Type-safe operations

## Usage

```dart
import 'package:platform_collections/platform_collections.dart';

// Create a collection
final numbers = Collection([1, 2, 3, 4, 5]);

// Basic operations
numbers.avg();  // 3.0
numbers.max();  // 5
numbers.min();  // 1

// Transformations
numbers.filter((n) => n.isEven);  // [2, 4]
numbers.mapItems((n) => n * 2);   // [2, 4, 6, 8, 10]
numbers.chunk(2);                 // [[1, 2], [3, 4], [5]]
```

## Key Features

### Creation and Basic Operations

```dart
// Create empty collection
final empty = Collection<int>();

// Create from items
final items = Collection([1, 2, 3]);

// Create range
final range = Collection.range(1, 5);  // [1, 2, 3, 4, 5]

// Get all items
final list = items.all();  // Returns unmodifiable List
```

### Transformations

```dart
// Filter items
collection.filter((item) => item.isEven);

// Map items
collection.mapItems((item) => item * 2);

// Chunk into smaller collections
collection.chunk(2);

// Flatten nested collections
Collection([[1, 2], [3, 4]]).flatten();  // [1, 2, 3, 4]

// Get unique items
collection.unique();
```

### Aggregations

```dart
// Calculate average
collection.avg();
collection.avg((item) => item.value);  // With callback

// Group items
final grouped = collection.groupBy((item) => item.category);

// Find maximum/minimum
collection.max();
collection.min();
```

### Working with Objects

```dart
final users = Collection([
  {'id': 1, 'name': 'John', 'role': 'admin'},
  {'id': 2, 'name': 'Jane', 'role': 'user'},
]);

// Group by a key
final byRole = users.groupBy((user) => user['role']);

// Get unique by key
final uniqueRoles = users.unique((user) => user['role']);

// Convert to Map
final map = users.toMap(
  (user) => user['id'],
  (user) => user['name'],
);
```

### List Operations

The Collection class implements Dart's `ListMixin`, providing all standard list operations:

```dart
final list = Collection(['a', 'b', 'c']);

// Add/remove items
list.add('d');
list.remove('b');

// Access by index
list[0] = 'A';
final first = list[0];

// Standard list methods
list.length;
list.isEmpty;
list.reversed;
```

### Helper Methods

```dart
// Get random items
collection.random();      // Single random item
collection.random(3);     // Multiple random items

// Join items
collection.joinWith(', ');  // Custom join with separator

// Cross join collections
final colors = Collection(['red', 'blue']);
final sizes = Collection(['S', 'M']);
colors.crossJoin([sizes]);  // All combinations
```

## Important Notes

1. The Collection class is generic and maintains type safety:
   ```dart
   final numbers = Collection<int>([1, 2, 3]);
   final strings = Collection<String>(['a', 'b', 'c']);
   ```

2. Most methods return a new Collection instance, keeping the original unchanged:
   ```dart
   final original = Collection([1, 2, 3]);
   final doubled = original.mapItems((n) => n * 2);  // Original unchanged
   ```

3. The class implements `ListMixin`, so it can be used anywhere a List is expected:
   ```dart
   void processList(List<int> list) {
     // Works with Collection<int>
   }
   ```

## Example

See the [example](example/platform_collections_example.dart) for a complete demonstration of all features.

## Features in Detail

### Transformation Methods
- `filter()` - Filter items using a callback
- `mapItems()` - Transform items using a callback
- `chunk()` - Split into smaller collections
- `flatten()` - Flatten nested collections
- `unique()` - Get unique items

### Aggregation Methods
- `avg()` - Calculate average
- `max()` - Get maximum value
- `min()` - Get minimum value
- `groupBy()` - Group items by key

### Utility Methods
- `random()` - Get random items
- `toMap()` - Convert to Map
- `joinWith()` - Join items with separator
- `crossJoin()` - Get all combinations

### List Operations
- Standard list methods (`add`, `remove`, etc.)
- Index access (`[]`, `[]=`)
- List properties (`length`, `isEmpty`, etc.)
