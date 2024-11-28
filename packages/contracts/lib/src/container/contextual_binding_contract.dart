import 'package:meta/meta.dart';

/// Contract for contextual binding in dependency injection.
///
/// This contract defines the interface for creating contextual bindings,
/// allowing dependencies to be resolved differently based on context.
@sealed
abstract class ContextualBindingContract {
  /// Specifies the concrete type that triggers this contextual binding.
  ///
  /// Parameters:
  ///   - [concrete]: The concrete type that needs dependencies.
  ///
  /// Returns a builder for specifying what type is needed.
  ContextualNeedsContract when(Type concrete);
}

/// Contract for specifying contextual needs.
///
/// This contract defines the interface for specifying what type
/// is needed in a particular context.
@sealed
abstract class ContextualNeedsContract {
  /// Specifies the type needed in this context.
  ///
  /// Returns a builder for specifying what to give.
  ContextualGiveContract needs<T>();
}

/// Contract for specifying contextual implementations.
///
/// This contract defines the interface for specifying what
/// implementation to provide in a particular context.
@sealed
abstract class ContextualGiveContract {
  /// Specifies what to give for this contextual binding.
  ///
  /// Parameters:
  ///   - [implementation]: The implementation to provide.
  ///     This can be an instance, a factory function, or a type.
  void give(dynamic implementation);
}
