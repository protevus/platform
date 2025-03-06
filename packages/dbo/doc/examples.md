# PDO Examples

This document provides practical examples of using PDO for Dart in various scenarios.

## Basic Usage

### Connecting to a Database

```dart
// MySQL connection
final pdo = PDOMySQL(
  'mysql:host=localhost;dbname=testdb;charset=utf8mb4',
  'username',
  'password',
);

// With connection options
final pdo = PDOMySQL(
  'mysql:host=localhost;dbname=testdb',
  'username',
  'password',
  {
    PDO.ATTR_ERRMODE: PDO.ERRMODE_EXCEPTION,
    PDO.ATTR_DEFAULT_FETCH_MODE: PDO.FETCH_ASSOC,
    PDO.ATTR_TIMEOUT: 30,
  },
);
```

### Simple Queries

```dart
// Direct execution for simple queries
final rowCount = pdo.exec('UPDATE users SET status = "active" WHERE id < 10');
print('Updated $rowCount rows');

// Fetching data
final stmt = pdo.prepare('SELECT * FROM users WHERE status = ?');
await stmt.execute(['active']);

final users = await stmt.fetchAll();
for (final user in users) {
  print('User: ${user['name']} (${user['email']})');
}
```

## Working with Data

### Insert Operations

```dart
// Single insert
final stmt = pdo.prepare('''
  INSERT INTO users (name, email, created_at)
  VALUES (:name, :email, :created_at)
''');

await stmt.execute({
  ':name': 'John Doe',
  ':email': 'john@example.com',
  ':created_at': DateTime.now().toIso8601String(),
});

final userId = pdo.lastInsertId();

// Batch insert
final stmt = pdo.prepare('''
  INSERT INTO users (name, email)
  VALUES (?, ?)
''');

final users = [
  ['Alice', 'alice@example.com'],
  ['Bob', 'bob@example.com'],
  ['Carol', 'carol@example.com'],
];

for (final user in users) {
  await stmt.execute(user);
}
```

### Update Operations

```dart
// Using named parameters
final stmt = pdo.prepare('''
  UPDATE users
  SET status = :status, updated_at = :updated_at
  WHERE last_login < :threshold
''');

await stmt.execute({
  ':status': 'inactive',
  ':updated_at': DateTime.now().toIso8601String(),
  ':threshold': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
});

print('Updated ${stmt.rowCount} rows');

// Using positional parameters
final stmt = pdo.prepare('UPDATE products SET stock = stock + ? WHERE id = ?');
await stmt.execute([5, 123]); // Add 5 items to product #123
```

### Delete Operations

```dart
// Simple delete
final stmt = pdo.prepare('DELETE FROM orders WHERE status = ?');
await stmt.execute(['cancelled']);

// Delete with multiple conditions
final stmt = pdo.prepare('''
  DELETE FROM audit_logs
  WHERE created_at < :threshold
  AND type IN (?, ?, ?)
''');

await stmt.execute([
  DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
  'debug',
  'info',
  'notice',
]);
```

## Advanced Queries

### Transactions

```dart
// Basic transaction
try {
  pdo.beginTransaction();
  
  final orderStmt = pdo.prepare('''
    INSERT INTO orders (user_id, total)
    VALUES (?, ?)
  ''');
  await orderStmt.execute([userId, total]);
  final orderId = pdo.lastInsertId();
  
  final itemsStmt = pdo.prepare('''
    INSERT INTO order_items (order_id, product_id, quantity)
    VALUES (?, ?, ?)
  ''');
  
  for (final item in items) {
    await itemsStmt.execute([orderId, item.productId, item.quantity]);
  }
  
  pdo.commit();
} catch (e) {
  pdo.rollBack();
  rethrow;
}

// Transaction with savepoints
try {
  pdo.beginTransaction();
  
  // First operation
  final stmt1 = pdo.prepare('INSERT INTO table1 VALUES (?)');
  await stmt1.execute(['data1']);
  
  pdo.exec("SAVEPOINT save1");
  
  try {
    // Second operation
    final stmt2 = pdo.prepare('INSERT INTO table2 VALUES (?)');
    await stmt2.execute(['data2']);
  } catch (e) {
    // Rollback to savepoint if second operation fails
    pdo.exec("ROLLBACK TO save1");
  }
  
  pdo.commit();
} catch (e) {
  pdo.rollBack();
  rethrow;
}
```

### Complex Joins

```dart
final stmt = pdo.prepare('''
  SELECT 
    u.id,
    u.name,
    COUNT(o.id) as order_count,
    SUM(o.total) as total_spent
  FROM users u
  LEFT JOIN orders o ON u.id = o.user_id
  WHERE u.status = ?
  GROUP BY u.id
  HAVING total_spent > ?
  ORDER BY total_spent DESC
  LIMIT ?
''');

await stmt.execute(['active', 1000, 10]);

final results = await stmt.fetchAll(PDO.FETCH_ASSOC);
```

### Working with BLOBs

```dart
// Storing a file
final file = File('image.jpg');
final data = await file.readAsBytes();

final stmt = pdo.prepare('INSERT INTO images (name, data) VALUES (?, ?)');
await stmt.bindValue(1, 'image.jpg', PDO.PARAM_STR);
await stmt.bindValue(2, data, PDO.PARAM_LOB);
await stmt.execute();

// Retrieving a file
final stmt = pdo.prepare('SELECT data FROM images WHERE id = ?');
await stmt.execute([123]);
final row = await stmt.fetch(PDO.FETCH_ASSOC);

if (row != null) {
  final file = File('retrieved_image.jpg');
  await file.writeAsBytes(row['data']);
}
```

### Stored Procedures

```dart
// Calling a stored procedure
final stmt = pdo.prepare('CALL get_user_stats(:user_id, @order_count, @total_spent)');
await stmt.execute({':user_id': 123});

final resultStmt = pdo.prepare('SELECT @order_count, @total_spent');
await resultStmt.execute();
final results = await resultStmt.fetch(PDO.FETCH_ASSOC);
```

## Error Handling

```dart
try {
  final stmt = pdo.prepare('INSERT INTO users (email) VALUES (?)');
  await stmt.execute(['existing@email.com']);
} on PDOException catch (e) {
  if (e.sqlState == '23000') { // Duplicate entry
    print('Email already exists');
  } else {
    print('Database error: ${e.message}');
    print('SQL State: ${e.sqlState}');
    print('Error Code: ${e.code}');
  }
}
```

## Performance Optimization

### Connection Pooling

```dart
final pool = PDOPool(
  create: () => PDOMySQL(
    'mysql:host=localhost;dbname=testdb',
    'username',
    'password',
  ),
  min: 5,
  max: 20,
);

final pdo = await pool.acquire();
try {
  // Use the connection
} finally {
  await pool.release(pdo);
}
```

### Prepared Statement Reuse

```dart
// Create the prepared statement once
final stmt = pdo.prepare('''
  SELECT id, name, email
  FROM users
  WHERE status = ?
  AND created_at > ?
''');

// Reuse it multiple times
await stmt.execute(['active', '2023-01-01']);
final activeUsers = await stmt.fetchAll();

await stmt.execute(['pending', '2023-01-01']);
final pendingUsers = await stmt.fetchAll();

await stmt.execute(['inactive', '2023-01-01']);
final inactiveUsers = await stmt.fetchAll();
```

### Batch Processing

```dart
// Process large datasets in chunks
final stmt = pdo.prepare('INSERT INTO logs (message, level) VALUES (?, ?)');

for (var i = 0; i < logs.length; i += 1000) {
  final batch = logs.skip(i).take(1000);
  
  pdo.beginTransaction();
  try {
    for (final log in batch) {
      await stmt.execute([log.message, log.level]);
    }
    pdo.commit();
  } catch (e) {
    pdo.rollBack();
    rethrow;
  }
}
