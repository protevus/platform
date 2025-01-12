import 'dart:async';

/// Interface for database operations needed by the session driver.
abstract class DatabaseStore {
  /// Gets a query for the given table.
  DatabaseQuery table(String name);
}

/// Interface for database queries.
abstract class DatabaseQuery {
  /// Adds a where clause to the query.
  DatabaseQuery where(String column, dynamic value, [String? operator]);

  /// Gets the first matching record.
  Future<Map<String, dynamic>?> first();

  /// Selects specific columns from the table.
  Future<List<Map<String, dynamic>>> select(List<String> columns);

  /// Inserts or updates a record.
  Future<void> upsert(Map<String, dynamic> values);

  /// Deletes matching records.
  Future<void> delete();
}
