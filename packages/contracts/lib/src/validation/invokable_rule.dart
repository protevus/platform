// Import necessary libraries
import 'dart:core';

// Define a type alias for the fail function closure
typedef FailFunction = void Function(String);

// Define the InvokableRule interface
///@deprecated see ValidateRule
abstract class InvokableRule {
  /// Run the validation rule.
  ///
  /// @param attribute The attribute being validated.
  /// @param value The value of the attribute.
  /// @param fail A function that will be called if the validation fails.
  void call(String attribute, dynamic value, FailFunction fail);
}
