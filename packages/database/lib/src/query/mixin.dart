/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/managed/backing.dart';
import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/managed/relationship_type.dart';
import 'package:protevus_database/src/query/page.dart';
import 'package:protevus_database/src/query/query.dart';
import 'package:protevus_database/src/query/sort_descriptor.dart';

/// A mixin that provides the implementation for the [Query] interface.
///
/// This mixin is used to add the functionality of the [Query] interface to a class
/// that represents a database query. It provides methods for setting and retrieving
/// properties of the query, such as the offset, fetch limit, timeout, and value map.
/// It also provides methods for creating and managing subqueries, sorting and paging
/// the results, and validating the input values.
mixin QueryMixin<InstanceType extends ManagedObject>
    implements Query<InstanceType> {
  /// The offset of the query, which determines the starting point for the results.
  ///
  /// The offset is used to skip a certain number of results from the beginning of the
  /// query. For example, an offset of 10 would skip the first 10 results and return
  /// the 11th result and all subsequent results.
  @override
  int offset = 0;

  /// The maximum number of results to fetch from the database.
  ///
  /// When the fetch limit is set to a non-zero value, the query will only return
  /// up to that many results. A fetch limit of 0 (the default) means that there
  /// is no limit on the number of results that can be returned.
  @override
  int fetchLimit = 0;

  /// The maximum number of seconds the query is allowed to run before it is terminated.
  ///
  /// The timeout is used to ensure that queries don't run indefinitely, which could
  /// cause issues in a production environment. If a query takes longer than the
  /// specified timeout, it will be automatically terminated and an error will be
  /// returned.
  @override
  int timeoutInSeconds = 30;

  /// Determines whether the query can modify all instances of the entity, regardless of
  /// any filtering or sorting criteria that may have been applied.
  ///
  /// When this property is set to `true`, the query will be able to modify all instances
  /// of the entity, even if the query has filters or sorting applied that would normally
  /// limit the set of instances that would be modified.
  ///
  /// This property is typically used in administrative or management scenarios, where
  /// the user may need to perform a global modification of all instances of an entity,
  /// regardless of any specific criteria.
  @override
  bool canModifyAllInstances = false;

  /// The value map associated with this query.
  ///
  /// The value map is a dictionary that maps property names to their corresponding values.
  /// This map is used to specify the values to be inserted or updated when the query is executed.
  @override
  Map<String, dynamic>? valueMap;

  /// The predicate of the query, which determines the conditions that must be met for a record to be included in the results.
  ///
  /// The predicate is a boolean expression that is evaluated for each record in the database. Only records for which the predicate
  /// evaluates to `true` will be included in the query results.
  @override
  QueryPredicate? predicate;

  /// The sort predicate of the query, which determines the order in which the results of the query are returned.
  ///
  /// The sort predicate is a list of `QuerySortDescriptor` objects, each of which specifies a property to sort by and the
  /// direction of the sort (ascending or descending). The results of the query will be sorted according to the order
  /// of the sort descriptors in the predicate.
  @override
  QuerySortPredicate? sortPredicate;

  /// The page descriptor for this query, which determines the ordering and
  /// bounding values for the results.
  ///
  /// The page descriptor is used to paginate the results of the query, allowing
  /// the client to retrieve the results in smaller chunks rather than all at
  /// once. It specifies the property to sort the results by, the sort order,
  /// and an optional bounding value to limit the results to a specific range.
  QueryPage? pageDescriptor;

  /// The list of sort descriptors for this query.
  ///
  /// The sort descriptors specify the properties to sort the query results by
  /// and the sort order (ascending or descending) for each property.
  final List<QuerySortDescriptor> sortDescriptors = <QuerySortDescriptor>[];

  /// A dictionary that maps ManagedRelationshipDescription objects to Query objects.
  ///
  /// This dictionary is used to store the subqueries that are created when the [join] method is called on the QueryMixin.
  /// Each key in the dictionary represents a relationship in the database, and the corresponding value is the subquery
  /// that was created to fetch the data for that relationship.
  final Map<ManagedRelationshipDescription, Query> subQueries = {};

  /// The parent query of this query, if any.
  ///
  /// This property is used to keep track of the parent query when this query is a
  /// subquery created by the [join] method. It is used to ensure that the subquery
  /// does not create a cyclic join.
  QueryMixin? _parentQuery;

  /// A list of `QueryExpression` objects that represent the expressions used in the query.
  ///
  /// The `QueryExpression` objects define the conditions that must be met for a record to be included in the query results.
  /// Each expression represents a single condition, and the list of expressions is combined using the logical `AND` operator
  /// to form the final predicate for the query.
  List<QueryExpression<dynamic, dynamic>> expressions = [];

  /// The value object associated with this query.
  ///
  /// This property represents the entity instance that will be used as the
  /// values for the query. It is used to set the values that will be inserted
  /// or updated when the query is executed.
  InstanceType? _valueObject;

  /// The list of properties to fetch for this query.
  ///
  /// This property is initialized to the entity's default properties if it has not
  /// been explicitly set. The properties are represented as `KeyPath` objects, which
  /// encapsulate the path to the property within the entity.
  List<KeyPath>? _propertiesToFetch;

  /// The list of properties to fetch for this query.
  ///
  /// This property is initialized to the entity's default properties if it has not
  /// been explicitly set. The properties are represented as `KeyPath` objects, which
  /// encapsulate the path to the property within the entity.
  List<KeyPath> get propertiesToFetch =>
      _propertiesToFetch ??
      entity.defaultProperties!
          .map((k) => KeyPath(entity.properties[k]))
          .toList();

  /// The value object associated with this query.
  ///
  /// This property represents the entity instance that will be used as the
  /// values for the query. It is used to set the values that will be inserted
  /// or updated when the query is executed.
  ///
  /// If the `_valueObject` is `null`, it is initialized to a new instance of the
  /// entity, and its `backing` property is set to a new `ManagedBuilderBacking`
  /// object that is created from the entity and the current `backing` of the
  /// `_valueObject`.
  ///
  /// The initialized `_valueObject` is then returned.
  @override
  InstanceType get values {
    if (_valueObject == null) {
      _valueObject = entity.instanceOf() as InstanceType?;
      _valueObject!.backing = ManagedBuilderBacking.from(
        _valueObject!.entity,
        _valueObject!.backing,
      );
    }
    return _valueObject!;
  }

  /// Sets the value object associated with this query.
  ///
  /// If the [obj] parameter is `null`, the `_valueObject` property is set to `null`.
  /// Otherwise, a new instance of the entity is created and its `backing` property
  /// is set to a new `ManagedBuilderBacking` object that is created from the entity
  /// and the `backing` of the provided `obj`.
  ///
  /// The initialized `_valueObject` is then assigned to the `_valueObject` property.
  @override
  set values(InstanceType? obj) {
    if (obj == null) {
      _valueObject = null;
      return;
    }

    _valueObject = entity.instanceOf(
      backing: ManagedBuilderBacking.from(entity, obj.backing),
    );
  }

  /// Adds a where clause to the query, which filters the results based on a specified property.
  ///
  /// The `propertyIdentifier` parameter is a function that takes an instance of the `InstanceType` entity
  /// and returns a value of type `T` that represents the property to filter on.
  ///
  /// If the `propertyIdentifier` function references more than one property, an `ArgumentError` will be
  /// thrown.
  ///
  /// The returned `QueryExpression` object represents the expression that will be used to filter the results
  /// of the query. You can call methods on this object to specify the conditions for the filter.
  @override
  QueryExpression<T, InstanceType> where<T>(
    T Function(InstanceType x) propertyIdentifier,
  ) {
    final properties = entity.identifyProperties(propertyIdentifier);
    if (properties.length != 1) {
      throw ArgumentError(
        "Invalid property selector. Must reference a single property only.",
      );
    }

    final expr = QueryExpression<T, InstanceType>(properties.first);
    expressions.add(expr);
    return expr;
  }

  /// Joins a related object or set of objects to the current query.
  ///
  /// This method is used to fetch related objects or sets of objects as part of the
  /// current query. The related objects or sets are specified using a function that
  /// takes an instance of the current entity and returns either a single related
  /// object or a set of related objects.
  ///
  /// The [object] parameter is a function that takes an instance of the current entity
  /// and returns a related object of type `T`. The [set] parameter is a function that
  /// takes an instance of the current entity and returns a set of related objects of
  /// type `T`.
  ///
  /// The return value of this method is a new `Query<T>` object that represents the
  /// subquery for the related objects or set of objects.
  ///
  /// Throws a `StateError` if the same property is joined more than once, or if the
  /// join would create a cyclic relationship.
  @override
  Query<T> join<T extends ManagedObject>({
    T? Function(InstanceType x)? object,
    ManagedSet<T>? Function(InstanceType x)? set,
  }) {
    final relationship = object ?? set!;
    final desc = entity.identifyRelationship(relationship);

    return _createSubquery<T>(desc);
  }

  /// Sets the page descriptor for the query, which determines the ordering and
  /// bounding values for the results.
  ///
  /// The page descriptor is used to paginate the results of the query, allowing
  /// the client to retrieve the results in smaller chunks rather than all at
  /// once. It specifies the property to sort the results by, the sort order,
  /// and an optional bounding value to limit the results to a specific range.
  ///
  /// The [propertyIdentifier] parameter is a function that takes an instance of
  /// the `InstanceType` entity and returns a value of type `T` that represents
  /// the property to sort the results by.
  ///
  /// The [order] parameter specifies the sort order, which can be either
  /// `QuerySortOrder.ascending` or `QuerySortOrder.descending`.
  ///
  /// The [boundingValue] parameter is an optional value that can be used to
  /// limit the results to a specific range. Only results where the value of the
  /// specified property is greater than or equal to the bounding value will be
  /// returned.
  @override
  void pageBy<T>(
    T Function(InstanceType x) propertyIdentifier,
    QuerySortOrder order, {
    T? boundingValue,
  }) {
    final attribute = entity.identifyAttribute(propertyIdentifier);
    pageDescriptor =
        QueryPage(order, attribute.name, boundingValue: boundingValue);
  }

  /// Adds a sort descriptor to the query, which determines the order in which the results are returned.
  ///
  /// The [propertyIdentifier] parameter is a function that takes an instance of the `InstanceType` entity
  /// and returns a value of type `T` that represents the property to sort the results by.
  ///
  /// The [order] parameter specifies the sort order, which can be either `QuerySortOrder.ascending` or
  /// `QuerySortOrder.descending`.
  ///
  /// This method adds a `QuerySortDescriptor` to the `sortDescriptors` list of the query. The descriptor
  /// specifies the name of the property to sort by and the sort order to use.
  @override
  void sortBy<T>(
    T Function(InstanceType x) propertyIdentifier,
    QuerySortOrder order,
  ) {
    final attribute = entity.identifyAttribute(propertyIdentifier);

    sortDescriptors.add(QuerySortDescriptor(attribute.name, order));
  }

  /// Sets the properties to be fetched by the query.
  ///
  /// This method allows you to specify the properties of the entity that should be
  /// fetched by the query. The `propertyIdentifiers` parameter is a function that
  /// takes an instance of the `InstanceType` entity and returns a list of properties
  /// to be fetched.
  ///
  /// Note that you cannot select has-many or has-one relationship properties using
  /// this method. Instead, you should use the `join` method to fetch related objects.
  ///
  /// If you attempt to select a has-many or has-one relationship property, an
  /// `ArgumentError` will be thrown.
  ///
  /// The specified properties are represented as `KeyPath` objects, which encapsulate
  /// the path to the property within the entity.
  @override
  void returningProperties(
    List<dynamic> Function(InstanceType x) propertyIdentifiers,
  ) {
    final properties = entity.identifyProperties(propertyIdentifiers);

    if (properties.any(
      (kp) => kp.path.any(
        (p) =>
            p is ManagedRelationshipDescription &&
            p.relationshipType != ManagedRelationshipType.belongsTo,
      ),
    )) {
      throw ArgumentError(
        "Invalid property selector. Cannot select has-many or has-one relationship properties. Use join instead.",
      );
    }

    _propertiesToFetch = entity.identifyProperties(propertyIdentifiers);
  }

  /// Validates the input values for the query.
  ///
  /// This method is used to validate the values associated with the query before
  /// the query is executed. It checks the validity of the values based on the
  /// specified `Validating` operation (`insert` or `update`).
  ///
  /// If the `valueMap` is `null`, the method will call the appropriate method
  /// (`willInsert` or `willUpdate`) on the `values` object to prepare it for
  /// the specified operation. It then calls the `validate` method on the `values`
  /// object, passing the specified `Validating` operation as the `forEvent`
  /// parameter.
  ///
  /// If the validation context returned by the `validate` method is not valid
  /// (i.e., `ctx.isValid` is `false`), the method will throw a `ValidationException`
  /// with the validation errors.
  ///
  /// Parameters:
  /// - `op`: The `Validating` operation to perform (either `Validating.insert`
  ///   or `Validating.update`).
  void validateInput(Validating op) {
    if (valueMap == null) {
      if (op == Validating.insert) {
        values.willInsert();
      } else if (op == Validating.update) {
        values.willUpdate();
      }

      final ctx = values.validate(forEvent: op);
      if (!ctx.isValid) {
        throw ValidationException(ctx.errors);
      }
    }
  }

  /// Creates a subquery for the specified relationship.
  ///
  /// This method is used to create a subquery for a related object or set of objects
  /// that are part of the current query. The subquery is created using the specified
  /// [fromRelationship], which is a `ManagedRelationshipDescription` object that
  /// describes the relationship between the current entity and the related entity.
  ///
  /// If the same property is joined more than once, a `StateError` will be thrown.
  /// If the join would create a cyclic relationship, a `StateError` will also be
  /// thrown, with a message that suggests joining on a different property.
  ///
  /// The returned `Query<T>` object represents the subquery for the related objects
  /// or set of objects. This subquery can be further customized using the methods
  /// provided by the `Query` interface.
  ///
  /// Parameters:
  /// - `fromRelationship`: The `ManagedRelationshipDescription` object that
  ///   describes the relationship between the current entity and the related entity.
  ///
  /// Returns:
  /// A `Query<T>` object that represents the subquery for the related objects or
  /// set of objects.
  Query<T> _createSubquery<T extends ManagedObject>(
    ManagedRelationshipDescription fromRelationship,
  ) {
    if (subQueries.containsKey(fromRelationship)) {
      throw StateError(
        "Invalid query. Cannot join same property more than once.",
      );
    }

    // Ensure we don't cyclically join
    var parent = _parentQuery;
    while (parent != null) {
      if (parent.subQueries.containsKey(fromRelationship.inverse)) {
        final validJoins = fromRelationship.entity.relationships.values
            .where((r) => !identical(r, fromRelationship))
            .map((r) => "'${r!.name}'")
            .join(", ");

        throw StateError(
            "Invalid query construction. This query joins '${fromRelationship.entity.tableName}' "
            "with '${fromRelationship.inverse!.entity.tableName}' on property '${fromRelationship.name}'. "
            "However, '${fromRelationship.inverse!.entity.tableName}' "
            "has also joined '${fromRelationship.entity.tableName}' on this property's inverse "
            "'${fromRelationship.inverse!.name}' earlier in the 'Query'. "
            "Perhaps you meant to join on another property, such as: $validJoins?");
      }

      parent = parent._parentQuery;
    }

    final subquery = Query<T>(context);
    (subquery as QueryMixin)._parentQuery = this;
    subQueries[fromRelationship] = subquery;

    return subquery;
  }
}
