/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:collection';
import 'package:protevus_database/src/managed/managed.dart';

/// Instances of this type contain zero or more instances of [ManagedObject] and represent has-many relationships.
///
/// 'Has many' relationship properties in [ManagedObject]s are represented by this type. [ManagedSet]s properties may only be declared in the persistent
/// type of a [ManagedObject]. Example usage:
///
///        class User extends ManagedObject<_User> implements _User {}
///        class _User {
///           ...
///           ManagedSet<Post> posts;
///        }
///
///        class Post extends ManagedObject<_Post> implements _Post {}
///        class _Post {
///          ...
///          @Relate(#posts)
///          User user;
///        }
class ManagedSet<InstanceType extends ManagedObject> extends Object
    with ListMixin<InstanceType> {
  /// Creates an empty [ManagedSet].
  ///
  /// This constructor initializes a new [ManagedSet] instance with an empty internal list.
  ManagedSet() {
    _innerValues = [];
  }

  /// Creates a [ManagedSet] from an [Iterable] of [InstanceType]s.
  ///
  /// This constructor initializes a new [ManagedSet] instance with the elements of the provided [Iterable].
  ManagedSet.from(Iterable<InstanceType> items) {
    _innerValues = items.toList();
  }

  /// Creates a [ManagedSet] from an [Iterable] of [dynamic]s.
  ///
  /// This constructor initializes a new [ManagedSet] instance with the elements of the provided [Iterable] of [dynamic]s.
  /// The elements are converted to the appropriate [InstanceType] using [List.from].
  ManagedSet.fromDynamic(Iterable<dynamic> items) {
    _innerValues = List<InstanceType>.from(items);
  }

  /// The internal list that stores the elements of this [ManagedSet].
  late final List<InstanceType> _innerValues;

  /// The number of elements in this [ManagedSet].
  ///
  /// This property returns the number of elements in the internal list that stores the elements of this [ManagedSet].
  @override
  int get length => _innerValues.length;

  /// Sets the length of the internal list that stores the elements of this [ManagedSet].
  ///
  /// This setter allows you to change the length of the internal list that stores the elements of this [ManagedSet].
  /// If the new length is greater than the current length, the list is extended and the new elements are initialized to `null`.
  /// If the new length is less than the current length, the list is truncated to the new length.
  @override
  set length(int newLength) {
    _innerValues.length = newLength;
  }

  /// Adds an [InstanceType] object to this [ManagedSet].
  ///
  /// This method adds the provided [InstanceType] object to the internal list of this [ManagedSet].
  /// The length of the [ManagedSet] is increased by 1, and the new element is appended to the end of the list.
  @override
  void add(InstanceType item) {
    _innerValues.add(item);
  }

  /// Adds all the elements of the provided [Iterable] of [InstanceType] to this [ManagedSet].
  ///
  /// This method adds all the elements of the provided [Iterable] to the internal list of this [ManagedSet].
  /// The length of the [ManagedSet] is increased by the number of elements in the [Iterable], and the new elements
  /// are appended to the end of the list.
  @override
  void addAll(Iterable<InstanceType> items) {
    _innerValues.addAll(items);
  }

  /// Retrieves an [InstanceType] from this set by an index.
  ///
  /// This overloaded index operator allows you to access the elements of the internal list
  /// that stores the elements of this [ManagedSet] using an integer index. The element
  /// at the specified index is returned.
  @override
  InstanceType operator [](int index) => _innerValues[index];

  /// Sets the [InstanceType] object at the specified [index] in this [ManagedSet].
  ///
  /// This overloaded index assignment operator allows you to assign a new [InstanceType] object to the
  /// element at the specified [index] in the internal list that stores the elements of this [ManagedSet].
  /// If the [index] is out of bounds, an [RangeError] will be thrown.
  @override
  void operator []=(int index, InstanceType value) {
    _innerValues[index] = value;
  }
}
