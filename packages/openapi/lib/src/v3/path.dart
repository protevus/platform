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

/// Represents a path in an API specification.
///
/// An [APIPath] MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available.
class APIPath extends APIObject {
  /// Constructs an [APIPath] instance.
  ///
  /// [summary] is an optional string summary, intended to apply to all operations in this path.
  /// [description] is an optional string description, intended to apply to all operations in this path.
  /// [parameters] is a list of parameters applicable for all operations described under this path. Defaults to an empty list if not provided.
  /// [operations] is a map of HTTP methods to their corresponding [APIOperation] objects. Defaults to an empty map if not provided.
  APIPath({
    this.summary,
    this.description,
    List<APIParameter?>? parameters,
    Map<String, APIOperation?>? operations,
  }) {
    this.parameters = parameters ?? [];
    this.operations = operations ?? {};
  }

  /// Creates an empty [APIPath] instance.
  ///
  /// This constructor initializes an [APIPath] with an empty list of parameters
  /// and an empty map of operations. It's useful when you need to create an
  /// [APIPath] instance without any initial data, which can be populated later.
  APIPath.empty()
      : parameters = <APIParameter?>[],
        operations = <String, APIOperation?>{};

  /// An optional, string summary, intended to apply to all operations in this path.
  ///
  /// This property provides a brief overview or summary that is applicable to all
  /// operations defined within this path. It can be used to quickly convey the
  /// general purpose or functionality of the path without going into specific details
  /// of individual operations.
  String? summary;

  /// An optional, string description, intended to apply to all operations in this path.
  ///
  /// This property provides a more detailed explanation that is applicable to all
  /// operations defined within this path. It can be used to offer comprehensive
  /// information about the path's purpose, usage, or any other relevant details.
  ///
  /// The description supports CommonMark syntax, allowing for rich text representation.
  /// This enables the use of formatted text, links, lists, and other markdown elements
  /// to create more readable and informative descriptions.
  ///
  /// CommonMark syntax MAY be used for rich text representation.
  String? description;

  /// A list of parameters that are applicable for all the operations described under this path.
  ///
  /// These parameters can be overridden at the operation level, but cannot be removed there.
  /// The list MUST NOT include duplicated parameters. A unique parameter is defined by a
  /// combination of a name and location. The list can use the Reference Object to link to
  /// parameters that are defined at the OpenAPI Object's components/parameters.
  ///
  /// This property is marked as 'late' to allow for delayed initialization. It holds a list
  /// of [APIParameter] objects, where each object represents a parameter applicable to all
  /// operations under this path. The list may contain null values, which should be handled
  /// appropriately when processing the parameters.
  ///
  /// The parameters defined here serve as default parameters for all operations in this path,
  /// providing a way to specify common parameters without repeating them for each operation.
  late List<APIParameter?> parameters;

  /// Definitions of operations on this path.
  ///
  /// A map where keys are lowercased HTTP methods (e.g., get, put, delete, post)
  /// and values are corresponding [APIOperation] objects.
  ///
  /// This property defines the available operations for this path, associating
  /// each HTTP method with its specific operation details. The use of lowercase
  /// keys ensures consistency and case-insensitive matching of HTTP methods.
  ///
  /// The map may contain null values, which should be handled appropriately
  /// when processing the operations. This property is marked as 'late' to allow
  /// for delayed initialization, typically done in the constructor or a dedicated
  /// initialization method.
  late Map<String, APIOperation?> operations;

  /// Checks if this path contains specific path parameters.
  ///
  /// Returns true if [parameters] contains path parameters with names that match [parameterNames] and
  /// both lists have the same number of elements.
  bool containsPathParameters(List<String> parameterNames) {
    final pathParams = parameters
        .where((p) => p?.location == APIParameterLocation.path)
        .map((p) => p?.name)
        .toList();
    if (pathParams.length != parameterNames.length) {
      return false;
    }

    return parameterNames.every((check) => pathParams.contains(check));
  }

  // todo (joeconwaystk): alternative servers not yet implemented

  /// Decodes the [APIPath] instance from a [KeyedArchive] object.
  ///
  /// This method populates the properties of the [APIPath] instance using data
  /// from the provided [KeyedArchive] object. It decodes the following properties:
  ///
  /// - [summary]: A brief summary of the path.
  /// - [description]: A detailed description of the path.
  /// - [parameters]: A list of [APIParameter] objects applicable to all operations in this path.
  /// - [operations]: A map of HTTP methods to their corresponding [APIOperation] objects.
  ///
  /// The method first calls the superclass's decode method, then decodes each specific
  /// property. For [parameters], it uses a factory function to create empty [APIParameter]
  /// instances if needed. For [operations], it checks for the presence of each HTTP method
  /// in the archive and decodes the corresponding [APIOperation] if present.
  ///
  /// @param object The [KeyedArchive] object containing the encoded data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    summary = object.decode("summary");
    description = object.decode("description");
    parameters =
        object.decodeObjects("parameters", () => APIParameter.empty()) ??
            <APIParameter?>[];

    final methodNames = [
      "get",
      "put",
      "post",
      "delete",
      "options",
      "head",
      "patch",
      "trace"
    ];
    for (final methodName in methodNames) {
      if (object.containsKey(methodName)) {
        operations[methodName] =
            object.decodeObject(methodName, () => APIOperation.empty());
      }
    }
  }

  /// Encodes the [APIPath] instance into a [KeyedArchive] object.
  ///
  /// This method serializes the properties of the [APIPath] instance into the provided
  /// [KeyedArchive] object. It encodes the following properties:
  ///
  /// - [summary]: A brief summary of the path.
  /// - [description]: A detailed description of the path.
  /// - [parameters]: A list of [APIParameter] objects applicable to all operations in this path.
  /// - [operations]: A map of HTTP methods to their corresponding [APIOperation] objects.
  ///
  /// The method first calls the superclass's encode method, then encodes each specific
  /// property. For [parameters], it only encodes the list if it's not empty. For [operations],
  /// it iterates through the map and encodes each operation, ensuring the HTTP method names
  /// are in lowercase.
  ///
  /// @param object The [KeyedArchive] object to encode the data into.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("summary", summary);
    object.encode("description", description);
    if (parameters.isNotEmpty) {
      object.encodeObjects("parameters", parameters);
    }

    operations.forEach((opName, op) {
      object.encodeObject(opName.toLowerCase(), op);
    });
  }
}
