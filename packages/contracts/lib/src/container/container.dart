import 'package:dsr_container/container.dart';
import 'binding_resolution_exception.dart';
import 'contextual_binding_builder.dart';

/// Interface for the IoC container.
///
/// This contract defines the interface for the Inversion of Control container,
/// which provides dependency injection and service location capabilities.
/// It extends the basic [ContainerInterface] with additional functionality
/// for binding, resolving, and managing services.
abstract class ContainerContract implements ContainerInterface {
  /// Determine if the given abstract type has been bound.
  bool bound(String abstract);

  /// Alias a type to a different name.
  ///
  /// Throws [ArgumentError] if the alias would cause a circular reference.
  void alias(String abstract, String alias);

  /// Assign a set of tags to a given binding.
  void tag(dynamic abstracts, String tag,
      [List<String> additionalTags = const []]);

  /// Resolve all of the bindings for a given tag.
  Iterable<dynamic> tagged(String tag);

  /// Register a binding with the container.
  ///
  /// The [concrete] parameter can be a Type, a factory function, or null.
  /// If [shared] is true, the same instance will be returned for subsequent
  /// resolutions of this binding.
  void bind(String abstract, dynamic concrete, {bool shared = false});

  /// Bind a callback to resolve with [call].
  void bindMethod(dynamic method, Function callback);

  /// Register a binding if it hasn't already been registered.
  void bindIf(String abstract, dynamic concrete, {bool shared = false});

  /// Register a shared binding in the container.
  void singleton(String abstract, [dynamic concrete]);

  /// Register a shared binding if it hasn't already been registered.
  void singletonIf(String abstract, [dynamic concrete]);

  /// Register a scoped binding in the container.
  void scoped(String abstract, [dynamic concrete]);

  /// Register a scoped binding if it hasn't already been registered.
  void scopedIf(String abstract, [dynamic concrete]);

  /// "Extend" an abstract type in the container.
  ///
  /// Throws [ArgumentError] if the abstract type isn't registered.
  void extend(String abstract, Function(dynamic service) closure);

  /// Register an existing instance as shared in the container.
  T instance<T>(String abstract, T instance);

  /// Add a contextual binding to the container.
  void addContextualBinding(
    String concrete,
    String abstract,
    dynamic implementation,
  );

  /// Define a contextual binding.
  ContextualBindingBuilderContract when(dynamic concrete);

  /// Define a contextual binding based on an attribute.
  ///
  /// This method allows binding resolution to be determined by the presence
  /// of a specific attribute on a dependency. The handler will be called
  /// when resolving dependencies that have the specified attribute.
  ///
  /// Example:
  /// ```dart
  /// container.whenHasAttribute(
  ///   'Logger',
  ///   (attribute, container) => FileLogger(),
  /// );
  /// ```
  void whenHasAttribute(String attribute, Function handler);

  /// Get a factory function to resolve the given type from the container.
  Function factory(String abstract);

  /// Flush the container of all bindings and resolved instances.
  void flush();

  /// Resolve the given type from the container.
  ///
  /// Throws [BindingResolutionException] if the type cannot be resolved.
  T make<T>(String abstract, [List<dynamic> parameters = const []]);

  /// Call the given callback / class@method and inject its dependencies.
  dynamic call(
    dynamic callback, [
    List<dynamic> parameters = const [],
    String? defaultMethod,
  ]);

  /// Determine if the given abstract type has been resolved.
  bool resolved(String abstract);

  /// Register a new before resolving callback.
  void beforeResolving(dynamic abstract, [Function? callback]);

  /// Register a new resolving callback.
  void resolving(dynamic abstract, [Function? callback]);

  /// Register a new after resolving callback.
  void afterResolving(dynamic abstract, [Function? callback]);
}
