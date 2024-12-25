import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/mirrors.dart';

/// A builder for defining contextual bindings for the container.
class ContextualBindingBuilder implements ContextualBindingBuilderContract {
  final ContainerContract _container;
  final List<String> _concrete;
  late String _abstract;

  /// Creates a new contextual binding builder with the given container and concrete types.
  ContextualBindingBuilder(this._container, this._concrete);

  @override
  ContextualBindingBuilderContract needs(dynamic abstract) {
    _abstract = abstract.toString();
    return this;
  }

  @override
  void give(dynamic implementation) {
    for (var concrete in _concrete) {
      _container.addContextualBinding(concrete, _abstract, implementation);
    }
  }

  @override
  void giveTagged(String tag) {
    for (var concrete in _concrete) {
      _container.addContextualBinding(
        concrete,
        _abstract,
        (ContainerContract container) => container.tagged(tag),
      );
    }
  }

  void giveFactory(dynamic factory) {
    for (var concrete in _concrete) {
      _container.addContextualBinding(
        concrete,
        _abstract,
        (ContainerContract container) {
          if (factory is Function) {
            return factory(container);
          } else if (factory is Object &&
              factory.runtimeType.toString().contains('Factory')) {
            return (factory as dynamic).make(container);
          } else {
            throw ArgumentError(
                'Invalid factory type. Expected a Function or a Factory object.');
          }
        },
      );
    }
  }

  @override
  void giveConfig(String key, [dynamic defaultValue]) {
    for (var concrete in _concrete) {
      _container.addContextualBinding(
        concrete,
        _abstract,
        (ContainerContract container) =>
            container.make('config').get(key, defaultValue: defaultValue),
      );
    }
  }

  void giveMethod(String method) {
    for (var concrete in _concrete) {
      _container.addContextualBinding(
        concrete,
        _abstract,
        (ContainerContract container) {
          var instance = container.make(concrete);
          return reflect(instance).invoke(Symbol(method), []).reflectee;
        },
      );
    }
  }
}
