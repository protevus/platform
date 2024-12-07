/// Interface for building contextual bindings in the container.
///
/// This contract allows for fluent configuration of contextual bindings,
/// which are used to specify different concrete implementations for a
/// dependency based on the context in which it is being resolved.
abstract class ContextualBindingBuilder {
  /// Define the abstract target that is being contextualized.
  ///
  /// This method specifies which abstract type or interface should be
  /// bound differently in the given context.
  ///
  /// Example:
  /// ```dart
  /// container.when([UserController]).needs(Logger).give(FileLogger);
  /// ```
  ContextualBindingBuilder needs(dynamic abstract);

  /// Define the concrete implementation that should be used.
  ///
  /// This method specifies the concrete implementation that should be
  /// used when resolving the abstract type in the given context.
  ///
  /// The implementation can be either a concrete type or a factory function.
  void give(dynamic implementation);

  /// Define tagged services to be used as the implementation.
  ///
  /// This method specifies that all services tagged with the given tag
  /// should be used as the implementation in this context.
  ///
  /// Example:
  /// ```dart
  /// container.when(ReportGenerator)
  ///          .needs(Logger)
  ///          .giveTagged('loggers');
  /// ```
  void giveTagged(String tag);

  /// Specify the configuration item to bind as a primitive.
  ///
  /// This method allows binding a configuration value as the implementation.
  /// If the configuration key doesn't exist, the default value is used.
  ///
  /// Example:
  /// ```dart
  /// container.when(MailService)
  ///          .needs(String)
  ///          .giveConfig('services.mail.host');
  /// ```
  ///
  /// @param key The configuration key to bind
  /// @param defaultValue The default value if the key doesn't exist (defaults to null)
  void giveConfig(String key, [dynamic defaultValue = null]);
}
