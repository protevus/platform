/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';
import 'package:meta/meta.dart';

/// Represents an API object with support for custom extensions.
///
/// This class extends [Coding] and provides functionality to handle
/// custom extensions in API objects. Extensions are key-value pairs
/// where keys must start with "x-".
///
/// The [extensions] map stores all custom extension data.
///
/// When decoding, it automatically extracts and stores all extension fields.
/// When encoding, it validates that all extension keys start with "x-" and
/// includes them in the encoded output.
class APIObject extends Coding {
  /// A map to store custom extension data for the API object.
  ///
  /// The keys in this map represent extension names, which must start with "x-".
  /// The values can be of any type (dynamic) to accommodate various extension data.
  ///
  /// This map is used to store and retrieve custom extensions that are not part of
  /// the standard API object properties. It allows for flexibility in adding
  /// custom data to API objects without modifying the core structure.
  Map<String, dynamic> extensions = {};

  /// Decodes the API object from a [KeyedArchive].
  ///
  /// This method overrides the [decode] method from the superclass and adds
  /// functionality to handle custom extensions.
  ///
  /// It performs the following steps:
  /// 1. Calls the superclass's decode method to handle standard fields.
  /// 2. Identifies all keys in the [object] that start with "x-" as extension keys.
  /// 3. For each extension key, decodes its value and stores it in the [extensions] map.
  ///
  /// This allows the APIObject to capture and store any custom extensions
  /// present in the decoded data, making them accessible via the [extensions] property.
  ///
  /// [object]: The [KeyedArchive] containing the encoded data to be decoded.
  @mustCallSuper
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    final extensionKeys = object.keys.where((k) => k.startsWith("x-"));
    for (final key in extensionKeys) {
      extensions[key] = object.decode(key);
    }
  }

  /// Encodes the API object into a [KeyedArchive].
  ///
  /// This method overrides the [encode] method from the superclass and adds
  /// functionality to handle custom extensions.
  ///
  /// It performs the following steps:
  /// 1. Validates that all keys in the [extensions] map start with "x-".
  ///    If any invalid keys are found, it throws an [ArgumentError] with details.
  /// 2. Encodes each key-value pair from the [extensions] map into the [object].
  ///
  /// This ensures that all custom extensions are properly encoded and that
  /// the extension naming convention (starting with "x-") is enforced.
  ///
  /// Throws:
  ///   [ArgumentError]: If any extension key does not start with "x-".
  ///
  /// [object]: The [KeyedArchive] where the encoded data will be stored.
  @override
  @mustCallSuper
  void encode(KeyedArchive object) {
    final invalidKeys = extensions.keys
        .where((key) => !key.startsWith("x-"))
        .map((key) => "'$key'")
        .toList();
    if (invalidKeys.isNotEmpty) {
      throw ArgumentError(
        "extension keys must start with 'x-'. The following keys are invalid: ${invalidKeys.join(", ")}",
      );
    }

    extensions.forEach((key, value) {
      object.encode(key, value);
    });
  }
}
