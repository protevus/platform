/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/managed/relationship_type.dart';

/// An [ArgumentError] thrown when attempting to access an invalid property while building a `Query.values`.
///
/// This error is thrown when attempting to access a property that is not backed by a column in the database table being inserted into.
/// This prohibits accessing `ManagedObject` and `ManagedSet` properties, except for `ManagedObject` properties with a `Relate` annotation.
/// For `Relate` properties, you may only set their primary key property.
final ArgumentError _invalidValueConstruction = ArgumentError(
    "Invalid property access when building 'Query.values'. "
    "May only assign values to properties backed by a column of the table being inserted into. "
    "This prohibits 'ManagedObject' and 'ManagedSet' properties, except for 'ManagedObject' "
    "properties with a 'Relate' annotation. For 'Relate' properties, you may only set their "
    "primary key property.");

/// A concrete implementation of [ManagedBacking] that stores the values of a [ManagedObject].
///
/// This class is responsible for managing the actual values of a [ManagedObject]. It provides methods to get and set the
/// values of the object's properties, and ensures that the values are valid according to the property's type.
///
/// When setting a value for a property, this class checks if the value is assignable to the property's type. If the value
/// is not assignable, a [ValidationException] is thrown.
class ManagedValueBacking extends ManagedBacking {
  @override
  Map<String, dynamic> contents = {};

  @override
  dynamic valueForProperty(ManagedPropertyDescription property) {
    return contents[property.name];
  }

  @override
  void setValueForProperty(ManagedPropertyDescription property, dynamic value) {
    if (value != null) {
      if (!property.isAssignableWith(value)) {
        throw ValidationException(
          ["invalid input value for '${property.name}'"],
        );
      }
    }

    contents[property.name] = value;
  }
}

/// A concrete implementation of [ManagedBacking] that is designed to work with foreign key properties of a [ManagedObject].
///
/// This class is used when you need to create a new [ManagedObject] instance and only set its primary key property, which is
/// typically the foreign key property in a relationship. It allows you to set the primary key property without having to create
/// a full [ManagedObject] instance.
///
/// The `ManagedForeignKeyBuilderBacking` class is useful when you are building a [Query] and need to set the foreign key property
/// of a related object, without creating the full related object. It ensures that only the primary key property can be set, and
/// throws an [ArgumentError] if you try to set any other properties.
class ManagedForeignKeyBuilderBacking extends ManagedBacking {
  ManagedForeignKeyBuilderBacking();
  ManagedForeignKeyBuilderBacking.from(
    ManagedEntity entity,
    ManagedBacking backing,
  ) {
    if (backing.contents.containsKey(entity.primaryKey)) {
      contents[entity.primaryKey] = backing.contents[entity.primaryKey];
    }
  }

  @override
  Map<String, dynamic> contents = {};

  @override
  dynamic valueForProperty(ManagedPropertyDescription property) {
    if (property is ManagedAttributeDescription && property.isPrimaryKey) {
      return contents[property.name];
    }

    throw _invalidValueConstruction;
  }

  @override
  void setValueForProperty(ManagedPropertyDescription property, dynamic value) {
    if (property is ManagedAttributeDescription && property.isPrimaryKey) {
      contents[property.name] = value;
      return;
    }

    throw _invalidValueConstruction;
  }
}

/// A concrete implementation of [ManagedBacking] that is designed to work with [ManagedObject] instances being used in a [Query.values].
///
/// This class is responsible for managing the values of a [ManagedObject] instance when it is being used to build a `Query.values` object.
/// It allows you to set the values of the object's properties, including its relationship properties, in a way that is compatible with the
/// constraints of the `Query.values` object.
///
/// When setting a value for a property, this class checks the type of the property and ensures that the value being set is compatible with it.
/// For example, if the property is a [ManagedRelationshipDescription] with a `ManagedRelationshipType.belongsTo` relationship type, this class will
/// allow you to set the property to a [ManagedObject] instance or `null`, but not to a [ManagedSet] or other [ManagedObject] type.
///
/// If you attempt to set an invalid value for a property, this class will throw an [ArgumentError] with a helpful error message.
class ManagedBuilderBacking extends ManagedBacking {
  ManagedBuilderBacking();
  ManagedBuilderBacking.from(ManagedEntity entity, ManagedBacking original) {
    if (original is! ManagedValueBacking) {
      throw ArgumentError(
        "Invalid 'ManagedObject' assignment to 'Query.values'. Object must be created through default constructor.",
      );
    }

    original.contents.forEach((key, value) {
      final prop = entity.properties[key];
      if (prop == null) {
        throw ArgumentError(
          "Invalid 'ManagedObject' assignment to 'Query.values'. Property '$key' does not exist for '${entity.name}'.",
        );
      }

      if (prop is ManagedRelationshipDescription) {
        if (!prop.isBelongsTo) {
          return;
        }
      }

      setValueForProperty(prop, value);
    });
  }

  /// The contents of the `ManagedValueBacking` class, which is a map that stores the values of a `ManagedObject`.
  @override
  Map<String, dynamic> contents = {};

  /// Retrieves the value for the given property in the `ManagedBacking` instance.
  ///
  /// If the property is a [ManagedRelationshipDescription] and not a `belongsTo` relationship,
  /// an [ArgumentError] is thrown with the `_invalidValueConstruction` message.
  ///
  /// If the property is a [ManagedRelationshipDescription] and the key is not present in the
  /// `contents` map, a new [ManagedObject] instance is created using the `ManagedForeignKeyBuilderBacking`
  /// and stored in the `contents` map under the property name.
  ///
  /// The value for the property is then returned from the `contents` map.
  @override
  dynamic valueForProperty(ManagedPropertyDescription property) {
    if (property is ManagedRelationshipDescription) {
      if (!property.isBelongsTo) {
        throw _invalidValueConstruction;
      }

      if (!contents.containsKey(property.name)) {
        contents[property.name] = property.inverse!.entity
            .instanceOf(backing: ManagedForeignKeyBuilderBacking());
      }
    }

    return contents[property.name];
  }

  /// Sets the value for the specified property in the `ManagedBacking` instance.
  ///
  /// If the property is a [ManagedRelationshipDescription] and not a `belongsTo` relationship,
  /// an [ArgumentError] is thrown with the `_invalidValueConstruction` message.
  ///
  /// If the property is a [ManagedRelationshipDescription] and the value is `null`, the
  /// value in the `contents` map is set to `null`.
  ///
  /// If the property is a [ManagedRelationshipDescription] and the value is not `null`,
  /// a new [ManagedObject] instance is created using the `ManagedForeignKeyBuilderBacking`
  /// and stored in the `contents` map under the property name.
  ///
  /// For all other property types, the value is simply stored in the `contents` map.
  @override
  void setValueForProperty(ManagedPropertyDescription property, dynamic value) {
    if (property is ManagedRelationshipDescription) {
      if (!property.isBelongsTo) {
        throw _invalidValueConstruction;
      }

      if (value == null) {
        contents[property.name] = null;
      } else {
        final original = value as ManagedObject;
        final replacementBacking = ManagedForeignKeyBuilderBacking.from(
          original.entity,
          original.backing,
        );
        final replacement =
            original.entity.instanceOf(backing: replacementBacking);
        contents[property.name] = replacement;
      }
    } else {
      contents[property.name] = value;
    }
  }
}

/// A concrete implementation of [ManagedBacking] that tracks the access of properties in a [ManagedObject].
///
/// This class is designed to monitor the access of properties in a [ManagedObject] instance. It keeps track of the
/// [KeyPath]s that are accessed, and when a property is accessed, it creates a new object or set based on the
/// type of the property.
///
/// For [ManagedRelationshipDescription] properties, it creates a new instance of the destination entity with a
/// `ManagedAccessTrackingBacking` backing, or a [ManagedSet] for `hasMany` relationships. For [ManagedAttributeDescription]
/// properties with a document type, it creates a [DocumentAccessTracker] object.
///
/// The `keyPaths` list keeps track of all the [KeyPath]s that have been accessed, and the `workingKeyPath` property
/// keeps track of the current [KeyPath] being built.
class ManagedAccessTrackingBacking extends ManagedBacking {
  List<KeyPath> keyPaths = [];
  KeyPath? workingKeyPath;

  @override
  Map<String, dynamic> get contents => {};

  @override
  dynamic valueForProperty(ManagedPropertyDescription property) {
    if (workingKeyPath != null) {
      workingKeyPath!.add(property);

      return forward(property, workingKeyPath);
    }

    final keyPath = KeyPath(property);
    keyPaths.add(keyPath);

    return forward(property, keyPath);
  }

  @override
  void setValueForProperty(ManagedPropertyDescription property, dynamic value) {
    // no-op
  }

  dynamic forward(ManagedPropertyDescription property, KeyPath? keyPath) {
    if (property is ManagedRelationshipDescription) {
      final tracker = ManagedAccessTrackingBacking()..workingKeyPath = keyPath;
      if (property.relationshipType == ManagedRelationshipType.hasMany) {
        return property.inverse!.entity.setOf([]);
      } else {
        return property.destinationEntity.instanceOf(backing: tracker);
      }
    } else if (property is ManagedAttributeDescription &&
        property.type!.kind == ManagedPropertyType.document) {
      return DocumentAccessTracker(keyPath);
    }

    return null;
  }
}

/// A class that tracks access to a document property in a [ManagedObject].
///
/// This class is used in conjunction with the [ManagedAccessTrackingBacking] class to monitor
/// the access of document properties in a [ManagedObject] instance. When a document property
/// is accessed, a new instance of this class is created, and the [KeyPath] that represents
/// the access to the document property is updated.
///
/// The `owner` property of this class holds the [KeyPath] that represents the access to the
/// document property. When the overridden `operator []` is called, it adds the key or index
/// used to access the document property to the `owner` [KeyPath].
class DocumentAccessTracker extends Document {
  DocumentAccessTracker(this.owner);

  final KeyPath? owner;

  @override
  dynamic operator [](dynamic keyOrIndex) {
    owner!.addDynamicElement(keyOrIndex);
    return this;
  }
}
