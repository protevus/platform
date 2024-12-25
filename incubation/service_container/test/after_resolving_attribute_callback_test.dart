import 'package:test/test.dart';
import 'package:platform_service_container/service_container.dart';

void main() {
  group('AfterResolvingAttributeCallbackTest', () {
    late Container container;

    setUp(() {
      container = Container();
    });

    test('callback is called after dependency resolution with attribute', () {
      container.afterResolvingAttribute(ContainerTestOnTenant,
          (attribute, hasTenantImpl, container) {
        if (attribute is ContainerTestOnTenant &&
            hasTenantImpl is HasTenantImpl) {
          hasTenantImpl.onTenant(attribute.tenant);
        }
      });

      var hasTenantA =
          container.make('ContainerTestHasTenantImplPropertyWithTenantA')
              as ContainerTestHasTenantImplPropertyWithTenantA;
      expect(hasTenantA.property, isA<HasTenantImpl>());
      expect(hasTenantA.property.tenant, equals(Tenant.TenantA));

      var hasTenantB =
          container.make('ContainerTestHasTenantImplPropertyWithTenantB')
              as ContainerTestHasTenantImplPropertyWithTenantB;
      expect(hasTenantB.property, isA<HasTenantImpl>());
      expect(hasTenantB.property.tenant, equals(Tenant.TenantB));
    });

    test('callback is called after class with attribute is resolved', () {
      container.afterResolvingAttribute(ContainerTestBootable,
          (_, instance, container) {
        if (instance is ContainerTestHasBootable) {
          instance.booting();
        }
      });

      var instance = container.make('ContainerTestHasBootable')
          as ContainerTestHasBootable;

      expect(instance, isA<ContainerTestHasBootable>());
      expect(instance.hasBooted, isTrue);
    });

    test(
        'callback is called after class with constructor and attribute is resolved',
        () {
      container.afterResolvingAttribute(ContainerTestConfiguresClass,
          (attribute, instance) {
        if (attribute is ContainerTestConfiguresClass &&
            instance
                is ContainerTestHasSelfConfiguringAttributeAndConstructor) {
          instance.value = attribute.value;
        }
      });

      container
          .when('ContainerTestHasSelfConfiguringAttributeAndConstructor')
          .needs('value')
          .give('not-the-right-value');

      var instance = container
              .make('ContainerTestHasSelfConfiguringAttributeAndConstructor')
          as ContainerTestHasSelfConfiguringAttributeAndConstructor;

      expect(instance,
          isA<ContainerTestHasSelfConfiguringAttributeAndConstructor>());
      expect(instance.value, equals('the-right-value'));
    });
  });
}

class ContainerTestOnTenant {
  final Tenant tenant;
  const ContainerTestOnTenant(this.tenant);
}

enum Tenant {
  TenantA,
  TenantB,
}

class HasTenantImpl {
  Tenant? tenant;

  void onTenant(Tenant tenant) {
    this.tenant = tenant;
  }
}

class ContainerTestHasTenantImplPropertyWithTenantA {
  @ContainerTestOnTenant(Tenant.TenantA)
  final HasTenantImpl property;

  ContainerTestHasTenantImplPropertyWithTenantA(this.property);
}

class ContainerTestHasTenantImplPropertyWithTenantB {
  @ContainerTestOnTenant(Tenant.TenantB)
  final HasTenantImpl property;

  ContainerTestHasTenantImplPropertyWithTenantB(this.property);
}

class ContainerTestConfiguresClass {
  final String value;
  const ContainerTestConfiguresClass(this.value);
}

@ContainerTestConfiguresClass('the-right-value')
class ContainerTestHasSelfConfiguringAttributeAndConstructor {
  String value;
  ContainerTestHasSelfConfiguringAttributeAndConstructor(this.value);
}

class ContainerTestBootable {
  const ContainerTestBootable();
}

@ContainerTestBootable()
class ContainerTestHasBootable {
  bool hasBooted = false;

  void booting() {
    hasBooted = true;
  }
}
