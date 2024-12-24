import 'package:test/test.dart';
import 'package:ioc_container/container.dart';
import 'package:platform_config/platform_config.dart';

void main() {
  group('ContextualBindingTest', () {
    test('testContainerCanInjectDifferentImplementationsDependingOnContext',
        () {
      var container = Container();

      container.bind('IContainerContextContractStub',
          (c) => ContainerContextImplementationStub());

      container
          .when('ContainerTestContextInjectOne')
          .needs('IContainerContextContractStub')
          .give('ContainerContextImplementationStub');
      container
          .when('ContainerTestContextInjectTwo')
          .needs('IContainerContextContractStub')
          .give('ContainerContextImplementationStubTwo');

      var one = container.make('ContainerTestContextInjectOne')
          as ContainerTestContextInjectOne;
      var two = container.make('ContainerTestContextInjectTwo')
          as ContainerTestContextInjectTwo;

      expect(one.impl, isA<ContainerContextImplementationStub>());
      expect(two.impl, isA<ContainerContextImplementationStubTwo>());

      // Test With Closures
      container = Container();

      container.bind('IContainerContextContractStub',
          (c) => ContainerContextImplementationStub());

      container
          .when('ContainerTestContextInjectOne')
          .needs('IContainerContextContractStub')
          .give('ContainerContextImplementationStub');
      container
          .when('ContainerTestContextInjectTwo')
          .needs('IContainerContextContractStub')
          .give((Container container) {
        return container.make('ContainerContextImplementationStubTwo');
      });

      one = container.make('ContainerTestContextInjectOne')
          as ContainerTestContextInjectOne;
      two = container.make('ContainerTestContextInjectTwo')
          as ContainerTestContextInjectTwo;

      expect(one.impl, isA<ContainerContextImplementationStub>());
      expect(two.impl, isA<ContainerContextImplementationStubTwo>());

      // Test nesting to make the same 'abstract' in different context
      container = Container();

      container.bind('IContainerContextContractStub',
          (c) => ContainerContextImplementationStub());

      container
          .when('ContainerTestContextInjectOne')
          .needs('IContainerContextContractStub')
          .give((Container container) {
        return container.make('IContainerContextContractStub');
      });

      one = container.make('ContainerTestContextInjectOne')
          as ContainerTestContextInjectOne;

      expect(one.impl, isA<ContainerContextImplementationStub>());
    });

    test('testContextualBindingWorksForExistingInstancedBindings', () {
      var container = Container();

      container.instance(
          'IContainerContextContractStub', ContainerImplementationStub());

      container
          .when('ContainerTestContextInjectOne')
          .needs('IContainerContextContractStub')
          .give('ContainerContextImplementationStubTwo');

      var instance = container.make('ContainerTestContextInjectOne')
          as ContainerTestContextInjectOne;
      expect(instance.impl, isA<ContainerContextImplementationStubTwo>());
    });

    test('testContextualBindingGivesValuesFromConfigWithDefault', () {
      var container = Container();

      container.singleton(
          'config',
          (c) => Repository({
                'test': {
                  'password': 'hunter42',
                },
              }));

      container
          .when('ContainerTestContextInjectFromConfigIndividualValues')
          .needs('\$username')
          .giveConfig('test.username', 'DEFAULT_USERNAME');

      container
          .when('ContainerTestContextInjectFromConfigIndividualValues')
          .needs('\$password')
          .giveConfig('test.password');

      var resolvedInstance =
          container.make('ContainerTestContextInjectFromConfigIndividualValues')
              as ContainerTestContextInjectFromConfigIndividualValues;

      expect(resolvedInstance.username, equals('DEFAULT_USERNAME'));
      expect(resolvedInstance.password, equals('hunter42'));
      expect(resolvedInstance.alias, isNull);
    });
  });
}

abstract class IContainerContextContractStub {}

class ContainerContextNonContractStub {}

class ContainerContextImplementationStub
    implements IContainerContextContractStub {}

class ContainerContextImplementationStubTwo
    implements IContainerContextContractStub {}

class ContainerImplementationStub implements IContainerContextContractStub {}

class ContainerTestContextInjectInstantiations
    implements IContainerContextContractStub {
  static int instantiations = 0;

  ContainerTestContextInjectInstantiations() {
    instantiations++;
  }
}

class ContainerTestContextInjectOne {
  final IContainerContextContractStub impl;

  ContainerTestContextInjectOne(this.impl);
}

class ContainerTestContextInjectTwo {
  final IContainerContextContractStub impl;

  ContainerTestContextInjectTwo(this.impl);
}

class ContainerTestContextInjectFromConfigIndividualValues {
  final String username;
  final String password;
  final String? alias;

  ContainerTestContextInjectFromConfigIndividualValues(
      this.username, this.password,
      [this.alias]);
}
