/// @deprecated see ValidationRule
abstract class Rule {
  /// Determine if the validation rule passes.
  ///
  /// @param attribute The name of the attribute.
  /// @param value The value of the attribute.
  /// @return True if the validation rule passes, false otherwise.
  bool passes(String attribute, dynamic value);

  /// Get the validation error message.
  ///
  /// @return The validation error message as a string or list of strings.
  dynamic message();
}
