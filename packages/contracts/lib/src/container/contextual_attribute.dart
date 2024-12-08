import 'container.dart';

/// Marker interface for contextual binding attributes.
///
/// This interface is used to mark attributes that can be used for contextual binding
/// in the container. When an attribute implements this interface, it can be used
/// to define contextual bindings through attributes rather than method calls.
///
/// Example:
/// ```dart
/// @ContextualBindingAttribute('logger')
/// class LoggerAttribute implements ContextualAttribute {
///   const LoggerAttribute(this.implementation);
///   final Type implementation;
/// }
/// ```
abstract class ContextualAttribute {
  /// Optional method to resolve the binding.
  ///
  /// If implemented, this method will be called when resolving the binding.
  /// If not implemented, the container will use its default resolution logic.
  dynamic resolve(dynamic instance, ContainerContract container) => null;

  /// Optional method called after resolving.
  ///
  /// If implemented, this method will be called after the instance has been resolved.
  /// This can be used for post-resolution configuration or setup.
  void after(dynamic instance, dynamic resolved, ContainerContract container) {}
}
