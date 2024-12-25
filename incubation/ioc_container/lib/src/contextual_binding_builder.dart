import 'package:platform_contracts/contracts.dart';
import 'package:ioc_container/src/util.dart';

class ContextualBindingBuilder implements ContextualBindingBuilderContract {
  /// The underlying container instance.
  final ContainerContract _container;

  /// The concrete instance.
  final dynamic _concrete;

  /// The abstract target.
  dynamic _needs;

  /// Create a new contextual binding builder.
  ContextualBindingBuilder(this._container, this._concrete);

  /// Define the abstract target that depends on the context.
  @override
  ContextualBindingBuilderContract needs(dynamic abstract) {
    _needs = abstract;
    return this;
  }

  /// Define the implementation for the contextual binding.
  @override
  void give(dynamic implementation) {
    for (var concrete in Util.arrayWrap(_concrete)) {
      _container.addContextualBinding(concrete, _needs, implementation);
    }
  }

  /// Define tagged services to be used as the implementation for the contextual binding.
  @override
  void giveTagged(String tag) {
    give((ContainerContract container) {
      var taggedServices = container.tagged(tag);
      return taggedServices is List ? taggedServices : taggedServices.toList();
    });
  }

  /// Specify the configuration item to bind as a primitive.
  @override
  void giveConfig(String key, [dynamic defaultValue]) {
    give((ContainerContract container) =>
        container.get('config').get(key, defaultValue));
  }
}
