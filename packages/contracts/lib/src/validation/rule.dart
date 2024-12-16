/// Interface for validation rules.
/// @deprecated see ValidationRule
abstract class Rule {
  /// Determine if the validation rule passes.
  bool passes(String attribute, dynamic value);

  /// Get the validation error message.
  dynamic message();
}
