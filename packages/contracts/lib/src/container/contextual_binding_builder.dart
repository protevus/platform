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
}
