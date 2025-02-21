# Illuminate Pagination for Dart

A Dart implementation of Laravel's pagination system, providing a clean and flexible way to paginate data collections while maintaining Dart idioms and best practices.

## Features

- Standard offset-based pagination with page numbers
- Length-aware pagination with total count and last page information
- Cursor-based pagination for APIs and real-time data
- URL generation for pagination links
- JSON serialization support
- Dart-idiomatic implementation
- Null safety

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  illuminate_pagination: ^0.5.1
```

## Usage

### Basic Pagination

Use the `Paginator` class when you don't need to know the total number of items or pages:

```dart
import 'package:illuminate_pagination/illuminate_pagination.dart';

void main() {
  final items = List.generate(100, (i) => 'Item ${i + 1}');
  final page = 2;
  final perPage = 15;

  // Get items for the current page
  final currentPageItems = items
      .skip((page - 1) * perPage)
      .take(perPage + 1) // Take one extra to determine if there are more pages
      .toList();

  final paginator = Paginator(
    items: currentPageItems,
    perPage: perPage,
    currentPage: page,
  );

  print('Current page: ${paginator.currentPage}');
  print('Has more pages: ${paginator.hasMorePages()}');
  print('Items: ${paginator.items()}');
}
```

### Length-Aware Pagination

Use `LengthAwarePaginator` when you know the total number of items:

```dart
import 'package:illuminate_pagination/illuminate_pagination.dart';

void main() {
  final items = List.generate(100, (i) => 'Item ${i + 1}');
  final page = 2;
  final perPage = 15;

  // Get items for the current page
  final currentPageItems = items
      .skip((page - 1) * perPage)
      .take(perPage)
      .toList();

  final paginator = LengthAwarePaginator(
    items: currentPageItems,
    total: items.length,
    perPage: perPage,
    currentPage: page,
  );

  print('Current page: ${paginator.currentPage}');
  print('Total items: ${paginator.getTotal()}');
  print('Last page: ${paginator.getLastPage()}');
  print('Items: ${paginator.items()}');
}
```

### Cursor-Based Pagination

Use `CursorPaginator` for APIs and real-time data where offset-based pagination might lead to skipped or duplicated items:

```dart
import 'package:illuminate_pagination/illuminate_pagination.dart';

void main() {
  // Example cursor parameters
  final currentCursor = Cursor({'id': 15, 'created_at': '2024-02-19T00:00:00Z'});
  final nextCursor = Cursor({'id': 30, 'created_at': '2024-02-19T01:00:00Z'});

  final paginator = CursorPaginator(
    items: currentPageItems,
    perPage: 15,
    previousCursor: currentCursor,
    nextCursor: nextCursor,
  );

  print('Has more pages: ${paginator.hasMorePages()}');
  print('Next cursor: ${paginator.nextCursor?.parameter}');
  print('Items: ${paginator.items()}');
}
```

### URL Generation

All paginators support URL generation for pagination links:

```dart
final paginator = LengthAwarePaginator(
  items: currentPageItems,
  total: totalItems,
  perPage: perPage,
  currentPage: page,
  path: '/api/items',
  query: {'sort': 'desc'},
);

print('Previous page URL: ${paginator.previousPageUrl()}');
print('Next page URL: ${paginator.nextPageUrl()}');
print('Page 5 URL: ${paginator.url(5)}');
```

### JSON Serialization

All paginators support conversion to JSON for API responses:

```dart
final json = paginator.toJson();
print(json);
```

Example output:
```json
{
  "current_page": 2,
  "data": [...],
  "first_page_url": "/api/items?page=1",
  "from": 16,
  "last_page": 7,
  "last_page_url": "/api/items?page=7",
  "links": [...],
  "next_page_url": "/api/items?page=3",
  "path": "/api/items",
  "per_page": 15,
  "prev_page_url": "/api/items?page=1",
  "to": 30,
  "total": 100
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is open-sourced software licensed under the MIT license.
