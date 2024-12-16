/// Interface for building contextual bindings in the container.
abstract class ContextualBindingBuilderContract {
  /// Define the abstract target that depends on the context.
  ///
  /// @param abstract The abstract type that needs a contextual binding
  /// @return This builder instance for method chaining
  ContextualBindingBuilderContract needs(dynamic abstract);

  /// Define the implementation for the contextual binding.
  ///
  /// @param implementation The implementation (closure, string, or array)
  void give(dynamic implementation);

  /// Define tagged services to be used as the implementation for the contextual binding.
  ///
  /// @param tag The tag to use for implementation
  void giveTagged(String tag);

  /// Specify the configuration item to bind as a primitive.
  ///
  /// @param key The configuration key to bind
  /// @param defaultValue The default value if the key doesn't exist
  void giveConfig(String key, [dynamic defaultValue = null]);
}
