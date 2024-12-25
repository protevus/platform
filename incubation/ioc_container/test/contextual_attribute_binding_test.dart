import 'package:test/test.dart';
import 'package:ioc_container/container.dart';

void main() {
  group('ContextualAttributeBindingTest', () {
    test('testDependencyCanBeResolvedFromAttributeBinding', () {
      var container = Container();

      container.bind('ContainerTestContract', (c) => ContainerTestImplB());
      container.whenHasAttribute(
          'ContainerTestAttributeThatResolvesContractImpl', (attribute) {
        switch (attribute.name) {
          case 'A':
            return ContainerTestImplA();
          case 'B':
            return ContainerTestImplB();
          default:
            throw Exception('Unknown implementation');
        }
      });

      var classA =
          container.make('ContainerTestHasAttributeThatResolvesToImplA')
              as ContainerTestHasAttributeThatResolvesToImplA;

      expect(classA, isA<ContainerTestHasAttributeThatResolvesToImplA>());
      expect(classA.property, isA<ContainerTestImplA>());

      var classB =
          container.make('ContainerTestHasAttributeThatResolvesToImplB')
              as ContainerTestHasAttributeThatResolvesToImplB;

      expect(classB, isA<ContainerTestHasAttributeThatResolvesToImplB>());
      expect(classB.property, isA<ContainerTestImplB>());
    });

    test('testScalarDependencyCanBeResolvedFromAttributeBinding', () {
      var container = Container();
      container.singleton(
          'config',
          (c) => Repository({
                'app': {
                  'timezone': 'Europe/Paris',
                },
              }));

      container.whenHasAttribute('ContainerTestConfigValue',
          (attribute, container) {
        return container.make('config').get(attribute.key);
      });

      var instance = container.make('ContainerTestHasConfigValueProperty')
          as ContainerTestHasConfigValueProperty;

      expect(instance, isA<ContainerTestHasConfigValueProperty>());
      expect(instance.timezone, equals('Europe/Paris'));
    });

    test('testScalarDependencyCanBeResolvedFromAttributeResolveMethod', () {
      var container = Container();
      container.singleton(
          'config',
          (c) => Repository({
                'app': {
                  'env': 'production',
                },
              }));

      var instance =
          container.make('ContainerTestHasConfigValueWithResolveProperty')
              as ContainerTestHasConfigValueWithResolveProperty;

      expect(instance, isA<ContainerTestHasConfigValueWithResolveProperty>());
      expect(instance.env, equals('production'));
    });

    test('testDependencyWithAfterCallbackAttributeCanBeResolved', () {
      var container = Container();

      var instance = container.make(
              'ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback')
          as ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback;

      expect(instance.person['role'], equals('Developer'));
    });
  });
}

class ContainerTestAttributeThatResolvesContractImpl {
  final String name;
  const ContainerTestAttributeThatResolvesContractImpl(this.name);
}

abstract class ContainerTestContract {}

class ContainerTestImplA implements ContainerTestContract {}

class ContainerTestImplB implements ContainerTestContract {}

class ContainerTestHasAttributeThatResolvesToImplA {
  final ContainerTestContract property;
  ContainerTestHasAttributeThatResolvesToImplA(this.property);
}

class ContainerTestHasAttributeThatResolvesToImplB {
  final ContainerTestContract property;
  ContainerTestHasAttributeThatResolvesToImplB(this.property);
}

class ContainerTestConfigValue {
  final String key;
  const ContainerTestConfigValue(this.key);
}

class ContainerTestHasConfigValueProperty {
  final String timezone;
  ContainerTestHasConfigValueProperty(this.timezone);
}

class ContainerTestConfigValueWithResolve {
  final String key;
  const ContainerTestConfigValueWithResolve(this.key);

  String resolve(
      ContainerTestConfigValueWithResolve attribute, Container container) {
    return container.make('config').get(attribute.key);
  }
}

class ContainerTestHasConfigValueWithResolveProperty {
  final String env;
  ContainerTestHasConfigValueWithResolveProperty(this.env);
}

class ContainerTestConfigValueWithResolveAndAfter {
  const ContainerTestConfigValueWithResolveAndAfter();

  Object resolve(ContainerTestConfigValueWithResolveAndAfter attribute,
      Container container) {
    return {'name': 'Taylor'};
  }

  void after(ContainerTestConfigValueWithResolveAndAfter attribute,
      Object value, Container container) {
    (value as Map)['role'] = 'Developer';
  }
}

class ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback {
  final Map person;
  ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback(this.person);
}

class Repository {
  final Map<String, dynamic> _data;

  Repository(this._data);

  dynamic get(String key) {
    var keys = key.split('.');
    var value = _data;
    for (var k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }
    return value;
  }
}
