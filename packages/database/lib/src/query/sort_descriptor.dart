/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/query/query.dart';

/// The order in which a collection of objects should be sorted when returned from a database.
///
/// See [Query.sortBy] and [Query.pageBy] for more details.
class QuerySortDescriptor {
  /// Creates a new [QuerySortDescriptor] instance with the specified [key] and [order].
  ///
  /// The [key] parameter represents the name of the property to sort by, and the [order]
  /// parameter specifies the order in which the values should be sorted, as defined by the
  /// [QuerySortOrder] class.
  QuerySortDescriptor(this.key, this.order);

  /// The name of a property to sort by.
  String key;

  /// The order in which values should be sorted.
  ///
  /// See [QuerySortOrder] for possible values.
  /// This property specifies the order in which the values should be sorted, as defined by the
  /// [QuerySortOrder] class. Possible values include [QuerySortOrder.ascending] and
  /// [QuerySortOrder.descending].
  QuerySortOrder order;
}
