/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';
import 'package:protevus_openapi/object.dart';
import 'package:protevus_openapi/v3.dart';

/// Represents a callback object in an OpenAPI specification.
///
/// Each value in the map is a [APIPath] that describes a set of requests that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
class APICallback extends APIObject {
  /// Creates an [APICallback] instance.
  ///
  /// [paths] is an optional parameter that represents the callback paths.
  /// Each key in the [paths] map is a runtime expression that identifies the URL
  /// to be used for the callback request, and the corresponding value is an [APIPath]
  /// object describing the set of requests and expected responses.
  APICallback({this.paths});

  /// Creates an empty [APICallback] instance.
  ///
  /// This constructor initializes an [APICallback] with no paths.
  /// It can be used when you need to create an empty callback object
  /// that will be populated later.
  APICallback.empty();

  /// Callback paths.
  ///
  /// The key that identifies the [APIPath] is a runtime expression that can be evaluated in the context of a runtime HTTP request/response to identify the URL to be used for the callback request. A simple example might be $request.body#/url.
  ///
  /// This map represents the various callback paths available in the API callback.
  /// Each entry in the map consists of:
  /// - A key (String): A runtime expression that identifies the URL for the callback request.
  /// - A value (APIPath): An object describing the set of requests and expected responses for that callback URL.
  ///
  /// The map can be null if no callback paths are defined.
  Map<String, APIPath>? paths;

  /// Decodes the [APICallback] object from a [KeyedArchive].
  ///
  /// This method overrides the `decode` method from the superclass and performs the following steps:
  /// 1. Calls the superclass's `decode` method.
  /// 2. Initializes the `paths` map.
  /// 3. Iterates through each key-value pair in the `object`.
  /// 4. For each pair, it checks if the value is a [KeyedArchive].
  /// 5. If it's not a [KeyedArchive], it throws an [ArgumentError].
  /// 6. If it is a [KeyedArchive], it decodes the value into an [APIPath] object and adds it to the `paths` map.
  ///
  /// Throws:
  ///   - [ArgumentError] if any value in the callback is not an object.
  ///
  /// Parameters:
  ///   - object: The [KeyedArchive] to decode from.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    paths = {};
    object.forEach((key, dynamic value) {
      if (value is! KeyedArchive) {
        throw ArgumentError(
          "Invalid specification. Callback contains non-object value.",
        );
      }
      paths![key] = value.decodeObject(key, () => APIPath())!;
    });
  }

  /// Encodes the [APICallback] object into a [KeyedArchive].
  ///
  /// This method overrides the `encode` method from the superclass.
  /// Currently, this method is not implemented and will throw a [StateError]
  /// when called.
  ///
  /// Parameters:
  ///   - object: The [KeyedArchive] to encode into.
  ///
  /// Throws:
  ///   - [StateError] with the message "APICallback.encode: not yet implemented."
  @override
  void encode(KeyedArchive object) {
    super.encode(object);
    throw StateError("APICallback.encode: not yet implemented.");
  }
}
