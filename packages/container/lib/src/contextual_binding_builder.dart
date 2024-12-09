import 'package:platform_contracts/contracts.dart';

/// Implementation of the contextual binding builder.
class ContextualBindingBuilder implements ContextualBindingBuilderContract {
  /// The underlying container instance.
  final ContainerContract _container;

  /// The concrete instance.
  final dynamic _concrete;

  /// The abstract target.
  String? _needs;

  /// Create a new contextual binding builder.
  ///
  /// @param container The container instance
  /// @param concrete The concrete instance
  ContextualBindingBuilder(this._container, this._concrete);

  @override
  ContextualBindingBuilder needs(dynamic abstract) {
    _needs = abstract.toString();
    return this;
  }

  @override
  void give(dynamic implementation) {
    for (final concrete in _wrapArray(_concrete)) {
      _container.addContextualBinding(
        concrete.toString(),
        _needs!,
        implementation,
      );
    }
  }

  @override
  void giveTagged(String tag) {
    give((ContainerContract container) {
      final taggedServices = container.tagged(tag);
      return taggedServices.toList();
    });
  }

  @override
  void giveConfig(String key, [dynamic defaultValue = null]) {
    give((ContainerContract container) =>
        container.make('config').get(key, defaultValue));
  }

  /// Wrap a value in an array if it isn't one.
  List<dynamic> _wrapArray(dynamic value) {
    if (value is List) {
      return value;
    }
    return [value];
  }
}
