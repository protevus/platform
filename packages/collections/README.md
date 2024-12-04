# Platform Collections

A Dart implementation of Laravel's Collection class, providing fluent wrappers for working with arrays of data.

## Features

- Fluent interface for array operations
- Rich set of collection manipulation methods
- Support for transformations and aggregations
- List interface implementation
- Type-safe operations
- Laravel-compatible dot notation support
- Wildcard operations and special segments
- Lazy collection support
- Higher order message passing

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

// Chunk by condition
collection.chunkWhile((current, next) => current < next);

// Flatten nested collections
Collection([[1, 2], [3, 4]]).flatten();  // [1, 2, 3, 4]

// Get unique items
collection.unique();

// Split into parts
collection.split(3);      // Split into 3 parts
collection.splitIn(2);    // Split in half
```

### Collection Operations

```dart
// Check for existence
collection.contains(value);
collection.containsStrict(value);  // Strict comparison

// Find differences
collection.diff(other);
collection.diffAssoc(other);

// Get items relative to another
collection.before(value);  // Get item before
collection.after(value);   // Get item after

// Multiply values
collection.multiply(3);  // Repeat each item 3 times

// Combine with another collection
keys.combine(values);    // Create map from two collections

// Count occurrences
collection.countBy();    // Count by value
collection.countBy((item) => item.type);  // Count by callback

// Get or set value
collection.getOrPut('key', () => computeValue());
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

// Get single items
collection.firstOrFail();  // Throws if empty
collection.sole();        // Throws if not exactly one item
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

### Lazy Collections

```dart
// Create lazy collection
final lazy = LazyCollection(() sync* {
  for (var i = 0; i < 1000000; i++) {
    yield i;
  }
});

// Operations are evaluated lazily
final result = lazy
    .filter((n) => n.isEven)
    .take(5)
    .toList();  // [0, 2, 4, 6, 8]

// Efficient for large datasets
final transformed = lazy
    .filter((n) => n.isEven)
    .map((n) => n * 2)
    .takeWhile((n) => n < 100);
```

### Higher Order Messages

```dart
// Access properties
collection.map('name');     // Same as map((item) => item.name)
collection.sum('quantity'); // Sum of quantity property

// Call methods
collection.map('toString'); // Call toString() on each item
collection.filter('isActive'); // Filter by isActive property/method

// Dynamic operations
collection['property'];     // Access property on each item
collection.invoke('method', args); // Call method with args
```

### Dot Notation Support

The package includes Laravel-compatible dot notation support for working with nested data structures:

```dart
// Get nested values
final data = {
  'users': [
    {'name': 'John', 'profile': {'age': 30}},
    {'name': 'Jane', 'profile': {'age': 25}}
  ]
};

// Get value using dot notation
dataGet(data, 'users.0.name');  // 'John'
dataGet(data, 'users.*.name');  // ['John', 'Jane']

// Set nested values
dataSet(data, 'users.0.profile.age', 31);

// Remove values
dataForget(data, 'users.0.profile');

// Fill missing values
dataFill(data, 'users.0.email', 'john@example.com');
```

### Special Segments

Support for special segment notation in dot paths:

```dart
// First/Last item access
dataGet(data, 'users.{first}.name');  // First user's name
dataGet(data, 'users.{last}.name');   // Last user's name

// Wildcard operations
dataGet(data, 'users.*.profile.age');  // All users' ages
dataSet(data, 'users.*.active', true); // Set all users active
```

### Helper Functions

```dart
// Get first/last elements
head([1, 2, 3]);  // 1
last([1, 2, 3]);  // 3

// Create collection from iterable
final collection = collect([1, 2, 3]);

// Get value from factory
final value = value(() => computeValue());
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

4. Dot notation operations maintain type safety and handle null values gracefully:
   ```dart
   dataGet(data, 'missing.path', defaultValue);  // Returns defaultValue
   ```

5. Lazy collections are memory efficient for large datasets:
   ```dart
   // Only processes what's needed
   LazyCollection(generator)
       .filter(predicate)
       .take(5);  // Stops after finding 5 items
   ```

## Example

See the [example](example/platform_collections_example.dart) for a complete demonstration of all features.

## Features in Detail

### Transformation Methods
- `filter()` - Filter items using a callback
- `mapItems()` - Transform items using a callback
- `chunk()` - Split into smaller collections
- `chunkWhile()` - Chunk by condition
- `flatten()` - Flatten nested collections
- `unique()` - Get unique items
- `split()` - Split into parts
- `splitIn()` - Split into equal parts

### Collection Operations
- `contains()` - Check for existence
- `containsStrict()` - Strict comparison
- `diff()` - Find differences
- `diffAssoc()` - Find differences with keys
- `before()` - Get previous item
- `after()` - Get next item
- `multiply()` - Repeat items
- `combine()` - Combine with values
- `countBy()` - Count occurrences
- `getOrPut()` - Get or set value

### Aggregation Methods
- `avg()` - Calculate average
- `max()` - Get maximum value
- `min()` - Get minimum value
- `groupBy()` - Group items by key
- `firstOrFail()` - Get first or throw
- `sole()` - Get single item

### Higher Order Methods
- Property access
- Method calls
- Dynamic operations

### Helper Functions
- `collect()` - Create collection from iterable
- `dataGet()` - Get value using dot notation
- `dataSet()` - Set value using dot notation
- `dataFill()` - Fill missing values
- `dataForget()` - Remove values
- `head()` - Get first element
- `last()` - Get last element
- `value()` - Get value from factory

### List Operations
- Standard list methods (`add`, `remove`, etc.)
- Index access (`[]`, `[]=`)
- List properties (`length`, `isEmpty`, etc.)
