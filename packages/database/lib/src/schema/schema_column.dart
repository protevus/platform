/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/schema/schema.dart';

/// A portable representation of a database column.
///
/// Instances of this type contain the database-only details of a [ManagedPropertyDescription].
class SchemaColumn {
  /// Creates a new instance of [SchemaColumn] with the specified properties.
  ///
  /// The [name] parameter is the name of the column.
  /// The [type] parameter is the [ManagedPropertyType] of the column.
  /// The [isIndexed] parameter specifies whether the column should be indexed.
  /// The [isNullable] parameter specifies whether the column can be null.
  /// The [autoincrement] parameter specifies whether the column should be auto-incremented.
  /// The [isUnique] parameter specifies whether the column should be unique.
  /// The [defaultValue] parameter specifies the default value of the column.
  /// The [isPrimaryKey] parameter specifies whether the column should be the primary key.
  SchemaColumn(
    this.name,
    ManagedPropertyType type, {
    this.isIndexed = false,
    this.isNullable = false,
    this.autoincrement = false,
    this.isUnique = false,
    this.defaultValue,
    this.isPrimaryKey = false,
  }) {
    _type = typeStringForType(type);
  }

  /// A convenience constructor for properties that represent foreign key relationships.
  ///
  /// This constructor creates a [SchemaColumn] instance with the specified properties for a foreign key relationship.
  ///
  /// The [name] parameter is the name of the column.
  /// The [type] parameter is the [ManagedPropertyType] of the column.
  /// The [isNullable] parameter specifies whether the column can be null.
  /// The [isUnique] parameter specifies whether the column should be unique.
  /// The [relatedTableName] parameter specifies the name of the related table.
  /// The [relatedColumnName] parameter specifies the name of the related column.
  /// The [rule] parameter specifies the [DeleteRule] for the foreign key constraint.
  SchemaColumn.relationship(
    this.name,
    ManagedPropertyType type, {
    this.isNullable = true,
    this.isUnique = false,
    this.relatedTableName,
    this.relatedColumnName,
    DeleteRule rule = DeleteRule.nullify,
  }) {
    isIndexed = true;
    _type = typeStringForType(type);
    _deleteRule = deleteRuleStringForDeleteRule(rule);
  }

  /// Creates a new [SchemaColumn] instance that mirrors the properties of the provided [ManagedPropertyDescription].
  ///
  /// This constructor is used to create a [SchemaColumn] instance that represents the same database column as the
  /// provided [ManagedPropertyDescription]. The properties of the [SchemaColumn] instance are set based on the
  /// properties of the [ManagedPropertyDescription].
  ///
  /// If the [ManagedPropertyDescription] is a [ManagedRelationshipDescription], the [SchemaColumn] instance
  /// will be set up as a foreign key column with the appropriate related table and column names, as well as the
  /// delete rule. If the [ManagedPropertyDescription] is a [ManagedAttributeDescription], the [SchemaColumn] instance
  /// will be set up with the appropriate type, nullability, autoincrement, uniqueness, and indexing properties, as well
  /// as the default value if it exists.
  ///
  /// @param desc The [ManagedPropertyDescription] to mirror.
  SchemaColumn.fromProperty(ManagedPropertyDescription desc) {
    name = desc.name;

    if (desc is ManagedRelationshipDescription) {
      isPrimaryKey = false;
      relatedTableName = desc.destinationEntity.tableName;
      relatedColumnName = desc.destinationEntity.primaryKey;
      if (desc.deleteRule != null) {
        _deleteRule = deleteRuleStringForDeleteRule(desc.deleteRule!);
      }
    } else if (desc is ManagedAttributeDescription) {
      defaultValue = desc.defaultValue;
      isPrimaryKey = desc.isPrimaryKey;
    }

    _type = typeStringForType(desc.type!.kind);
    isNullable = desc.isNullable;
    autoincrement = desc.autoincrement;
    isUnique = desc.isUnique;
    isIndexed = desc.isIndexed;
  }

  /// Creates a new instance of [SchemaColumn] that is a copy of [otherColumn].
  ///
  /// This constructor creates a new [SchemaColumn] instance with the same properties as the provided [otherColumn].
  /// The new instance will have the same name, type, indexing, nullability, autoincrement, uniqueness, default value,
  /// primary key status, related table name, related column name, and delete rule as the [otherColumn].
  SchemaColumn.from(SchemaColumn otherColumn) {
    name = otherColumn.name;
    _type = otherColumn._type;
    isIndexed = otherColumn.isIndexed;
    isNullable = otherColumn.isNullable;
    autoincrement = otherColumn.autoincrement;
    isUnique = otherColumn.isUnique;
    defaultValue = otherColumn.defaultValue;
    isPrimaryKey = otherColumn.isPrimaryKey;
    relatedTableName = otherColumn.relatedTableName;
    relatedColumnName = otherColumn.relatedColumnName;
    _deleteRule = otherColumn._deleteRule;
  }

  /// Creates an instance of [SchemaColumn] from the provided [map].
  ///
  /// Where [map] is typically created by [asMap].
  SchemaColumn.fromMap(Map<String, dynamic> map) {
    name = map["name"] as String;
    _type = map["type"] as String?;
    isIndexed = map["indexed"] as bool?;
    isNullable = map["nullable"] as bool?;
    autoincrement = map["autoincrement"] as bool?;
    isUnique = map["unique"] as bool?;
    defaultValue = map["defaultValue"] as String?;
    isPrimaryKey = map["primaryKey"] as bool?;
    relatedTableName = map["relatedTableName"] as String?;
    relatedColumnName = map["relatedColumnName"] as String?;
    _deleteRule = map["deleteRule"] as String?;
  }

  /// Creates a new, empty instance of [SchemaColumn].
  ///
  /// This constructor creates a new [SchemaColumn] instance with all properties set to their default values.
  ///
  /// The new instance will have no name, no type, no indexing, be nullable, not be autoincremented, not be unique,
  /// have no default value, not be a primary key, have no related table or column names, and no delete rule.
  SchemaColumn.empty();

  /// The name of this column.
  late String name;

  /// The [SchemaTable] this column belongs to.
  ///
  /// This property indicates the [SchemaTable] that the [SchemaColumn] instance is associated with.
  /// If the [SchemaColumn] is not assigned to a specific table, this property will be `null`.
  SchemaTable? table;

  /// The [String] representation of this column's type.
  String? get typeString => _type;

  /// The type of this column in a [ManagedDataModel].
  ManagedPropertyType? get type => typeFromTypeString(_type);

  set type(ManagedPropertyType? t) {
    _type = typeStringForType(t);
  }

  /// Whether or not this column is indexed.
  bool? isIndexed = false;

  /// Whether or not this column is nullable.
  bool? isNullable = false;

  /// Whether or not this column is autoincremented.
  bool? autoincrement = false;

  /// Whether or not this column is unique.
  bool? isUnique = false;

  /// The default value for this column when inserted into a database.
  String? defaultValue;

  /// Whether or not this column is the primary key of its [table].
  bool? isPrimaryKey = false;

  /// The related table name if this column is a foreign key column.
  ///
  /// If this column has a foreign key constraint, this property is the name
  /// of the referenced table.
  ///
  /// Null if this column is not a foreign key reference.
  String? relatedTableName;

  /// The related column if this column is a foreign key column.
  ///
  /// If this column has a foreign key constraint, this property is the name
  /// of the reference column in [relatedTableName].
  String? relatedColumnName;

  /// The delete rule for this column if it is a foreign key column.
  ///
  /// Undefined if not a foreign key column.
  DeleteRule? get deleteRule =>
      _deleteRule == null ? null : deleteRuleForDeleteRuleString(_deleteRule);

  set deleteRule(DeleteRule? t) {
    if (t == null) {
      _deleteRule = null;
    } else {
      _deleteRule = deleteRuleStringForDeleteRule(t);
    }
  }

  /// Whether or not this column is a foreign key column.
  ///
  /// This property returns `true` if the [relatedTableName] and [relatedColumnName] properties are not `null`,
  /// indicating that this column represents a foreign key relationship. Otherwise, it returns `false`.
  bool get isForeignKey {
    return relatedTableName != null && relatedColumnName != null;
  }

  /// The type of this column as a string.
  String? _type;

  /// The delete rule for this column if it is a foreign key column.
  ///
  /// Undefined if not a foreign key column.
  String? _deleteRule;

  /// Compares the current [SchemaColumn] instance with the provided [column] and returns a [SchemaColumnDifference] object
  /// that represents the differences between the two columns.
  ///
  /// This method is used to determine the differences between the expected and actual database schema when performing
  /// schema validation or database migrations. The returned [SchemaColumnDifference] object contains information about
  /// any differences in the properties of the two columns, such as name, type, nullability, indexing, uniqueness,
  /// default value, and delete rule.
  ///
  /// @param column The [SchemaColumn] instance to compare with the current instance.
  /// @return A [SchemaColumnDifference] object that represents the differences between the two columns.
  SchemaColumnDifference differenceFrom(SchemaColumn column) {
    return SchemaColumnDifference(this, column);
  }

  /// Returns the string representation of the provided [ManagedPropertyType].
  ///
  /// This method takes a [ManagedPropertyType] instance and returns the corresponding string representation of the
  /// property type. The mapping between the [ManagedPropertyType] and its string representation is as follows:
  ///
  /// - `ManagedPropertyType.integer` -> `"integer"`
  /// - `ManagedPropertyType.doublePrecision` -> `"double"`
  /// - `ManagedPropertyType.bigInteger` -> `"bigInteger"`
  /// - `ManagedPropertyType.boolean` -> `"boolean"`
  /// - `ManagedPropertyType.datetime` -> `"datetime"`
  /// - `ManagedPropertyType.string` -> `"string"`
  /// - `ManagedPropertyType.list` -> `null`
  /// - `ManagedPropertyType.map` -> `null`
  /// - `ManagedPropertyType.document` -> `"document"`
  ///
  /// If the provided [ManagedPropertyType] is not recognized, this method will return `null`.
  ///
  /// @param type The [ManagedPropertyType] to convert to a string representation.
  /// @return The string representation of the provided [ManagedPropertyType], or `null` if it is not recognized.
  static String? typeStringForType(ManagedPropertyType? type) {
    switch (type) {
      case ManagedPropertyType.integer:
        return "integer";
      case ManagedPropertyType.doublePrecision:
        return "double";
      case ManagedPropertyType.bigInteger:
        return "bigInteger";
      case ManagedPropertyType.boolean:
        return "boolean";
      case ManagedPropertyType.datetime:
        return "datetime";
      case ManagedPropertyType.string:
        return "string";
      case ManagedPropertyType.list:
        return null;
      case ManagedPropertyType.map:
        return null;
      case ManagedPropertyType.document:
        return "document";
      default:
        return null;
    }
  }

  /// Returns the [ManagedPropertyType] that corresponds to the provided string representation.
  ///
  /// This method takes a string representation of a property type and returns the corresponding
  /// [ManagedPropertyType] instance. The mapping between the string representation and the
  /// [ManagedPropertyType] is as follows:
  ///
  /// - `"integer"` -> `ManagedPropertyType.integer`
  /// - `"double"` -> `ManagedPropertyType.doublePrecision`
  /// - `"bigInteger"` -> `ManagedPropertyType.bigInteger`
  /// - `"boolean"` -> `ManagedPropertyType.boolean`
  /// - `"datetime"` -> `ManagedPropertyType.datetime`
  /// - `"string"` -> `ManagedPropertyType.string`
  /// - `"document"` -> `ManagedPropertyType.document`
  ///
  /// If the provided string representation is not recognized, this method will return `null`.
  ///
  /// @param type The string representation of the property type to convert to a [ManagedPropertyType].
  /// @return The [ManagedPropertyType] that corresponds to the provided string representation, or `null` if it is not recognized.
  static ManagedPropertyType? typeFromTypeString(String? type) {
    switch (type) {
      case "integer":
        return ManagedPropertyType.integer;
      case "double":
        return ManagedPropertyType.doublePrecision;
      case "bigInteger":
        return ManagedPropertyType.bigInteger;
      case "boolean":
        return ManagedPropertyType.boolean;
      case "datetime":
        return ManagedPropertyType.datetime;
      case "string":
        return ManagedPropertyType.string;
      case "document":
        return ManagedPropertyType.document;
      default:
        return null;
    }
  }

  /// Returns a string representation of the provided [DeleteRule].
  ///
  /// This method takes a [DeleteRule] value and returns the corresponding string representation.
  /// The mapping between the [DeleteRule] and its string representation is as follows:
  ///
  /// - [DeleteRule.cascade] -> `"cascade"`
  /// - [DeleteRule.nullify] -> `"nullify"`
  /// - [DeleteRule.restrict] -> `"restrict"`
  /// - [DeleteRule.setDefault] -> `"default"`
  ///
  /// @param rule The [DeleteRule] value to convert to a string representation.
  /// @return The string representation of the provided [DeleteRule], or `null` if the [DeleteRule] is not recognized.
  static String? deleteRuleStringForDeleteRule(DeleteRule rule) {
    switch (rule) {
      case DeleteRule.cascade:
        return "cascade";
      case DeleteRule.nullify:
        return "nullify";
      case DeleteRule.restrict:
        return "restrict";
      case DeleteRule.setDefault:
        return "default";
    }
  }

  /// Converts a string representation of a [DeleteRule] to the corresponding [DeleteRule] value.
  ///
  /// This method takes a string representation of a [DeleteRule] and returns the corresponding [DeleteRule] value.
  /// The mapping between the string representation and the [DeleteRule] value is as follows:
  ///
  /// - `"cascade"` -> [DeleteRule.cascade]
  /// - `"nullify"` -> [DeleteRule.nullify]
  /// - `"restrict"` -> [DeleteRule.restrict]
  /// - `"default"` -> [DeleteRule.setDefault]
  ///
  /// If the provided string representation is not recognized, this method will return `null`.
  ///
  /// @param rule The string representation of the [DeleteRule] to convert.
  /// @return The [DeleteRule] value that corresponds to the provided string representation, or `null` if it is not recognized.
  static DeleteRule? deleteRuleForDeleteRuleString(String? rule) {
    switch (rule) {
      case "cascade":
        return DeleteRule.cascade;
      case "nullify":
        return DeleteRule.nullify;
      case "restrict":
        return DeleteRule.restrict;
      case "default":
        return DeleteRule.setDefault;
    }
    return null;
  }

  /// Returns a map representation of the current [SchemaColumn] instance.
  ///
  /// The map contains the following key-value pairs:
  ///
  /// - "name": the name of the column
  /// - "type": the string representation of the column's [ManagedPropertyType]
  /// - "nullable": whether the column is nullable
  /// - "autoincrement": whether the column is auto-incremented
  /// - "unique": whether the column is unique
  /// - "defaultValue": the default value of the column
  /// - "primaryKey": whether the column is the primary key
  /// - "relatedTableName": the name of the related table (for foreign key columns)
  /// - "relatedColumnName": the name of the related column (for foreign key columns)
  /// - "deleteRule": the delete rule for the foreign key constraint (for foreign key columns)
  /// - "indexed": whether the column is indexed
  ///
  /// This method is used to create a portable representation of the [SchemaColumn] instance that can be easily
  /// serialized and deserialized, for example, when storing schema information in a database or
  /// transferring it over a network.
  Map<String, dynamic> asMap() {
    return {
      "name": name,
      "type": _type,
      "nullable": isNullable,
      "autoincrement": autoincrement,
      "unique": isUnique,
      "defaultValue": defaultValue,
      "primaryKey": isPrimaryKey,
      "relatedTableName": relatedTableName,
      "relatedColumnName": relatedColumnName,
      "deleteRule": _deleteRule,
      "indexed": isIndexed
    };
  }

  /// Returns a string representation of the SchemaColumn instance.
  ///
  /// The format of the string is "[name] (-> [relatedTableName].[relatedColumnName])", where:
  ///
  /// - [name] is the name of the column
  /// - [relatedTableName] is the name of the related table, if the column is a foreign key
  /// - [relatedColumnName] is the name of the related column, if the column is a foreign key
  ///
  /// If the column is not a foreign key, the string will only include the column name.
  @override
  String toString() => "$name (-> $relatedTableName.$relatedColumnName)";
}

/// The difference between two compared [SchemaColumn]s.
///
/// This class is used for comparing database columns for validation and migration.
class SchemaColumnDifference {
  /// Creates a new instance that represents the difference between [expectedColumn] and [actualColumn].
  ///
  /// This constructor creates a new [SchemaColumnDifference] instance that represents the differences between the
  /// provided [expectedColumn] and [actualColumn]. The constructor compares the properties of the two columns and
  /// populates the [_differingProperties] list with any differences found.
  ///
  /// If the [actualColumn] and [expectedColumn] have different primary key, related column name, related table name,
  /// type, or autoincrement behavior, a [SchemaException] is thrown with an appropriate error message.
  ///
  /// The following properties are compared between the [expectedColumn] and [actualColumn]:
  /// - Name (case-insensitive)
  /// - Indexing
  /// - Uniqueness
  /// - Nullability
  /// - Default value
  /// - Delete rule (for foreign key columns)
  ///
  /// @param expectedColumn The expected [SchemaColumn] instance.
  /// @param actualColumn The actual [SchemaColumn] instance.
  SchemaColumnDifference(this.expectedColumn, this.actualColumn) {
    if (actualColumn != null && expectedColumn != null) {
      if (actualColumn!.isPrimaryKey != expectedColumn!.isPrimaryKey) {
        throw SchemaException(
          "Cannot change primary key of '${expectedColumn!.table!.name}'",
        );
      }

      if (actualColumn!.relatedColumnName !=
          expectedColumn!.relatedColumnName) {
        throw SchemaException(
          "Cannot change an existing column '${expectedColumn!.table!.name}.${expectedColumn!.name}' to an inverse Relationship",
        );
      }

      if (actualColumn!.relatedTableName != expectedColumn!.relatedTableName) {
        throw SchemaException(
          "Cannot change type of '${expectedColumn!.table!.name}.${expectedColumn!.name}'",
        );
      }

      if (actualColumn!.type != expectedColumn!.type) {
        throw SchemaException(
          "Cannot change type of '${expectedColumn!.table!.name}.${expectedColumn!.name}'",
        );
      }

      if (actualColumn!.autoincrement != expectedColumn!.autoincrement) {
        throw SchemaException(
          "Cannot change autoincrement behavior of '${expectedColumn!.table!.name}.${expectedColumn!.name}'",
        );
      }

      if (expectedColumn!.name.toLowerCase() !=
          actualColumn!.name.toLowerCase()) {
        _differingProperties.add(
          _PropertyDifference(
            "name",
            expectedColumn!.name,
            actualColumn!.name,
          ),
        );
      }

      if (expectedColumn!.isIndexed != actualColumn!.isIndexed) {
        _differingProperties.add(
          _PropertyDifference(
            "isIndexed",
            expectedColumn!.isIndexed,
            actualColumn!.isIndexed,
          ),
        );
      }

      if (expectedColumn!.isUnique != actualColumn!.isUnique) {
        _differingProperties.add(
          _PropertyDifference(
            "isUnique",
            expectedColumn!.isUnique,
            actualColumn!.isUnique,
          ),
        );
      }

      if (expectedColumn!.isNullable != actualColumn!.isNullable) {
        _differingProperties.add(
          _PropertyDifference(
            "isNullable",
            expectedColumn!.isNullable,
            actualColumn!.isNullable,
          ),
        );
      }

      if (expectedColumn!.defaultValue != actualColumn!.defaultValue) {
        _differingProperties.add(
          _PropertyDifference(
            "defaultValue",
            expectedColumn!.defaultValue,
            actualColumn!.defaultValue,
          ),
        );
      }

      if (expectedColumn!.deleteRule != actualColumn!.deleteRule) {
        _differingProperties.add(
          _PropertyDifference(
            "deleteRule",
            expectedColumn!.deleteRule,
            actualColumn!.deleteRule,
          ),
        );
      }
    }
  }

  /// The expected column.
  ///
  /// This property represents the expected [SchemaColumn] instance that is being compared to the [actualColumn].
  /// If there is no expected column, this property will be `null`.
  final SchemaColumn? expectedColumn;

  /// The actual [SchemaColumn] instance being compared.
  ///
  /// May be null if there is no actual column.
  final SchemaColumn? actualColumn;

  /// Whether or not [expectedColumn] and [actualColumn] are different.
  ///
  /// This property returns `true` if there are any differences between the [expectedColumn] and [actualColumn],
  /// as determined by the [_differingProperties] list. It also returns `true` if one of the columns is `null`
  /// while the other is not.
  ///
  /// The [_differingProperties] list contains the specific properties that differ between the two columns.
  bool get hasDifferences =>
      _differingProperties.isNotEmpty ||
      (expectedColumn == null && actualColumn != null) ||
      (actualColumn == null && expectedColumn != null);

  /// Provides a human-readable list of differences between the expected and actual database columns.
  ///
  /// Empty is there are no differences.
  List<String> get errorMessages {
    if (expectedColumn == null && actualColumn != null) {
      return [
        "Column '${actualColumn!.name}' in table '${actualColumn!.table!.name}' should NOT exist, but is created by migration files"
      ];
    } else if (expectedColumn != null && actualColumn == null) {
      return [
        "Column '${expectedColumn!.name}' in table '${expectedColumn!.table!.name}' should exist, but is NOT created by migration files"
      ];
    }

    return _differingProperties.map((property) {
      return property.getErrorMessage(
        expectedColumn!.table!.name,
        expectedColumn!.name,
      );
    }).toList();
  }

  /// A list that stores the differences between expected and actual database columns.
  ///
  /// This list stores the specific properties that differ between the expected [SchemaColumn] and the actual [SchemaColumn]
  /// being compared. Each difference is represented by a [_PropertyDifference] instance, which contains the name of the
  /// property, the expected value, and the actual value.
  final List<_PropertyDifference> _differingProperties = [];
}

/// Represents a difference between an expected and actual database column property.
///
/// This class is used within the `SchemaColumnDifference` class to track the specific properties that differ
/// between an expected [SchemaColumn] and an actual [SchemaColumn] being compared.
///
/// The [name] property represents the name of the property that is different, such as "name", "isIndexed",
/// "isUnique", "isNullable", "defaultValue", or "deleteRule".
///
/// The [expectedValue] property represents the expected value of the property, as defined in the schema.
///
/// The [actualValue] property represents the actual value of the property, as found in the database.
///
/// The [getErrorMessage] method returns a human-readable error message that describes the difference between
/// the expected and actual values for the property, including the name of the table and column.
class _PropertyDifference {
  /// Represents a difference between an expected and actual database column property.
  ///
  /// This class is used within the `SchemaColumnDifference` class to track the specific properties that differ
  /// between an expected [SchemaColumn] and an actual [SchemaColumn] being compared.
  ///
  /// The [name] property represents the name of the property that is different, such as "name", "isIndexed",
  /// "isUnique", "isNullable", "defaultValue", or "deleteRule".
  ///
  /// The [expectedValue] property represents the expected value of the property, as defined in the schema.
  ///
  /// The [actualValue] property represents the actual value of the property, as found in the database.
  ///
  /// The [getErrorMessage] method returns a human-readable error message that describes the difference between
  /// the expected and actual values for the property, including the name of the table and column.
  _PropertyDifference(this.name, this.expectedValue, this.actualValue);

  /// The name of the database column.
  final String name;

  /// The expected value of the database column property.
  ///
  /// This represents the value that is expected for the database column property,
  /// as defined in the schema. It is used to compare against the actual value
  /// found in the database.
  final dynamic expectedValue;

  /// The actual value of the database column property.
  ///
  /// This represents the value that is actually found in the database for the
  /// column property. It is used to compare against the expected value defined
  /// in the schema.
  final dynamic actualValue;

  /// Generates an error message for a column mismatch in the database schema.
  ///
  /// This method constructs a detailed error message when there's a discrepancy
  /// between the expected and actual values for a specific column property.
  ///
  /// Parameters:
  /// - [actualTableName]: The name of the table where the mismatch occurred.
  /// - [expectedColumnName]: The name of the column with the mismatched property.
  ///
  /// Returns:
  /// A formatted error message string that includes:
  /// - The table name
  /// - The column name
  /// - The expected value for the property
  /// - The actual value found in the migration files
  ///
  /// The message follows the format:
  /// "Column '[expectedColumnName]' in table '[actualTableName]' expected
  /// '[expectedValue]' for '[name]', but migration files yield '[actualValue]'"
  ///
  /// This method is typically used during schema validation to provide clear
  /// and actionable error messages for database administrators or developers.
  String getErrorMessage(String? actualTableName, String? expectedColumnName) {
    return "Column '$expectedColumnName' in table '$actualTableName' expected "
        "'$expectedValue' for '$name', but migration files yield '$actualValue'";
  }
}
