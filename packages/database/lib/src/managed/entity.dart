/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_database/src/managed/backing.dart';
import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/managed/relationship_type.dart';
import 'package:protevus_database/src/query/query.dart';
import 'package:protevus_openapi/v3.dart';
import 'package:protevus_runtime/runtime.dart';

/// Mapping information between a table in a database and a [ManagedObject] object.
///
/// An entity defines the mapping between a database table and [ManagedObject] subclass. Entities
/// are created by declaring [ManagedObject] subclasses and instantiating a [ManagedDataModel].
/// In general, you do not need to use or create instances of this class.
///
/// An entity describes the properties that a subclass of [ManagedObject] will have and their representation in the underlying database.
/// Each of these properties are represented by an instance of a [ManagedPropertyDescription] subclass. A property is either an attribute or a relationship.
///
/// Attribute values are scalar (see [ManagedPropertyType]) - [int], [String], [DateTime], [double] and [bool].
/// Attributes are typically backed by a column in the underlying database for a [ManagedObject], but may also represent transient values
/// defined by the [instanceType].
/// Attributes are represented by [ManagedAttributeDescription].
///
/// The value of a relationship property is a reference to another [ManagedObject]. If a relationship property has [Relate] metadata,
/// the property is backed be a foreign key column in the underlying database. Relationships are represented by [ManagedRelationshipDescription].
class ManagedEntity implements APIComponentDocumenter {
  /// Creates an instance of this type..
  ///
  /// You should never call this method directly, it will be called by [ManagedDataModel].
  ManagedEntity(this._tableName, this.instanceType, this.tableDefinition);

  /// The name of this entity.
  ///
  /// This name will match the name of [instanceType].
  String get name => instanceType.toString();

  /// The type of instances represented by this entity.
  ///
  /// Managed objects are made up of two components, a table definition and an instance type. Applications
  /// use instances of the instance type to work with queries and data from the database table this entity represents.
  final Type instanceType;

  /// Set of callbacks that are implemented differently depending on compilation target.
  ///
  /// If running in default mode (mirrors enabled), is a set of mirror operations. Otherwise,
  /// code generated.
  ManagedEntityRuntime get runtime =>
      RuntimeContext.current[instanceType] as ManagedEntityRuntime;

  /// The name of type of persistent instances represented by this entity.
  ///
  /// Managed objects are made up of two components, a table definition and an instance type.
  /// The system uses this type to define the mapping to the underlying database table.
  final String tableDefinition;

  /// All attribute values of this entity.
  ///
  /// An attribute maps to a single column or field in a database that is a scalar value, such as a string, integer, etc. or a
  /// transient property declared in the instance type.
  /// The keys are the case-sensitive name of the attribute. Values that represent a relationship to another object
  /// are not stored in [attributes].
  late Map<String, ManagedAttributeDescription?> attributes;

  /// All relationship values of this entity.
  ///
  /// A relationship represents a value that is another [ManagedObject] or [ManagedSet] of [ManagedObject]s. Not all relationships
  /// correspond to a column or field in a database, only those with [Relate] metadata (see also [ManagedRelationshipType.belongsTo]). In
  /// this case, the underlying database column is a foreign key reference. The underlying database does not have storage
  /// for [ManagedRelationshipType.hasMany] or [ManagedRelationshipType.hasOne] properties, as those values are derived by the foreign key reference
  /// on the inverse relationship property.
  /// Keys are the case-sensitive name of the relationship.
  late Map<String, ManagedRelationshipDescription?> relationships;

  /// All properties (relationships and attributes) of this entity.
  ///
  /// The string key is the name of the property, case-sensitive. Values will be instances of either [ManagedAttributeDescription]
  /// or [ManagedRelationshipDescription]. This is the concatenation of [attributes] and [relationships].
  Map<String, ManagedPropertyDescription?> get properties {
    final all = Map<String, ManagedPropertyDescription?>.from(attributes);
    all.addAll(relationships);
    return all;
  }

  /// Set of properties that, together, are unique for each instance of this entity.
  ///
  /// If non-null, each instance of this entity is unique for the combination of values
  /// for these properties. Instances may have the same values for each property in [uniquePropertySet],
  /// but cannot have the same value for all properties in [uniquePropertySet]. This differs from setting
  /// a single property as unique with [Column], where each instance has
  /// a unique value for that property.
  ///
  /// This value is set by adding [Table] to the table definition of a [ManagedObject].
  List<ManagedPropertyDescription>? uniquePropertySet;

  /// List of [ManagedValidator]s for attributes of this entity.
  ///
  /// All validators for all [attributes] in one, flat list. Order is undefined.
  late List<ManagedValidator> validators;

  /// The list of default property names of this object.
  ///
  /// By default, a [Query] will fetch the properties in this list. You may specify
  /// a different set of properties by setting the [Query.returningProperties] value. The default
  /// set of properties is a list of all attributes that do not have the [Column.shouldOmitByDefault] flag
  /// set in their [Column] and all [ManagedRelationshipType.belongsTo] relationships.
  ///
  /// This list cannot be modified.
  List<String>? get defaultProperties {
    if (_defaultProperties == null) {
      final elements = <String?>[];
      elements.addAll(
        attributes.values
            .where((prop) => prop!.isIncludedInDefaultResultSet)
            .where((prop) => !prop!.isTransient)
            .map((prop) => prop!.name),
      );

      elements.addAll(
        relationships.values
            .where(
              (prop) =>
                  prop!.isIncludedInDefaultResultSet &&
                  prop.relationshipType == ManagedRelationshipType.belongsTo,
            )
            .map((prop) => prop!.name),
      );
      _defaultProperties = List.unmodifiable(elements);
    }
    return _defaultProperties;
  }

  /// Name of primary key property.
  ///
  /// This is determined by the attribute with the [primaryKey] annotation.
  late String primaryKey;

  /// Returns the primary key attribute of this entity.
  ///
  /// The primary key attribute is the [ManagedAttributeDescription] instance that represents the primary key
  /// column of the database table associated with this entity. This property retrieves that attribute
  /// by looking up the [primaryKey] property of this entity.
  ManagedAttributeDescription? get primaryKeyAttribute {
    return attributes[primaryKey];
  }

  /// A map from accessor symbol name to property name.
  ///
  /// This map should not be modified.
  late Map<Symbol, String> symbolMap;

  /// Name of table in database this entity maps to.
  ///
  /// By default, the table will be named by the table definition, e.g., a managed object declared as so will have a [tableName] of '_User'.
  ///
  ///       class User extends ManagedObject<_User> implements _User {}
  ///       class _User { ... }
  ///
  /// You may implement the static method [tableName] on the table definition of a [ManagedObject] to return a [String] table
  /// name override this default.
  String get tableName {
    return _tableName;
  }

  /// The name of the table in the database that this entity maps to.
  ///
  /// By default, the table will be named by the table definition, e.g., a managed object declared as so will have a [tableName] of '_User'.
  ///
  ///       class User extends ManagedObject<_User> implements _User {}
  ///       class _User { ... }
  ///
  /// You may implement the static method [tableName] on the table definition of a [ManagedObject] to return a [String] table
  /// name override this default.
  final String _tableName;

  /// The list of default property names of this object.
  ///
  /// By default, a [Query] will fetch the properties in this list. You may specify
  /// a different set of properties by setting the [Query.returningProperties] value. The default
  /// set of properties is a list of all attributes that do not have the [Column.shouldOmitByDefault] flag
  /// set in their [Column] and all [ManagedRelationshipType.belongsTo] relationships.
  ///
  /// This list cannot be modified.
  List<String>? _defaultProperties;

  /// Derived from this' [tableName].
  ///
  /// This overrides the default [hashCode] implementation for the [ManagedEntity] class.
  /// The hash code is calculated based solely on the [tableName] property of the
  /// [ManagedEntity] instance. This means that two [ManagedEntity] instances will be
  /// considered equal (i.e., have the same hash code) if they have the same [tableName].
  @override
  int get hashCode {
    return tableName.hashCode;
  }

  /// Creates a new instance of the [ManagedObject] subclass associated with this [ManagedEntity].
  ///
  /// By default, the returned object will use a normal value backing map.
  /// If [backing] is non-null, it will be the backing map of the returned object.
  T instanceOf<T extends ManagedObject>({ManagedBacking? backing}) {
    if (backing != null) {
      return (runtime.instanceOfImplementation(backing: backing)..entity = this)
          as T;
    }
    return (runtime.instanceOfImplementation()..entity = this) as T;
  }

  /// Creates a new [ManagedSet] of type [T] from the provided [objects].
  ///
  /// The [objects] parameter should be an [Iterable] of dynamic values that can be
  /// converted to instances of [T]. This method will use the [ManagedEntityRuntime]
  /// implementation to create the appropriate [ManagedSet] instance.
  ///
  /// If the [objects] cannot be converted to instances of [T], this method will
  /// return `null`.
  ManagedSet<T>? setOf<T extends ManagedObject>(Iterable<dynamic> objects) {
    return runtime.setOfImplementation(objects) as ManagedSet<T>?;
  }

  /// Returns an attribute in this entity for a property selector.
  ///
  /// Invokes [identifyProperties] with [propertyIdentifier], and ensures that a single attribute
  /// on this entity was selected. Returns that attribute.
  ManagedAttributeDescription identifyAttribute<T, U extends ManagedObject>(
    T Function(U x) propertyIdentifier,
  ) {
    final keyPaths = identifyProperties(propertyIdentifier);
    if (keyPaths.length != 1) {
      throw ArgumentError(
        "Invalid property selector. Cannot access more than one property for this operation.",
      );
    }

    final firstKeyPath = keyPaths.first;
    if (firstKeyPath.dynamicElements != null) {
      throw ArgumentError(
        "Invalid property selector. Cannot access subdocuments for this operation.",
      );
    }

    final elements = firstKeyPath.path;
    if (elements.length > 1) {
      throw ArgumentError(
        "Invalid property selector. Cannot use relationships for this operation.",
      );
    }

    final propertyName = elements.first!.name;
    final attribute = attributes[propertyName];
    if (attribute == null) {
      if (relationships.containsKey(propertyName)) {
        throw ArgumentError(
            "Invalid property selection. Property '$propertyName' on "
            "'$name' "
            "is a relationship and cannot be selected for this operation.");
      } else {
        throw ArgumentError(
            "Invalid property selection. Column '$propertyName' does not "
            "exist on table '$tableName'.");
      }
    }

    return attribute;
  }

  /// Returns a relationship in this entity for a property selector.
  ///
  /// Invokes [identifyProperties] with [propertyIdentifier], and ensures that a single relationship
  /// on this entity was selected. Returns that relationship.
  ManagedRelationshipDescription
      identifyRelationship<T, U extends ManagedObject>(
    T Function(U x) propertyIdentifier,
  ) {
    final keyPaths = identifyProperties(propertyIdentifier);
    if (keyPaths.length != 1) {
      throw ArgumentError(
        "Invalid property selector. Cannot access more than one property for this operation.",
      );
    }

    final firstKeyPath = keyPaths.first;
    if (firstKeyPath.dynamicElements != null) {
      throw ArgumentError(
        "Invalid property selector. Cannot access subdocuments for this operation.",
      );
    }

    final elements = firstKeyPath.path;
    if (elements.length > 1) {
      throw ArgumentError(
        "Invalid property selector. Cannot identify a nested relationship for this operation.",
      );
    }

    final propertyName = elements.first!.name;
    final desc = relationships[propertyName];
    if (desc == null) {
      throw ArgumentError(
        "Invalid property selection. Relationship named '$propertyName' on table '$tableName' is not a relationship.",
      );
    }

    return desc;
  }

  /// Returns a property selected by [propertyIdentifier].
  ///
  /// Invokes [identifyProperties] with [propertyIdentifier], and ensures that a single property
  /// on this entity was selected. Returns that property.
  KeyPath identifyProperty<T, U extends ManagedObject>(
    T Function(U x) propertyIdentifier,
  ) {
    final properties = identifyProperties(propertyIdentifier);
    if (properties.length != 1) {
      throw ArgumentError(
        "Invalid property selector. Must reference a single property only.",
      );
    }

    return properties.first;
  }

  /// Returns a list of properties selected by [propertiesIdentifier].
  ///
  /// Each selected property in [propertiesIdentifier] is returned in a [KeyPath] object that fully identifies the
  /// property relative to this entity.
  List<KeyPath> identifyProperties<T, U extends ManagedObject>(
    T Function(U x) propertiesIdentifier,
  ) {
    final tracker = ManagedAccessTrackingBacking();
    final obj = instanceOf<U>(backing: tracker);
    propertiesIdentifier(obj);

    return tracker.keyPaths;
  }

  /// Generates an API schema object for this managed entity.
  ///
  /// This method creates an [APISchemaObject] that represents the database table
  /// associated with this managed entity. The schema object includes properties
  /// for each attribute and relationship defined in the entity, excluding any
  /// transient properties or properties that are not included in the default
  /// result set.
  ///
  /// The schema object's title is set to the name of the entity, and the description
  /// is set to a message indicating that no two objects may have the same value for
  /// all of the unique properties defined for this entity (if any).
  ///
  /// The [APIDocumentContext] parameter is used to register the schema object
  /// with the API document context.
  APISchemaObject document(APIDocumentContext context) {
    final schemaProperties = <String, APISchemaObject>{};
    final obj = APISchemaObject.object(schemaProperties)..title = name;

    final buffer = StringBuffer();
    if (uniquePropertySet != null) {
      final propString =
          uniquePropertySet!.map((s) => "'${s.name}'").join(", ");
      buffer.writeln(
        "No two objects may have the same value for all of: $propString.",
      );
    }

    obj.description = buffer.toString();

    properties.forEach((name, def) {
      if (def is ManagedAttributeDescription &&
          !def.isIncludedInDefaultResultSet &&
          !def.isTransient) {
        return;
      }

      final schemaProperty = def!.documentSchemaObject(context);
      schemaProperties[name] = schemaProperty;
    });

    return obj;
  }

  /// Compares two [ManagedEntity] instances for equality based on their [tableName].
  ///
  /// Two [ManagedEntity] instances are considered equal if they have the same [tableName].
  @override
  bool operator ==(Object other) =>
      other is ManagedEntity && tableName == other.tableName;

  /// Provides a string representation of the [ManagedEntity] instance.
  ///
  /// The string representation includes the following information:
  ///
  /// - The name of the database table associated with the entity.
  /// - A list of all attribute properties defined in the entity, with their string representations.
  /// - A list of all relationship properties defined in the entity, with their string representations.
  ///
  /// This method is primarily intended for debugging and logging purposes.
  @override
  String toString() {
    final buf = StringBuffer();
    buf.writeln("Entity: $tableName");

    buf.writeln("Attributes:");
    attributes.forEach((name, attr) {
      buf.writeln("\t$attr");
    });

    buf.writeln("Relationships:");
    relationships.forEach((name, rel) {
      buf.writeln("\t$rel");
    });

    return buf.toString();
  }

  /// Generates an API schema object for this managed entity and registers it with the provided API document context.
  ///
  /// This method creates an [APISchemaObject] that represents the database table
  /// associated with this managed entity. The schema object includes properties
  /// for each attribute and relationship defined in the entity, excluding any
  /// transient properties or properties that are not included in the default
  /// result set.
  ///
  /// The schema object's title is set to the name of the entity, and the description
  /// is set to a message indicating that no two objects may have the same value for
  /// all of the unique properties defined for this entity (if any).
  ///
  /// The [APIDocumentContext] parameter is used to register the schema object
  /// with the API document context.
  @override
  void documentComponents(APIDocumentContext context) {
    final obj = document(context);
    context.schema.register(name, obj, representation: instanceType);
  }
}

/// Defines the runtime implementation for a [ManagedEntity].
///
/// The `ManagedEntityRuntime` interface provides a set of methods that are used to implement the
/// runtime behavior of a [ManagedEntity]. This interface is used by the `ManagedEntity` class to
/// interact with the underlying runtime implementation, which may vary depending on the compilation
/// target (e.g., using mirrors or code generation).
///
/// Implementers of this interface must provide the following functionality:
///
/// - `finalize(ManagedDataModel dataModel)`: Perform any necessary finalization steps for the
///   managed entity, such as setting up caches or performing other initialization tasks.
/// - `instanceOfImplementation({ManagedBacking? backing})`: Create a new instance of the
///   [ManagedObject] associated with the managed entity, optionally using the provided backing
///   object.
/// - `setOfImplementation(Iterable<dynamic> objects)`: Create a new instance of [ManagedSet] for the
///   managed entity, using the provided objects.
/// - `setTransientValueForKey(ManagedObject object, String key, dynamic value)`: Set a transient
///   value for the specified key on the given [ManagedObject] instance.
/// - `getTransientValueForKey(ManagedObject object, String? key)`: Retrieve the transient value
///   for the specified key on the given [ManagedObject] instance.
/// - `isValueInstanceOf(dynamic value)`: Check if the provided value is an instance of the
///   [ManagedObject] associated with the managed entity.
/// - `isValueListOf(dynamic value)`: Check if the provided value is a list of instances of the
///   [ManagedObject] associated with the managed entity.
/// - `getPropertyName(Invocation invocation, ManagedEntity entity)`: Retrieve the property name
///   associated with the provided method invocation, given the managed entity.
/// - `dynamicConvertFromPrimitiveValue(ManagedPropertyDescription property, dynamic value)`:
///   Convert the provided primitive value to the appropriate type for the specified managed
///   property description.
abstract class ManagedEntityRuntime {
  /// Performs any necessary finalization steps for the managed entity, such as setting up caches or performing other initialization tasks.
  ///
  /// This method is called by the [ManagedDataModel] to finalize the managed entity after it has been created. Implementers of this interface
  /// should use this method to perform any necessary setup or initialization tasks for the managed entity, such as building caches or
  /// preparing other data structures.
  ///
  /// The [dataModel] parameter provides access to the overall [ManagedDataModel] that contains this managed entity, which may be useful for
  /// performing finalization tasks that require information about the broader data model.
  void finalize(ManagedDataModel dataModel) {}

  /// The entity associated with this managed object.
  ///
  /// This property provides access to the [ManagedEntity] instance that represents the database table
  /// associated with this [ManagedObject]. The [ManagedEntity] contains metadata about the structure of
  /// the database table, such as the names and types of its columns, and the relationships between
  /// this table and other tables.
  ManagedEntity get entity;

  /// Creates a new instance of this entity's instance type.
  ///
  /// By default, the returned object will use a normal value backing map.
  /// If [backing] is non-null, it will be the backing map of the returned object.
  ManagedObject instanceOfImplementation({ManagedBacking? backing});

  /// Creates a new [ManagedSet] of the type associated with this managed entity from the provided [objects].
  ///
  /// The [objects] parameter should be an [Iterable] of dynamic values that can be
  /// converted to instances of the [ManagedObject] type associated with this managed entity.
  /// This method will use the [ManagedEntityRuntime] implementation to create the appropriate
  /// [ManagedSet] instance.
  ///
  /// If the [objects] cannot be converted to instances of the [ManagedObject] type, this
  /// method will return `null`.
  ManagedSet setOfImplementation(Iterable<dynamic> objects);

  /// Sets a transient value for the specified key on the given [ManagedObject] instance.
  ///
  /// The [object] parameter is the [ManagedObject] instance on which the transient value should be set.
  /// The [key] parameter is the string identifier for the transient value that should be set.
  /// The [value] parameter is the dynamic value that should be assigned to the transient property identified by the [key].
  void setTransientValueForKey(ManagedObject object, String key, dynamic value);

  /// Retrieves the transient value for the specified key on the given [ManagedObject] instance.
  ///
  /// The [object] parameter is the [ManagedObject] instance from which the transient value should be retrieved.
  /// The [key] parameter is the string identifier for the transient value that should be retrieved.
  /// This method returns the dynamic value associated with the transient property identified by the [key].
  /// If the [key] does not exist or is `null`, this method will return `null`.
  dynamic getTransientValueForKey(ManagedObject object, String? key);

  /// Checks if the provided [value] is an instance of the [ManagedObject] associated with this [ManagedEntity].
  ///
  /// This method is used to determine if a given value is an instance of the [ManagedObject] type that corresponds
  /// to the current [ManagedEntity]. This is useful for validating the type of values that are being used with
  /// this managed entity.
  ///
  /// The [value] parameter is the dynamic value to be checked.
  ///
  /// Returns `true` if the [value] is an instance of the [ManagedObject] associated with this [ManagedEntity],
  /// and `false` otherwise.
  bool isValueInstanceOf(dynamic value);

  /// Checks if the provided [value] is a list of instances of the [ManagedObject] associated with this [ManagedEntity].
  ///
  /// This method is used to determine if a given value is a list of instances of the [ManagedObject] type that corresponds
  /// to the current [ManagedEntity]. This is useful for validating the type of values that are being used with
  /// this managed entity.
  ///
  /// The [value] parameter is the dynamic value to be checked.
  ///
  /// Returns `true` if the [value] is a list of instances of the [ManagedObject] associated with this [ManagedEntity],
  /// and `false` otherwise.
  bool isValueListOf(dynamic value);

  /// Retrieves the property name associated with the provided method invocation, given the managed entity.
  ///
  /// This method is used to determine the name of the property that a method invocation is accessing on a
  /// [ManagedObject] instance. This information is often needed to properly handle the invocation and
  /// interact with the managed entity.
  ///
  /// The [invocation] parameter is the [Invocation] object that represents the method invocation.
  /// The [entity] parameter is the [ManagedEntity] instance that the method invocation is being performed on.
  ///
  /// Returns the property name associated with the provided method invocation, or `null` if the property
  /// name cannot be determined.
  String? getPropertyName(Invocation invocation, ManagedEntity entity);

  /// Converts the provided primitive [value] to the appropriate type for the specified [property].
  ///
  /// This method is used to convert a dynamic value, such as one retrieved from a database or API,
  /// into the correct type for a [ManagedPropertyDescription]. The [property] parameter specifies
  /// the type of the property that the value should be converted to.
  ///
  /// The [value] parameter is the dynamic value to be converted. This method will attempt to
  /// convert the [value] to the appropriate type for the [property], based on the property's
  /// [ManagedPropertyType]. If the conversion is not possible, the method may return a value
  /// that is not strictly type-compatible with the property, but is the closest possible
  /// representation.
  ///
  /// The returned value will be of a type that is compatible with the [property]'s
  /// [ManagedPropertyType]. If the conversion is not possible, the method may return a value
  /// that is not strictly type-compatible with the property, but is the closest possible
  /// representation.
  dynamic dynamicConvertFromPrimitiveValue(
    ManagedPropertyDescription property,
    dynamic value,
  );
}
