/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/query/query.dart';

/// Represents a predicate for sorting a collection of objects in a database query.
///
/// This class encapsulates the information needed to sort a collection of objects
/// retrieved from a database, including the name of the property to sort by and
/// the order in which the values should be sorted.
class QuerySortPredicate {
  /// Constructs a new [QuerySortPredicate] instance.
  ///
  /// The [predicate] parameter specifies the name of the property to sort by.
  /// The [order] parameter specifies the order in which the values should be
  /// sorted, using one of the values from the [QuerySortOrder] enum.
  QuerySortPredicate(
    this.predicate,
    this.order,
  );

  /// The name of a property to sort by.
  String predicate;

  /// The order in which values should be sorted.
  ///
  /// This property specifies the order in which the values should be sorted, using one of the values from the [QuerySortOrder] enum.
  QuerySortOrder order;
}
