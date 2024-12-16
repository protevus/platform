/// Interface for invokable validation rules.
/// @deprecated see ValidationRule
abstract class InvokableRule {
  /// Run the validation rule.
  void call(String attribute, dynamic value, Function fail);
}
