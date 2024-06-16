import 'validator.dart'; // Assume this is the correct import for the Validator class

abstract class ValidatorAwareRule {
  /// Set the current validator.
  ///
  /// @param  Validator  validator
  /// @return ValidatorAwareRule
  ValidatorAwareRule setValidator(Validator validator);
}
