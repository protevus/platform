/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/managed/managed.dart';

/// Possible data types for [ManagedEntity] attributes.
///
/// This enum represents the different data types that can be used for attributes in a [ManagedEntity].
/// Each enum value corresponds to a specific Dart data type that will be used to represent the attribute.
enum ManagedPropertyType {
  /// Represented by instances of [int].
  integer,

  /// Represented by instances of [int].
  bigInteger,

  /// Represented by instances of [String].
  string,

  /// Represented by instances of [DateTime].
  datetime,

  /// Represented by instances of [bool].
  boolean,

  /// Represented by instances of [double].
  doublePrecision,

  /// Represented by instances of [Map].
  map,

  /// Represented by instances of [List].
  list,

  /// Represented by instances of [Document]
  document
}

/// Represents complex data types for attributes in a [ManagedEntity].
///
/// This class provides a way to represent complex data types, such as maps, lists, and enumerations, that can be used as
/// attributes in a [ManagedEntity]. It encapsulates information about the type, including the primitive kind, the type
/// of elements in the case of collections, and whether the type is an enumeration.
///
/// The [ManagedType] class is used internally by the Protevus database management system to handle the storage and
/// retrieval of complex data types in the database.
class ManagedType {
  /// Creates a new instance of [ManagedType] with the provided parameters.
  ///
  /// [type] must be representable by [ManagedPropertyType].
  ManagedType(this.type, this.kind, this.elements, this.enumerationMap);

  /// Creates a new instance of [ManagedType] with the provided parameters.
  ///
  /// [kind] is the primitive type of the managed property.
  /// [elements] is the type of the elements in the case of a collection (map or list) property.
  /// [enumerationMap] is a map of the enum options and their corresponding Dart enum types, in the case of an enumerated property.
  ///
  /// This method is a convenience constructor for creating [ManagedType] instances with the appropriate parameters.
  static ManagedType make<T>(
    ManagedPropertyType kind,
    ManagedType? elements,
    Map<String, dynamic> enumerationMap,
  ) {
    return ManagedType(T, kind, elements, enumerationMap);
  }

  /// The primitive kind of this type.
  ///
  /// All types have a kind. If [kind] is a map or list, it will also have [elements] to specify the type of the map keys or list elements.
  final ManagedPropertyType kind;

  /// The type of the elements in this managed property.
  ///
  /// If [kind] is a collection (map or list), this value stores the type of each element in the collection.
  /// Keys of map types are always [String].
  final ManagedType? elements;

  /// The Dart type represented by this [ManagedType] instance.
  final Type type;

  /// Whether this [ManagedType] instance represents an enumerated type.
  ///
  /// This property returns `true` if the `enumerationMap` property is not empty, indicating that this type represents an enumeration. Otherwise, it returns `false`.
  bool get isEnumerated => enumerationMap.isNotEmpty;

  /// For enumerated types, this is a map of the name of the option to its Dart enum type.
  ///
  /// This property provides a way to associate the string representation of an enumeration value with its corresponding
  /// Dart enum type. It is used in the context of a [ManagedType] instance to represent an enumerated property in a
  /// [ManagedEntity].
  ///
  /// The keys of this map are the string representations of the enum options, and the values are the corresponding
  /// Dart enum types.
  final Map<String, dynamic> enumerationMap;

  /// Checks whether the provided [dartValue] can be assigned to properties with this [ManagedType].
  ///
  /// This method examines the [kind] of the [ManagedType] and determines whether the provided [dartValue] is compatible
  /// with the expected data type.
  ///
  /// If the [dartValue] is `null`, this method will return `true`, as null can be assigned to any property.
  ///
  /// For each specific [ManagedPropertyType], the method checks the type of the [dartValue] and returns `true` if it
  /// matches the expected type, and `false` otherwise.
  ///
  /// For [ManagedPropertyType.string], if the [enumerationMap] is not empty, the method checks whether the [dartValue]
  /// is one of the enum values in the map.
  ///
  /// @param dartValue The value to be checked for assignment compatibility.
  /// @return `true` if the [dartValue] can be assigned to properties with this [ManagedType], `false` otherwise.
  bool isAssignableWith(dynamic dartValue) {
    if (dartValue == null) {
      return true;
    }

    switch (kind) {
      case ManagedPropertyType.bigInteger:
        return dartValue is int;
      case ManagedPropertyType.integer:
        return dartValue is int;
      case ManagedPropertyType.boolean:
        return dartValue is bool;
      case ManagedPropertyType.datetime:
        return dartValue is DateTime;
      case ManagedPropertyType.doublePrecision:
        return dartValue is double;
      case ManagedPropertyType.map:
        return dartValue is Map<String, dynamic>;
      case ManagedPropertyType.list:
        return dartValue is List<dynamic>;
      case ManagedPropertyType.document:
        return dartValue is Document;
      case ManagedPropertyType.string:
        {
          if (enumerationMap.isNotEmpty) {
            return enumerationMap.values.contains(dartValue);
          }
          return dartValue is String;
        }
    }
  }

  /// Returns a string representation of the [ManagedPropertyType] instance.
  ///
  /// The string representation is simply the name of the [ManagedPropertyType] enum value.
  /// This method is useful for logging or debugging purposes, as it provides a human-readable
  /// representation of the property type.
  ///
  /// Example usage:
  /// ```dart
  /// ManagedPropertyType type = ManagedPropertyType.integer;
  /// print(type.toString()); // Output: "integer"
  /// ```
  @override
  String toString() {
    return "$kind";
  }

  /// Returns a list of Dart types that are supported by the Protevus database management system.
  ///
  /// The supported Dart types are:
  /// - `String`: Represents a string of text.
  /// - `DateTime`: Represents a specific date and time.
  /// - `bool`: Represents a boolean value (true or false).
  /// - `int`: Represents an integer number.
  /// - `double`: Represents a floating-point number.
  /// - `Document`: Represents a complex data structure that can be stored in the database.
  ///
  /// This list of supported types is used internally by the Protevus database management system to ensure that
  /// the data being stored in the database is compatible with the expected data types.
  static List<Type> get supportedDartTypes {
    return [String, DateTime, bool, int, double, Document];
  }

  /// Returns the [ManagedPropertyType] for integer properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.integer] value,
  /// which represents integer properties in a [ManagedEntity].
  static ManagedPropertyType get integer => ManagedPropertyType.integer;

  /// Returns the [ManagedPropertyType] for big integer properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.bigInteger] value,
  /// which represents big integer properties in a [ManagedEntity].
  static ManagedPropertyType get bigInteger => ManagedPropertyType.bigInteger;

  /// Returns the [ManagedPropertyType] for string properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.string] value,
  /// which represents string properties in a [ManagedEntity].
  static ManagedPropertyType get string => ManagedPropertyType.string;

  /// Returns the [ManagedPropertyType] for datetime properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.datetime] value,
  /// which represents datetime properties in a [ManagedEntity].
  static ManagedPropertyType get datetime => ManagedPropertyType.datetime;

  /// Returns the [ManagedPropertyType] for boolean properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.boolean] value,
  /// which represents boolean properties in a [ManagedEntity].
  static ManagedPropertyType get boolean => ManagedPropertyType.boolean;

  /// Returns the [ManagedPropertyType] for double precision properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.doublePrecision] value,
  /// which represents double precision properties in a [ManagedEntity].
  static ManagedPropertyType get doublePrecision =>
      ManagedPropertyType.doublePrecision;

  /// Returns the [ManagedPropertyType] for map properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.map] value,
  /// which represents map properties in a [ManagedEntity].
  static ManagedPropertyType get map => ManagedPropertyType.map;

  /// Returns the [ManagedPropertyType] for list properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.list] value,
  /// which represents list properties in a [ManagedEntity].
  static ManagedPropertyType get list => ManagedPropertyType.list;

  /// Returns the [ManagedPropertyType] for document properties.
  ///
  /// This property provides a convenient way to access the [ManagedPropertyType.document] value,
  /// which represents document properties in a [ManagedEntity].
  static ManagedPropertyType get document => ManagedPropertyType.document;
}
