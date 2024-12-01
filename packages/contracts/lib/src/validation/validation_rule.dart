/// Interface for validation rules.
abstract class ValidationRule {
  /// Run the validation rule.
  void validate(String attribute, dynamic value, Function fail);
}
