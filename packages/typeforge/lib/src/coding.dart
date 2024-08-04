/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:meta/meta.dart';
import 'package:protevus_typeforge/cast.dart' as cast;
import 'package:protevus_typeforge/codable.dart';

/// Abstract class representing a coding mechanism.
///
/// This class provides a framework for encoding and decoding objects.
/// It includes a [referenceURI] property and a [castMap] getter for type casting.
///
/// The [decode] method is used to populate the object's properties from a [KeyedArchive].
/// It must be called by subclasses, hence the @mustCallSuper annotation.
///
/// The [encode] method is abstract and must be implemented by subclasses to define
/// how the object should be encoded into a [KeyedArchive].
abstract class Coding {
  /// The URI reference for this coding object.
  ///
  /// This property holds a [Uri] that can be used as a reference or identifier
  /// for the coded object. It may represent the location or source of the data,
  /// or serve as a unique identifier within a larger system.
  ///
  /// The [referenceURI] is typically set during decoding and can be accessed
  /// or modified as needed. It may be null if no reference is available or required.
  Uri? referenceURI;

  /// A map of property names to their corresponding cast functions.
  ///
  /// This getter returns a [Map] where the keys are strings representing
  /// property names, and the values are [cast.Cast] functions for those properties.
  /// The cast functions are used to convert decoded values to their appropriate types.
  ///
  /// By default, this getter returns `null`, indicating that no custom casting
  /// is required. Subclasses can override this getter to provide specific
  /// casting behavior for their properties.
  ///
  /// Returns `null` if no custom casting is needed, or a [Map] of property
  /// names to cast functions if custom casting is required.
  Map<String, cast.Cast<dynamic>>? get castMap => null;

  /// Decodes the object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the object's properties from the
  /// provided [KeyedArchive]. It performs two main actions:
  ///
  /// 1. Sets the [referenceURI] of this object to the [referenceURI] of the
  ///    provided [KeyedArchive].
  /// 2. Applies any necessary type casting to the values in the [KeyedArchive]
  ///    using the [castMap] defined for this object.
  ///
  /// This method is marked with [@mustCallSuper], indicating that subclasses
  /// overriding this method must call the superclass implementation.
  ///
  /// [object] The [KeyedArchive] containing the encoded data to be decoded.
  @mustCallSuper
  void decode(KeyedArchive object) {
    referenceURI = object.referenceURI;
    object.castValues(castMap);
  }

  /// Encodes the object into a [KeyedArchive].
  ///
  /// This abstract method must be implemented by subclasses to define
  /// how the object should be encoded into a [KeyedArchive]. The implementation
  /// should write all relevant properties of the object to the provided [object].
  ///
  /// [object] The [KeyedArchive] to which the object's data should be encoded.
  ///
  /// Note that the [referenceURI] of the object is not automatically written
  /// to the [KeyedArchive]. See note in [KeyedArchive._encodedObject].
  void encode(KeyedArchive object);
}
