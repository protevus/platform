abstract class SupportsPartialRelations {
  /// Indicate that the relation is a single result of a larger one-to-many relationship.
  ///
  /// [column] is the column to aggregate, defaults to 'id'.
  /// [aggregate] is the aggregate function, defaults to 'MAX'.
  /// [relation] is the relation name.
  ///
  /// Returns the instance of the class.
  SupportsPartialRelations ofMany(
    String? column = 'id',
    dynamic aggregate = 'MAX',
    String? relation,
  );

  /// Determine whether the relationship is a one-of-many relationship.
  ///
  /// Returns a boolean value indicating whether the relationship is one-of-many.
  bool isOneOfMany();

  /// Get the one of many inner join subselect query builder instance.
  ///
  /// Returns an instance of the query builder or null.
  dynamic getOneOfManySubQuery();
}
