import 'package:platform_container/container.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:test/test.dart';
import '../lib/src/reflection.dart';

// Attribute classes
@ContainerReflectable()
class ContainerTestAttributeThatResolvesContractImpl
    implements ContextualAttribute {
  final String name;

  const ContainerTestAttributeThatResolvesContractImpl(this.name);

  @override
  dynamic resolve(dynamic attribute, ContainerContract container) {
    return switch (name) {
      'A' => ContainerTestImplA(),
      'B' => ContainerTestImplB(),
      _ => throw ArgumentError('Unknown implementation'),
    };
  }

  @override
  void after(dynamic attribute, dynamic value, ContainerContract container) {}

  static String type() => 'ContainerTestAttributeThatResolvesContractImpl';
}

// Test contract and implementations
@ContainerReflectable()
abstract class ContainerTestContract {
  static String type() => 'ContainerTestContract';
}

@ContainerReflectable()
class ContainerTestImplA implements ContainerTestContract {
  static String type() => 'ContainerTestImplA';
}

@ContainerReflectable()
class ContainerTestImplB implements ContainerTestContract {
  static String type() => 'ContainerTestImplB';
}

// Test classes with attributes
@ContainerReflectable()
class ContainerTestHasAttributeThatResolvesToImplA {
  final ContainerTestContract property;

  ContainerTestHasAttributeThatResolvesToImplA(
    @ContainerTestAttributeThatResolvesContractImpl('A') this.property,
  );

  static String type() => 'ContainerTestHasAttributeThatResolvesToImplA';
}

@ContainerReflectable()
class ContainerTestHasAttributeThatResolvesToImplB {
  final ContainerTestContract property;

  ContainerTestHasAttributeThatResolvesToImplB(
    @ContainerTestAttributeThatResolvesContractImpl('B') this.property,
  );

  static String type() => 'ContainerTestHasAttributeThatResolvesToImplB';
}

// Config value attribute
@ContainerReflectable()
class ContainerTestConfigValue implements ContextualAttribute {
  final String key;

  const ContainerTestConfigValue(this.key);

  @override
  dynamic resolve(dynamic attribute, ContainerContract container) {
    final config = container.make('config') as Map;
    final parts = key.split('.');
    var value = config;
    for (final part in parts) {
      value = value[part];
    }
    return value;
  }

  @override
  void after(dynamic attribute, dynamic value, ContainerContract container) {}

  static String type() => 'ContainerTestConfigValue';
}

@ContainerReflectable()
class ContainerTestHasConfigValueProperty {
  final String timezone;

  ContainerTestHasConfigValueProperty(
    @ContainerTestConfigValue('app.timezone') this.timezone,
  );

  static String type() => 'ContainerTestHasConfigValueProperty';
}

// Config value with resolve method
@ContainerReflectable()
class ContainerTestConfigValueWithResolve implements ContextualAttribute {
  final String key;

  const ContainerTestConfigValueWithResolve(this.key);

  @override
  dynamic resolve(dynamic attribute, ContainerContract container) {
    final config = container.make('config') as Map;
    final parts = key.split('.');
    var value = config;
    for (final part in parts) {
      value = value[part];
    }
    return value;
  }

  @override
  void after(dynamic attribute, dynamic value, ContainerContract container) {}

  static String type() => 'ContainerTestConfigValueWithResolve';
}

@ContainerReflectable()
class ContainerTestHasConfigValueWithResolveProperty {
  final String env;

  ContainerTestHasConfigValueWithResolveProperty(
    @ContainerTestConfigValueWithResolve('app.env') this.env,
  );

  static String type() => 'ContainerTestHasConfigValueWithResolveProperty';
}

// Config value with resolve and after callback
@ContainerReflectable()
class ContainerTestConfigValueWithResolveAndAfter
    implements ContextualAttribute {
  const ContainerTestConfigValueWithResolveAndAfter();

  @override
  dynamic resolve(dynamic attribute, ContainerContract container) {
    return {'name': 'Taylor'};
  }

  @override
  void after(dynamic attribute, dynamic value, ContainerContract container) {
    (value as Map)['role'] = 'Developer';
  }

  static String type() => 'ContainerTestConfigValueWithResolveAndAfter';
}

@ContainerReflectable()
class ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback {
  final Map<String, String> person;

  ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback(
    @ContainerTestConfigValueWithResolveAndAfter() this.person,
  );

  static String type() =>
      'ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback';
}

void main() {
  setUp(() {
    initializeReflection();

    // Register test classes
    registerTypes([
      ContainerTestAttributeThatResolvesContractImpl,
      ContainerTestContract,
      ContainerTestImplA,
      ContainerTestImplB,
      ContainerTestHasAttributeThatResolvesToImplA,
      ContainerTestHasAttributeThatResolvesToImplB,
      ContainerTestConfigValue,
      ContainerTestHasConfigValueProperty,
      ContainerTestConfigValueWithResolve,
      ContainerTestHasConfigValueWithResolveProperty,
      ContainerTestConfigValueWithResolveAndAfter,
      ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback,
    ]);
  });

  test('dependency can be resolved from attribute binding', () {
    final container = Container();

    container.bind(ContainerTestContract.type(), () => ContainerTestImplB());
    container.whenHasAttribute(
      ContainerTestAttributeThatResolvesContractImpl.type(),
      (attribute) {
        return switch (attribute.name) {
          'A' => ContainerTestImplA(),
          'B' => ContainerTestImplB(),
          _ => throw ArgumentError('Unknown implementation'),
        };
      },
    );

    final classA =
        container.make(ContainerTestHasAttributeThatResolvesToImplA.type());
    expect(classA, isA<ContainerTestHasAttributeThatResolvesToImplA>());
    expect(classA.property, isA<ContainerTestImplA>());

    final classB =
        container.make(ContainerTestHasAttributeThatResolvesToImplB.type());
    expect(classB, isA<ContainerTestHasAttributeThatResolvesToImplB>());
    expect(classB.property, isA<ContainerTestImplB>());
  });

  test('scalar dependency can be resolved from attribute binding', () {
    final container = Container();
    container.singleton(
        'config',
        () => {
              'app': {
                'timezone': 'Europe/Paris',
              },
            });

    container.whenHasAttribute(
      ContainerTestConfigValue.type(),
      (attribute, container) {
        final config = container.make('config') as Map;
        final parts = attribute.key.split('.');
        var value = config;
        for (final part in parts) {
          value = value[part];
        }
        return value;
      },
    );

    final class_ = container.make(ContainerTestHasConfigValueProperty.type());
    expect(class_, isA<ContainerTestHasConfigValueProperty>());
    expect(class_.timezone, equals('Europe/Paris'));
  });

  test('scalar dependency can be resolved from attribute resolve method', () {
    final container = Container();
    container.singleton(
        'config',
        () => {
              'app': {
                'env': 'production',
              },
            });

    final class_ =
        container.make(ContainerTestHasConfigValueWithResolveProperty.type());
    expect(class_, isA<ContainerTestHasConfigValueWithResolveProperty>());
    expect(class_.env, equals('production'));
  });

  test('dependency with after callback attribute can be resolved', () {
    final container = Container();

    final class_ = container.make(
        ContainerTestHasConfigValueWithResolvePropertyAndAfterCallback.type());
    expect(class_.person['role'], equals('Developer'));
  });
}
