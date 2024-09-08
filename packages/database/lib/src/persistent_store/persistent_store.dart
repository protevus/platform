/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'package:protevus_database/src/managed/context.dart';
import 'package:protevus_database/src/managed/entity.dart';
import 'package:protevus_database/src/managed/object.dart';
import 'package:protevus_database/src/query/query.dart';
import 'package:protevus_database/src/schema/schema.dart';

/// Specifies the return type for a persistent store query.
///
/// - [rowCount]: Indicates that the query should return the number of rows affected.
/// - [rows]: Indicates that the query should return the result set as a list of rows.
enum PersistentStoreQueryReturnType { rowCount, rows }

/// Specifies the return type for a persistent store query.
///
/// You rarely need to use this class directly. See [Query] for how to interact with instances of this class.
/// Implementors of this class serve as the bridge between [Query]s and a specific database.
abstract class PersistentStore {
  /// Creates a new database-specific [Query].
  ///
  /// This method creates a new instance of a [Query] subclass that is specific to the
  /// database implementation represented by this [PersistentStore]. The returned
  /// [Query] instance will be capable of interacting with the database in the appropriate
  /// way.
  ///
  /// The [context] parameter specifies the [ManagedContext] that the [Query] will be
  /// associated with. The [entity] parameter specifies the [ManagedEntity] that the
  /// [Query] will operate on. Optionally, [values] can be provided which will be
  /// used to initialize the [Query].
  ///
  /// Subclasses must override this method to provide a concrete implementation of [Query]
  /// specific to this type of [PersistentStore]. The objects returned from this method
  /// must implement [Query] and should mixin [QueryMixin] to inherit the majority of
  /// the behavior provided by a query.
  Query<T> newQuery<T extends ManagedObject>(
    ManagedContext context,
    ManagedEntity entity, {
    T? values,
  });

  /// Executes an arbitrary SQL command on the database.
  ///
  /// This method allows you to execute any SQL command on the database managed by
  /// this [PersistentStore] instance. The [sql] parameter should contain the SQL
  /// statement to be executed, and the optional [substitutionValues] parameter
  /// can be used to provide values to be substituted into the SQL statement, similar
  /// to how a prepared statement works.
  ///
  /// The return value of this method is a [Future] that completes when the SQL
  /// command has finished executing. The return value of the [Future] depends on
  /// the type of SQL statement being executed, but it is typically `null` for
  /// non-SELECT statements, or a value representing the result of the SQL statement.
  ///
  /// This method is intended for advanced use cases where the higher-level query
  /// APIs provided by the [Query] class are not sufficient. In general, it is
  /// recommended to use the [Query] class instead of calling [execute] directly,
  /// as the [Query] class provides a more type-safe and database-agnostic interface
  /// for interacting with the database.
  Future execute(String sql, {Map<String, dynamic>? substitutionValues});

  /// Executes a database query with the provided parameters.
  ///
  /// This method allows you to execute a database query using a format string and a map of values.
  ///
  /// The `formatString` parameter is a SQL string that can contain placeholders for values, which will be
  /// replaced with the values from the `values` parameter.
  ///
  /// The `values` parameter is a map of key-value pairs, where the keys correspond to the placeholders
  /// in the `formatString`, and the values are the actual values to be substituted.
  ///
  /// The `timeoutInSeconds` parameter specifies the maximum time, in seconds, that the query is allowed to
  /// run before being cancelled.
  ///
  /// The optional `returnType` parameter specifies the type of return value expected from the query. If
  /// `PersistentStoreQueryReturnType.rowCount` is specified, the method will return the number of rows
  /// affected by the query. If `PersistentStoreQueryReturnType.rows` is specified, the method will return
  /// the result set as a list of rows.
  ///
  /// The return value of this method is a `Future` that completes when the query has finished executing.
  /// The type of the value returned by the `Future` depends on the `returnType` parameter.
  Future<dynamic> executeQuery(
    String formatString,
    Map<String, dynamic> values,
    int timeoutInSeconds, {
    PersistentStoreQueryReturnType? returnType,
  });

  /// Executes a database transaction.
  ///
  /// This method allows you to execute a sequence of database operations as a single
  /// atomic transaction. If any of the operations in the transaction fail, the entire
  /// transaction is rolled back, ensuring data consistency.
  ///
  /// The `transactionContext` parameter is the `ManagedContext` in which the transaction
  /// will be executed. This context must be separate from any existing `ManagedContext`
  /// instances, as transactions require their own isolated context.
  ///
  /// The `transactionBlock` parameter is a callback function that contains the database
  /// operations to be executed as part of the transaction. This function takes the
  /// `transactionContext` as its argument and returns a `Future<T>` that represents the
  /// result of the transaction.
  ///
  /// The return value of this method is a `Future<T>` that completes when the transaction
  /// has finished executing. The value returned by the `Future` is the same as the value
  /// returned by the `transactionBlock` callback.
  ///
  /// Example usage:
  /// ```dart
  /// final result = await persistentStore.transaction(
  ///   transactionContext,
  ///   (context) async {
  ///     final user = await User(name: 'John Doe').insert(context);
  ///     final account = await Account(userId: user.id, balance: 100.0).insert(context);
  ///     return account;
  ///   },
  /// );
  /// ```
  Future<T> transaction<T>(
    ManagedContext transactionContext,
    Future<T> Function(ManagedContext transaction) transactionBlock,
  );

  /// Closes the underlying database connection.
  ///
  /// This method is used to close the database connection managed by this
  /// `PersistentStore` instance. Calling this method will ensure that all
  /// resources associated with the database connection are properly released,
  /// and that the connection is no longer available for use.
  ///
  /// The return value of this method is a `Future` that completes when the
  /// database connection has been successfully closed. If there is an error
  /// closing the connection, the `Future` will complete with an error.
  Future close();

  // -- Schema Ops --

  /// Creates a list of SQL statements to create a new database table.
  ///
  /// This method generates the necessary SQL statements to create a new database table
  /// based on the provided [SchemaTable] object. The table can be created as a
  /// temporary table if the `isTemporary` parameter is set to `true`.
  ///
  /// The returned list of strings represents the SQL statements that should be executed
  /// to create the new table. The caller of this method is responsible for executing
  /// these statements to create the table in the database.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object that defines the structure of the new table.
  /// - `isTemporary`: A boolean indicating whether the table should be created as a
  ///   temporary table. Temporary tables are only visible within the current session
  ///   and are automatically dropped when the session ends. Defaults to `false`.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to create the new table.
  List<String> createTable(SchemaTable table, {bool isTemporary = false});

  /// Generates a list of SQL statements to rename a database table.
  ///
  /// This method generates the necessary SQL statements to rename an existing database table.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table to be renamed.
  /// - `name`: The new name for the table.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to rename the table.
  List<String> renameTable(SchemaTable table, String name);

  /// Generates a list of SQL statements to delete a database table.
  ///
  /// This method generates the necessary SQL statements to delete an existing database table.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table to be deleted.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to delete the table.
  List<String> deleteTable(SchemaTable table);

  /// Generates a list of SQL statements to create a unique column set for a database table.
  ///
  /// This method generates the necessary SQL statements to create a unique column set
  /// for an existing database table. A unique column set is a set of one or more columns
  /// that must have unique values for each row in the table.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table for which the unique column
  ///   set should be created.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to create the unique column set.
  List<String> addTableUniqueColumnSet(SchemaTable table);

  /// Generates a list of SQL statements to delete a unique column set for a database table.
  ///
  /// This method generates the necessary SQL statements to delete an existing unique column set
  /// for a database table. A unique column set is a set of one or more columns
  /// that must have unique values for each row in the table.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table for which the unique column
  ///   set should be deleted.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to delete the unique column set.
  List<String> deleteTableUniqueColumnSet(SchemaTable table);

  /// Generates a list of SQL statements to add a new column to a database table.
  ///
  /// This method generates the necessary SQL statements to add a new column to an existing
  /// database table. The new column is defined by the provided [SchemaColumn] object.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table to which the new column should be added.
  /// - `column`: The [SchemaColumn] object that defines the new column to be added.
  /// - `unencodedInitialValue`: An optional string that specifies an initial value for the new column.
  ///   This value will be used as the default value for the column unless the column has a specific
  ///   default value defined in the [SchemaColumn] object.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be executed
  /// to add the new column to the table.
  List<String> addColumn(
    SchemaTable table,
    SchemaColumn column, {
    String? unencodedInitialValue,
  });

  /// Generates a list of SQL statements to delete a column from a database table.
  ///
  /// This method generates the necessary SQL statements to delete an existing column from
  /// a database table. The column to be deleted is specified by the provided [SchemaTable]
  /// and [SchemaColumn] objects.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table from which the column
  ///   should be deleted.
  /// - `column`: The [SchemaColumn] object representing the column to be deleted.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to delete the specified column from the table.
  List<String> deleteColumn(SchemaTable table, SchemaColumn column);

  /// Generates a list of SQL statements to rename a column in a database table.
  ///
  /// This method generates the necessary SQL statements to rename an existing column
  /// in a database table.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table containing the column
  ///   to be renamed.
  /// - `column`: The [SchemaColumn] object representing the column to be renamed.
  /// - `name`: The new name for the column.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to rename the column.
  List<String> renameColumn(
    SchemaTable table,
    SchemaColumn column,
    String name,
  );

  /// Generates a list of SQL statements to alter the nullability of a column in a database table.
  ///
  /// This method generates the necessary SQL statements to change the nullability of an existing
  /// column in a database table. The new nullability setting is specified by the `nullable` parameter
  /// of the provided [SchemaColumn] object.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table containing the column to be altered.
  /// - `column`: The [SchemaColumn] object representing the column to be altered.
  /// - `unencodedInitialValue`: An optional string that specifies an initial value for the column
  ///   if it is being changed from nullable to non-nullable. This value will be used to populate
  ///   any existing rows that have a null value in the column.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be executed
  /// to alter the nullability of the column.
  List<String> alterColumnNullability(
    SchemaTable table,
    SchemaColumn column,
    String? unencodedInitialValue,
  );

  /// Generates a list of SQL statements to alter the uniqueness of a column in a database table.
  ///
  /// This method generates the necessary SQL statements to change the uniqueness of an existing
  /// column in a database table. The new uniqueness setting is specified by the `unique` property
  /// of the provided [SchemaColumn] object.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table containing the column to be altered.
  /// - `column`: The [SchemaColumn] object representing the column to be altered.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be executed
  /// to alter the uniqueness of the column.
  List<String> alterColumnUniqueness(SchemaTable table, SchemaColumn column);

  /// Generates a list of SQL statements to alter the default value of a column in a database table.
  ///
  /// This method generates the necessary SQL statements to change the default value of an existing
  /// column in a database table. The new default value is specified by the `defaultValue` property
  /// of the provided [SchemaColumn] object.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table containing the column to be altered.
  /// - `column`: The [SchemaColumn] object representing the column to be altered.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be executed
  /// to alter the default value of the column.
  List<String> alterColumnDefaultValue(SchemaTable table, SchemaColumn column);

  /// Generates a list of SQL statements to alter the delete rule of a column in a database table.
  ///
  /// This method generates the necessary SQL statements to change the delete rule of an existing
  /// column in a database table. The delete rule determines what happens to the data in the
  /// column when a row is deleted from the table.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table containing the column to be altered.
  /// - `column`: The [SchemaColumn] object representing the column to be altered.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be executed
  /// to alter the delete rule of the column.
  List<String> alterColumnDeleteRule(SchemaTable table, SchemaColumn column);

  /// Generates a list of SQL statements to add a new index to a column in a database table.
  ///
  /// This method generates the necessary SQL statements to add a new index to an existing
  /// column in a database table. The index is defined by the provided [SchemaTable] and
  /// [SchemaColumn] objects.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table to which the new index
  ///   should be added.
  /// - `column`: The [SchemaColumn] object representing the column on which the new
  ///   index should be created.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to add the new index to the table.
  List<String> addIndexToColumn(SchemaTable table, SchemaColumn column);

  /// Generates a list of SQL statements to rename an index on a column in a database table.
  ///
  /// This method generates the necessary SQL statements to rename an existing index on a
  /// column in a database table.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table containing the index
  ///   to be renamed.
  /// - `column`: The [SchemaColumn] object representing the column on which the index
  ///   is defined.
  /// - `newIndexName`: The new name for the index.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to rename the index.
  List<String> renameIndex(
    SchemaTable table,
    SchemaColumn column,
    String newIndexName,
  );

  /// Generates a list of SQL statements to delete an index from a column in a database table.
  ///
  /// This method generates the necessary SQL statements to delete an existing index
  /// from a column in a database table.
  ///
  /// Parameters:
  /// - `table`: The [SchemaTable] object representing the table from which the index
  ///   should be deleted.
  /// - `column`: The [SchemaColumn] object representing the column on which the index
  ///   is defined.
  ///
  /// Returns:
  /// A list of strings, where each string represents a SQL statement that should be
  /// executed to delete the index from the table.
  List<String> deleteIndexFromColumn(SchemaTable table, SchemaColumn column);

  /// Returns the current version of the database schema.
  ///
  /// This property returns the current version of the database schema managed by the
  /// `PersistentStore` instance. The schema version is typically used to track the
  /// state of the database and ensure that migrations are applied correctly when the
  /// application is upgraded.
  ///
  /// The returned value is a `Future<int>` that resolves to the current schema version.
  /// This method should be implemented by the concrete `PersistentStore` subclass to
  /// provide the appropriate implementation for the underlying database system.
  Future<int> get schemaVersion;

  /// Upgrades the database schema to a new version.
  ///
  /// This method applies a series of database migrations to upgrade the schema from the
  /// specified `fromSchema` version to a new version.
  ///
  /// Parameters:
  /// - `fromSchema`: The current schema version of the database.
  /// - `withMigrations`: A list of [Migration] instances that should be applied to upgrade
  ///   the schema to the new version.
  /// - `temporary`: If `true`, the schema upgrade will be performed on a temporary table
  ///   instead of the main database table. This can be useful for testing or other
  ///   advanced use cases.
  ///
  /// Returns:
  /// A `Future<Schema>` that completes with the new schema version after the migrations
  /// have been successfully applied.
  Future<Schema> upgrade(
    Schema fromSchema,
    List<Migration> withMigrations, {
    bool temporary = false,
  });
}
