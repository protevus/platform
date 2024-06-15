abstract class DeviatesCastableAttributes {
  /// Increment the attribute.
  ///
  /// @param  Model  model
  /// @param  String  key
  /// @param  dynamic  value
  /// @param  Map<String, dynamic>  attributes
  /// @return dynamic
  dynamic increment(Model model, String key, dynamic value, Map<String, dynamic> attributes);

  /// Decrement the attribute.
  ///
  /// @param  Model  model
  /// @param  String  key
  /// @param  dynamic  value
  /// @param  Map<String, dynamic>  attributes
  /// @return dynamic
  dynamic decrement(Model model, String key, dynamic value, Map<String, dynamic> attributes);
}
