import 'package:test/test.dart';
import 'package:ioc_container/container.dart';
import 'package:platform_contracts/contracts.dart';

class ContainerConcreteStub {}

class IContainerContractStub {}

class ContainerImplementationStub implements IContainerContractStub {}

class ContainerDependentStub {
  final IContainerContractStub impl;

  ContainerDependentStub(this.impl);
}

void main() {
  group('ContainerTest', () {
    late Container container;

    setUp(() {
      container = Container();
      setUpBindings(container);
    });

    test('testContainerSingleton', () {
      var container1 = Container.getInstance();
      var container2 = Container.getInstance();
      expect(container1, same(container2));
    });

    test('testClosureResolution', () {
      container.bind('name', (Container c) => 'Taylor');
      expect(container.make('name'), equals('Taylor'));
    });

    test('testBindIfDoesntRegisterIfServiceAlreadyRegistered', () {
      container.bind('name', (Container c) => 'Taylor');
      container.bindIf('name', (Container c) => 'Dayle');

      expect(container.make('name'), equals('Taylor'));
    });

    test('testBindIfDoesRegisterIfServiceNotRegisteredYet', () {
      container.bind('surname', (Container c) => 'Taylor');
      container.bindIf('name', (Container c) => 'Dayle');

      expect(container.make('name'), equals('Dayle'));
    });

    test('testSingletonIfDoesntRegisterIfBindingAlreadyRegistered', () {
      container.singleton('class', (Container c) => ContainerConcreteStub());
      var firstInstantiation = container.make('class');
      container.singletonIf('class', (Container c) => ContainerConcreteStub());
      var secondInstantiation = container.make('class');
      expect(firstInstantiation, same(secondInstantiation));
    });

    test('testSingletonIfDoesRegisterIfBindingNotRegisteredYet', () {
      container.singleton('class', (Container c) => ContainerConcreteStub());
      container.singletonIf(
          'otherClass', (Container c) => ContainerConcreteStub());
      var firstInstantiation = container.make('otherClass');
      var secondInstantiation = container.make('otherClass');
      expect(firstInstantiation, same(secondInstantiation));
    });

    test('testSharedClosureResolution', () {
      container.singleton('class', (Container c) => ContainerConcreteStub());
      var firstInstantiation = container.make('class');
      var secondInstantiation = container.make('class');
      expect(firstInstantiation, same(secondInstantiation));
    });

    test('testAutoConcreteResolution', () {
      var instance = container.make('ContainerConcreteStub');
      expect(instance, isA<ContainerConcreteStub>());
    });

    test('testSharedConcreteResolution', () {
      container.singleton(
          'ContainerConcreteStub', (Container c) => ContainerConcreteStub());

      var var1 = container.make('ContainerConcreteStub');
      var var2 = container.make('ContainerConcreteStub');
      expect(var1, same(var2));
    });

    test('testAbstractToConcreteResolution', () {
      container.bind('IContainerContractStub',
          (Container c) => ContainerImplementationStub());
      var instance = container.make('ContainerDependentStub');
      expect(instance.impl, isA<ContainerImplementationStub>());
    });

    test('testNestedDependencyResolution', () {
      container.bind('IContainerContractStub',
          (Container c) => ContainerImplementationStub());
      var instance = container.make('ContainerNestedDependentStub');
      expect(instance.inner, isA<ContainerDependentStub>());
      expect(instance.inner.impl, isA<ContainerImplementationStub>());
    });

    test('testContainerIsPassedToResolvers', () {
      container.bind('something', (Container c) => c);
      var c = container.make('something');
      expect(c, same(container));
    });

    test('testArrayAccess', () {
      container['something'] = (Container c) => 'foo';
      expect(container['something'], equals('foo'));
    });

    test('testAliases', () {
      container['foo'] = 'bar';
      container.alias('foo', 'baz');
      container.alias('baz', 'bat');
      expect(container.make('foo'), equals('bar'));
      expect(container.make('baz'), equals('bar'));
      expect(container.make('bat'), equals('bar'));
    });

    test('testBindingsCanBeOverridden', () {
      container['foo'] = 'bar';
      container['foo'] = 'baz';
      expect(container['foo'], equals('baz'));
    });

    test('testResolutionOfDefaultParameters', () {
      container.bind('foo', (Container c) => 'bar');
      container.bind(
          'ContainerDefaultValueStub',
          (Container c) => ContainerDefaultValueStub(
              c.make('ContainerConcreteStub'), c.make('foo')));
      var result = container.make('ContainerDefaultValueStub');
      expect(result.stub, isA<ContainerConcreteStub>());
      expect(result.defaultValue, equals('bar'));
    });

    test('testUnsetRemoveBoundInstances', () {
      container.instance('obj', Object());
      expect(container.bound('obj'), isTrue);
      container.forgetInstance('obj');
      expect(container.bound('obj'), isFalse);
    });

    test('testExtendMethod', () {
      container.singleton('foo', (Container c) => 'foo');
      container.extend('foo', (dynamic original) {
        return '$original bar';
      });
      expect(container.make('foo'), equals('foo bar'));
    });

    test('testFactoryMethod', () {
      container.bind('foo', (Container c) => 'foo');
      var factory = container.factory('foo');
      expect(factory(), equals('foo'));
    });

    test('testTaggedBindings', () {
      container.tag(['foo', 'bar'], 'foobar');
      container.bind('foo', (Container c) => 'foo');
      container.bind('bar', (Container c) => 'bar');
      var tagged = container.tagged('foobar');
      expect(tagged, containsAll(['foo', 'bar']));
    });

    test('testCircularDependencies', () {
      container.bind('circular1', (Container c) => c.make('circular2'));
      container.bind('circular2', (Container c) => c.make('circular1'));
      expect(() => container.make('circular1'),
          throwsA(isA<CircularDependencyException>()));
    });

    test('testScopedClosureResolution', () {
      container.scoped('class', (Container c) => Object());
      var firstInstantiation = container.make('class');
      var secondInstantiation = container.make('class');
      expect(firstInstantiation, same(secondInstantiation));
    });

    test('testScopedClosureResets', () {
      container.scoped('class', (Container c) => Object());
      var firstInstantiation = container.makeScoped('class');
      container.forgetScopedInstances();
      var secondInstantiation = container.makeScoped('class');
      expect(firstInstantiation, isNot(same(secondInstantiation)));
    });

    test('testScopedClosureResolution', () {
      container.scoped('class', (Container c) => Object());
      var firstInstantiation = container.makeScoped('class');
      var secondInstantiation = container.makeScoped('class');
      expect(firstInstantiation, same(secondInstantiation));
    });
    test('testForgetInstanceForgetsInstance', () {
      var containerConcreteStub = ContainerConcreteStub();
      container.instance('ContainerConcreteStub', containerConcreteStub);
      expect(container.isShared('ContainerConcreteStub'), isTrue);
      container.forgetInstance('ContainerConcreteStub');
      expect(container.isShared('ContainerConcreteStub'), isFalse);
    });

    test('testForgetInstancesForgetsAllInstances', () {
      var stub1 = ContainerConcreteStub();
      var stub2 = ContainerConcreteStub();
      var stub3 = ContainerConcreteStub();
      container.instance('Instance1', stub1);
      container.instance('Instance2', stub2);
      container.instance('Instance3', stub3);
      expect(container.isShared('Instance1'), isTrue);
      expect(container.isShared('Instance2'), isTrue);
      expect(container.isShared('Instance3'), isTrue);
      container.forgetInstances();
      expect(container.isShared('Instance1'), isFalse);
      expect(container.isShared('Instance2'), isFalse);
      expect(container.isShared('Instance3'), isFalse);
    });

    test('testContainerFlushFlushesAllBindingsAliasesAndResolvedInstances', () {
      container.bind('ConcreteStub', (Container c) => ContainerConcreteStub(),
          shared: true);
      container.alias('ConcreteStub', 'ContainerConcreteStub');
      container.make('ConcreteStub');
      expect(container.resolved('ConcreteStub'), isTrue);
      expect(container.isAlias('ContainerConcreteStub'), isTrue);
      expect(container.getBindings().containsKey('ConcreteStub'), isTrue);
      expect(container.isShared('ConcreteStub'), isTrue);
      container.flush();
      expect(container.resolved('ConcreteStub'), isFalse);
      expect(container.isAlias('ContainerConcreteStub'), isFalse);
      expect(container.getBindings().isEmpty, isTrue);
      expect(container.isShared('ConcreteStub'), isFalse);
    });

    test('testResolvedResolvesAliasToBindingNameBeforeChecking', () {
      container.bind('ConcreteStub', (Container c) => ContainerConcreteStub(),
          shared: true);
      container.alias('ConcreteStub', 'foo');

      expect(container.resolved('ConcreteStub'), isFalse);
      expect(container.resolved('foo'), isFalse);

      container.make('ConcreteStub');

      expect(container.resolved('ConcreteStub'), isTrue);
      expect(container.resolved('foo'), isTrue);
    });
  });
}

class ContainerDefaultValueStub {
  final ContainerConcreteStub stub;
  final String defaultValue;

  ContainerDefaultValueStub(this.stub, [this.defaultValue = 'taylor']);
}

class ContainerNestedDependentStub {
  final ContainerDependentStub inner;

  ContainerNestedDependentStub(this.inner);
}

// Helper function to set up bindings
void setUpBindings(Container container) {
  container.bind(
      'ContainerConcreteStub', (Container c) => ContainerConcreteStub());
  container.bind(
      'ContainerDependentStub',
      (Container c) =>
          ContainerDependentStub(c.make('IContainerContractStub')));
  container.bind(
      'ContainerNestedDependentStub',
      (Container c) =>
          ContainerNestedDependentStub(c.make('ContainerDependentStub')));
}
