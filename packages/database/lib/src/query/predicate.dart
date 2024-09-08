/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/persistent_store/persistent_store.dart';
import 'package:protevus_database/src/query/query.dart';

/// A predicate contains instructions for filtering rows when performing a [Query].
///
/// Predicates currently are the WHERE clause in a SQL statement and are used verbatim
/// by the [PersistentStore]. In general, you should use [Query.where] instead of using this class directly, as [Query.where] will
/// use the underlying [PersistentStore] to generate a [QueryPredicate] for you.
///
/// A predicate has a format and parameters. The format is the [String] that comes after WHERE in a SQL query. The format may
/// have parameterized values, for which the corresponding value is in the [parameters] map. A parameter is prefixed with '@' in the format string. Currently,
/// the format string's parameter syntax is defined by the [PersistentStore] it is used on. An example of that format:
///
///     var predicate = new QueryPredicate("x = @xValue", {"xValue" : 5});
class QueryPredicate {
  /// Default constructor for [QueryPredicate].
  ///
  /// The [format] and [parameters] of this predicate. [parameters] may be null.
  QueryPredicate(this.format, [this.parameters = const {}]);

  /// Creates an empty [QueryPredicate] instance.
  ///
  /// The format string is the empty string and parameters is the empty map.
  QueryPredicate.empty()
      : format = "",
        parameters = {};

  /// Combines [predicates] with 'AND' keyword.
  ///
  /// This factory method takes an [Iterable] of [QueryPredicate] instances and combines them
  /// using the 'AND' keyword. The resulting [QueryPredicate] will have a [format] string that
  /// is the concatenation of each individual [QueryPredicate]'s [format] string, separated by
  /// the 'AND' keyword. The [parameters] map will be a combination of all the individual
  /// [QueryPredicate]'s [parameters] maps.
  ///
  /// If there are duplicate parameter names in [predicates], they will be disambiguated by suffixing
  /// the parameter name in both [format] and [parameters] with a unique integer.
  ///
  /// If [predicates] is null or empty, an empty predicate is returned. If [predicates] contains only
  /// one predicate, that predicate is returned.
  factory QueryPredicate.and(Iterable<QueryPredicate> predicates) {
    /// Filters the provided [predicates] to only include those with a non-empty [QueryPredicate.format].
    ///
    /// This method creates a new list containing only the [QueryPredicate] instances from the provided [Iterable]
    /// that have a non-empty [QueryPredicate.format] string.
    ///
    /// @param predicates The [Iterable] of [QueryPredicate] instances to filter.
    /// @return A new [List] containing the [QueryPredicate] instances from [predicates] that have a non-empty [QueryPredicate.format].
    final predicateList = predicates.where((p) => p.format.isNotEmpty).toList();

    /// If the provided [predicateList] is empty, this method returns an empty [QueryPredicate].
    ///
    /// If the [predicateList] contains only a single predicate, this method returns that single predicate.
    if (predicateList.isEmpty) {
      return QueryPredicate.empty();
    }

    if (predicateList.length == 1) {
      return predicateList.first;
    }

    /// If there are duplicate parameter names in [predicates], this variable is used to
    /// disambiguate them by suffixing the parameter name in both [format] and [parameters]
    /// with a unique integer.
    int dupeCounter = 0;

    /// Stores the format strings for each predicate in the `predicateList`.
    ///
    /// This list is used to build the final `format` string for the combined `QueryPredicate`.
    final allFormatStrings = [];

    /// A map that stores the values to replace in the [format] string of a [QueryPredicate] at execution time.
    ///
    /// The keys of this map will be searched for in the [format] string of the [QueryPredicate] and replaced with
    /// their corresponding values. This allows the [QueryPredicate] to be parameterized, rather than having
    /// dynamic values directly embedded in the [format] string.
    final valueMap = <String, dynamic>{};

    /// Combines the provided [QueryPredicate] instances using the 'AND' keyword.
    ///
    /// This method takes an [Iterable] of [QueryPredicate] instances and combines them
    /// using the 'AND' keyword. The resulting [QueryPredicate] will have a [format] string that
    /// is the concatenation of each individual [QueryPredicate]'s [format] string, separated by
    /// the 'AND' keyword. The [parameters] map will be a combination of all the individual
    /// [QueryPredicate]'s [parameters] maps.
    ///
    /// If there are duplicate parameter names in [predicates], they will be disambiguated by suffixing
    /// the parameter name in both [format] and [parameters] with a unique integer.
    ///
    /// If [predicates] is null or empty, an empty predicate is returned. If [predicates] contains only
    /// one predicate, that predicate is returned.
    ///
    /// The code performs the following steps:
    /// 1. Filters the provided [predicates] to only include those with a non-empty [QueryPredicate.format].
    /// 2. If the filtered list is empty, returns an empty [QueryPredicate].
    /// 3. If the filtered list contains only one predicate, returns that predicate.
    /// 4. Initializes a `dupeCounter` variable to keep track of duplicate parameter names.
    /// 5. Iterates through the filtered list of [QueryPredicate] instances:
    ///    - If there are any duplicate parameter names, it replaces them in the `format` string and
    ///      the `parameters` map with a unique identifier.
    ///    - Adds the modified `format` string to the `allFormatStrings` list.
    ///    - Adds the `parameters` map (with any modifications) to the `valueMap`.
    /// 6. Constructs the final `predicateFormat` string by joining the `allFormatStrings` with the 'AND' keyword.
    /// 7. Returns a new [QueryPredicate] instance with the `predicateFormat` and the `valueMap`.
    for (final predicate in predicateList) {
      final duplicateKeys = predicate.parameters.keys
          .where((k) => valueMap.keys.contains(k))
          .toList();

      if (duplicateKeys.isNotEmpty) {
        var fmt = predicate.format;
        final Map<String, String> dupeMap = {};
        for (final key in duplicateKeys) {
          final replacementKey = "$key$dupeCounter";
          fmt = fmt.replaceAll("@$key", "@$replacementKey");
          dupeMap[key] = replacementKey;
          dupeCounter++;
        }

        allFormatStrings.add(fmt);
        predicate.parameters.forEach((key, value) {
          valueMap[dupeMap[key] ?? key] = value;
        });
      } else {
        allFormatStrings.add(predicate.format);
        valueMap.addAll(predicate.parameters);
      }
    }

    final predicateFormat = "(${allFormatStrings.join(" AND ")})";
    return QueryPredicate(predicateFormat, valueMap);
  }

  /// The string format of this predicate.
  ///
  /// This is the predicate text. Do not write dynamic values directly to the format string, instead, prefix an identifier with @
  /// and add that identifier to the [parameters] map.
  String format;

  /// A map of values to replace in the format string at execution time.
  ///
  /// This map contains the parameter values that will be used to replace placeholders (prefixed with '@') in the [format] string when the [QueryPredicate] is executed. The keys of this map correspond to the parameter names in the [format] string, and the values are the actual values to be substituted.
  ///
  /// For example, if the [format] string is `"x = @xValue AND y > @yValue"`, the [parameters] map might look like `{"xValue": 5, "yValue": 10}`. When the [QueryPredicate] is executed, the placeholders `@xValue` and `@yValue` in the [format] string will be replaced with the corresponding values from the [parameters] map.
  ///
  /// Input values should not be directly embedded in the [format] string, but instead provided in this [parameters] map. This allows the [QueryPredicate] to be parameterized, rather than having dynamic values directly included in the [format] string.
  Map<String, dynamic> parameters;
}

/// The operator used in a comparison-based predicate expression.
///
/// The available operators are:
///
/// - `lessThan`: Less than
/// - `greaterThan`: Greater than
/// - `notEqual`: Not equal to
/// - `lessThanEqualTo`: Less than or equal to
/// - `greaterThanEqualTo`: Greater than or equal to
/// - `equalTo`: Equal to
enum PredicateOperator {
  lessThan,
  greaterThan,
  notEqual,
  lessThanEqualTo,
  greaterThanEqualTo,
  equalTo
}

/// A comparison-based predicate expression that represents a comparison between a value and a predicate operator.
///
/// This class encapsulates a comparison between a `value` and a `PredicateOperator`. It provides a way to represent
/// comparison-based predicates in a query, such as "x < 5" or "y >= 10".
///
/// The `value` property represents the value being compared, which can be of any type.
/// The `operator` property represents the comparison operator, which is defined by the `PredicateOperator` enum.
///
/// The `inverse` getter returns a new `ComparisonExpression` with the opposite `PredicateOperator`. This allows you
/// to easily negate a comparison expression, such as changing "x < 5" to "x >= 5".
///
/// The `inverseOperator` getter returns the opposite `PredicateOperator` for the current `operator`. This is used
/// to implement the `inverse` getter.
class ComparisonExpression implements PredicateExpression {
  /// Constructs a new instance of [ComparisonExpression].
  ///
  /// The [value] parameter represents the value being compared, which can be of any type.
  /// The [operator] parameter represents the comparison operator, which is defined by the [PredicateOperator] enum.
  const ComparisonExpression(this.value, this.operator);

  /// The value being compared in the comparison-based predicate expression.
  ///
  /// This property represents the value that is being compared to the predicate operator in the [ComparisonExpression].
  /// The value can be of any type.
  final dynamic value;

  /// The comparison operator used in the comparison-based predicate expression.
  ///
  /// This property represents the comparison operator used in the [ComparisonExpression]. The operator is defined by
  /// the [PredicateOperator] enum, which includes options such as "less than", "greater than", "equal to", and others.
  final PredicateOperator operator;

  /// Returns a new [ComparisonExpression] with the opposite [PredicateOperator] to the current one.
  ///
  /// This getter creates a new [ComparisonExpression] instance with the same [value] as the current instance,
  /// but with the [PredicateOperator] reversed. For example, if the current [operator] is [PredicateOperator.lessThan],
  /// the returned [ComparisonExpression] will have an [operator] of [PredicateOperator.greaterThanEqualTo].
  ///
  /// This allows you to easily negate a comparison expression, such as changing "x < 5" to "x >= 5".
  @override
  PredicateExpression get inverse {
    return ComparisonExpression(value, inverseOperator);
  }

  /// Returns the opposite [PredicateOperator] for the current [operator].
  ///
  /// This getter is used to implement the `inverse` getter of the [ComparisonExpression] class.
  /// It returns the opposite operator for the current [operator]. For example, if the current
  /// [operator] is [PredicateOperator.lessThan], this getter will return
  /// [PredicateOperator.greaterThanEqualTo].
  PredicateOperator get inverseOperator {
    switch (operator) {
      case PredicateOperator.lessThan:
        return PredicateOperator.greaterThanEqualTo;
      case PredicateOperator.greaterThan:
        return PredicateOperator.lessThanEqualTo;
      case PredicateOperator.notEqual:
        return PredicateOperator.equalTo;
      case PredicateOperator.lessThanEqualTo:
        return PredicateOperator.greaterThan;
      case PredicateOperator.greaterThanEqualTo:
        return PredicateOperator.lessThan;
      case PredicateOperator.equalTo:
        return PredicateOperator.notEqual;
    }
  }
}

/// The operator used in a string-based predicate expression.
///
/// The available operators are:
///
/// - `beginsWith`: The string must begin with the specified value.
/// - `contains`: The string must contain the specified value.
/// - `endsWith`: The string must end with the specified value.
/// - `equals`: The string must be exactly equal to the specified value.
enum PredicateStringOperator { beginsWith, contains, endsWith, equals }

/// A predicate contains instructions for filtering rows when performing a [Query].
///
/// Predicates currently are the WHERE clause in a SQL statement and are used verbatim
/// by the [PersistentStore]. In general, you should use [Query.where] instead of using this class directly, as [Query.where] will
/// use the underlying [PersistentStore] to generate a [QueryPredicate] for you.
///
/// A predicate has a format and parameters. The format is the [String] that comes after WHERE in a SQL query. The format may
/// have parameterized values, for which the corresponding value is in the [parameters] map. A parameter is prefixed with '@' in the format string. Currently,
/// the format string's parameter syntax is defined by the [PersistentStore] it is used on. An example of that format:
///
///     var predicate = new QueryPredicate("x = @xValue", {"xValue" : 5});
abstract class PredicateExpression {
  /// Returns a new instance of the [PredicateExpression] with the opposite condition.
  ///
  /// This getter creates and returns a new instance of the [PredicateExpression] with the opposite condition to the current one.
  /// For example, if the current expression is "x < 5", the returned expression would be "x >= 5".
  PredicateExpression get inverse;
}

/// A predicate expression that represents a range comparison.
///
/// This class encapsulates a range comparison between a `lhs` (left-hand side) value and an `rhs` (right-hand side) value.
/// It provides a way to represent range-based predicates in a query, such as "x between 5 and 10" or "y not between 20 and 30".
///
/// The `lhs` and `rhs` properties represent the left-hand side and right-hand side values of the range, respectively.
/// The `within` property determines whether the comparison is a "within" or "not within" range.
///
/// The `inverse` getter returns a new `RangeExpression` with the opposite `within` value. This allows you
/// to easily negate a range expression, such as changing "x between 5 and 10" to "x not between 5 and 10".
class RangeExpression implements PredicateExpression {
  /// Constructs a new instance of [RangeExpression].
  ///
  /// The [lhs] parameter represents the left-hand side value of the range comparison.
  /// The [rhs] parameter represents the right-hand side value of the range comparison.
  /// The [within] parameter determines whether the comparison is a "within" or "not within" range.
  /// If [within] is `true` (the default), the range expression will match values that are within the range.
  /// If [within] is `false`, the range expression will match values that are not within the range.
  const RangeExpression(this.lhs, this.rhs, {this.within = true});

  /// Determines whether the range comparison is a "within" or "not within" range.
  ///
  /// If `true` (the default), the range expression will match values that are within the range.
  /// If `false`, the range expression will match values that are not within the range.
  final bool within;

  /// The left-hand side value of the range comparison.
  ///
  /// This property represents the left-hand side value of the range comparison in the [RangeExpression]. The type of this value
  /// can be anything, as it is represented by the generic `dynamic` type.
  final dynamic lhs;

  /// The right-hand side value of the range comparison.
  ///
  /// This property represents the right-hand side value of the range comparison in the [RangeExpression]. The type of this value
  /// can be anything, as it is represented by the generic `dynamic` type.
  final dynamic rhs;

  /// Returns a new instance of the [RangeExpression] with the opposite `within` condition.
  ///
  /// This getter creates and returns a new instance of the [RangeExpression] with the opposite `within` condition to the current one.
  /// For example, if the current `within` value is `true`, the returned expression would have `within` set to `false`.
  /// This allows you to easily negate a range expression, such as changing "x between 5 and 10" to "x not between 5 and 10".
  @override
  PredicateExpression get inverse {
    return RangeExpression(lhs, rhs, within: !within);
  }
}

/// A predicate expression that checks if a value is null or not null.
///
/// This class encapsulates a null check predicate expression, which can be used to
/// filter data based on whether a value is null or not null.
///
/// The [shouldBeNull] parameter determines whether the expression checks for a null
/// value (if true) or a non-null value (if false).
///
/// The [inverse] getter returns a new [NullCheckExpression] with the opposite
/// [shouldBeNull] value. This allows you to easily negate a null check expression,
/// such as changing "x is null" to "x is not null".
class NullCheckExpression implements PredicateExpression {
  /// Constructs a new instance of [NullCheckExpression].
  ///
  /// The [shouldBeNull] parameter determines whether the expression checks for a null
  /// value (if `true`) or a non-null value (if `false`). The default value is `true`,
  /// which means the expression will check for a null value.
  const NullCheckExpression({this.shouldBeNull = true});

  /// Determines whether the expression checks for a null
  /// value (if `true`) or a non-null value (if `false`). The default value is `true`,
  /// which means the expression will check for a null value.
  final bool shouldBeNull;

  /// Returns a new instance of the [NullCheckExpression] with the opposite `shouldBeNull` condition.
  ///
  /// This getter creates and returns a new instance of the [NullCheckExpression] with the opposite `shouldBeNull` condition to the current one.
  /// For example, if the current `shouldBeNull` value is `true`, the returned expression would have `shouldBeNull` set to `false`.
  /// This allows you to easily negate a null check expression, such as changing "x is null" to "x is not null".
  @override
  PredicateExpression get inverse {
    return NullCheckExpression(shouldBeNull: !shouldBeNull);
  }
}

/// A predicate expression that checks if a value is a member of a set.
///
/// This class encapsulates a set membership predicate expression, which can be used to
/// filter data based on whether a value is a member of a set of values.
///
/// The [values] parameter represents the set of values to check for membership.
/// The [within] parameter determines whether the expression checks for membership
/// (if `true`) or non-membership (if `false`). The default value is `true`, which
/// means the expression will check for membership.
///
/// The [inverse] getter returns a new [SetMembershipExpression] with the opposite
/// [within] value. This allows you to easily negate a set membership expression,
/// such as changing "x is in the set" to "x is not in the set".
class SetMembershipExpression implements PredicateExpression {
  /// Constructs a new instance of [SetMembershipExpression].
  ///
  /// The [values] parameter represents the set of values to check for membership.
  /// The [within] parameter determines whether the expression checks for membership
  /// (if `true`) or non-membership (if `false`). The default value is `true`, which
  /// means the expression will check for membership.
  const SetMembershipExpression(this.values, {this.within = true});

  /// The set of values to check for membership.
  final List<dynamic> values;

  /// Determines whether the expression checks for membership
  /// (if `true`) or non-membership (if `false`). The default value is `true`,
  /// which means the expression will check for membership.
  final bool within;

  /// Returns a new instance of the [SetMembershipExpression] with the opposite `within` condition.
  ///
  /// This getter creates and returns a new instance of the [SetMembershipExpression] with the opposite `within` condition to the current one.
  /// For example, if the current `within` value is `true`, the returned expression would have `within` set to `false`.
  /// This allows you to easily negate a set membership expression, such as changing "x is in the set" to "x is not in the set".
  @override
  PredicateExpression get inverse {
    return SetMembershipExpression(values, within: !within);
  }
}

/// A predicate expression that represents a string-based comparison.
///
/// This class encapsulates a string-based predicate expression, which can be used to
/// filter data based on string comparisons such as "begins with", "contains", "ends with", or "equals".
///
/// The [value] property represents the string value to compare against.
/// The [operator] property represents the string comparison operator, which is defined by the [PredicateStringOperator] enum.
/// The [caseSensitive] property determines whether the comparison should be case-sensitive or not.
/// The [invertOperator] property determines whether the operator should be inverted (e.g., "not contains" instead of "contains").
/// The [allowSpecialCharacters] property determines whether special characters should be allowed in the string comparison.
///
/// The [inverse] getter returns a new [StringExpression] with the opposite [invertOperator] value. This allows you
/// to easily negate a string expression, such as changing "x contains 'abc'" to "x does not contain 'abc'".
class StringExpression implements PredicateExpression {
  /// Constructs a new instance of [StringExpression].
  ///
  /// The [value] parameter represents the string value to compare against.
  /// The [operator] parameter represents the string comparison operator, which is defined by the [PredicateStringOperator] enum.
  /// The [caseSensitive] parameter determines whether the comparison should be case-sensitive or not. The default value is `true`.
  /// The [invertOperator] parameter determines whether the operator should be inverted (e.g., "not contains" instead of "contains"). The default value is `false`.
  /// The [allowSpecialCharacters] parameter determines whether special characters should be allowed in the string comparison. The default value is `true`.
  const StringExpression(
    this.value,
    this.operator, {
    this.caseSensitive = true,
    this.invertOperator = false,
    this.allowSpecialCharacters = true,
  });

  /// The string value to compare against.
  final String value;

  /// The string comparison operator, which is defined by the [PredicateStringOperator] enum.
  final PredicateStringOperator operator;

  /// Determines whether the operator should be inverted (e.g., "not contains" instead of "contains"). The default value is `false`.
  final bool invertOperator;

  /// Determines whether the comparison should be case-sensitive or not. The default value is `true`.
  final bool caseSensitive;

  /// Determines whether special characters should be allowed in the string comparison. The default value is `true`.
  final bool allowSpecialCharacters;

  /// Returns a new instance of the [StringExpression] with the opposite [invertOperator] condition.
  ///
  /// This getter creates and returns a new instance of the [StringExpression] with the opposite [invertOperator] condition to the current one.
  /// For example, if the current [invertOperator] value is `false`, the returned expression would have [invertOperator] set to `true`.
  /// This allows you to easily negate a string expression, such as changing "x contains 'abc'" to "x does not contain 'abc'".
  @override
  PredicateExpression get inverse {
    return StringExpression(
      value,
      operator,
      caseSensitive: caseSensitive,
      invertOperator: !invertOperator,
      allowSpecialCharacters: allowSpecialCharacters,
    );
  }
}
