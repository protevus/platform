/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'container.dart';

/// A builder class for defining contextual bindings in the container.
///
/// This class provides a fluent interface for defining how abstract types should
/// be resolved in specific contexts. It allows for different implementations of
/// an interface to be used depending on where they are being injected.
class ContextualBindingBuilder {
  /// The container instance this builder is associated with
  final Container container;

  /// The concrete type that needs a contextual binding
  final List<Type> concrete;

  /// Creates a new contextual binding builder
  ContextualBindingBuilder(this.container, this.concrete);

  /// Define the abstract type that should be bound differently in this context
  ContextualImplementationBuilder needs<T>() {
    return ContextualImplementationBuilder(container, concrete, T);
  }
}

/// A builder class for defining the implementation for a contextual binding.
///
/// This class completes the contextual binding definition by specifying what
/// implementation should be used for the abstract type in the given context.
class ContextualImplementationBuilder {
  /// The container instance this builder is associated with
  final Container container;

  /// The concrete type that needs a contextual binding
  final List<Type> concrete;

  /// The abstract type that needs to be bound
  final Type abstract;

  /// Creates a new contextual implementation builder
  ContextualImplementationBuilder(
      this.container, this.concrete, this.abstract) {
    // Register an empty binding by default
    for (var concreteType in concrete) {
      container.addContextualBinding(concreteType, abstract, null);
    }
  }

  /// Specify the implementation that should be used
  void give<T>() {
    for (var concreteType in concrete) {
      container.addContextualBinding(
          concreteType, abstract, (Container c) => c.make<T>());
    }
  }

  /// Specify a factory function that should be used to create the implementation
  void giveFactory(dynamic Function(Container container) factory) {
    for (var concreteType in concrete) {
      container.addContextualBinding(concreteType, abstract, factory);
    }
  }
}
