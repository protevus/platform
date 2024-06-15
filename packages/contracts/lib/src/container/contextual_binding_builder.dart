abstract class ContextualBindingBuilder {
  /// Define the abstract target that depends on the context.
  ///
  /// [abstract] The abstract target.
  /// Returns the current instance.
  ContextualBindingBuilder needs(String abstract);

  /// Define the implementation for the contextual binding.
  ///
  /// [implementation] The implementation which can be a Closure, String, or List.
  void give(dynamic implementation);

  /// Define tagged services to be used as the implementation for the contextual binding.
  ///
  /// [tag] The tag to use.
  void giveTagged(String tag);

  /// Specify the configuration item to bind as a primitive.
  ///
  /// [key] The configuration key.
  /// [defaultValue] The default value.
  void giveConfig(String key, [dynamic defaultValue]);
}
