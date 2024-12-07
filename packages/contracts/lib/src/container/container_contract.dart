/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import '../reflection/reflector_contract.dart';

/// Core container contract defining dependency injection functionality.
abstract class ContainerBase {
  /// Gets the reflector instance used by this container.
  ReflectorContract get reflector;

  /// Whether this is a root container (has no parent).
  bool get isRoot;

  /// Creates a child container that inherits from this container.
  ContainerBase createChild();

  /// Determine if the given abstract type has been bound.
  bool bound(String abstract);

  /// Register a binding with the container.
  void bind<T>(T Function(ContainerBase) concrete, {bool shared = false});

  /// Register a binding if it hasn't already been registered.
  void bindIf<T>(T Function(ContainerBase) concrete, {bool shared = false});

  /// Register a shared binding in the container.
  void singleton<T>(T Function(ContainerBase) concrete);

  /// Register a shared binding if it hasn't already been registered.
  void singletonIf<T>(T Function(ContainerBase) concrete);

  /// Register a scoped binding in the container.
  void scoped<T>(T Function(ContainerBase) concrete);

  /// Register a scoped binding if it hasn't already been registered.
  void scopedIf<T>(T Function(ContainerBase) concrete);

  /// Register an existing instance as shared in the container.
  T instance<T>(T instance);

  /// Bind a callback to resolve with Container::call.
  void bindMethod(String method, Function callback);

  /// Call the given Closure / class@method and inject its dependencies.
  dynamic call(Function callback, [List<dynamic> parameters = const []]);

  /// Wrap the given closure such that its dependencies will be injected when executed.
  Function wrap(Function callback, [List<dynamic> parameters = const []]);

  /// Define a contextual binding.
  ContextualBindingBuilder when(Type concrete);

  /// Add a contextual binding to the container.
  void addContextualBinding(
      Type concrete, Type abstract, dynamic implementation);

  /// Register a new before resolving callback.
  void beforeResolving<T>(void Function(ContainerBase, T instance) callback);

  /// Register a new resolving callback.
  void resolving<T>(void Function(ContainerBase, T instance) callback);

  /// Register a new after resolving callback.
  void afterResolving<T>(void Function(ContainerBase, T instance) callback);

  /// Checks if a type is registered in this container or its parents.
  bool has<T>([Type? t]);

  /// Checks if a named instance exists in this container or its parents.
  bool hasNamed(String name);

  /// Makes an instance of type [T].
  T make<T>([Type? type]);

  /// Makes an instance of type [T] asynchronously.
  Future<T> makeAsync<T>([Type? type]);

  /// Registers a singleton instance.
  T registerSingleton<T>(T object, {Type? as});

  /// Registers a factory function.
  T Function(ContainerBase) registerFactory<T>(
      T Function(ContainerBase) factory,
      {Type? as});

  /// Registers a lazy singleton.
  T Function(ContainerBase) registerLazySingleton<T>(
      T Function(ContainerBase) factory,
      {Type? as});

  /// Gets a named singleton.
  T findByName<T>(String name);

  /// Registers a named singleton.
  T registerNamedSingleton<T>(String name, T object);

  /// Tag a set of dependencies.
  void tag(List<Type> abstracts, String tag);

  /// Resolve all tagged dependencies.
  List<T> tagged<T>(String tag);

  /// Alias a type to a different name.
  void alias(Type abstract, Type alias);

  /// Check if a name is an alias.
  bool isAlias(String name);

  /// Get the alias for an abstract if available.
  Type getAlias(Type abstract);

  /// Extend an abstract type in the container.
  void extend(Type abstract, Function(dynamic instance) extension);

  /// Get the extender callbacks for a given type.
  List<Function> getExtenders(Type abstract);

  /// Remove all extender callbacks for a given type.
  void forgetExtenders(Type abstract);

  /// Remove a resolved instance from the instance cache.
  void forgetInstance(Type abstract);

  /// Clear all instances from the container.
  void forgetInstances();

  /// Clear all scoped instances from the container.
  void forgetScopedInstances();

  /// Flush the container of all bindings and resolved instances.
  void flush();

  /// Bind a new callback to an abstract's rebind event.
  void rebinding(Type abstract, Function(ContainerBase, dynamic) callback);

  /// Refresh an instance on the given target and method.
  void refresh(Type abstract, dynamic target, String method);
}

/// Builder for contextual bindings.
abstract class ContextualBindingBuilder {
  /// Specify what type needs the contextual binding.
  ContextualBindingBuilder needs<T>();

  /// Specify what to give for this contextual binding.
  void give(dynamic implementation);
}
