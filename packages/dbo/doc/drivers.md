# PDO Database Drivers

PDO for Dart supports multiple database systems through a consistent interface. This document explains how to implement and use database drivers.

## Available Drivers

### MySQL Driver

The MySQL driver provides connectivity to MySQL databases:

```dart
final pdo = PDOMySQL(
  'mysql:host=localhost;dbname=testdb;port=3306;charset=utf8mb4',
  'username',
  'password',
  {
    PDO.ATTR_PERSISTENT: true,
    PDO.MYSQL_ATTR_USE_BUFFERED_QUERY: true,
  },
);
```

DSN Parameters:
- `host`: Database host (default: localhost)
- `port`: Port number (default: 3306)
- `dbname`: Database name
- `charset`: Connection charset (default: utf8mb4)
- `unix_socket`: Unix socket path
- `ssl_ca`: SSL CA certificate path
- `ssl_cert`: SSL certificate path
- `ssl_key`: SSL key path

## Implementing a Driver

To create a new PDO driver, you need to implement two main classes:

1. A driver class extending `PDO`
2. A statement class implementing `PDOStatement`

### Driver Implementation

```dart
class PDOPostgreSQL extends PDO {
  late final PostgreSQLConnection _conn;
  
  PDOPostgreSQL(String dsn, [String? username, String? password, Map<int, dynamic>? options]) {
    final params = _parseDsn(dsn);
    // Initialize connection
    _conn = PostgreSQLConnection(
      params['host'] ?? 'localhost',
      int.parse(params['port'] ?? '5432'),
      params['dbname'] ?? '',
      username: username,
      password: password,
    );
  }
  
  @override
  PDOStatement prepare(String statement, [List<dynamic>? driverOptions]) {
    return PDOPostgreSQLStatement(this, statement);
  }
  
  @override
  bool beginTransaction() {
    // Implement transaction start
  }
  
  @override
  bool commit() {
    // Implement transaction commit
  }
  
  @override
  bool rollBack() {
    // Implement transaction rollback
  }
  
  // ... implement other required methods
}
```

### Statement Implementation

```dart
class PDOPostgreSQLStatement implements PDOStatement {
  final PDOPostgreSQL _pdo;
  final String _queryString;
  PostgreSQLResult? _result;
  
  PDOPostgreSQLStatement(this._pdo, this._queryString);
  
  @override
  Future<bool> execute([List<dynamic>? parameters]) async {
    // Implement statement execution
  }
  
  @override
  Future<dynamic> fetch([int? fetchMode]) async {
    // Implement row fetching
  }
  
  @override
  Future<List<dynamic>> fetchAll([int? fetchMode]) async {
    // Implement fetching all rows
  }
  
  // ... implement other required methods
}
```

## Driver Guidelines

When implementing a PDO driver, follow these guidelines:

1. **Error Handling**
   - Convert driver-specific errors to PDOException
   - Include SQLSTATE codes where applicable
   - Preserve original error information

```dart
try {
  // Driver-specific operation
} catch (e) {
  throw PDOException(
    'Driver error: ${e.message}',
    sqlState: _mapErrorCodeToSqlState(e.code),
    code: e.code,
    errorInfo: {
      'driver_code': e.code,
      'driver_message': e.message,
    },
  );
}
```

2. **Parameter Binding**
   - Support both positional (?) and named (:name) parameters
   - Handle different parameter types appropriately
   - Validate parameter count and types

```dart
String _prepareQuery(String query, Map<String, dynamic> params) {
  // Convert named parameters to driver's format
  return query.replaceAllMapped(
    RegExp(r':([a-zA-Z_][a-zA-Z0-9_]*)'),
    (match) => '\$${params[match[1]]}',
  );
}
```

3. **Result Sets**
   - Implement all fetch modes
   - Provide accurate column metadata
   - Handle large result sets efficiently

```dart
Map<String, dynamic> _getColumnMetadata(int column) {
  final field = _result!.fields[column];
  return {
    'name': field.name,
    'type': _mapFieldType(field.typeId),
    'length': field.length,
    'precision': field.precision,
    'flags': _getColumnFlags(field),
  };
}
```

4. **Transactions**
   - Support nested transactions if possible
   - Ensure proper cleanup on errors
   - Handle auto-commit mode correctly

```dart
@override
bool beginTransaction() {
  if (_inTransaction) {
    if (_supportsNestedTransactions) {
      return _beginSavepoint();
    }
    throw PDOException('Nested transactions not supported');
  }
  // Start transaction
}
```

5. **Resource Management**
   - Close statements when no longer needed
   - Release connections back to pool
   - Clean up temporary resources

```dart
@override
Future<bool> closeCursor() async {
  _result = null;
  _executed = false;
  // Release any driver-specific resources
  return true;
}
```

## Testing Drivers

Each driver should include comprehensive tests:

```dart
void main() {
  group('PDOPostgreSQL', () {
    late PDOPostgreSQL pdo;
    
    setUp(() {
      pdo = PDOPostgreSQL(
        'pgsql:host=localhost;dbname=testdb',
        'test_user',
        'test_pass',
      );
    });
    
    test('connects successfully', () {
      expect(pdo.getAttribute(PDO.ATTR_CONNECTION_STATUS), isNotNull);
    });
    
    test('handles transactions', () async {
      expect(pdo.beginTransaction(), isTrue);
      // Test transaction operations
      expect(pdo.commit(), isTrue);
    });
    
    // ... more tests
  });
}
```

## Driver Configuration

Drivers can support custom attributes through the driver options:

```dart
final pdo = PDOPostgreSQL(
  'pgsql:host=localhost;dbname=testdb',
  'username',
  'password',
  {
    PDO.ATTR_PERSISTENT: true,
    PDO.PGSQL_ATTR_DISABLE_PREPARES: true,
  },
);
```

Document driver-specific options:

- Connection settings
- Performance tuning parameters
- Feature flags
- Security options

## Error Handling

Implement comprehensive error handling:

```dart
class PDOPostgreSQLException implements PDOException {
  @override
  final String message;
  @override
  final String? sqlState;
  @override
  final int? code;
  
  PDOPostgreSQLException(this.message, {this.sqlState, this.code});
  
  static String _mapErrorCodeToSqlState(String errorCode) {
    // Map PostgreSQL error codes to SQLSTATE codes
    switch (errorCode) {
      case '23505': return '23000'; // Unique violation
      case '42P01': return '42S02'; // Table not found
      default: return 'HY000';      // Generic error
    }
  }
}
