import 'package:platform_container/container.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';

// Tenant attribute and related classes
@reflectable
class ContainerTestOnTenant implements ContextualAttribute {
  final Tenant tenant;

  const ContainerTestOnTenant(this.tenant);

  @override
  dynamic resolve(dynamic attribute, ContainerContract container) => null;

  @override
  void after(dynamic attribute, dynamic value, ContainerContract container) {}

  static String type() => 'ContainerTestOnTenant';
}

enum Tenant {
  tenantA,
  tenantB,
}

@reflectable
class HasTenantImpl {
  Tenant? tenant;

  void onTenant(Tenant tenant) {
    this.tenant = tenant;
  }

  static String type() => 'HasTenantImpl';
}

@reflectable
class ContainerTestHasTenantImplPropertyWithTenantA {
  final HasTenantImpl property;

  ContainerTestHasTenantImplPropertyWithTenantA(
    @ContainerTestOnTenant(Tenant.tenantA) this.property,
  );

  static String type() => 'ContainerTestHasTenantImplPropertyWithTenantA';
}

@reflectable
class ContainerTestHasTenantImplPropertyWithTenantB {
  final HasTenantImpl property;

  ContainerTestHasTenantImplPropertyWithTenantB(
    @ContainerTestOnTenant(Tenant.tenantB) this.property,
  );

  static String type() => 'ContainerTestHasTenantImplPropertyWithTenantB';
}

// Configures class attribute
@reflectable
class ContainerTestConfiguresClass implements ContextualAttribute {
  final String value;

  const ContainerTestConfiguresClass(this.value);

  @override
  dynamic resolve(dynamic attribute, ContainerContract container) => null;

  @override
  void after(dynamic attribute, dynamic value, ContainerContract container) {}

  static String type() => 'ContainerTestConfiguresClass';
}

@reflectable
@ContainerTestConfiguresClass('the-right-value')
class ContainerTestHasSelfConfiguringAttributeAndConstructor {
  String value;

  ContainerTestHasSelfConfiguringAttributeAndConstructor(this.value);

  static String type() =>
      'ContainerTestHasSelfConfiguringAttributeAndConstructor';
}

// Bootable attribute
@reflectable
class ContainerTestBootable implements ContextualAttribute {
  const ContainerTestBootable();

  @override
  dynamic resolve(dynamic attribute, ContainerContract container) => null;

  @override
  void after(dynamic attribute, dynamic value, ContainerContract container) {}

  static String type() => 'ContainerTestBootable';
}

@reflectable
@ContainerTestBootable()
class ContainerTestHasBootable {
  bool hasBooted = false;

  void booting() {
    hasBooted = true;
  }

  static String type() => 'ContainerTestHasBootable';
}

void main() {
  setUp(() {
    // Register test classes using Container's static method
    Container.registerTypes([
      ContainerTestOnTenant,
      HasTenantImpl,
      ContainerTestHasTenantImplPropertyWithTenantA,
      ContainerTestHasTenantImplPropertyWithTenantB,
      ContainerTestConfiguresClass,
      ContainerTestHasSelfConfiguringAttributeAndConstructor,
      ContainerTestBootable,
      ContainerTestHasBootable,
    ]);
  });

  test('callback is called after dependency resolution with attribute', () {
    final container = Container();

    container.afterResolvingAttribute(
      ContainerTestOnTenant.type(),
      (attribute, instance, container) {
        (instance as HasTenantImpl).onTenant(attribute.tenant);
      },
    );

    final hasTenantA =
        container.make(ContainerTestHasTenantImplPropertyWithTenantA.type());
    expect(hasTenantA.property, isA<HasTenantImpl>());
    expect(hasTenantA.property.tenant, equals(Tenant.tenantA));

    final hasTenantB =
        container.make(ContainerTestHasTenantImplPropertyWithTenantB.type());
    expect(hasTenantB.property, isA<HasTenantImpl>());
    expect(hasTenantB.property.tenant, equals(Tenant.tenantB));
  });

  test('callback is called after class with attribute is resolved', () {
    final container = Container();

    container.afterResolvingAttribute(
      ContainerTestBootable.type(),
      (attribute, instance, container) {
        if (instance is ContainerTestHasBootable) {
          instance.booting();
        }
      },
    );

    final instance = container.make(ContainerTestHasBootable.type());
    expect(instance, isA<ContainerTestHasBootable>());
    expect(instance.hasBooted, isTrue);
  });

  test(
      'callback is called after class with constructor and attribute is resolved',
      () {
    final container = Container();

    container.afterResolvingAttribute(
      ContainerTestConfiguresClass.type(),
      (attribute, instance, container) {
        if (instance
            is ContainerTestHasSelfConfiguringAttributeAndConstructor) {
          instance.value = attribute.value;
        }
      },
    );

    container
        .when(ContainerTestHasSelfConfiguringAttributeAndConstructor.type())
        .needs('value')
        .give('not-the-right-value');

    final instance = container
        .make(ContainerTestHasSelfConfiguringAttributeAndConstructor.type());
    expect(instance,
        isA<ContainerTestHasSelfConfiguringAttributeAndConstructor>());
    expect(instance.value, equals('the-right-value'));
  });
}
