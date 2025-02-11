/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Base class for all container binding attributes
abstract class BindingAttribute {
  const BindingAttribute();
}

/// Marks a class as injectable and optionally specifies how it should be bound
class Injectable extends BindingAttribute {
  /// The type to bind this implementation to (usually an interface)
  final Type? bindTo;

  /// Whether this should be bound as a singleton
  final bool singleton;

  /// Tags that can be used to identify this implementation
  final List<String> tags;

  const Injectable({
    this.bindTo,
    this.singleton = false,
    this.tags = const [],
  });
}

/// Marks a parameter as requiring a specific implementation
class Inject extends BindingAttribute {
  /// The implementation type to inject
  final Type implementation;

  /// Configuration parameters for the implementation
  final Map<String, dynamic> config;

  const Inject(this.implementation, {this.config = const {}});
}

/// Marks a parameter as requiring a tagged implementation
class InjectTagged extends BindingAttribute {
  /// The tag to use when resolving the implementation
  final String tag;

  const InjectTagged(this.tag);
}

/// Marks a parameter as requiring all implementations of a type
class InjectAll extends BindingAttribute {
  /// Optional tag to filter implementations
  final String? tag;

  const InjectAll({this.tag});
}
