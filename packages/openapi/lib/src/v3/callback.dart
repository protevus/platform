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

/// A map of possible out-of band callbacks related to the parent operation.
///
/// Each value in the map is a [APIPath] that describes a set of requests that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
class APICallback extends APIObject {
  APICallback({this.paths});
  APICallback.empty();

  /// Callback paths.
  ///
  /// The key that identifies the [APIPath] is a runtime expression that can be evaluated in the context of a runtime HTTP request/response to identify the URL to be used for the callback request. A simple example might be $request.body#/url.
  Map<String, APIPath>? paths;

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

  @override
  void encode(KeyedArchive object) {
    super.encode(object);
    throw StateError("APICallback.encode: not yet implemented.");
  }
}
