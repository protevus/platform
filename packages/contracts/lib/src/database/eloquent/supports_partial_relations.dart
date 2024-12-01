/// Interface for models that support partial relations.
///
/// This contract defines how models should handle one-of-many relationships,
/// which are used to retrieve a single record from a one-to-many relationship
/// based on some aggregate condition.
abstract class SupportsPartialRelations {
  /// Indicate that the relation is a single result of a larger one-to-many relationship.
  ///
  /// Example:
  /// ```dart
  /// // Get the user's latest post
  /// user.ofMany('created_at', 'MAX', 'posts');
  ///
  /// // Get the user's most expensive order
  /// user.ofMany('total', 'MAX', 'orders');
  /// ```
  dynamic ofMany([
    String column = 'id',
    String aggregate = 'MAX',
    String? relation,
  ]);

  /// Determine whether the relationship is a one-of-many relationship.
  ///
  /// Example:
  /// ```dart
  /// if (user.latestPost.isOneOfMany()) {
  ///   // Handle one-of-many relationship
  /// }
  /// ```
  bool isOneOfMany();

  /// Get the one of many inner join subselect query builder instance.
  ///
  /// Example:
  /// ```dart
  /// var subQuery = user.latestPost.getOneOfManySubQuery();
  /// ```
  dynamic getOneOfManySubQuery();
}
