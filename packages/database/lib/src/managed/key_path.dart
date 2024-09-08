/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/managed/managed.dart';

/// A class that represents a path to a property in a managed object.
///
/// The `KeyPath` class is used to represent a path to a property within a managed object.
/// It provides methods to create new `KeyPath` instances by removing or adding keys to an
/// existing `KeyPath`.
///
/// The `path` field is a list of `ManagedPropertyDescription` objects, which represent
/// the individual properties that make up the path. The `dynamicElements` field is used
/// to store any dynamic elements that are part of the path.
///
/// Example usage:
/// ```dart
/// final keyPath = KeyPath(managedObject.property);
/// final newKeyPath = KeyPath.byAddingKey(keyPath, managedObject.anotherProperty);
/// ```
class KeyPath {
  /// Constructs a new `KeyPath` instance with the given root property.
  ///
  /// The `path` field of the `KeyPath` instance will be initialized with a single
  /// `ManagedPropertyDescription` object, which represents the root property.
  ///
  /// This constructor is typically used as the starting point for building a `KeyPath`
  /// instance, which can then be further modified using the other constructors and
  /// methods provided by the `KeyPath` class.
  ///
  /// Example:
  /// ```dart
  /// final keyPath = KeyPath(managedObject.property);
  /// ```
  KeyPath(ManagedPropertyDescription? root) : path = [root];

  /// Creates a new `KeyPath` instance by removing the first `offset` keys from the original `KeyPath`.
  ///
  /// This constructor is useful when you want to create a new `KeyPath` that represents a sub-path of an existing `KeyPath`.
  ///
  /// The `original` parameter is the `KeyPath` instance from which the new `KeyPath` will be derived.
  /// The `offset` parameter specifies the number of keys to remove from the beginning of the `original` `KeyPath`.
  ///
  /// The resulting `KeyPath` instance will have a `path` list that contains the remaining keys, starting from the `offset`-th key.
  ///
  /// Example:
  /// ```dart
  /// final originalKeyPath = KeyPath(managedObject.property1).byAddingKey(managedObject.property2);
  /// final subKeyPath = KeyPath.byRemovingFirstNKeys(originalKeyPath, 1);
  /// // The `subKeyPath` will have a `path` list containing only `managedObject.property2`
  /// ```
  KeyPath.byRemovingFirstNKeys(KeyPath original, int offset)
      : path = original.path.sublist(offset);

  /// Constructs a new `KeyPath` instance by adding a new key to the end of an existing `KeyPath`.
  ///
  /// This constructor is useful when you want to create a new `KeyPath` that represents a longer path
  /// by adding a new property to the end of an existing `KeyPath`.
  ///
  /// The `original` parameter is the `KeyPath` instance to which the new key will be added.
  /// The `key` parameter is the `ManagedPropertyDescription` of the new property to be added to the `KeyPath`.
  ///
  /// The resulting `KeyPath` instance will have a `path` list that contains all the keys from the `original`
  /// `KeyPath`, plus the new `key` added to the end.
  ///
  /// Example:
  /// ```dart
  /// final originalKeyPath = KeyPath(managedObject.property1);
  /// final newKeyPath = KeyPath.byAddingKey(originalKeyPath, managedObject.property2);
  /// // The `newKeyPath` will have a `path` list containing both `managedObject.property1` and `managedObject.property2`
  /// ```
  KeyPath.byAddingKey(KeyPath original, ManagedPropertyDescription key)
      : path = List.from(original.path)..add(key);

  /// A list of `ManagedPropertyDescription` objects that represent the individual properties
  /// that make up the path of the `KeyPath` instance. The order of the properties in the
  /// list corresponds to the order of the path.
  ///
  /// This field is used to store the individual properties that make up the path of the `KeyPath`.
  /// Each `ManagedPropertyDescription` object in the list represents a single property in the path.
  /// The order of the properties in the list corresponds to the order of the path, with the first
  /// property in the path being the first element in the list, and so on.
  final List<ManagedPropertyDescription?> path;

  /// A list of dynamic elements that are part of the key path.
  ///
  /// The `dynamicElements` field is used to store any dynamic elements that are part of the `KeyPath`. This allows the `KeyPath` to represent paths that include dynamic or variable elements, in addition to the static property descriptions stored in the `path` field.
  List<dynamic>? dynamicElements;

  /// Returns the `ManagedPropertyDescription` at the specified `index` in the `path` list.
  ///
  /// This operator allows you to access the individual `ManagedPropertyDescription` objects that make up the `KeyPath` instance, using an index.
  ///
  /// Example:
  /// ```dart
  /// final keyPath = KeyPath(managedObject.property1).byAddingKey(managedObject.property2);
  /// final secondProperty = keyPath[1]; // Returns the `ManagedPropertyDescription` for `managedObject.property2`
  /// ```
  ManagedPropertyDescription? operator [](int index) => path[index];

  /// Returns the number of properties in the key path.
  ///
  /// This getter returns the length of the `path` list, which represents the number of
  /// properties that make up the key path. This can be useful when you need to know
  /// how many properties are in the key path, for example, when iterating over them
  /// or performing other operations that require the length of the key path.
  int get length => path.length;

  /// Adds a new `ManagedPropertyDescription` to the end of the `path` list.
  ///
  /// This method is used to add a new property description to the `KeyPath` instance.
  /// The new property description will be appended to the end of the `path` list, effectively
  /// extending the key path.
  ///
  /// This can be useful when you need to create a new `KeyPath` by adding additional properties
  /// to an existing `KeyPath` instance.
  ///
  /// Example:
  /// ```dart
  /// final keyPath = KeyPath(managedObject.property1);
  /// keyPath.add(managedObject.property2);
  /// // The `keyPath` now represents the path "property1.property2"
  /// ```
  void add(ManagedPropertyDescription element) {
    path.add(element);
  }

  /// Adds a dynamic element to the `dynamicElements` list.
  ///
  /// This method is used to add a new dynamic element to the `dynamicElements` list of the `KeyPath` instance.
  /// The `dynamicElements` list is used to store any dynamic or variable elements that are part of the key path, in
  /// addition to the static property descriptions stored in the `path` list.
  ///
  /// If the `dynamicElements` list is `null`, it will be initialized before adding the new element.
  ///
  /// Example:
  /// ```dart
  /// final keyPath = KeyPath(managedObject.property1);
  /// keyPath.addDynamicElement(someVariable);
  /// ```
  void addDynamicElement(dynamic element) {
    dynamicElements ??= [];
    dynamicElements!.add(element);
  }
}
