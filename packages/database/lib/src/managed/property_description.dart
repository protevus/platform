/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/managed/relationship_type.dart';
import 'package:protevus_database/src/persistent_store/persistent_store.dart';
import 'package:protevus_database/src/query/query.dart';
import 'package:protevus_openapi/v3.dart';
import 'package:protevus_runtime/runtime.dart';

/// Contains database column information and metadata for a property of a [ManagedObject] object.
///
/// Each property a [ManagedObject] object manages is described by an instance of [ManagedPropertyDescription], which contains useful information
/// about the property such as its name and type. Those properties are represented by concrete subclasses of this class, [ManagedRelationshipDescription]
/// and [ManagedAttributeDescription].
abstract class ManagedPropertyDescription {
  /// Initializes a new instance of [ManagedPropertyDescription].
  ///
  /// The [ManagedPropertyDescription] class represents a property of a [ManagedObject] object. This constructor sets the basic properties of the
  /// [ManagedPropertyDescription] instance, such as the entity, name, type, declared type, uniqueness, indexing, nullability, inclusion in default result sets,
  /// autoincrement, validators, response model, and response key.
  ///
  /// Parameters:
  /// - [entity]: The [ManagedEntity] that contains this property.
  /// - [name]: The identifying name of this property.
  /// - [type]: The value type of this property, indicating the Dart type and database column type.
  /// - [declaredType]: The type of the variable that this property represents.
  /// - [unique]: Whether or not this property must be unique across all instances represented by [entity]. Defaults to `false`.
  /// - [indexed]: Whether or not this property should be indexed by a [PersistentStore]. Defaults to `false`.
  /// - [nullable]: Whether or not this property can be null. Defaults to `false`.
  /// - [includedInDefaultResultSet]: Whether or not this property is returned in the default set of [Query.returningProperties]. Defaults to `true`.
  /// - [autoincrement]: Whether or not this property should use an auto-incrementing scheme. Defaults to `false`.
  /// - [validators]: A list of [ManagedValidator]s for this instance.
  /// - [responseModel]: The [ResponseModel] associated with this property.
  /// - [responseKey]: The [ResponseKey] associated with this property.
  ManagedPropertyDescription(
    this.entity,
    this.name,
    this.type,
    this.declaredType, {
    bool unique = false,
    bool indexed = false,
    bool nullable = false,
    bool includedInDefaultResultSet = true,
    this.autoincrement = false,
    List<ManagedValidator> validators = const [],
    this.responseModel,
    this.responseKey,
  })  : isUnique = unique,
        isIndexed = indexed,
        isNullable = nullable,
        isIncludedInDefaultResultSet = includedInDefaultResultSet,
        _validators = validators {
    for (final v in _validators) {
      v.property = this;
    }
  }

  /// A reference to the [ManagedEntity] that contains this property.
  ///
  /// The [ManagedEntity] that this [ManagedPropertyDescription] belongs to. This property provides a way to access the entity that
  /// manages the data represented by this property.
  final ManagedEntity entity;

  /// The value type of this property.
  ///
  /// This property indicates the Dart type and database column type of this property. It is used to determine how the property
  /// should be stored and retrieved from the database, as well as how it should be represented in the application's data model.
  final ManagedType? type;

  /// The identifying name of this property.
  ///
  /// This field represents the name of the property being described by this [ManagedPropertyDescription] instance.
  /// The name is used to uniquely identify the property within the [ManagedEntity] that it belongs to.
  final String name;

  /// Whether or not this property must be unique to across all instances represented by [entity].
  ///
  /// This property determines if the value of this property must be unique across all instances of the [ManagedObject] that this [ManagedPropertyDescription] belongs to. If set to `true`, the [PersistentStore] will ensure that no two instances have the same value for this property.
  ///
  /// Defaults to `false`.
  final bool isUnique;

  /// Whether or not this property should be indexed by a [PersistentStore].
  ///
  /// When set to `true`, the [PersistentStore] will create an index for this property, which can improve the performance of
  /// queries that filter or sort on this property. This is useful for properties that are frequently used in queries, but it
  /// may come at the cost of increased storage requirements and write latency.
  ///
  /// Defaults to `false`.
  final bool isIndexed;

  /// Whether or not this property can be null.
  ///
  /// This property determines if the value of this property can be `null` or not. If set to `true`, the [ManagedObject] that this
  /// [ManagedPropertyDescription] belongs to can have a `null` value for this property. If set to `false`, the [ManagedObject]
  /// cannot have a `null` value for this property.
  ///
  /// Defaults to `false`.
  final bool isNullable;

  /// Whether or not this property is returned in the default set of [Query.returningProperties].
  ///
  /// This defaults to `true`. If `true`, when executing a [Query] that does not explicitly specify [Query.returningProperties],
  /// this property will be returned. If `false`, you must explicitly specify this property in [Query.returningProperties] to retrieve it from persistent storage.
  final bool isIncludedInDefaultResultSet;

  /// Whether or not this property should use an auto-incrementing scheme.
  ///
  /// When this is set to `true`, it signals to the [PersistentStore] that this property should automatically be assigned a value
  /// by the database. This is commonly used for primary key properties that should have a unique, incrementing value for each new
  /// instance of the [ManagedObject].
  ///
  /// Defaults to `false`.
  final bool autoincrement;

  /// Determines whether the current property is marked as private.
  ///
  /// Private variables are prefixed with `_` (underscores). This properties are not read
  /// or written to maps and cannot be accessed from outside the class.
  ///
  /// This flag is not included in schemas documents used by database migrations and other tools.
  bool get isPrivate {
    return name.startsWith("_");
  }

  /// The list of [ManagedValidator]s associated with this instance.
  ///
  /// [ManagedValidator]s are used to validate the values of this property
  /// before they are stored in the database. The `validators` property
  /// returns a read-only list of these validators.
  List<ManagedValidator> get validators => _validators;

  /// The list of [ManagedValidator]s associated with this instance.
  ///
  /// [ManagedValidator]s are used to validate the values of this property
  /// before they are stored in the database. The `validators` property
  /// returns a read-only list of these validators.
  final List<ManagedValidator> _validators;

  /// The [ResponseModel] associated with this property.
  ///
  /// The [ResponseModel] defines the structure of the response
  /// that will be returned for this property. This allows for
  /// customization of the documentation and schema for this
  /// property, beyond the default behavior.
  final ResponseModel? responseModel;

  /// The [ResponseKey] associated with this property.
  ///
  /// The [ResponseKey] defines the key that will be used for this
  /// property in the response object. This allows for customization
  /// of the property names in the response, beyond the default
  /// behavior.
  final ResponseKey? responseKey;

  /// Determines whether the provided Dart value can be assigned to this property.
  ///
  /// This method checks if the given `dartValue` is compatible with the type of this property.
  /// It delegates the type checking to the `isAssignableWith` method of the [ManagedType] associated with this property.
  ///
  /// Returns:
  /// - `true` if the `dartValue` can be assigned to this property.
  /// - `false` otherwise.
  bool isAssignableWith(dynamic dartValue) => type!.isAssignableWith(dartValue);

  /// Converts a value from a more complex value into a primitive value according to this instance's definition.
  ///
  /// This method takes a Dart representation of a value and converts it to something that can
  /// be used elsewhere (e.g. an HTTP body or database query). How this value is computed
  /// depends on this instance's definition.
  ///
  /// Parameters:
  /// - [value]: The Dart representation of the value to be converted.
  ///
  /// Returns:
  /// The converted primitive value.
  dynamic convertToPrimitiveValue(dynamic value);

  /// Converts a value to a more complex value from a primitive value according to this instance's definition.
  ///
  /// This method takes a non-Dart representation of a value (e.g. an HTTP body or database query)
  /// and turns it into a Dart representation. How this value is computed
  /// depends on this instance's definition.
  dynamic convertFromPrimitiveValue(dynamic value);

  /// The type of the variable that this property represents.
  ///
  /// This property represents the Dart type of the variable that the [ManagedPropertyDescription] instance
  /// is describing. It is used to ensure that the value assigned to this property is compatible with the
  /// expected type.
  final Type? declaredType;

  /// Returns an [APISchemaObject] that represents this property.
  ///
  /// This method generates an [APISchemaObject] that describes the schema of this property, which can be used for API documentation.
  ///
  /// Parameters:
  /// - [context]: The [APIDocumentContext] that provides information about the current documentation context.
  ///
  /// Returns:
  /// An [APISchemaObject] that represents the schema of this property.
  APISchemaObject documentSchemaObject(APIDocumentContext context);

  /// Creates a typed API schema object based on the provided [ManagedType].
  ///
  /// This method generates an [APISchemaObject] that represents the schema of a property based on its
  /// [ManagedType]. The generated schema object can be used for API documentation and other purposes.
  ///
  /// Parameters:
  /// - [type]: The [ManagedType] that the schema object should be generated for.
  ///
  /// Returns:
  /// An [APISchemaObject] that represents the schema of the provided [ManagedType].
  static APISchemaObject _typedSchemaObject(ManagedType type) {
    switch (type.kind) {
      case ManagedPropertyType.integer:
        return APISchemaObject.integer();
      case ManagedPropertyType.bigInteger:
        return APISchemaObject.integer();
      case ManagedPropertyType.doublePrecision:
        return APISchemaObject.number();
      case ManagedPropertyType.string:
        return APISchemaObject.string();
      case ManagedPropertyType.datetime:
        return APISchemaObject.string(format: "date-time");
      case ManagedPropertyType.boolean:
        return APISchemaObject.boolean();
      case ManagedPropertyType.list:
        return APISchemaObject.array(
          ofSchema: _typedSchemaObject(type.elements!),
        );
      case ManagedPropertyType.map:
        return APISchemaObject.map(
          ofSchema: _typedSchemaObject(type.elements!),
        );
      case ManagedPropertyType.document:
        return APISchemaObject.freeForm();
    }

    // throw UnsupportedError("Unsupported type '$type' when documenting entity.");
  }
}

/// Stores the specifics of database columns in [ManagedObject]s as indicated by [Column].
///
/// This class is used internally to manage data models. For specifying these attributes,
/// see [Column].
///
/// Attributes are the scalar values of a [ManagedObject] (as opposed to relationship values,
/// which are [ManagedRelationshipDescription] instances).
///
/// Each scalar property [ManagedObject] object persists is described by an instance of [ManagedAttributeDescription]. This class
/// adds two properties to [ManagedPropertyDescription] that are only valid for non-relationship types, [isPrimaryKey] and [defaultValue].
class ManagedAttributeDescription extends ManagedPropertyDescription {
  /// This constructor is used to create a [ManagedAttributeDescription] instance, which represents a scalar property of a [ManagedObject].
  /// It initializes the properties of the [ManagedPropertyDescription] base class, and also sets the `isPrimaryKey` and `defaultValue` properties
  /// specific to [ManagedAttributeDescription].
  ///
  /// Parameters:
  /// - `entity`: The [ManagedEntity] that contains this property.
  /// - `name`: The identifying name of this property.
  /// - `type`: The value type of this property, indicating the Dart type and database column type.
  /// - `declaredType`: The type of the variable that this property represents.
  /// - `transientStatus`: The validity of this attribute as input, output or both.
  /// - `primaryKey`: Whether or not this attribute is the primary key for its [ManagedEntity]. Defaults to `false`.
  /// - `defaultValue`: The default value for this attribute. Defaults to `null`.
  /// - `unique`: Whether or not this property must be unique across all instances represented by `entity`. Defaults to `false`.
  /// - `indexed`: Whether or not this property should be indexed by a [PersistentStore]. Defaults to `false`.
  /// - `nullable`: Whether or not this property can be null. Defaults to `false`.
  /// - `includedInDefaultResultSet`: Whether or not this property is returned in the default set of [Query.returningProperties]. Defaults to `true`.
  /// - `autoincrement`: Whether or not this property should use an auto-incrementing scheme. Defaults to `false`.
  /// - `validators`: A list of [ManagedValidator]s for this instance. Defaults to an empty list.
  /// - `responseModel`: The [ResponseModel] associated with this property.
  /// - `responseKey`: The [ResponseKey] associated with this property.
  ManagedAttributeDescription(
    super.entity,
    super.name,
    ManagedType super.type,
    super.declaredType, {
    this.transientStatus,
    bool primaryKey = false,
    this.defaultValue,
    super.unique,
    super.indexed,
    super.nullable,
    super.includedInDefaultResultSet,
    super.autoincrement,
    super.validators,
    super.responseModel,
    super.responseKey,
  }) : isPrimaryKey = primaryKey;

  /// Initializes a new instance of [ManagedAttributeDescription] for a transient property.
  ///
  /// A transient property is a property that is not backed by a database column, but is still part of the [ManagedObject] model.
  ///
  /// Parameters:
  /// - `entity`: The [ManagedEntity] that contains this property.
  /// - `name`: The identifying name of this property.
  /// - `type`: The value type of this property, indicating the Dart type and database column type.
  /// - `declaredType`: The type of the variable that this property represents.
  /// - `transientStatus`: The validity of this attribute as input, output or both.
  /// - `responseKey`: The [ResponseKey] associated with this property.
  ManagedAttributeDescription.transient(
    super.entity,
    super.name,
    ManagedType super.type,
    Type super.declaredType,
    this.transientStatus, {
    super.responseKey,
  })  : isPrimaryKey = false,
        defaultValue = null,
        super(
          unique: false,
          indexed: false,
          nullable: false,
          includedInDefaultResultSet: false,
          autoincrement: false,
          validators: [],
        );

  /// Creates a new instance of [ManagedAttributeDescription] with the provided parameters.
  ///
  /// This method is a factory method that simplifies the creation of [ManagedAttributeDescription] instances.
  ///
  /// Parameters:
  /// - `entity`: The [ManagedEntity] that contains this property.
  /// - `name`: The identifying name of this property.
  /// - `type`: The value type of this property, indicating the Dart type and database column type.
  /// - `transientStatus`: The validity of this attribute as input, output or both.
  /// - `primaryKey`: Whether or not this attribute is the primary key for its [ManagedEntity]. Defaults to `false`.
  /// - `defaultValue`: The default value for this attribute. Defaults to `null`.
  /// - `unique`: Whether or not this property must be unique across all instances represented by `entity`. Defaults to `false`.
  /// - `indexed`: Whether or not this property should be indexed by a [PersistentStore]. Defaults to `false`.
  /// - `nullable`: Whether or not this property can be null. Defaults to `false`.
  /// - `includedInDefaultResultSet`: Whether or not this property is returned in the default set of [Query.returningProperties]. Defaults to `true`.
  /// - `autoincrement`: Whether or not this property should use an auto-incrementing scheme. Defaults to `false`.
  /// - `validators`: A list of [ManagedValidator]s for this instance. Defaults to an empty list.
  /// - `responseKey`: The [ResponseKey] associated with this property.
  /// - `responseModel`: The [ResponseModel] associated with this property.
  ///
  /// Returns:
  /// A new instance of [ManagedAttributeDescription] with the provided parameters.
  static ManagedAttributeDescription make<T>(
    ManagedEntity entity,
    String name,
    ManagedType type, {
    Serialize? transientStatus,
    bool primaryKey = false,
    String? defaultValue,
    bool unique = false,
    bool indexed = false,
    bool nullable = false,
    bool includedInDefaultResultSet = true,
    bool autoincrement = false,
    List<ManagedValidator> validators = const [],
    ResponseKey? responseKey,
    ResponseModel? responseModel,
  }) {
    return ManagedAttributeDescription(
      entity,
      name,
      type,
      T,
      transientStatus: transientStatus,
      primaryKey: primaryKey,
      defaultValue: defaultValue,
      unique: unique,
      indexed: indexed,
      nullable: nullable,
      includedInDefaultResultSet: includedInDefaultResultSet,
      autoincrement: autoincrement,
      validators: validators,
      responseKey: responseKey,
      responseModel: responseModel,
    );
  }

  /// Indicates whether this attribute is the primary key for its [ManagedEntity].
  ///
  /// Defaults to false.
  final bool isPrimaryKey;

  /// The default value for this attribute.
  ///
  /// By default, this property is `null`. This value is a `String`, so the underlying persistent store is responsible for parsing it. This allows for
  /// default values that aren't constant values, such as database function calls.
  final String? defaultValue;

  /// Determines whether this attribute is backed directly by the database.
  ///
  /// If [transientStatus] is non-null, this value will be true. Otherwise, the attribute is backed by a database field/column.
  bool get isTransient => transientStatus != null;

  /// Contains lookup table for string value of an enumeration to the enumerated value.
  ///
  /// This property returns a map that maps the string representation of an enumeration value
  /// to the actual enumeration value. This is used when dealing with enumerated values in
  /// the context of a [ManagedAttributeDescription].
  ///
  /// If `enum Options { option1, option2 }` then this map contains:
  ///
  ///         {
  ///           "option1": Options.option1,
  ///           "option2": Options.option2
  ///          }
  ///
  Map<String, dynamic> get enumerationValueMap => type!.enumerationMap;

  /// The validity of a transient attribute as input, output or both.
  ///
  /// If this property is non-null, the attribute is transient (not backed by a database field/column).
  /// The [Serialize] value indicates whether the attribute is available for input, output, or both.
  final Serialize? transientStatus;

  /// Determines whether this attribute is represented by a Dart enum.
  ///
  /// If the [enumerationValueMap] property is not empty, this attribute is considered an
  /// enumerated value, meaning it is represented by a Dart enum.
  bool get isEnumeratedValue => enumerationValueMap.isNotEmpty;

  /// Generates an [APISchemaObject] that represents the schema of this property for API documentation.
  ///
  /// This method creates an [APISchemaObject] that describes the schema of this property, including
  /// information about its type, nullability, enumerations, and other metadata.
  ///
  /// Parameters:
  /// - `context`: The [APIDocumentContext] that provides information about the current documentation context.
  ///
  /// Returns:
  /// An [APISchemaObject] that represents the schema of this property.
  @override
  APISchemaObject documentSchemaObject(APIDocumentContext context) {
    final prop = ManagedPropertyDescription._typedSchemaObject(type!)
      ..title = name;
    final buf = StringBuffer();

    // Add'l schema info
    prop.isNullable = isNullable;
    for (final v in validators) {
      v.definition.constrainSchemaObject(context, prop);
    }

    if (isEnumeratedValue) {
      prop.enumerated = prop.enumerated!.map(convertToPrimitiveValue).toList();
    }

    if (isTransient) {
      if (transientStatus!.isAvailableAsInput &&
          !transientStatus!.isAvailableAsOutput) {
        prop.isWriteOnly = true;
      } else if (!transientStatus!.isAvailableAsInput &&
          transientStatus!.isAvailableAsOutput) {
        prop.isReadOnly = true;
      }
    }

    if (isUnique) {
      buf.writeln("No two objects may have the same value for this field.");
    }

    if (isPrimaryKey) {
      buf.writeln("This is the primary identifier for this object.");
    }

    if (defaultValue != null) {
      prop.defaultValue = defaultValue;
    }

    if (buf.isNotEmpty) {
      prop.description = buf.toString();
    }

    return prop;
  }

  /// Generates a string representation of the properties of this `ManagedPropertyDescription` instance.
  ///
  /// The resulting string includes information about the following properties:
  /// - `isPrimaryKey`: Whether this property is the primary key for the associated `ManagedEntity`.
  /// - `isTransient`: Whether this property is a transient property (i.e., not backed by a database column).
  /// - `autoincrement`: Whether this property uses auto-incrementing for its values.
  /// - `isUnique`: Whether this property must have unique values across all instances of the associated `ManagedEntity`.
  /// - `defaultValue`: The default value for this property, if any.
  /// - `isIndexed`: Whether this property is indexed in the database.
  /// - `isNullable`: Whether this property can have a `null` value.
  ///
  /// The string representation is formatted as follows:
  /// ```
  /// - <name> | <type> | Flags: <flag1> <flag2> ... <flagN>
  /// ```
  /// where `<name>` is the name of the property, `<type>` is the type of the property, and `<flag1>`, `<flag2>`, ..., `<flagN>` are the flags
  /// corresponding to the property's characteristics (e.g., `primary_key`, `transient`, `autoincrementing`, `unique`, `defaults to <value>`, `indexed`, `nullable`, `required`).
  @override
  String toString() {
    final flagBuffer = StringBuffer();
    if (isPrimaryKey) {
      flagBuffer.write("primary_key ");
    }
    if (isTransient) {
      flagBuffer.write("transient ");
    }
    if (autoincrement) {
      flagBuffer.write("autoincrementing ");
    }
    if (isUnique) {
      flagBuffer.write("unique ");
    }
    if (defaultValue != null) {
      flagBuffer.write("defaults to $defaultValue ");
    }
    if (isIndexed) {
      flagBuffer.write("indexed ");
    }
    if (isNullable) {
      flagBuffer.write("nullable ");
    } else {
      flagBuffer.write("required ");
    }

    return "- $name | $type | Flags: $flagBuffer";
  }

  /// Converts a value to a more primitive value according to this instance's definition.
  ///
  /// This method takes a Dart representation of a value and converts it to something that can
  /// be used elsewhere (e.g. an HTTP body or database query). The conversion depends on the
  /// type of this property.
  ///
  /// For `DateTime` values, the method converts the `DateTime` to an ISO 8601 string.
  /// For enumerated values, the method converts the enum value to a string representing the enum name.
  /// For `Document` values, the method extracts the data from the `Document` object.
  /// For all other values, the method simply returns the original value.
  ///
  /// Parameters:
  /// - [value]: The Dart representation of the value to be converted.
  ///
  /// Returns:
  /// The converted primitive value.
  @override
  dynamic convertToPrimitiveValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (type!.kind == ManagedPropertyType.datetime && value is DateTime) {
      return value.toIso8601String();
    } else if (isEnumeratedValue) {
      // todo: optimize?
      return value.toString().split(".").last;
    } else if (type!.kind == ManagedPropertyType.document &&
        value is Document) {
      return value.data;
    }

    return value;
  }

  /// Converts a value from a primitive value into a more complex value according to this instance's definition.
  ///
  /// This method takes a non-Dart representation of a value (e.g. an HTTP body or database query)
  /// and turns it into a Dart representation. The conversion process depends on the type of this property.
  ///
  /// For `DateTime` values, the method parses the input string into a `DateTime` object.
  /// For `double` values, the method converts the input number to a `double`.
  /// For enumerated values, the method looks up the corresponding enum value using the `enumerationValueMap`.
  /// For `Document` values, the method wraps the input value in a `Document` object.
  /// For `List` and `Map` values, the method delegates the conversion to the `entity.runtime.dynamicConvertFromPrimitiveValue` method.
  ///
  /// If the input value is not compatible with the expected type, a `ValidationException` is thrown.
  ///
  /// Parameters:
  /// - `value`: The non-Dart representation of the value to be converted.
  ///
  /// Returns:
  /// The converted Dart representation of the value.
  @override
  dynamic convertFromPrimitiveValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (type!.kind == ManagedPropertyType.datetime) {
      if (value is! String) {
        throw ValidationException(["invalid input value for '$name'"]);
      }
      return DateTime.parse(value);
    } else if (type!.kind == ManagedPropertyType.doublePrecision) {
      if (value is! num) {
        throw ValidationException(["invalid input value for '$name'"]);
      }
      return value.toDouble();
    } else if (isEnumeratedValue) {
      if (!enumerationValueMap.containsKey(value)) {
        throw ValidationException(["invalid option for key '$name'"]);
      }
      return enumerationValueMap[value];
    } else if (type!.kind == ManagedPropertyType.document) {
      return Document(value);
    } else if (type!.kind == ManagedPropertyType.list ||
        type!.kind == ManagedPropertyType.map) {
      try {
        return entity.runtime.dynamicConvertFromPrimitiveValue(this, value);
      } on TypeCoercionException {
        throw ValidationException(["invalid input value for '$name'"]);
      }
    }

    return value;
  }
}

/// Contains information for a relationship property of a [ManagedObject].
///
/// The `ManagedRelationshipDescription` class represents a relationship property of a [ManagedObject]. It contains information about the
/// destination entity, the delete rule, the relationship type, and the inverse key. This class is used to manage the data model and
/// provide information about relationship properties.
class ManagedRelationshipDescription extends ManagedPropertyDescription {
  /// Initializes a new instance of [ManagedRelationshipDescription].
  ///
  /// This constructor creates a new instance of [ManagedRelationshipDescription], which represents a relationship property of a [ManagedObject].
  /// The constructor sets the properties of the [ManagedRelationshipDescription] instance, including the destination entity, delete rule, relationship type,
  /// inverse key, and other metadata.
  ///
  /// Parameters:
  /// - `entity`: The [ManagedEntity] that contains this property.
  /// - `name`: The identifying name of this property.
  /// - `type`: The value type of this property, indicating the Dart type and database column type.
  /// - `declaredType`: The type of the variable that this property represents.
  /// - `destinationEntity`: The [ManagedEntity] that represents the destination of this relationship.
  /// - `deleteRule`: The delete rule for this relationship.
  /// - `relationshipType`: The type of relationship (e.g., belongs to, has one, has many).
  /// - `inverseKey`: The name of the [ManagedRelationshipDescription] on the `destinationEntity` that represents the inverse of this relationship.
  /// - `unique`: Whether or not this property must be unique across all instances represented by `entity`. Defaults to `false`.
  /// - `indexed`: Whether or not this property should be indexed by a [PersistentStore]. Defaults to `false`.
  /// - `nullable`: Whether or not this property can be null. Defaults to `false`.
  /// - `includedInDefaultResultSet`: Whether or not this property is returned in the default set of [Query.returningProperties]. Defaults to `true`.
  /// - `validators`: A list of [ManagedValidator]s for this instance. Defaults to an empty list.
  /// - `responseModel`: The [ResponseModel] associated with this property.
  /// - `responseKey`: The [ResponseKey] associated with this property.
  ManagedRelationshipDescription(
    super.entity,
    super.name,
    super.type,
    super.declaredType,
    this.destinationEntity,
    this.deleteRule,
    this.relationshipType,
    this.inverseKey, {
    super.unique,
    super.indexed,
    super.nullable,
    super.includedInDefaultResultSet,
    super.validators = const [],
    super.responseModel,
    super.responseKey,
  });

  /// Creates a new instance of [ManagedRelationshipDescription] with the provided parameters.
  ///
  /// This method is a factory method that simplifies the creation of [ManagedRelationshipDescription] instances.
  ///
  /// Parameters:
  /// - `entity`: The [ManagedEntity] that contains this property.
  /// - `name`: The identifying name of this property.
  /// - `type`: The value type of this property, indicating the Dart type and database column type.
  /// - `destinationEntity`: The [ManagedEntity] that represents the destination of this relationship.
  /// - `deleteRule`: The delete rule for this relationship.
  /// - `relationshipType`: The type of relationship (e.g., belongs to, has one, has many).
  /// - `inverseKey`: The name of the [ManagedRelationshipDescription] on the `destinationEntity` that represents the inverse of this relationship.
  /// - `unique`: Whether or not this property must be unique across all instances represented by `entity`. Defaults to `false`.
  /// - `indexed`: Whether or not this property should be indexed by a [PersistentStore]. Defaults to `false`.
  /// - `nullable`: Whether or not this property can be null. Defaults to `false`.
  /// - `includedInDefaultResultSet`: Whether or not this property is returned in the default set of [Query.returningProperties]. Defaults to `true`.
  /// - `validators`: A list of [ManagedValidator]s for this instance. Defaults to an empty list.
  /// - `responseKey`: The [ResponseKey] associated with this property.
  /// - `responseModel`: The [ResponseModel] associated with this property.
  ///
  /// Returns:
  /// A new instance of [ManagedRelationshipDescription] with the provided parameters.
  static ManagedRelationshipDescription make<T>(
    ManagedEntity entity,
    String name,
    ManagedType? type,
    ManagedEntity destinationEntity,
    DeleteRule? deleteRule,
    ManagedRelationshipType relationshipType,
    String inverseKey, {
    bool unique = false,
    bool indexed = false,
    bool nullable = false,
    bool includedInDefaultResultSet = true,
    List<ManagedValidator> validators = const [],
    ResponseKey? responseKey,
    ResponseModel? responseModel,
  }) {
    return ManagedRelationshipDescription(
      entity,
      name,
      type,
      T,
      destinationEntity,
      deleteRule,
      relationshipType,
      inverseKey,
      unique: unique,
      indexed: indexed,
      nullable: nullable,
      includedInDefaultResultSet: includedInDefaultResultSet,
      validators: validators,
      responseKey: responseKey,
      responseModel: responseModel,
    );
  }

  /// The [ManagedEntity] that represents the destination of this relationship.
  ///
  /// This property holds a reference to the [ManagedEntity] that describes the model
  /// that the objects on the other end of this relationship belong to. This is used
  /// to ensure that the values assigned to this relationship property are compatible
  /// with the expected model.
  final ManagedEntity destinationEntity;

  /// The delete rule for this relationship.
  ///
  /// The delete rule determines what happens to the related objects when the object
  /// containing this relationship is deleted. The possible values are:
  ///
  /// - `DeleteRule.cascade`: When the object is deleted, all related objects are also deleted.
  /// - `DeleteRule.restrict`: When the object is deleted, the operation will fail if there are any related objects.
  /// - `DeleteRule.nullify`: When the object is deleted, the foreign key values in the related objects will be set to `null`.
  /// - `DeleteRule.setDefault`: When the object is deleted, the foreign key values in the related objects will be set to their default values.
  final DeleteRule? deleteRule;

  /// The type of relationship represented by this [ManagedRelationshipDescription].
  ///
  /// The relationship type can be one of the following:
  /// - `ManagedRelationshipType.belongsTo`: This property represents a "belongs to" relationship, where the object containing this property
  ///   belongs to another object.
  /// - `ManagedRelationshipType.hasOne`: This property represents a "has one" relationship, where the object containing this property
  ///   has a single related object.
  /// - `ManagedRelationshipType.hasMany`: This property represents a "has many" relationship, where the object containing this property
  ///   has a set of related objects.
  final ManagedRelationshipType relationshipType;

  /// The [ManagedRelationshipDescription] on [destinationEntity] that represents the inverse of this relationship.
  ///
  /// This property holds the name of the [ManagedRelationshipDescription] on the [destinationEntity] that represents the inverse
  /// of this relationship. This information is used to ensure that the relationships between objects are properly defined and
  /// navigable in both directions.
  final String inverseKey;

  /// Gets the [ManagedRelationshipDescription] on [destinationEntity] that represents the inverse of this relationship.
  ///
  /// This property returns the [ManagedRelationshipDescription] instance on the [destinationEntity] that represents the
  /// inverse of the current relationship. The inverse relationship is specified by the [inverseKey] property.
  ///
  /// This method is used to navigate the relationship in the opposite direction, allowing you to access the related
  /// objects from the other side of the relationship.
  ///
  /// Returns:
  /// The [ManagedRelationshipDescription] that represents the inverse of this relationship, or `null` if no inverse
  /// relationship is defined.
  ManagedRelationshipDescription? get inverse =>
      destinationEntity.relationships[inverseKey];

  /// Indicates whether this relationship is on the belonging side of the relationship.
  ///
  /// This property returns `true` if the `relationshipType` of this `ManagedRelationshipDescription` is
  /// `ManagedRelationshipType.belongsTo`, which means that the object containing this property "belongs to"
  /// another object. If the `relationshipType` is not `belongsTo`, this property returns `false`.
  bool get isBelongsTo => relationshipType == ManagedRelationshipType.belongsTo;

  /// Determines whether the provided Dart value can be assigned to this property.
  ///
  /// This method checks if the given `dartValue` is compatible with the type of this property.
  /// For relationships with a 'has many' type, the method checks if the `dartValue` is a list of
  /// [ManagedObject] instances that belong to the destination entity. For other relationship
  /// types, the method checks if the `dartValue` is a [ManagedObject] instance that belongs
  /// to the destination entity.
  ///
  /// Parameters:
  /// - `dartValue`: The Dart value to be checked for assignment compatibility.
  ///
  /// Returns:
  /// - `true` if the `dartValue` can be assigned to this property.
  /// - `false` otherwise.
  @override
  bool isAssignableWith(dynamic dartValue) {
    if (relationshipType == ManagedRelationshipType.hasMany) {
      return destinationEntity.runtime.isValueListOf(dartValue);
    }
    return destinationEntity.runtime.isValueInstanceOf(dartValue);
  }

  /// Converts a value to a more primitive value according to this instance's definition.
  ///
  /// This method takes a Dart representation of a value and converts it to something that can
  /// be used elsewhere (e.g. an HTTP body or database query). The conversion process depends
  /// on the type of the relationship.
  ///
  /// For relationship properties with a "has many" type, the method converts the `ManagedSet`
  /// instance to a list of maps, where each map represents the associated `ManagedObject`
  /// instances.
  ///
  /// For relationship properties with a "belongs to" type, the method checks if only the
  /// primary key of the associated `ManagedObject` is being fetched. If so, it returns a
  /// map containing only the primary key value. Otherwise, it returns the full map
  /// representation of the associated `ManagedObject`.
  ///
  /// If the provided `value` is `null`, the method returns `null`.
  ///
  /// If the provided `value` is not a `ManagedSet` or `ManagedObject`, the method throws a
  /// `StateError` with a message indicating the invalid relationship assignment.
  ///
  /// Parameters:
  /// - `value`: The Dart representation of the value to be converted.
  ///
  /// Returns:
  /// The converted primitive value.
  @override
  dynamic convertToPrimitiveValue(dynamic value) {
    if (value is ManagedSet) {
      return value
          .map((ManagedObject innerValue) => innerValue.asMap())
          .toList();
    } else if (value is ManagedObject) {
      // If we're only fetching the foreign key, don't do a full asMap
      if (relationshipType == ManagedRelationshipType.belongsTo &&
          value.backing.contents.length == 1 &&
          value.backing.contents.containsKey(destinationEntity.primaryKey)) {
        return <String, Object>{
          destinationEntity.primaryKey: value[destinationEntity.primaryKey]
        };
      }

      return value.asMap();
    } else if (value == null) {
      return null;
    }

    throw StateError(
      "Invalid relationship assigment. Relationship '$entity.$name' is not a 'ManagedSet' or 'ManagedObject'.",
    );
  }

  /// Converts a value from a primitive value into a more complex value according to this instance's definition.
  ///
  /// This method takes a non-Dart representation of a value (e.g. an HTTP body or database query)
  /// and turns it into a Dart representation. The conversion process depends on the type of the relationship.
  ///
  /// For relationship properties with a "belongs to" or "has one" type, the method creates a new instance of the
  /// [ManagedObject] associated with the destination entity, and populates it with the data from the provided map.
  ///
  /// For relationship properties with a "has many" type, the method creates a [ManagedSet] instance, and populates
  /// it with new [ManagedObject] instances created from the provided list of maps.
  ///
  /// If the input value is `null`, the method returns `null`.
  ///
  /// If the input value is not a map or list, as expected for the relationship type, a [ValidationException] is thrown.
  ///
  /// Parameters:
  /// - `value`: The non-Dart representation of the value to be converted.
  ///
  /// Returns:
  /// The converted Dart representation of the value.
  @override
  dynamic convertFromPrimitiveValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (relationshipType == ManagedRelationshipType.belongsTo ||
        relationshipType == ManagedRelationshipType.hasOne) {
      if (value is! Map<String, dynamic>) {
        throw ValidationException(["invalid input type for '$name'"]);
      }

      final instance = destinationEntity.instanceOf()..readFromMap(value);

      return instance;
    }

    /* else if (relationshipType == ManagedRelationshipType.hasMany) { */

    if (value is! List) {
      throw ValidationException(["invalid input type for '$name'"]);
    }

    ManagedObject instantiator(dynamic m) {
      if (m is! Map<String, dynamic>) {
        throw ValidationException(["invalid input type for '$name'"]);
      }
      final instance = destinationEntity.instanceOf()..readFromMap(m);
      return instance;
    }

    return destinationEntity.setOf(value.map(instantiator));
  }

  /// Generates an [APISchemaObject] that represents the schema of this relationship property for API documentation.
  ///
  /// This method creates an [APISchemaObject] that describes the schema of this relationship property, including
  /// information about the type of relationship (hasMany, hasOne, or belongsTo), the related object schema, and
  /// whether the property is read-only and nullable.
  ///
  /// Parameters:
  /// - `context`: The [APIDocumentContext] that provides information about the current documentation context.
  ///
  /// Returns:
  /// An [APISchemaObject] that represents the schema of this relationship property.
  @override
  APISchemaObject documentSchemaObject(APIDocumentContext context) {
    final relatedType =
        context.schema.getObjectWithType(inverse!.entity.instanceType);

    if (relationshipType == ManagedRelationshipType.hasMany) {
      return APISchemaObject.array(ofSchema: relatedType)
        ..isReadOnly = true
        ..isNullable = true;
    } else if (relationshipType == ManagedRelationshipType.hasOne) {
      return relatedType
        ..isReadOnly = true
        ..isNullable = true;
    }

    final destPk = destinationEntity.primaryKeyAttribute!;
    return APISchemaObject.object({
      destPk.name: ManagedPropertyDescription._typedSchemaObject(destPk.type!)
    })
      ..title = name;
  }

  /// Generates a string representation of the properties of this `ManagedRelationshipDescription` instance.
  ///
  /// The resulting string includes information about the following properties:
  /// - `name`: The identifying name of this property.
  /// - `destinationEntity`: The name of the `ManagedEntity` that represents the destination of this relationship.
  /// - `relationshipType`: The type of relationship (e.g., `belongs to`, `has one`, `has many`).
  /// - `inverseKey`: The name of the `ManagedRelationshipDescription` on the `destinationEntity` that represents the inverse of this relationship.
  ///
  /// The string representation is formatted as follows:
  /// ```
  /// - <name> -> '<destinationEntity.name>' | Type: <relTypeString> | Inverse: <inverseKey>
  /// ```
  @override
  String toString() {
    var relTypeString = "has-one";
    switch (relationshipType) {
      case ManagedRelationshipType.belongsTo:
        relTypeString = "belongs to";
        break;
      case ManagedRelationshipType.hasMany:
        relTypeString = "has-many";
        break;
      case ManagedRelationshipType.hasOne:
        relTypeString = "has-a";
        break;
      // case null:
      //   relTypeString = 'Not set';
      //   break;
    }
    return "- $name -> '${destinationEntity.name}' | Type: $relTypeString | Inverse: $inverseKey";
  }
}
