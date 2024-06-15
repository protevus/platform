import 'contextual_binding_builder.dart';
abstract class Container {
  /// Determine if the given abstract type has been bound.
  ///
  /// @param  String  abstract
  /// @return bool
  bool bound(String abstract);

  /// Alias a type to a different name.
  ///
  /// @param  String  abstract
  /// @param  String  alias
  /// @return void
  ///
  /// @throws LogicException
  void alias(String abstract, String alias);

  /// Assign a set of tags to a given binding.
  ///
  /// @param  List<String>|String  abstracts
  /// @param  List<dynamic>|dynamic  tags
  /// @return void
  void tag(dynamic abstracts, dynamic tags);

  /// Resolve all of the bindings for a given tag.
  ///
  /// @param  String  tag
  /// @return Iterable
  Iterable tagged(String tag);

  /// Register a binding with the container.
  ///
  /// @param  String  abstract
  /// @param  Function|String|null  concrete
  /// @param  bool  shared
  /// @return void
  void bind(String abstract, [dynamic concrete, bool shared = false]);

  /// Bind a callback to resolve with Container::call.
  ///
  /// @param  List<String>|String  method
  /// @param  Function  callback
  /// @return void
  void bindMethod(dynamic method, Function callback);

  /// Register a binding if it hasn't already been registered.
  ///
  /// @param  String  abstract
  /// @param  Function|String|null  concrete
  /// @param  bool  shared
  /// @return void
  void bindIf(String abstract, [dynamic concrete, bool shared = false]);

  /// Register a shared binding in the container.
  ///
  /// @param  String  abstract
  /// @param  Function|String|null  concrete
  /// @return void
  void singleton(String abstract, [dynamic concrete]);

  /// Register a shared binding if it hasn't already been registered.
  ///
  /// @param  String  abstract
  /// @param  Function|String|null  concrete
  /// @return void
  void singletonIf(String abstract, [dynamic concrete]);

  /// Register a scoped binding in the container.
  ///
  /// @param  String  abstract
  /// @param  Function|String|null  concrete
  /// @return void
  void scoped(String abstract, [dynamic concrete]);

  /// Register a scoped binding if it hasn't already been registered.
  ///
  /// @param  String  abstract
  /// @param  Function|String|null  concrete
  /// @return void
  void scopedIf(String abstract, [dynamic concrete]);

  /// "Extend" an abstract type in the container.
  ///
  /// @param  String  abstract
  /// @param  Function  closure
  /// @return void
  ///
  /// @throws InvalidArgumentException
  void extend(String abstract, Function closure);

  /// Register an existing instance as shared in the container.
  ///
  /// @param  String  abstract
  /// @param  dynamic  instance
  /// @return dynamic
  dynamic instance(String abstract, dynamic instance);

  /// Add a contextual binding to the container.
  ///
  /// @param  String  concrete
  /// @param  String  abstract
  /// @param  Function|String  implementation
  /// @return void
  void addContextualBinding(String concrete, String abstract, dynamic implementation);

  /// Define a contextual binding.
  ///
  /// @param  String|List<String>  concrete
  /// @return ContextualBindingBuilder
  ContextualBindingBuilder when(dynamic concrete);

  /// Get a closure to resolve the given type from the container.
  ///
  /// @param  String  abstract
  /// @return Function
  Function factory(String abstract);

  /// Flush the container of all bindings and resolved instances.
  ///
  /// @return void
  void flush();

  /// Resolve the given type from the container.
  ///
  /// @param  String  abstract
  /// @param  Map<String, dynamic>  parameters
  /// @return dynamic
  ///
  /// @throws BindingResolutionException
  dynamic make(String abstract, [Map<String, dynamic> parameters = const {}]);

  /// Call the given Function / class@method and inject its dependencies.
  ///
  /// @param  dynamic  callback
  /// @param  Map<String, dynamic>  parameters
  /// @param  String|null  defaultMethod
  /// @return dynamic
  dynamic call(dynamic callback, [Map<String, dynamic> parameters = const {}, String defaultMethod]);

  /// Determine if the given abstract type has been resolved.
  ///
  /// @param  String  abstract
  /// @return bool
  bool resolved(String abstract);

  /// Register a new before resolving callback.
  ///
  /// @param  String|Function  abstract
  /// @param  Function|null  callback
  /// @return void
  void beforeResolving(dynamic abstract, [Function? callback]);

  /// Register a new resolving callback.
  ///
  /// @param  String|Function  abstract
  /// @param  Function|null  callback
  /// @return void
  void resolving(dynamic abstract, [Function? callback]);

  /// Register a new after resolving callback.
  ///
  /// @param  String|Function  abstract
  /// @param  Function|null  callback
  /// @return void
  void afterResolving(dynamic abstract, [Function? callback]);
}

class InvalidArgumentException implements Exception {
  // Implementation for InvalidArgumentException
}

class LogicException implements Exception {
  // Implementation for LogicException
}
