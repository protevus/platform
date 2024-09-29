import 'dart:mirrors' as mirrors;
import 'service_provider.dart';

abstract class ProviderDiscovery {
  List<Type> discoverProviders();
  ServiceProvider? createInstance(Type type);
}

class MirrorProviderDiscovery implements ProviderDiscovery {
  @override
  List<Type> discoverProviders() {
    var providers = <Type>[];
    mirrors.currentMirrorSystem().libraries.values.forEach((lib) {
      for (var declaration in lib.declarations.values) {
        if (declaration is mirrors.ClassMirror &&
            declaration.isSubclassOf(mirrors.reflectClass(ServiceProvider)) &&
            !declaration.isAbstract) {
          providers.add(declaration.reflectedType);
        }
      }
    });
    return providers;
  }

  @override
  ServiceProvider? createInstance(Type type) {
    var classMirror = mirrors.reflectClass(type);
    if (classMirror.declarations.containsKey(const Symbol(''))) {
      var ctor =
          classMirror.declarations[const Symbol('')] as mirrors.MethodMirror?;
      if (ctor != null && ctor.isConstructor && ctor.parameters.isEmpty) {
        return classMirror.newInstance(const Symbol(''), []).reflectee
            as ServiceProvider;
      }
    }
    return null;
  }
}

class ManualProviderDiscovery implements ProviderDiscovery {
  final List<Type> _registeredTypes = [];
  final Map<Type, ServiceProvider Function()> _factories = {};

  void registerProviderType(Type type, ServiceProvider Function() factory) {
    _registeredTypes.add(type);
    _factories[type] = factory;
  }

  @override
  List<Type> discoverProviders() => List.unmodifiable(_registeredTypes);

  @override
  ServiceProvider? createInstance(Type type) => _factories[type]?.call();
}
