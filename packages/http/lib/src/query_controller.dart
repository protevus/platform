/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'package:protevus_database/db.dart';
import 'package:protevus_http/http.dart';

/// A partial class for implementing an [ResourceController] that has a few conveniences
/// for executing [Query]s.
///
/// Instances of [QueryController] are [ResourceController]s that have a pre-baked [Query] available. This [Query]'s type -
/// the [ManagedObject] type is operates on - is defined by [InstanceType].
///
/// The values of [query] are set based on the HTTP method, HTTP path and request body.
/// Prior to executing an operation method in subclasses of [QueryController], the [query]
/// will have the following attributes under the following conditions:
///
/// 1. The [Query] will always have a type argument that matches [InstanceType].
/// 2. If the request contains a path variable that matches the name of the primary key of [InstanceType], the [Query] will set
/// its [Query.where] to match on the [ManagedObject] whose primary key is that value of the path parameter.
/// 3. If the [Request] contains a body, it will be decoded per the [acceptedContentTypes] and deserialized into the [Query.values] property via [ManagedObject.readFromMap].
abstract class QueryController<InstanceType extends ManagedObject>
    extends ResourceController {
  /// Create an instance of [QueryController].
  ///
  /// [context] is the [ManagedContext] used for database operations.
  QueryController(ManagedContext context) : super() {
    query = Query<InstanceType>(context);
  }

  /// A query representing the values received from the [request] being processed.
  ///
  /// You may execute this [query] as is or modify it. The following is true of this property:
  ///
  /// 1. The [Query] will always have a type argument that matches [InstanceType].
  /// 2. If the request contains a path variable that matches the name of the primary key of [InstanceType], the [Query] will set
  /// its [Query.where] to match on the [ManagedObject] whose primary key is that value of the path parameter.
  /// 3. If the [Request] contains a body, it will be decoded per the [acceptedContentTypes] and deserialized into the [Query.values] property via [ManagedObject.readFromMap].
  Query<InstanceType>? query;

  /// Overrides [ResourceController.willProcessRequest] to set up the [query] based on the request.
  ///
  /// This method checks if there's a path variable matching the primary key of [InstanceType],
  /// and if so, sets up the [query] to filter by this primary key value.
  ///
  /// Returns a [Future] that completes with either the [Request] or a [Response].
  @override
  FutureOr<RequestOrResponse> willProcessRequest(Request req) {
    if (req.path.orderedVariableNames.isNotEmpty) {
      final firstVarName = req.path.orderedVariableNames.first;
      final idValue = req.path.variables[firstVarName];

      if (idValue != null) {
        final primaryKeyDesc =
            query!.entity.attributes[query!.entity.primaryKey]!;
        if (primaryKeyDesc.isAssignableWith(idValue)) {
          query!.where((o) => o[query!.entity.primaryKey]).equalTo(idValue);
        } else if (primaryKeyDesc.type!.kind ==
                ManagedPropertyType.bigInteger ||
            primaryKeyDesc.type!.kind == ManagedPropertyType.integer) {
          try {
            query!
                .where((o) => o[query!.entity.primaryKey])
                .equalTo(int.parse(idValue));
          } on FormatException {
            return Response.notFound();
          }
        } else {
          return Response.notFound();
        }
      }
    }

    return super.willProcessRequest(req);
  }

  /// Overrides [ResourceController.didDecodeRequestBody] to populate [query.values] with the decoded request body.
  ///
  /// This method reads the decoded request body into [query.values] and removes the primary key
  /// from the backing map to prevent accidental updates to the primary key.
  ///
  /// [body] is the decoded request body.
  @override
  void didDecodeRequestBody(RequestBody body) {
    query!.values.readFromMap(body.as());
    query!.values.removePropertyFromBackingMap(query!.values.entity.primaryKey);
  }
}
