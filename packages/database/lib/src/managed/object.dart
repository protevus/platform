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
import 'package:protevus_database/src/managed/data_model_manager.dart' as mm;
import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/query/query.dart';
import 'package:protevus_http/http.dart';
import 'package:protevus_openapi/v3.dart';
import 'package:meta/meta.dart';

/// An abstract class that provides storage for [ManagedObject] instances.
///
/// This class is primarily used internally.
///
/// A [ManagedObject] stores properties declared by its type argument in instances of this type.
/// Values are validated against the [ManagedObject.entity].
///
/// Instances of this type only store properties for which a value has been explicitly set. This allows
/// serialization classes to omit unset values from the serialized values. Therefore, instances of this class
/// provide behavior that can differentiate between a property being the null value and a property simply not being
/// set. (Therefore, you must use [removeProperty] instead of setting a value to null to really remove it from instances
/// of this type.)
///
/// Conduit implements concrete subclasses of this class to provide behavior for property storage
/// and query-building.
abstract class ManagedBacking {
  /// Retrieves the value of the specified [ManagedPropertyDescription] property.
  ///
  /// This method is used to get the value of a property from the [ManagedBacking] instance.
  ///
  /// Parameters:
  /// - [property]: The [ManagedPropertyDescription] for the property to retrieve.
  ///
  /// Returns:
  /// The value of the specified property.
  dynamic valueForProperty(ManagedPropertyDescription property);

  /// Sets the value of the specified [ManagedPropertyDescription] property to the provided [value].
  ///
  /// Parameters:
  /// - [property]: The [ManagedPropertyDescription] of the property to be set.
  /// - [value]: The value to be set for the specified property.
  void setValueForProperty(ManagedPropertyDescription property, dynamic value);

  /// Removes a property from the backing map of this [ManagedBacking] instance.
  ///
  /// Use this method to use any reference of a property from this instance.
  void removeProperty(String propertyName) {
    contents.remove(propertyName);
  }

  /// A map of all set values of this instance.
  ///
  /// This property returns a map that contains all the properties that have been set
  /// on this instance of `ManagedBacking`. The keys in the map are the property names,
  /// and the values are the corresponding property values.
  Map<String, dynamic> get contents;
}

/// An abstract class that provides storage for [ManagedObject] instances.
///
/// This class must be subclassed. A subclass is declared for each table in a database. These subclasses
/// create the data model of an application.
///
/// A managed object is declared in two parts, the subclass and its table definition.
///
///         class User extends ManagedObject<_User> implements _User {
///           String name;
///         }
///         class _User {
///           @primaryKey
///           int id;
///
///           @Column(indexed: true)
///           String email;
///         }
///
/// Table definitions are plain Dart objects that represent a database table. Each property is a column in the database.
///
/// A subclass of this type must implement its table definition and use it as the type argument of [ManagedObject]. Properties and methods
/// declared in the subclass (also called the 'instance type') are not stored in the database.
///
/// See more documentation on defining a data model at http://conduit.io/docs/db/modeling_data/
abstract class ManagedObject<T> extends Serializable {
  /// IMPROVEMENT: Cache of entity.properties to reduce property loading time
  ///
  /// This code caches the entity's properties in a `Map<String, ManagedPropertyDescription?>` to
  /// improve the performance of accessing these properties. By caching the properties, the code
  /// avoids having to load them from the `entity` object every time they are needed, which can
  /// improve the overall performance of the application.
  late Map<String, ManagedPropertyDescription?> properties = entity.properties;

  /// A cache of the `entity.properties` map, using the response key name as the key.
  ///
  /// If a property does not have a response key set, the default property name is used as the key instead.
  /// This cache is used to improve the performance of accessing the property information, as it avoids having to
  /// look up the properties in the `entity.properties` map every time they are needed.
  late Map<String, ManagedPropertyDescription?> responseKeyProperties = {
    for (final key in properties.keys) mapKeyName(key): properties[key]
  };

  /// A flag that determines whether to include a property with a null value in the output map.
  ///
  /// When the `ManagedObject` has no properties or the first property's response model has `includeIfNullField` set to `true`,
  /// this flag is set to `true`, indicating that null values should be included in the output map.
  /// Otherwise, it is set to `false`, and null values will be omitted from the output map.
  late final bool modelFieldIncludeIfNull = properties.isEmpty ||
      (properties.values.first?.responseModel?.includeIfNullField ?? true);

  /// Determines the key name to use for a property when serializing the model to a map.
  ///
  /// This method first checks if the property has a response key set, and if so, uses that as the key name.
  /// If the property does not have a response key, it uses the property name.
  /// If the property name is null, it falls back to using the original property name.
  ///
  /// This allows the model to control the key names used in the serialized output, which can be useful for
  /// maintaining consistent naming conventions or working with external APIs that have specific key naming requirements.
  ///
  /// Parameters:
  /// - `propertyName`: The name of the property to get the key name for.
  ///
  /// Returns:
  /// The key name to use for the property when serializing the model to a map.
  String mapKeyName(String propertyName) {
    final property = properties[propertyName];
    return property?.responseKey?.name ?? property?.name ?? propertyName;
  }

  /// A flag that determines whether this class should be automatically documented.
  ///
  /// If `true`, the class will be automatically documented, typically as part of an API documentation generation process.
  /// If `false`, the class will not be automatically documented, and any documentation for it must be added manually.
  static bool get shouldAutomaticallyDocument => false;

  /// The [ManagedEntity] this instance is described by.
  ///
  /// This property holds the [ManagedEntity] that describes the table definition for the managed object
  /// of type `T`. The [ManagedEntity] is used to provide metadata about the object, such as its
  /// properties, relationships, and validation rules.
  ManagedEntity entity = mm.findEntity(T);

  /// The persistent values of this object.
  ///
  /// This property represents the persistent values of the current `ManagedObject` instance. The values are stored in a
  /// [ManagedBacking] object, which is a `Map` where the keys are property names and the values are the corresponding
  /// property values.
  ///
  /// You rarely need to use [backing] directly. There are many implementations of [ManagedBacking]
  /// for fulfilling the behavior of the ORM, so you cannot rely on its behavior.
  ManagedBacking backing = ManagedValueBacking();

  /// Retrieves a value by property name from [backing].
  ///
  /// This operator overload allows you to access the value of a property on the `ManagedObject` instance
  /// using the bracket notation (`instance[propertyName]`).
  ///
  /// Parameters:
  /// - `propertyName`: The name of the property to retrieve the value for.
  ///
  /// Returns:
  /// The value of the specified property, or throws an `ArgumentError` if the property does not exist on the entity.
  dynamic operator [](String propertyName) {
    final prop = properties[propertyName];
    if (prop == null) {
      throw ArgumentError("Invalid property access for '${entity.name}'. "
          "Property '$propertyName' does not exist on '${entity.name}'.");
    }

    return backing.valueForProperty(prop);
  }

  /// Sets a value by property name in [backing].
  ///
  /// This operator overload allows you to set the value of a property on the `ManagedObject` instance
  /// using the bracket notation (`instance[propertyName] = value`).
  ///
  /// Parameters:
  /// - `propertyName`: The name of the property to set the value for.
  /// - `value`: The value to set for the specified property.
  ///
  /// Throws:
  /// - `ArgumentError` if the specified `propertyName` does not exist on the entity.
  void operator []=(String? propertyName, dynamic value) {
    final prop = properties[propertyName];
    if (prop == null) {
      throw ArgumentError("Invalid property access for '${entity.name}'. "
          "Property '$propertyName' does not exist on '${entity.name}'.");
    }

    backing.setValueForProperty(prop, value);
  }

  /// Removes a property from [backing].
  ///
  /// This method removes the specified property from the backing map of the `ManagedBacking` instance.
  ///
  /// Parameters:
  /// - `propertyName`: The name of the property to remove from the backing map.
  void removePropertyFromBackingMap(String propertyName) {
    backing.removeProperty(propertyName);
  }

  /// Removes multiple properties from [backing].
  ///
  /// This method removes the specified properties from the backing map of the `ManagedBacking` instance.
  ///
  /// Parameters:
  /// - `propertyNames`: A list of property names to remove from the backing map.
  void removePropertiesFromBackingMap(List<String> propertyNames) {
    for (final propertyName in propertyNames) {
      backing.removeProperty(propertyName);
    }
  }

  /// Checks whether or not a property has been set in this instances' [backing].
  ///
  /// This method checks if the specified property name exists as a key in the [contents] map of the [backing] object.
  /// It returns `true` if the property has been set, and `false` otherwise.
  ///
  /// Parameters:
  /// - `propertyName`: The name of the property to check for.
  ///
  /// Returns:
  /// `true` if the property has been set in the [backing] object, `false` otherwise.
  bool hasValueForProperty(String propertyName) {
    return backing.contents.containsKey(propertyName);
  }

  /// Callback to modify an object prior to updating it with a [Query].
  ///
  /// Subclasses of this type may override this method to set or modify values prior to being updated
  /// via [Query.update] or [Query.updateOne]. It is automatically invoked by [Query.update] and [Query.updateOne].
  ///
  /// This method is invoked prior to validation and therefore any values modified in this method
  /// are subject to the validation behavior of this instance.
  ///
  /// An example implementation would set the 'updatedDate' of an object each time it was updated:
  ///
  ///         @override
  ///         void willUpdate() {
  ///           updatedDate = new DateTime.now().toUtc();
  ///         }
  ///
  /// This method is only invoked when a query is configured by its [Query.values]. This method is not invoked
  /// if [Query.valueMap] is used to configure a query.
  void willUpdate() {}

  /// Callback to modify an object prior to inserting it with a [Query].
  ///
  /// Subclasses of this type may override this method to set or modify values prior to being inserted
  /// via [Query.insert]. It is automatically invoked by [Query.insert].
  ///
  /// This method is invoked prior to validation and therefore any values modified in this method
  /// are subject to the validation behavior of this instance.
  ///
  /// An example implementation would set the 'createdDate' of an object when it is first created:
  ///         @override
  ///         void willInsert() {
  ///           createdDate = new DateTime.now().toUtc();
  ///         }
  ///
  /// This method is only invoked when a query is configured by its [Query.values]. This method is not invoked
  /// if [Query.valueMap] is used to configure a query.
  void willInsert() {}

  /// Validates an object according to its property [Validate] metadata.
  ///
  /// This method is invoked by [Query] when inserting or updating an instance of this type. By default,
  /// this method runs all of the [Validate] metadata for each property of this instance's persistent type. See [Validate]
  /// for more information. If validations succeed, the returned context [ValidationContext.isValid] will be true. Otherwise,
  /// it is false and all errors are available in [ValidationContext.errors].
  ///
  /// This method returns the result of [ManagedValidator.run]. You may override this method to provide additional validation
  /// prior to insertion or deletion. If you override this method, you *must* invoke the super implementation to
  /// allow [Validate] annotations to run, e.g.:
  ///
  ///         ValidationContext validate({Validating forEvent: Validating.insert}) {
  ///           var context = super(forEvent: forEvent);
  ///
  ///           if (a + b > 10) {
  ///             context.addError("a + b > 10");
  ///           }
  ///
  ///           return context;
  ///         }
  @mustCallSuper
  ValidationContext validate({Validating forEvent = Validating.insert}) {
    return ManagedValidator.run(this, event: forEvent);
  }

  /// Provides dynamic handling of property access and updates.
  ///
  /// This `noSuchMethod` implementation allows for dynamic access and updates to properties of the `ManagedObject`.
  ///
  /// When an unknown method is called on the `ManagedObject`, this implementation will check if the method name
  /// corresponds to a property on the entity. If it does, it will return the value of the property if the method
  /// is a getter, or set the value of the property if the method is a setter.
  ///
  /// If the method name does not correspond to a property, the default `NoSuchMethodError` is thrown.
  ///
  /// This implementation provides a more convenient way to access and update properties compared to using the
  /// square bracket notation (`[]` and `[]=`).
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final propertyName = entity.runtime.getPropertyName(invocation, entity);
    if (propertyName != null) {
      if (invocation.isGetter) {
        return this[propertyName];
      } else if (invocation.isSetter) {
        this[propertyName] = invocation.positionalArguments.first;

        return null;
      }
    }

    throw NoSuchMethodError.withInvocation(this, invocation);
  }

  /// Reads the values from the provided [object] map and sets them on the [ManagedObject] instance.
  ///
  /// This method iterates over the key-value pairs in the [object] map and sets the corresponding
  /// properties on the [ManagedObject] instance. It checks the following:
  ///
  /// - If the key in the [object] map does not correspond to a property in the [responseKeyProperties]
  ///   map, it throws a [ValidationException] with the error message "invalid input key 'key'".
  /// - If the property is marked as private (its name starts with an underscore), it throws a
  ///   [ValidationException] with the error message "invalid input key 'key'".
  /// - If the property is a [ManagedAttributeDescription]:
  ///   - If the property is not transient, it sets the value on the [backing] object using the
  ///     [convertFromPrimitiveValue] method of the property.
  ///   - If the property is transient, it checks if the property is available as input. If not, it
  ///     throws a [ValidationException] with the error message "invalid input key 'key'". Otherwise,
  ///     it sets the transient value on the [ManagedObject] instance using the
  ///     [setTransientValueForKey] method of the [entity.runtime].
  /// - For all other properties, it sets the value on the [backing] object using the
  ///   [convertFromPrimitiveValue] method of the property.
  ///
  /// Parameters:
  /// - [object]: A map of the values to be set on the [ManagedObject] instance.
  ///
  /// Throws:
  /// - [ValidationException] if any of the input keys are invalid or the values cannot be converted
  ///   to the appropriate type.
  @override
  void readFromMap(Map<String, dynamic> object) {
    object.forEach((key, v) {
      final property = responseKeyProperties[key];
      if (property == null) {
        throw ValidationException(["invalid input key '$key'"]);
      }
      if (property.isPrivate) {
        throw ValidationException(["invalid input key '$key'"]);
      }

      if (property is ManagedAttributeDescription) {
        if (!property.isTransient) {
          backing.setValueForProperty(
            property,
            property.convertFromPrimitiveValue(v),
          );
        } else {
          if (!property.transientStatus!.isAvailableAsInput) {
            throw ValidationException(["invalid input key '$key'"]);
          }

          final decodedValue = property.convertFromPrimitiveValue(v);

          if (!property.isAssignableWith(decodedValue)) {
            throw ValidationException(["invalid input type for key '$key'"]);
          }

          entity.runtime
              .setTransientValueForKey(this, property.name, decodedValue);
        }
      } else {
        backing.setValueForProperty(
          property,
          property.convertFromPrimitiveValue(v),
        );
      }
    });
  }

  /// Converts this instance into a serializable map.
  ///
  /// This method returns a map of the key-values pairs in this instance. This value is typically converted into a transmission format like JSON.
  ///
  /// Only properties present in [backing] are serialized, otherwise, they are omitted from the map. If a property is present in [backing] and the value is null,
  /// the value null will be serialized for that property key.
  ///
  /// Usage:
  ///     var json = json.encode(model.asMap());
  @override
  Map<String, dynamic> asMap() {
    final outputMap = <String, dynamic>{};

    backing.contents.forEach((k, v) {
      if (!_isPropertyPrivate(k)) {
        final property = properties[k];
        final value = property!.convertToPrimitiveValue(v);
        if (value == null && !_includeIfNull(property)) {
          return;
        }
        outputMap[mapKeyName(k)] = value;
      }
    });

    entity.attributes.values
        .where((attr) => attr!.transientStatus?.isAvailableAsOutput ?? false)
        .forEach((attr) {
      final value = entity.runtime.getTransientValueForKey(this, attr!.name);
      if (value != null) {
        outputMap[mapKeyName(attr.responseKey?.name ?? attr.name)] = value;
      }
    });

    return outputMap;
  }

  /// Generates an [APISchemaObject] that describes the schema of the managed object.
  ///
  /// This method is used to generate an [APISchemaObject] that describes the schema of the managed object. The resulting
  /// schema object can be used in OpenAPI/Swagger documentation or other API documentation tools.
  ///
  /// The [APIDocumentContext] parameter is used to provide contextual information about the API documentation being generated.
  /// This context is passed to the [ManagedEntity.document] method, which is responsible for generating the schema object.
  ///
  /// Returns:
  /// The [APISchemaObject] that describes the schema of the managed object.
  @override
  APISchemaObject documentSchema(APIDocumentContext context) =>
      entity.document(context);

  /// Checks if a property is private.
  ///
  /// This method checks whether the given property name starts with an underscore,
  /// which is a common convention in Dart to indicate a private property.
  ///
  /// Parameters:
  /// - `propertyName`: The name of the property to check.
  ///
  /// Returns:
  /// `true` if the property name starts with an underscore, indicating that the
  /// property is private, and `false` otherwise.
  static bool _isPropertyPrivate(String propertyName) =>
      propertyName.startsWith("_");

  /// Determines whether to include a property with a null value in the output map.
  ///
  /// This method checks the `includeIfNull` property of the `responseKey` associated with the
  /// given `ManagedPropertyDescription`. If the `responseKey` has an `includeIfNull` value set,
  /// that value is used. Otherwise, the `modelFieldIncludeIfNull` flag is used.
  ///
  /// Parameters:
  /// - `property`: The `ManagedPropertyDescription` to check for the `includeIfNull` setting.
  ///
  /// Returns:
  /// `true` if a property with a null value should be included in the output map, `false` otherwise.
  bool _includeIfNull(ManagedPropertyDescription property) =>
      property.responseKey?.includeIfNull ?? modelFieldIncludeIfNull;
}
