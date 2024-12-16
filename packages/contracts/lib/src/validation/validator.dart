import '../support/message_provider.dart';

/// Interface for validation.
abstract class Validator implements MessageProvider {
  /// Run the validator's rules against its data.
  Map<String, dynamic> validate();

  /// Get the attributes and values that were validated.
  Map<String, dynamic> validated();

  /// Determine if the data fails the validation rules.
  bool fails();

  /// Get the failed validation rules.
  Map<String, dynamic> failed();

  /// Add conditions to a given field based on a callback.
  Validator sometimes(dynamic attribute, dynamic rules, Function callback);

  /// Add an after validation callback.
  Validator after(dynamic callback);

  /// Get all of the validation error messages.
  dynamic errors();
}
