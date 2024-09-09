/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_http/http.dart';
import 'package:protevus_openapi/v3.dart';
import 'package:protevus_runtime/runtime.dart';

/// Interface for serializable instances to be decoded from an HTTP request body and encoded to an HTTP response body.
///
/// Implementers of this interface may be a [Response.body] and bound with an [Bind.body] in [ResourceController].
abstract class Serializable {
  /// Returns an [APISchemaObject] describing this object's type.
  ///
  /// The returned [APISchemaObject] will be of type [APIType.object]. By default, each instance variable
  /// of the receiver's type will be a property of the return value.
  ///
  /// [context] The API document context.
  /// Returns an [APISchemaObject] representing the schema of this serializable object.
  APISchemaObject documentSchema(APIDocumentContext context) {
    return (RuntimeContext.current[runtimeType] as SerializableRuntime)
        .documentSchema(context);
  }

  /// Reads values from [object].
  ///
  /// Use [read] instead of this method. [read] applies filters
  /// to [object] before calling this method.
  ///
  /// This method is used by implementors to assign and use values from [object] for its own
  /// purposes. [SerializableException]s should be thrown when [object] violates a constraint
  /// of the receiver.
  ///
  /// [object] The map containing the values to be read.
  void readFromMap(Map<String, dynamic> object);

  /// Reads values from [object], after applying filters.
  ///
  /// The key name must exactly match the name of the property as defined in the receiver's type.
  /// If [object] contains a key that is unknown to the receiver, an exception is thrown (status code: 400).
  ///
  /// [object] The map containing the values to be read.
  /// [accept] If set, only these keys will be accepted from the object.
  /// [ignore] If set, these keys will be ignored from the object.
  /// [reject] If set, the presence of any of these keys will cause an exception.
  /// [require] If set, all of these keys must be present in the object.
  void read(
    Map<String, dynamic> object, {
    Iterable<String>? accept,
    Iterable<String>? ignore,
    Iterable<String>? reject,
    Iterable<String>? require,
  }) {
    if (accept == null && ignore == null && reject == null && require == null) {
      readFromMap(object);
      return;
    }

    final copy = Map<String, dynamic>.from(object);
    final stillRequired = require?.toList();
    for (final key in object.keys) {
      if (reject?.contains(key) ?? false) {
        throw SerializableException(["invalid input key '$key'"]);
      }
      if ((ignore?.contains(key) ?? false) ||
          !(accept?.contains(key) ?? true)) {
        copy.remove(key);
      }
      stillRequired?.remove(key);
    }

    if (stillRequired?.isNotEmpty ?? false) {
      throw SerializableException(
        ["missing required input key(s): '${stillRequired!.join(", ")}'"],
      );
    }

    readFromMap(copy);
  }

  /// Returns a serializable version of an object.
  ///
  /// This method returns a [Map<String, dynamic>] where each key is the name of a property in the implementing type.
  /// If a [Response.body]'s type implements this interface, this method is invoked prior to any content-type encoding
  /// performed by the [Response].  A [Response.body] may also be a [List<Serializable>], for which this method is invoked on
  /// each element in the list.
  ///
  /// Returns a [Map<String, dynamic>] representation of the object.
  Map<String, dynamic> asMap();

  /// Whether a subclass will automatically be registered as a schema component automatically.
  ///
  /// Defaults to true. When an instance of this subclass is used in a [ResourceController],
  /// it will automatically be registered as a schema component. Its properties will be reflected
  /// on to create the [APISchemaObject]. If false, you must register a schema for the subclass manually.
  ///
  /// Overriding static methods is not enforced by the Dart compiler - check for typos.
  static bool get shouldAutomaticallyDocument => true;
}

/// Exception thrown when there's an error in serialization or deserialization.
class SerializableException implements HandlerException {
  /// Constructor for SerializableException.
  ///
  /// [reasons] A list of reasons for the exception.
  SerializableException(this.reasons);

  /// The reasons for the exception.
  final List<String> reasons;

  /// Generates a response for this exception.
  ///
  /// Returns a [Response] with a bad request status and error details.
  @override
  Response get response {
    return Response.badRequest(
      body: {"error": "entity validation failed", "reasons": reasons},
    );
  }

  /// Returns a string representation of the exception.
  ///
  /// Returns a string containing the error and reasons.
  @override
  String toString() {
    final errorString = response.body["error"] as String?;
    final reasons = (response.body["reasons"] as List).join(", ");
    return "$errorString $reasons";
  }
}

/// Abstract class representing the runtime behavior of a Serializable object.
abstract class SerializableRuntime {
  /// Documents the schema of a Serializable object.
  ///
  /// [context] The API document context.
  /// Returns an [APISchemaObject] representing the schema of the Serializable object.
  APISchemaObject documentSchema(APIDocumentContext context);
}
