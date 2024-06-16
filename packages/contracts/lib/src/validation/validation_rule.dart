import 'package:meta/meta.dart';

typedef FailCallback = void Function(String message);

abstract class ValidationRule {
  /// Run the validation rule.
  ///
  /// @param attribute The name of the attribute being validated.
  /// @param value The value of the attribute.
  /// @param fail A callback function that accepts a failure message.
  void validate(String attribute, dynamic value, FailCallback fail);
}
