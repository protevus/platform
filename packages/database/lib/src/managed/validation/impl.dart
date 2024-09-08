/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/managed/managed.dart';

/// Represents the different types of validations that can be performed on an input.
///
/// - `regex`: Validate the input using a regular expression pattern.
/// - `comparison`: Validate the input using a comparison operator and a value.
/// - `length`: Validate the length of the input.
/// - `present`: Ensure the input is not null or empty.
/// - `absent`: Ensure the input is null or empty.
/// - `oneOf`: Ensure the input is one of the specified values.
enum ValidateType { regex, comparison, length, present, absent, oneOf }

/// Represents the different comparison operators that can be used in a validation expression.
///
/// - `equalTo`: Ensures the input is equal to the specified value.
/// - `lessThan`: Ensures the input is less than the specified value.
/// - `lessThanEqualTo`: Ensures the input is less than or equal to the specified value.
/// - `greaterThan`: Ensures the input is greater than the specified value.
/// - `greaterThanEqualTo`: Ensures the input is greater than or equal to the specified value.
enum ValidationOperator {
  equalTo,
  lessThan,
  lessThanEqualTo,
  greaterThan,
  greaterThanEqualTo
}

/// Represents a validation expression that can be used to validate an input value.
///
/// The `ValidationExpression` class has two properties:
///
/// - `operator`: The comparison operator to be used in the validation.
/// - `value`: The value to be compared against the input.
///
/// The `compare` method is used to perform the validation and add any errors to the provided `ValidationContext`.
class ValidationExpression {
  /// Initializes a new instance of the [ValidationExpression] class.
  ///
  /// The [operator] parameter specifies the comparison operator to be used in the validation.
  /// The [value] parameter specifies the value to be compared against the input.
  ValidationExpression(this.operator, this.value);

  /// The comparison operator to be used in the validation.
  final ValidationOperator operator;

  /// The value to be compared against the input during the validation process.
  dynamic value;

  /// Compares the provided input value against the value specified in the [ValidationExpression].
  ///
  /// The comparison is performed based on the [ValidationOperator] specified in the [ValidationExpression].
  /// If the comparison fails, an error message is added to the provided [ValidationContext].
  ///
  /// Parameters:
  ///   - [context]: The [ValidationContext] to which any errors will be added.
  ///   - [input]: The value to be compared against the [ValidationExpression] value.
  ///
  /// Throws:
  ///   - [ClassCastException]: If the [value] property of the [ValidationExpression] is not a [Comparable].
  void compare(ValidationContext context, dynamic input) {
    /// Converts the [value] property of the [ValidationExpression] to a [Comparable] type, or sets it to `null` if the conversion fails.
    ///
    /// This step is necessary because the [compare] method requires the [value] to be a [Comparable] in order to perform the comparison.
    final comparisonValue = value as Comparable?;

    /// Compares the provided input value against the value specified in the [ValidationExpression].
    ///
    /// The comparison is performed based on the [ValidationOperator] specified in the [ValidationExpression].
    /// If the comparison fails, an error message is added to the provided [ValidationContext].
    ///
    /// Parameters:
    ///   - [context]: The [ValidationContext] to which any errors will be added.
    ///   - [input]: The value to be compared against the [ValidationExpression] value.
    ///
    /// Throws:
    ///   - [ClassCastException]: If the [value] property of the [ValidationExpression] is not a [Comparable].
    switch (operator) {
      case ValidationOperator.equalTo:
        {
          if (comparisonValue!.compareTo(input) != 0) {
            context.addError("must be equal to '$comparisonValue'.");
          }
        }
        break;
      case ValidationOperator.greaterThan:
        {
          if (comparisonValue!.compareTo(input) >= 0) {
            context.addError("must be greater than '$comparisonValue'.");
          }
        }
        break;

      case ValidationOperator.greaterThanEqualTo:
        {
          if (comparisonValue!.compareTo(input) > 0) {
            context.addError(
              "must be greater than or equal to '$comparisonValue'.",
            );
          }
        }
        break;

      case ValidationOperator.lessThan:
        {
          if (comparisonValue!.compareTo(input) <= 0) {
            context.addError("must be less than to '$comparisonValue'.");
          }
        }
        break;
      case ValidationOperator.lessThanEqualTo:
        {
          if (comparisonValue!.compareTo(input) < 0) {
            context
                .addError("must be less than or equal to '$comparisonValue'.");
          }
        }
        break;
    }
  }
}
