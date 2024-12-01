import 'validator.dart';

/// Interface for validation factory.
abstract class ValidationFactory {
  /// Create a new Validator instance.
  Validator make(
    Map<String, dynamic> data,
    Map<String, dynamic> rules, [
    Map<String, dynamic> messages = const {},
    Map<String, dynamic> attributes = const {},
  ]);

  /// Register a custom validator extension.
  void extend(String rule, dynamic extension, [String? message]);

  /// Register a custom implicit validator extension.
  void extendImplicit(String rule, dynamic extension, [String? message]);

  /// Register a custom implicit validator message replacer.
  void replacer(String rule, dynamic replacer);
}
