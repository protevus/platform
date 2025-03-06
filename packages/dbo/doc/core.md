# PDO Core Concepts

PDO (PHP Data Objects) for Dart provides a lightweight, consistent interface for accessing databases in Dart. This implementation follows PHP's PDO design while taking advantage of Dart's features and type system.

## Key Components

### PDO Class

The main database abstraction class that provides a consistent interface for database operations:

```dart
final pdo = PDOMySQL(
  'mysql:host=localhost;dbname=testdb',
  'username',
  'password',
);
```

Key features:
- Database connection management
- Transaction handling
- Error handling with SQLSTATE codes
- Statement preparation and execution
- Quote/escape utilities

### PDOStatement

Represents a prepared statement and, after execution, an associated result set:

```dart
final stmt = pdo.prepare('SELECT * FROM users WHERE id = ?');
await stmt.execute([1]);
final user = await stmt.fetch(PDO.FETCH_ASSOC);
```

Key features:
- Parameter binding
- Result set fetching
- Multiple fetch modes
- Column metadata access
- Cursor operations

### PDOException

Provides detailed error information for database operations:

```dart
try {
  // Database operations
} on PDOException catch (e) {
  print('Error: ${e.message}');
  print('SQLSTATE: ${e.sqlState}');
  print('Driver Code: ${e.code}');
}
```

## Core Features

### Connection Management

PDO provides a consistent way to connect to different databases using Data Source Names (DSNs):

```dart
// MySQL connection
final mysql = PDOMySQL('mysql:host=localhost;dbname=testdb', 'user', 'pass');

// PostgreSQL connection
final pgsql = PDOPostgreSQL('pgsql:host=localhost;dbname=testdb', 'user', 'pass');

// SQLite connection
final sqlite = PDOSQLite('sqlite:/path/to/database.db');
```

### Prepared Statements

PDO encourages the use of prepared statements to prevent SQL injection:

```dart
final stmt = pdo.prepare('INSERT INTO users (name, email) VALUES (?, ?)');
await stmt.execute(['John Doe', 'john@example.com']);
```

Named parameters are also supported:

```dart
final stmt = pdo.prepare('SELECT * FROM users WHERE status = :status AND role = :role');
await stmt.execute({
  ':status': 'active',
  ':role': 'admin'
});
```

### Transactions

PDO provides transaction support with automatic rollback on errors:

```dart
try {
  pdo.beginTransaction();
  
  // Multiple database operations
  await stmt1.execute();
  await stmt2.execute();
  
  pdo.commit();
} catch (e) {
  pdo.rollBack();
  rethrow;
}
```

### Fetch Modes

Multiple fetch modes are available for retrieving data:

```dart
// Associative array
final row = await stmt.fetch(PDO.FETCH_ASSOC);

// Numeric array
final row = await stmt.fetch(PDO.FETCH_NUM);

// Both numeric and associative
final row = await stmt.fetch(PDO.FETCH_BOTH);

// Object
final row = await stmt.fetch(PDO.FETCH_OBJ);
```

### Error Handling

Comprehensive error handling with SQLSTATE codes:

```dart
try {
  await stmt.execute();
} on PDOException catch (e) {
  switch (e.sqlState) {
    case '23000': // Integrity constraint violation
      print('Duplicate entry or invalid data');
      break;
    case '42S02': // Base table or view not found
      print('Table does not exist');
      break;
    default:
      print('Database error: ${e.message}');
  }
}
```

## Best Practices

1. **Always use prepared statements**
   ```dart
   // Good
   final stmt = pdo.prepare('SELECT * FROM users WHERE id = ?');
   await stmt.execute([userId]);
   
   // Bad - vulnerable to SQL injection
   pdo.exec('SELECT * FROM users WHERE id = $userId');
   ```

2. **Use transactions for multiple operations**
   ```dart
   pdo.beginTransaction();
   try {
     // Multiple operations
     pdo.commit();
   } catch (e) {
     pdo.rollBack();
     rethrow;
   }
   ```

3. **Close resources when done**
   ```dart
   final stmt = pdo.prepare('SELECT * FROM large_table');
   try {
     await stmt.execute();
     // Process results
   } finally {
     await stmt.closeCursor();
   }
   ```

4. **Handle errors appropriately**
   ```dart
   try {
     // Database operations
   } on PDOException catch (e) {
     // Log error details
     log.error('Database error: ${e.message} (${e.sqlState})');
     // Take appropriate action
     rethrow;
   }
   ```

5. **Use appropriate fetch modes**
   ```dart
   // When you need specific columns
   final stmt = pdo.prepare('SELECT id, name FROM users');
   final rows = await stmt.fetchAll(PDO.FETCH_KEY_PAIR);
   
   // When you need all columns
   final stmt = pdo.prepare('SELECT * FROM users');
   final rows = await stmt.fetchAll(PDO.FETCH_ASSOC);
