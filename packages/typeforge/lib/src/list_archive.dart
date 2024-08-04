/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:collection';
import 'package:protevus_typeforge/codable.dart';

/// A list of values in a [KeyedArchive].
///
/// This object is a [List] that has additional behavior for encoding and decoding [Coding] objects.
/// It provides functionality to store and manipulate a list of dynamic values, with special handling
/// for nested maps and lists. The class implements [Referenceable], allowing it to resolve references
/// within its contents when used in conjunction with a [ReferenceResolver].
///
/// The [ListArchive] can be created empty or initialized from an existing list. When initialized
/// from a list, it automatically converts nested maps and lists to [KeyedArchive] and [ListArchive]
/// instances respectively, providing a consistent interface for complex nested structures.
///
/// This class is particularly useful when working with serializable data structures that may
/// contain nested objects or arrays, as it preserves the structure while allowing for easy
/// manipulation and serialization.
class ListArchive extends Object
    with ListBase<dynamic>
    implements Referenceable {
  /// The internal list that stores the dynamic values of this [ListArchive].
  ///
  /// This list can contain various types of elements, including primitive types,
  /// [KeyedArchive] instances (for nested maps), and other [ListArchive] instances
  /// (for nested lists). It is used to maintain the structure and order of the
  /// archived data while providing the necessary functionality for the [ListArchive].
  final List<dynamic> _inner;

  /// Creates an empty [ListArchive].
  ///
  /// This constructor initializes a new [ListArchive] instance with an empty internal list.
  /// The resulting [ListArchive] is ready to accept new elements through its various
  /// list manipulation methods inherited from [ListBase].
  ListArchive() : _inner = [];

  /// Creates a [ListArchive] from an existing [List] of dynamic values.
  ///
  /// This constructor takes a [List] of dynamic values as input and initializes
  /// a new [ListArchive] instance. It processes each element of the input list,
  /// converting any nested [Map] to [KeyedArchive] and nested [List] to [ListArchive].
  /// This conversion is done using the [_toAtchiveType] function.
  ///
  /// The resulting [ListArchive] maintains the structure of the original list
  /// but with enhanced functionality for handling nested data structures.
  ///
  /// Parameters:
  ///   [raw]: The input [List] of dynamic values to be converted into a [ListArchive].
  ///
  /// Returns:
  ///   A new [ListArchive] instance containing the processed elements from the input list.
  ListArchive.from(List<dynamic> raw)
      : _inner = raw.map(_toAtchiveType).toList();

  /// Returns the element at the specified [index] in the list.
  ///
  /// This operator overrides the default list indexing behavior to access
  /// elements in the internal [_inner] list.
  ///
  /// Parameters:
  ///   [index]: An integer index of the element to retrieve.
  ///
  /// Returns:
  ///   The element at the specified [index] in the list.
  ///
  /// Throws:
  ///   [RangeError] if the [index] is out of bounds.
  @override
  dynamic operator [](int index) => _inner[index];

  /// Returns the length of the internal list.
  ///
  /// This getter overrides the [length] property from [ListBase] to provide
  /// the correct length of the internal [_inner] list.
  ///
  /// Returns:
  ///   An integer representing the number of elements in the [ListArchive].
  @override
  int get length => _inner.length;

  /// Sets the length of the internal list.
  ///
  /// This setter overrides the [length] property from [ListBase] to allow
  /// modification of the internal [_inner] list's length. Setting the length
  /// can be used to truncate the list or extend it with null values.
  ///
  /// Parameters:
  ///   [length]: The new length to set for the list.
  ///
  /// Throws:
  ///   [RangeError] if [length] is negative.
  ///   [UnsupportedError] if the list is fixed-length.
  @override
  set length(int length) {
    _inner.length = length;
  }

  /// Sets the value at the specified [index] in the list.
  ///
  /// This operator overrides the default list indexing assignment behavior to
  /// modify elements in the internal [_inner] list.
  ///
  /// Parameters:
  ///   [index]: An integer index of the element to set.
  ///   [val]: The new value to be assigned at the specified [index].
  ///
  /// Throws:
  ///   [RangeError] if the [index] is out of bounds.
  ///   [UnsupportedError] if the list is fixed-length.
  @override
  void operator []=(int index, dynamic val) {
    _inner[index] = val;
  }

  /// Adds a single element to the end of this list.
  ///
  /// This method overrides the [add] method from [ListBase] to add an element
  /// to the internal [_inner] list.
  ///
  /// Parameters:
  ///   [element]: The element to be added to the list. Can be of any type.
  ///
  /// The list grows by one element.
  @override
  void add(dynamic element) {
    _inner.add(element);
  }

  /// Adds all elements of the given [iterable] to the end of this list.
  ///
  /// This method overrides the [addAll] method from [ListBase] to add multiple
  /// elements to the internal [_inner] list.
  ///
  /// Parameters:
  ///   [iterable]: An [Iterable] of elements to be added to the list. The elements
  ///               can be of any type.
  ///
  /// The list grows by the length of the [iterable].
  @override
  void addAll(Iterable<dynamic> iterable) {
    _inner.addAll(iterable);
  }

  /// Converts the [ListArchive] to a list of primitive values.
  ///
  /// This method traverses the [ListArchive] and converts its contents to a list
  /// of primitive values. It recursively processes nested [KeyedArchive] and
  /// [ListArchive] instances, ensuring that the entire structure is converted
  /// to basic Dart types.
  ///
  /// Returns:
  ///   A [List<dynamic>] containing the primitive representation of the [ListArchive].
  ///   - [KeyedArchive] instances are converted to [Map]s.
  ///   - [ListArchive] instances are converted to [List]s.
  ///   - Other values are left as-is.
  ///
  /// This method is useful for serialization purposes or when you need to
  /// convert the [ListArchive] to a format that can be easily serialized
  /// or transmitted.
  List<dynamic> toPrimitive() {
    final out = [];
    for (final val in _inner) {
      if (val is KeyedArchive) {
        out.add(val.toPrimitive());
      } else if (val is ListArchive) {
        out.add(val.toPrimitive());
      } else {
        out.add(val);
      }
    }
    return out;
  }

  /// Resolves references within this [ListArchive] using the provided [ReferenceResolver].
  ///
  /// This method iterates through all elements in the internal list ([_inner]) and
  /// resolves references for nested [KeyedArchive] and [ListArchive] instances.
  /// It's part of the [Referenceable] interface implementation, allowing for
  /// deep resolution of references in complex nested structures.
  ///
  /// Parameters:
  ///   [coder]: A [ReferenceResolver] used to resolve references within the archive.
  ///
  /// Throws:
  ///   May throw exceptions if reference resolution fails, as implied by the method name.
  ///
  /// This method is typically called during the decoding process to ensure all
  /// references within the archive structure are properly resolved.
  @override
  void resolveOrThrow(ReferenceResolver coder) {
    for (final i in _inner) {
      if (i is KeyedArchive) {
        i.resolveOrThrow(coder);
      } else if (i is ListArchive) {
        i.resolveOrThrow(coder);
      }
    }
  }
}

/// Converts a dynamic value to an archive type if necessary.
///
/// This function takes a dynamic value and converts it to an appropriate archive type:
/// - If the input is a [Map<String, dynamic>], it's converted to a [KeyedArchive].
/// - If the input is a [List], it's converted to a [ListArchive].
/// - For all other types, the input is returned as-is.
///
/// This function is used internally by [ListArchive] to ensure that nested structures
/// (maps and lists) are properly converted to their respective archive types when
/// creating a new [ListArchive] instance.
///
/// Parameters:
///   [e]: The dynamic value to be converted.
///
/// Returns:
///   The input value converted to an appropriate archive type, or the original value
///   if no conversion is necessary.
dynamic _toAtchiveType(dynamic e) {
  if (e is Map<String, dynamic>) {
    return KeyedArchive(e);
  } else if (e is List) {
    return ListArchive.from(e);
  }
  return e;
}
