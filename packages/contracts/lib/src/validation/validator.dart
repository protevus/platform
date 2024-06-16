import 'message_provider.dart';
import 'validation_exception.dart';
import 'message_bag.dart';

// TODO: Fix Imports.

abstract class Validator implements MessageProvider {
  /// Run the validator's rules against its data.
  ///
  /// Throws a [ValidationException] if validation fails.
  ///
  /// Returns a map of validated data.
  Map<String, dynamic> validate();

  /// Get the attributes and values that were validated.
  ///
  /// Throws a [ValidationException] if validation fails.
  ///
  /// Returns a map of validated data.
  Map<String, dynamic> validated();

  /// Determine if the data fails the validation rules.
  ///
  /// Returns true if validation fails, false otherwise.
  bool fails();

  /// Get the failed validation rules.
  ///
  /// Returns a map of failed validation rules.
  Map<String, dynamic> failed();

  /// Add conditions to a given field based on a callback.
  ///
  /// Takes an [attribute], [rules], and a [callback] function.
  ///
  /// Returns the current instance of [Validator].
  Validator sometimes(dynamic attribute, dynamic rules, Function callback);

  /// Add an after validation callback.
  ///
  /// Takes a [callback] function.
  ///
  /// Returns the current instance of [Validator].
  Validator after(Function callback);

  /// Get all of the validation error messages.
  ///
  /// Returns a [MessageBag] containing the error messages.
  MessageBag errors();
}
