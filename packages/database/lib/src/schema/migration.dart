/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'package:protevus_database/src/persistent_store/persistent_store.dart';
import 'package:protevus_database/src/schema/schema.dart';

/// Thrown when a [Migration] encounters an error.
///
/// This exception is used to indicate that an error occurred during the execution of a database migration.
/// The exception includes a [message] property that provides more information about the error that occurred.
class MigrationException implements Exception {
  /// Creates a new [MigrationException] with the given [message].
  ///
  /// The [message] parameter is a string that describes the error that occurred.
  MigrationException(this.message);

  /// A message describing the error that occurred.
  String message;

  /// Returns a string representation of the [MigrationException] object.
  ///
  /// The string representation includes the [message] property, which provides
  /// a description of the error that occurred during the migration.
  @override
  String toString() => message;
}

/// The base class for migration instructions.
///
/// For each set of changes to a database, a subclass of [Migration] is created.
/// Subclasses will override [upgrade] to make changes to the [Schema] which
/// are translated into database operations to update a database's schema.
abstract class Migration {
  /// The current state of the [Schema].
  ///
  /// During migration, this value will be modified as [SchemaBuilder] operations
  /// are executed. See [SchemaBuilder].
  Schema get currentSchema => database.schema;

  /// The [PersistentStore] that represents the database being migrated.
  PersistentStore? get store => database.store;

  // This value is provided by the 'upgrade' tool and is derived from the filename.
  int? version;

  /// Receiver for database altering operations.
  ///
  /// Methods invoked on this instance - such as [SchemaBuilder.createTable] - will be validated
  /// and generate the appropriate SQL commands to apply to a database to alter its schema.
  late SchemaBuilder database;

  /// Method invoked to upgrade a database to this migration version.
  ///
  /// Subclasses will override this method and invoke methods on [database] to upgrade
  /// the database represented by [store].
  Future upgrade();

  /// Method invoked to downgrade a database from this migration version.
  ///
  /// Subclasses will override this method and invoke methods on [database] to downgrade
  /// the database represented by [store].
  Future downgrade();

  /// Method invoked to seed a database's data after this migration version is upgraded to.
  ///
  /// Subclasses will override this method and invoke query methods on [store] to add data
  /// to a database after this migration version is executed.
  Future seed();

  /// Generates the source code for a database schema upgrade migration.
  ///
  /// This method compares an existing [Schema] with a new [Schema] and generates
  /// the source code for a migration class that can be used to upgrade a database
  /// from the existing schema to the new schema.
  ///
  /// The generated migration class will have an `upgrade()` method that contains
  /// the necessary schema changes, and empty `downgrade()` and `seed()` methods.
  ///
  /// Parameters:
  /// - `existingSchema`: The current schema of the database.
  /// - `newSchema`: The new schema that the database should be upgraded to.
  /// - `version`: The version number of the migration. This is used to name the migration class.
  /// - `changeList`: An optional list of strings that describe the changes being made in this migration.
  ///
  /// Returns:
  /// The source code for the migration class as a string.
  static String sourceForSchemaUpgrade(
    Schema existingSchema,
    Schema newSchema,
    int? version, {
    List<String>? changeList,
  }) {
    final diff = existingSchema.differenceFrom(newSchema);
    final source =
        SchemaBuilder.fromDifference(null, diff, changeList: changeList)
            .commands
            .map((line) => "\t\t$line")
            .join("\n");

    return """
import 'dart:async';
import 'package:protevus_database/prots_database.dart

class Migration$version extends Migration { 
  @override
  Future upgrade() async {
   $source
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    """;
  }
}
