/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/persistent_store/persistent_store.dart';
import 'package:protevus_database/src/schema/schema.dart';

/*
Tests for this class are spread out some. The testing concept used starts by understanding that
that each method invoked on the builder (e.g. createTable, addColumn) adds a statement to [commands].
A statement is either:

a) A Dart statement that replicate the command to build migration code
b) A SQL command when running a migration

In effect, the generated Dart statement is the source code for the invoked method. Each method invoked on a
builder is tested so that the generated Dart code is equivalent
to the invocation. These tests are in generate_code_test.dart.

The code to ensure the generated SQL is accurate is in db/postgresql/schema_generator_sql_mapping_test.dart.

The logic that goes into testing that the commands generated to build a valid schema in an actual postgresql are in db/postgresql/migration_test.dart.
 */

/// Generates SQL or Dart code that modifies a database schema.
class SchemaBuilder {
  /// Creates a new [SchemaBuilder] instance from an existing [Schema].
  ///
  /// If [store] is null, this builder will emit [commands] that are Dart statements that replicate the methods invoked on this object.
  /// Otherwise, [commands] are SQL commands (for the database represented by [store]) that are equivalent to the method invoked on this object.
  SchemaBuilder(this.store, this.inputSchema, {this.isTemporary = false}) {
    schema = Schema.from(inputSchema);
  }

  /// Creates a builder starting from the empty schema.
  ///
  /// If [store] is null, this builder will emit [commands] that are Dart statements that replicate the methods invoked on this object.
  /// Otherwise, [commands] are SQL commands (for the database represented by [store]) that are equivalent to the method invoked on this object.
  ///
  /// The [targetSchema] parameter specifies the desired schema to be built. The [SchemaDifference] between the empty schema and the [targetSchema]
  /// will be used to generate the necessary commands to transform the empty schema into the [targetSchema].
  ///
  /// The [isTemporary] flag determines whether the generated schema changes should create temporary tables.
  ///
  /// The optional [changeList] parameter is a list that will be populated with human-readable descriptions of the schema changes as they are generated.
  SchemaBuilder.toSchema(
    PersistentStore? store,
    Schema targetSchema, {
    bool isTemporary = false,
    List<String>? changeList,
  }) : this.fromDifference(
          store,
          SchemaDifference(Schema.empty(), targetSchema),
          isTemporary: isTemporary,
          changeList: changeList,
        );

  /// Creates a new [SchemaBuilder] instance from the given [SchemaDifference].
  ///
  /// The [SchemaDifference] represents the changes that need to be made to the
  /// input schema to arrive at the target schema. This constructor will generate
  /// the necessary SQL or Dart code commands to apply those changes.
  ///
  /// If [store] is not null, the generated commands will be SQL commands for the
  /// underlying database. If [store] is null, the generated commands will be
  /// Dart expressions that replicate the method calls to build the schema.
  ///
  /// The [isTemporary] flag determines whether the generated schema changes
  /// should create temporary tables.
  ///
  /// The optional [changeList] parameter is a list that will be populated with
  /// human-readable descriptions of the schema changes as they are generated.
  SchemaBuilder.fromDifference(
    this.store,
    SchemaDifference difference, {
    this.isTemporary = false,
    List<String>? changeList,
  }) {
    schema = difference.expectedSchema;
    _generateSchemaCommands(
      difference,
      changeList: changeList,
      temporary: isTemporary,
    );
  }

  /// The starting schema of this builder.
  ///
  /// This property holds the initial schema that the [SchemaBuilder] instance will use as a starting point. As operations are performed on the
  /// builder, the [schema] property will be updated to reflect the resulting schema.
  late Schema inputSchema;

  /// The resulting schema of this builder as operations are applied to it.
  ///
  /// This property holds the final schema that the [SchemaBuilder] instance will generate after applying all the requested operations.
  /// As operations are performed on the builder, the [schema] property will be updated to reflect the resulting schema.
  late Schema schema;

  /// The persistent store to validate and construct operations.
  ///
  /// If this value is not-null, [commands] is a list of SQL commands for the underlying database that change the schema in response to
  /// methods invoked on this object. If this value is null, [commands] is a list Dart statements that replicate the methods invoked on this object.
  PersistentStore? store;

  /// Whether or not this builder should create temporary tables.
  ///
  /// When this flag is set to `true`, the schema commands generated by this builder will create temporary tables
  /// instead of permanent tables. This can be useful for testing or other scenarios where the schema changes are
  /// not intended to be persisted.
  bool isTemporary;

  /// A list of commands generated by operations performed on this builder.
  ///
  /// If [store] is non-null, these commands will be SQL commands that upgrade [inputSchema] to [schema] as determined by [store].
  /// If [store] is null, these commands are ;-terminated Dart expressions that replicate the methods to call on this object to upgrade [inputSchema] to [schema].
  List<String> commands = [];

  /// Validates and adds a table to [schema].
  ///
  /// This method adds the given [table] to the current [schema] and generates the necessary SQL or Dart code
  /// commands to create the table. If [store] is not null, the generated commands will be SQL commands for
  /// the underlying database. If [store] is null, the generated commands will be Dart expressions that
  /// replicate the method calls to build the schema.
  ///
  /// The [isTemporary] flag, which is inherited from the [SchemaBuilder] instance, determines whether the
  /// generated schema changes should create temporary tables.
  void createTable(SchemaTable table) {
    schema.addTable(table);

    if (store != null) {
      commands.addAll(store!.createTable(table, isTemporary: isTemporary));
    } else {
      commands.add(_getNewTableExpression(table));
    }
  }

  /// Validates and renames a table in [schema].
  ///
  /// This method renames the table with the [currentTableName] to the [newName].
  /// If the [currentTableName] does not exist in the [schema], a [SchemaException]
  /// will be thrown.
  ///
  /// If [store] is not null, the generated SQL commands to rename the table
  /// will be added to the [commands] list. If [store] is null, a Dart expression
  /// that replicates the table renaming will be added to the [commands] list.
  void renameTable(String currentTableName, String newName) {
    final table = schema.tableForName(currentTableName);
    if (table == null) {
      throw SchemaException("Table $currentTableName does not exist.");
    }

    schema.renameTable(table, newName);
    if (store != null) {
      commands.addAll(store!.renameTable(table, newName));
    } else {
      commands.add("database.renameTable('$currentTableName', '$newName');");
    }
  }

  /// Validates and deletes a table in [schema].
  ///
  /// This method removes the specified [tableName] from the current [schema] and generates the necessary SQL or Dart code
  /// commands to delete the table. If [store] is not null, the generated commands will be SQL commands for
  /// the underlying database. If [store] is null, the generated commands will be Dart expressions that
  /// replicate the method call to delete the table.
  ///
  /// If the specified [tableName] does not exist in the [schema], a [SchemaException] will be thrown.
  void deleteTable(String tableName) {
    final table = schema.tableForName(tableName);
    if (table == null) {
      throw SchemaException("Table $tableName does not exist.");
    }

    schema.removeTable(table);

    if (store != null) {
      commands.addAll(store!.deleteTable(table));
    } else {
      commands.add('database.deleteTable("$tableName");');
    }
  }

  /// Alters a table in [schema].
  ///
  /// This method allows you to modify the properties of an existing table in the schema.
  /// It takes a [tableName] parameter to identify the table to be modified, and a
  /// [modify] callback function that accepts a [SchemaTable] parameter and allows you
  /// to make changes to the table.
  ///
  /// If the specified [tableName] does not exist in the [schema], a [SchemaException]
  /// will be thrown.
  ///
  /// The changes made to the table through the [modify] callback function will be
  /// reflected in the [schema] and the necessary SQL commands (if [store] is not null)
  /// or Dart expressions (if [store] is null) will be added to the [commands] list.
  ///
  /// Example usage:
  ///
  ///     database.alterTable("users", (t) {
  ///       t.uniqueColumnSet = ["email", "username"];
  ///     });
  void alterTable(
    String tableName,
    void Function(SchemaTable targetTable) modify,
  ) {
    final existingTable = schema.tableForName(tableName);
    if (existingTable == null) {
      throw SchemaException("Table $tableName does not exist.");
    }

    final newTable = SchemaTable.from(existingTable);
    modify(newTable);
    schema.replaceTable(existingTable, newTable);

    final shouldAddUnique = existingTable.uniqueColumnSet == null &&
        newTable.uniqueColumnSet != null;
    final shouldRemoveUnique = existingTable.uniqueColumnSet != null &&
        newTable.uniqueColumnSet == null;

    final innerCommands = <String>[];
    if (shouldAddUnique) {
      if (store != null) {
        commands.addAll(store!.addTableUniqueColumnSet(newTable));
      } else {
        innerCommands.add(
          "t.uniqueColumnSet = [${newTable.uniqueColumnSet!.map((s) => '"$s"').join(',')}]",
        );
      }
    } else if (shouldRemoveUnique) {
      if (store != null) {
        commands.addAll(store!.deleteTableUniqueColumnSet(newTable));
      } else {
        innerCommands.add("t.uniqueColumnSet = null");
      }
    } else {
      final haveSameLength = existingTable.uniqueColumnSet!.length ==
          newTable.uniqueColumnSet!.length;
      final haveSameKeys = existingTable.uniqueColumnSet!
          .every((s) => newTable.uniqueColumnSet!.contains(s));

      if (!haveSameKeys || !haveSameLength) {
        if (store != null) {
          commands.addAll(store!.deleteTableUniqueColumnSet(newTable));
          commands.addAll(store!.addTableUniqueColumnSet(newTable));
        } else {
          innerCommands.add(
            "t.uniqueColumnSet = [${newTable.uniqueColumnSet!.map((s) => '"$s"').join(',')}]",
          );
        }
      }
    }

    if (store == null && innerCommands.isNotEmpty) {
      commands.add(
        'database.alterTable("$tableName", (t) {${innerCommands.join(";")};});',
      );
    }
  }

  /// Validates and adds a column to a table in [schema].
  ///
  /// This method adds the given [column] to the table with the specified [tableName] in the current [schema].
  /// If the specified [tableName] does not exist in the [schema], a [SchemaException] will be thrown.
  ///
  /// If [store] is not null, the necessary SQL commands to add the column will be added to the [commands] list.
  /// If [store] is null, a Dart expression that replicates the call to add the column will be added to the [commands] list.
  ///
  /// The optional [unencodedInitialValue] parameter can be used to specify an initial value for the column when it is
  /// added to a table that already has rows. This is useful when adding a non-nullable column to an existing table.
  void addColumn(
    String tableName,
    SchemaColumn column, {
    String? unencodedInitialValue,
  }) {
    final table = schema.tableForName(tableName);
    if (table == null) {
      throw SchemaException("Table $tableName does not exist.");
    }

    table.addColumn(column);
    if (store != null) {
      commands.addAll(
        store!.addColumn(
          table,
          column,
          unencodedInitialValue: unencodedInitialValue,
        ),
      );
    } else {
      commands.add(
        'database.addColumn("${column.table!.name}", ${_getNewColumnExpression(column)});',
      );
    }
  }

  /// Validates and deletes a column in a table in [schema].
  ///
  /// This method removes the specified [columnName] from the table with the given [tableName] in the current [schema]
  /// and generates the necessary SQL or Dart code commands to delete the column. If [store] is not null, the generated
  /// commands will be SQL commands for the underlying database. If [store] is null, the generated commands will be
  /// Dart expressions that replicate the method call to delete the column.
  ///
  /// If the specified [tableName] does not exist in the [schema], a [SchemaException] will be thrown. If the specified
  /// [columnName] does not exist in the table, a [SchemaException] will also be thrown.
  void deleteColumn(String tableName, String columnName) {
    final table = schema.tableForName(tableName);
    if (table == null) {
      throw SchemaException("Table $tableName does not exist.");
    }

    final column = table.columnForName(columnName);
    if (column == null) {
      throw SchemaException("Column $columnName does not exists.");
    }

    table.removeColumn(column);

    if (store != null) {
      commands.addAll(store!.deleteColumn(table, column));
    } else {
      commands.add('database.deleteColumn("$tableName", "$columnName");');
    }
  }

  /// Validates and renames a column in a table in [schema].
  ///
  /// This method renames the column with the [columnName] to the [newName] in the
  /// table with the specified [tableName]. If the [tableName] does not exist in
  /// the [schema], a [SchemaException] will be thrown. If the [columnName] does
  /// not exist in the table, a [SchemaException] will also be thrown.
  ///
  /// If [store] is not null, the generated SQL commands to rename the column
  /// will be added to the [commands] list. If [store] is null, a Dart expression
  /// that replicates the column renaming will be added to the [commands] list.
  void renameColumn(String tableName, String columnName, String newName) {
    final table = schema.tableForName(tableName);
    if (table == null) {
      throw SchemaException("Table $tableName does not exist.");
    }

    final column = table.columnForName(columnName);
    if (column == null) {
      throw SchemaException("Column $columnName does not exists.");
    }

    table.renameColumn(column, newName);

    if (store != null) {
      commands.addAll(store!.renameColumn(table, column, newName));
    } else {
      commands.add(
        "database.renameColumn('$tableName', '$columnName', '$newName');",
      );
    }
  }

  /// Validates and alters a column in a table in [schema].
  ///
  /// Alterations are made by setting properties of the column passed to [modify]. If the column's nullability
  /// changes from nullable to not nullable,  all previously null values for that column
  /// are set to the value of [unencodedInitialValue].
  ///
  /// Example:
  ///
  ///         database.alterColumn("table", "column", (c) {
  ///           c.isIndexed = true;
  ///           c.isNullable = false;
  ///         }), unencodedInitialValue: "0");
  void alterColumn(
    String tableName,
    String columnName,
    void Function(SchemaColumn targetColumn) modify, {
    String? unencodedInitialValue,
  }) {
    final table = schema.tableForName(tableName);
    if (table == null) {
      throw SchemaException("Table $tableName does not exist.");
    }

    final existingColumn = table[columnName];
    if (existingColumn == null) {
      throw SchemaException("Column $columnName does not exist.");
    }

    final newColumn = SchemaColumn.from(existingColumn);
    modify(newColumn);

    if (existingColumn.type != newColumn.type) {
      throw SchemaException(
        "May not change column type for '${existingColumn.name}' in '$tableName' (${existingColumn.typeString} -> ${newColumn.typeString})",
      );
    }

    if (existingColumn.autoincrement != newColumn.autoincrement) {
      throw SchemaException(
        "May not change column autoincrementing behavior for '${existingColumn.name}' in '$tableName'",
      );
    }

    if (existingColumn.isPrimaryKey != newColumn.isPrimaryKey) {
      throw SchemaException(
        "May not change column primary key status for '${existingColumn.name}' in '$tableName'",
      );
    }

    if (existingColumn.relatedTableName != newColumn.relatedTableName) {
      throw SchemaException(
        "May not change reference table for foreign key column '${existingColumn.name}' in '$tableName' (${existingColumn.relatedTableName} -> ${newColumn.relatedTableName})",
      );
    }

    if (existingColumn.relatedColumnName != newColumn.relatedColumnName) {
      throw SchemaException(
        "May not change reference column for foreign key column '${existingColumn.name}' in '$tableName' (${existingColumn.relatedColumnName} -> ${newColumn.relatedColumnName})",
      );
    }

    if (existingColumn.name != newColumn.name) {
      renameColumn(tableName, existingColumn.name, newColumn.name);
    }

    table.replaceColumn(existingColumn, newColumn);

    final innerCommands = <String>[];
    if (existingColumn.isIndexed != newColumn.isIndexed) {
      if (store != null) {
        if (newColumn.isIndexed!) {
          commands.addAll(store!.addIndexToColumn(table, newColumn));
        } else {
          commands.addAll(store!.deleteIndexFromColumn(table, newColumn));
        }
      } else {
        innerCommands.add("c.isIndexed = ${newColumn.isIndexed}");
      }
    }

    if (existingColumn.isUnique != newColumn.isUnique) {
      if (store != null) {
        commands.addAll(store!.alterColumnUniqueness(table, newColumn));
      } else {
        innerCommands.add('c.isUnique = ${newColumn.isUnique}');
      }
    }

    if (existingColumn.defaultValue != newColumn.defaultValue) {
      if (store != null) {
        commands.addAll(store!.alterColumnDefaultValue(table, newColumn));
      } else {
        final value = newColumn.defaultValue == null
            ? 'null'
            : '"${newColumn.defaultValue}"';
        innerCommands.add('c.defaultValue = $value');
      }
    }

    if (existingColumn.isNullable != newColumn.isNullable) {
      if (store != null) {
        commands.addAll(
          store!
              .alterColumnNullability(table, newColumn, unencodedInitialValue),
        );
      } else {
        innerCommands.add('c.isNullable = ${newColumn.isNullable}');
      }
    }

    if (existingColumn.deleteRule != newColumn.deleteRule) {
      if (store != null) {
        commands.addAll(store!.alterColumnDeleteRule(table, newColumn));
      } else {
        innerCommands.add('c.deleteRule = ${newColumn.deleteRule}');
      }
    }

    if (store == null && innerCommands.isNotEmpty) {
      commands.add(
        'database.alterColumn("$tableName", "$columnName", (c) {${innerCommands.join(";")};});',
      );
    }
  }

  /// Generates the necessary schema commands to apply the given [SchemaDifference].
  ///
  /// This method is responsible for generating the SQL or Dart code commands
  /// required to transform the input schema into the target schema represented
  /// by the [SchemaDifference].
  ///
  /// The generated commands are added to the [commands] list of this [SchemaBuilder]
  /// instance. If [store] is not null, the commands will be SQL commands for the
  /// underlying database. If [store] is null, the commands will be Dart expressions
  /// that replicate the method calls to build the schema.
  ///
  /// The [changeList] parameter is an optional list that will be populated with
  /// human-readable descriptions of the schema changes as they are generated.
  ///
  /// The [temporary] flag determines whether the generated schema changes should
  /// create temporary tables instead of permanent tables.
  void _generateSchemaCommands(
    SchemaDifference difference, {
    List<String>? changeList,
    bool temporary = false,
  }) {
    /// This code handles the case where a table being added to the schema
    /// has a foreign key constraint. To avoid issues with the foreign key
    /// constraint during the initial table creation, the foreign key
    /// information is extracted and deferred until after all tables have
    /// been created. This is done by creating a list of `SchemaTableDifference`
    /// objects, which represent the differences between the actual and expected
    /// tables, including the foreign key information. These differences are
    /// then processed separately after the initial table creation.
    final fkDifferences = <SchemaTableDifference>[];

    /// Handles the case where a table being added to the schema has a foreign key constraint.
    ///
    /// To avoid issues with the foreign key constraint during the initial table creation, the foreign key
    /// information is extracted and deferred until after all tables have been created. This is done by
    /// creating a list of `SchemaTableDifference` objects, which represent the differences between the
    /// actual and expected tables, including the foreign key information. These differences are then
    /// processed separately after the initial table creation.
    for (final t in difference.tablesToAdd) {
      final copy = SchemaTable.from(t!);
      if (copy.hasForeignKeyInUniqueSet) {
        copy.uniqueColumnSet = null;
      }
      copy.columns.where((c) => c.isForeignKey).forEach(copy.removeColumn);

      changeList?.add("Adding table '${copy.name}'");
      createTable(copy);

      fkDifferences.add(SchemaTableDifference(copy, t));
    }

    /// Generates the necessary schema commands for the foreign key constraints in the given [SchemaDifference].
    ///
    /// This method is called after all tables have been created to handle the case where a table being added to the schema
    /// has a foreign key constraint. The foreign key information is extracted and deferred until after the initial table
    /// creation to avoid issues with the foreign key constraint during the initial table creation process.
    ///
    /// The [fkDifferences] list contains `SchemaTableDifference` objects, which represent the differences between the
    /// actual and expected tables, including the foreign key information. These differences are processed separately
    /// after the initial table creation.
    ///
    /// The [changeList] parameter is an optional list that will be populated with human-readable descriptions of the
    /// schema changes as they are generated.
    for (final td in fkDifferences) {
      _generateTableCommands(td, changeList: changeList);
    }

    /// Deletes the tables specified in the [difference.tablesToDelete] list.
    ///
    /// For each table in the [difference.tablesToDelete] list, this method:
    /// 1. Adds a human-readable description of the table deletion to the [changeList] (if provided).
    /// 2. Calls the [deleteTable] method to delete the table from the schema.
    for (final t in difference.tablesToDelete) {
      changeList?.add("Deleting table '${t!.name}'");
      deleteTable(t!.name!);
    }

    /// Generates the necessary schema commands for the tables specified in the given [SchemaDifference].
    ///
    /// This method is responsible for generating the SQL or Dart code commands required to modify the
    /// tables in the input schema according to the changes specified in the [SchemaDifference].
    ///
    /// The generated commands are added to the [commands] list of the [SchemaBuilder] instance. If [store]
    /// is not null, the commands will be SQL commands for the underlying database. If [store] is null,
    /// the commands will be Dart expressions that replicate the method calls to build the schema.
    ///
    /// The [changeList] parameter is an optional list that will be populated with human-readable
    /// descriptions of the schema changes as they are generated.
    for (final t in difference.tablesToModify) {
      _generateTableCommands(t, changeList: changeList);
    }
  }

  /// Generates the necessary schema commands for the tables specified in the given [SchemaDifference].
  ///
  /// This method is responsible for generating the SQL or Dart code commands required to modify the
  /// tables in the input schema according to the changes specified in the [SchemaDifference].
  ///
  /// The generated commands are added to the [commands] list of the [SchemaBuilder] instance. If [store]
  /// is not null, the commands will be SQL commands for the underlying database. If [store] is null,
  /// the commands will be Dart expressions that replicate the method calls to build the schema.
  ///
  /// The [changeList] parameter is an optional list that will be populated with human-readable
  /// descriptions of the schema changes as they are generated.
  void _generateTableCommands(
    SchemaTableDifference difference, {
    List<String>? changeList,
  }) {
    for (final c in difference.columnsToAdd) {
      changeList?.add(
        "Adding column '${c!.name}' to table '${difference.actualTable!.name}'",
      );
      addColumn(difference.actualTable!.name!, c!);

      if (!c.isNullable! && c.defaultValue == null) {
        changeList?.add(
            "WARNING: This migration may fail if table '${difference.actualTable!.name}' already has rows. "
            "Add an 'unencodedInitialValue' to the statement 'database.addColumn(\"${difference.actualTable!.name}\", "
            "SchemaColumn(\"${c.name}\", ...)'.");
      }
    }

    for (final c in difference.columnsToRemove) {
      changeList?.add(
        "Deleting column '${c!.name}' from table '${difference.actualTable!.name}'",
      );
      deleteColumn(difference.actualTable!.name!, c!.name);
    }

    for (final columnDiff in difference.columnsToModify) {
      changeList?.add(
        "Modifying column '${columnDiff.actualColumn!.name}' in '${difference.actualTable!.name}'",
      );
      alterColumn(difference.actualTable!.name!, columnDiff.actualColumn!.name,
          (c) {
        c.isIndexed = columnDiff.actualColumn!.isIndexed;
        c.defaultValue = columnDiff.actualColumn!.defaultValue;
        c.isUnique = columnDiff.actualColumn!.isUnique;
        c.isNullable = columnDiff.actualColumn!.isNullable;
        c.deleteRule = columnDiff.actualColumn!.deleteRule;
      });

      if (columnDiff.expectedColumn!.isNullable! &&
          !columnDiff.actualColumn!.isNullable! &&
          columnDiff.actualColumn!.defaultValue == null) {
        changeList?.add(
            "WARNING: This migration may fail if table '${difference.actualTable!.name}' already has rows. "
            "Add an 'unencodedInitialValue' to the statement 'database.addColumn(\"${difference.actualTable!.name}\", "
            "SchemaColumn(\"${columnDiff.actualColumn!.name}\", ...)'.");
      }
    }

    if (difference.uniqueSetDifference?.hasDifferences ?? false) {
      changeList?.add(
        "Setting unique column constraint of '${difference.actualTable!.name}' to ${difference.uniqueSetDifference!.actualColumnNames}.",
      );
      alterTable(difference.actualTable!.name!, (t) {
        if (difference.uniqueSetDifference!.actualColumnNames.isEmpty) {
          t.uniqueColumnSet = null;
        } else {
          t.uniqueColumnSet = difference.uniqueSetDifference!.actualColumnNames;
        }
      });
    }
  }

  /// Generates a Dart expression that creates a new [SchemaTable] instance with the specified columns and unique column set.
  ///
  /// This method is used by the [SchemaBuilder] class to generate Dart code that replicates the operations performed on the builder.
  ///
  /// The generated Dart expression will create a new [SchemaTable] instance with the specified table name and columns. If the table
  /// has a unique column set, the expression will also include the unique column set names.
  ///
  /// The [table] parameter is the [SchemaTable] instance for which the Dart expression should be generated.
  ///
  /// Returns the generated Dart expression as a [String].
  static String _getNewTableExpression(SchemaTable table) {
    final builder = StringBuffer();
    builder.write('database.createTable(SchemaTable("${table.name}", [');
    builder.write(table.columns.map(_getNewColumnExpression).join(","));
    builder.write("]");

    if (table.uniqueColumnSet != null) {
      final set = table.uniqueColumnSet!.map((p) => '"$p"').join(",");
      builder.write(", uniqueColumnSetNames: [$set]");
    }

    builder.write('));');
    return builder.toString();
  }

  /// Generates a Dart expression that creates a new [SchemaColumn] instance with the specified properties.
  ///
  /// This method is used by the [SchemaBuilder] class to generate Dart code that replicates the operations performed
  /// on the builder.
  ///
  /// The generated Dart expression will create a new [SchemaColumn] instance with the specified name, type, and other
  /// properties. If the column is a foreign key, the expression will include the related table name, related column
  /// name, and delete rule.
  ///
  /// The [column] parameter is the [SchemaColumn] instance for which the Dart expression should be generated.
  ///
  /// Returns the generated Dart expression as a [String].
  static String _getNewColumnExpression(SchemaColumn column) {
    final builder = StringBuffer();
    if (column.relatedTableName != null) {
      builder
          .write('SchemaColumn.relationship("${column.name}", ${column.type}');
      builder.write(', relatedTableName: "${column.relatedTableName}"');
      builder.write(', relatedColumnName: "${column.relatedColumnName}"');
      builder.write(", rule: ${column.deleteRule}");
    } else {
      builder.write('SchemaColumn("${column.name}", ${column.type}');
      if (column.isPrimaryKey!) {
        builder.write(", isPrimaryKey: true");
      } else {
        builder.write(", isPrimaryKey: false");
      }
      if (column.autoincrement!) {
        builder.write(", autoincrement: true");
      } else {
        builder.write(", autoincrement: false");
      }
      if (column.defaultValue != null) {
        builder.write(', defaultValue: "${column.defaultValue}"');
      }
      if (column.isIndexed!) {
        builder.write(", isIndexed: true");
      } else {
        builder.write(", isIndexed: false");
      }
    }

    if (column.isNullable!) {
      builder.write(", isNullable: true");
    } else {
      builder.write(", isNullable: false");
    }
    if (column.isUnique!) {
      builder.write(", isUnique: true");
    } else {
      builder.write(", isUnique: false");
    }

    builder.write(")");
    return builder.toString();
  }
}
