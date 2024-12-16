import 'validator.dart';

/// Interface for validation rules that need access to the validator instance.
abstract class ValidatorAwareRule {
  /// Set the current validator.
  ValidatorAwareRule setValidator(Validator validator);
}
