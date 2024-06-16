import 'validator.dart';
abstract class Factory {
  /// Create a new Validator instance.
  ///
  /// @param  Map<String, dynamic>  data
  /// @param  Map<String, dynamic>  rules
  /// @param  Map<String, String>  messages
  /// @param  Map<String, String>  attributes
  /// @return Validator
  Validator make(
      Map<String, dynamic> data,
      Map<String, dynamic> rules,
      [Map<String, String> messages = const {},
      Map<String, String> attributes = const {}]);

  /// Register a custom validator extension.
  ///
  /// @param  String  rule
  /// @param  Function|string  extension
  /// @param  String|null  message
  /// @return void
  void extend(String rule, dynamic extension, [String? message]);

  /// Register a custom implicit validator extension.
  ///
  /// @param  String  rule
  /// @param  Function|string  extension
  /// @param  String|null  message
  /// @return void
  void extendImplicit(String rule, dynamic extension, [String? message]);

  /// Register a custom implicit validator message replacer.
  ///
  /// @param  String  rule
  /// @param  Function|string  replacer
  /// @return void
  void replacer(String rule, dynamic replacer);
}
