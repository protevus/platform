# PDO for Dart

A Dart implementation of PHP's PDO (PHP Data Objects) database abstraction layer. This package provides a consistent interface for accessing databases in Dart, similar to PHP's PDO extension.

## Features

- Consistent database access interface
- Support for prepared statements
- Multiple fetch modes for result sets
- Parameter binding
- Transaction support
- Error handling with SQLSTATE codes

## Usage

```dart
import 'package:pdo/pdo.dart';

void main() async {
  // Create a new PDO instance
  final pdo = PDO(
    'mysql:host=localhost;dbname=testdb',
    'username',
    'password',
  );

  // Simple query
  final stmt = pdo.prepare('SELECT * FROM users WHERE id = ?');
  await stmt.execute([1]);
  
  // Fetch a single row
  final row = await stmt.fetch();
  print(row['name']);

  // Using named parameters
  final stmt2 = pdo.prepare('SELECT * FROM users WHERE name = :name');
  stmt2.bindParam(':name', 'John');
  await stmt2.execute();

  // Fetch all rows
  final rows = await stmt2.fetchAll();
  for (final row in rows) {
    print(row['email']);
  }

  // Transaction example
  try {
    pdo.beginTransaction();
    
    final stmt = pdo.prepare('INSERT INTO users (name) VALUES (?)');
    await stmt.execute(['Alice']);
    
    final id = pdo.lastInsertId();
    
    await pdo.prepare('UPDATE logs SET user_id = ?').execute([id]);
    
    pdo.commit();
  } catch (e) {
    pdo.rollBack();
    rethrow;
  }
}
```

## Fetch Modes

The package supports various fetch modes for retrieving data:

- `PDO.FETCH_ASSOC`: Returns an associative array indexed by column name
- `PDO.FETCH_NUM`: Returns an indexed array
- `PDO.FETCH_BOTH`: Returns an array indexed by both column name and number
- `PDO.FETCH_OBJ`: Returns an anonymous object with property names that correspond to column names
- `PDO.FETCH_COLUMN`: Returns a single column
- `PDO.FETCH_KEY_PAIR`: Returns an array where first column is the key and second column is the value
- `PDO.FETCH_NAMED`: Returns an associative array of arrays

## Error Handling

The package uses exceptions for error handling:

```dart
try {
  final stmt = pdo.prepare('INVALID SQL');
  await stmt.execute();
} on PDOException catch (e) {
  print('SQL Error: ${e.message}');
  print('SQLSTATE: ${e.sqlState}');
  print('Driver Error Code: ${e.code}');
}
```

## Database Drivers

This package provides a base PDO implementation. Database-specific drivers should be implemented separately and will need to:

1. Extend the PDO class
2. Implement the required database connection logic
3. Implement statement preparation and execution
4. Handle driver-specific features and options

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the BSD-style license that can be found in the LICENSE file.
