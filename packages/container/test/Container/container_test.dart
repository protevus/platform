import 'package:platform_contracts/contracts.dart';
import 'package:platform_container/platform_container.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../laravel_container_test.mocks.dart';
import '../stubs.dart';

@GenerateMocks([
  ReflectorContract,
  ReflectedClassContract,
  ReflectedInstanceContract,
  ReflectedFunctionContract,
  ReflectedParameterContract,
  ReflectedTypeContract
])
void main() {
  late IlluminateContainer container;
  late MockReflectorContract reflector;
  late MockReflectedClassContract reflectedClass;
  late MockReflectedInstanceContract reflectedInstance;
  late MockReflectedFunctionContract reflectedFunction;
  late MockReflectedParameterContract reflectedParameter;
  late MockReflectedTypeContract reflectedType;

  setUp(() {
    reflector = MockReflectorContract();
    reflectedClass = MockReflectedClassContract();
    reflectedInstance = MockReflectedInstanceContract();
    reflectedFunction = MockReflectedFunctionContract();
    reflectedParameter = MockReflectedParameterContract();
    reflectedType = MockReflectedTypeContract();
    container = IlluminateContainer(reflector);

    // Setup default reflection behavior
    when(reflector.reflectClass(any)).thenReturn(reflectedClass);
    when(reflectedClass.newInstance('', [])).thenReturn(reflectedInstance);
  });

  group('Container Basic Resolution', () {
    test('testClosureResolution', () {
      container.bind<String>((c) => 'Taylor');
      expect(container.make<String>(), equals('Taylor'));
    });

    test('testBindIfDoesntRegisterIfServiceAlreadyRegistered', () {
      container.bind<String>((c) => 'Taylor');
      container.bindIf<String>((c) => 'Dayle');
      expect(container.make<String>(), equals('Taylor'));
    });

    test('testBindIfDoesRegisterIfServiceNotRegisteredYet', () {
      container.bindIf<String>((c) => 'Dayle');
      expect(container.make<String>(), equals('Dayle'));
    });

    test('testAutoConcreteResolution', () {
      final instance = ContainerConcreteStub();
      when(reflectedInstance.reflectee).thenReturn(instance);
      expect(container.make<ContainerConcreteStub>(),
          isA<ContainerConcreteStub>());
    });
  });

  group('Container Singleton', () {
    test('testSharedClosureResolution', () {
      container
          .singleton<ContainerConcreteStub>((c) => ContainerConcreteStub());
      final first = container.make<ContainerConcreteStub>();
      final second = container.make<ContainerConcreteStub>();
      expect(identical(first, second), isTrue);
    });

    test('testSingletonIfDoesntRegisterIfBindingAlreadyRegistered', () {
      container
          .singleton<ContainerConcreteStub>((c) => ContainerConcreteStub());
      final first = container.make<ContainerConcreteStub>();
      container
          .singletonIf<ContainerConcreteStub>((c) => ContainerConcreteStub());
      final second = container.make<ContainerConcreteStub>();
      expect(identical(first, second), isTrue);
    });

    test('testSingletonIfDoesRegisterIfBindingNotRegisteredYet', () {
      container
          .singletonIf<ContainerConcreteStub>((c) => ContainerConcreteStub());
      final first = container.make<ContainerConcreteStub>();
      final second = container.make<ContainerConcreteStub>();
      expect(identical(first, second), isTrue);
    });

    test('testBindingAnInstanceAsShared', () {
      final instance = ContainerConcreteStub();
      container.instance<ContainerConcreteStub>(instance);
      expect(
          identical(container.make<ContainerConcreteStub>(), instance), isTrue);
    });
  });

  group('Container Scoped', () {
    test('testScopedClosureResolution', () {
      container.scoped<ContainerConcreteStub>((c) => ContainerConcreteStub());
      final first = container.make<ContainerConcreteStub>();
      final second = container.make<ContainerConcreteStub>();
      expect(identical(first, second), isTrue);

      container.forgetScopedInstances();
      final third = container.make<ContainerConcreteStub>();
      expect(identical(second, third), isFalse);
    });

    test('testScopedIfDoesntRegisterIfBindingAlreadyRegistered', () {
      container.scoped<ContainerConcreteStub>((c) => ContainerConcreteStub());
      final first = container.make<ContainerConcreteStub>();
      container.scopedIf<ContainerConcreteStub>((c) => ContainerConcreteStub());
      final second = container.make<ContainerConcreteStub>();
      expect(identical(first, second), isTrue);
    });

    test('testScopedIfDoesRegisterIfBindingNotRegisteredYet', () {
      container.scopedIf<ContainerConcreteStub>((c) => ContainerConcreteStub());
      final first = container.make<ContainerConcreteStub>();
      final second = container.make<ContainerConcreteStub>();
      expect(identical(first, second), isTrue);
    });
  });

  group('Container Dependencies', () {
    test('testAbstractToConcreteResolution', () {
      final impl = ContainerImplementationStub();
      final dependent = ContainerDependentStub(impl);
      when(reflectedInstance.reflectee).thenReturn(dependent);

      container
          .bind<IContainerContractStub>((c) => ContainerImplementationStub());
      final instance = container.make<ContainerDependentStub>();
      expect(instance.impl, isA<ContainerImplementationStub>());
    });

    test('testNestedDependencyResolution', () {
      final impl = ContainerImplementationStub();
      final dependent = ContainerDependentStub(impl);
      final nested = ContainerNestedDependentStub(dependent);
      when(reflectedInstance.reflectee).thenReturn(nested);

      container
          .bind<IContainerContractStub>((c) => ContainerImplementationStub());
      final instance = container.make<ContainerNestedDependentStub>();
      expect(instance.inner, isA<ContainerDependentStub>());
      expect(instance.inner.impl, isA<ContainerImplementationStub>());
    });

    test('testContainerIsPassedToResolvers', () {
      container.bind<ContainerContract>((c) => c);
      final resolved = container.make<ContainerContract>();
      expect(identical(resolved, container), isTrue);
    });
  });

  group('Container Aliases', () {
    test('testAliases', () {
      final impl = ContainerImplementationStub('bar');
      when(reflectedInstance.reflectee).thenReturn(impl);

      container.bind<IContainerContractStub>((c) => impl);
      container.alias(IContainerContractStub, ContainerImplementationStub);

      expect(
          container.make<IContainerContractStub>().getValue(), equals('bar'));
      expect(container.make<ContainerImplementationStub>().getValue(),
          equals('bar'));
      expect(container.isAlias('ContainerImplementationStub'), isTrue);
    });

    test('testAliasesWithArrayOfParameters', () {
      final impl = ContainerImplementationStub('foo');
      when(reflectedInstance.reflectee).thenReturn(impl);

      container.bind<IContainerContractStub>((c) => impl);
      container.alias(IContainerContractStub, ContainerImplementationStub);

      expect(
          container.make<IContainerContractStub>().getValue(), equals('foo'));
      expect(container.make<ContainerImplementationStub>().getValue(),
          equals('foo'));
    });

    test('testGetAliasRecursive', () {
      final impl = ContainerImplementationStub('foo');
      when(reflectedInstance.reflectee).thenReturn(impl);

      // Bind the implementation to the interface
      container.bind<IContainerContractStub>((c) => impl);

      // Create alias chain in reverse order
      container.alias(ContainerImplementationStub, StubAlias);
      container.alias(IContainerContractStub, ContainerImplementationStub);

      // Verify immediate aliases
      expect(
          container.getAlias(StubAlias), equals(ContainerImplementationStub));
      expect(container.getAlias(ContainerImplementationStub),
          equals(IContainerContractStub));

      // Verify instance resolution through alias chain
      final instance = container.make<IContainerContractStub>();
      expect(instance.getValue(), equals('foo'));
    });
  });

  group('Container State', () {
    test('testBindingsCanBeOverridden', () {
      container.bind<String>((c) => 'bar');
      container.bind<String>((c) => 'baz');
      expect(container.make<String>(), equals('baz'));
    });

    test('testContainerFlushFlushesAllBindingsAliasesAndResolvedInstances', () {
      container
          .bind<IContainerContractStub>((c) => ContainerImplementationStub());
      container.bind<ContainerConcreteStub>((c) => ContainerConcreteStub());
      container.tag([ContainerConcreteStub], 'services');
      container.alias(IContainerContractStub, ContainerImplementationStub);

      expect(container.has<IContainerContractStub>(), isTrue);
      expect(container.has<ContainerConcreteStub>(), isTrue);
      expect(container.isAlias('ContainerImplementationStub'), isTrue);

      container.flush();

      expect(container.has<IContainerContractStub>(), isFalse);
      expect(container.has<ContainerConcreteStub>(), isFalse);
      expect(container.isAlias('ContainerImplementationStub'), isFalse);
    });

    test('testForgetInstanceForgetsInstance', () {
      final instance = ContainerConcreteStub();
      container.instance<ContainerConcreteStub>(instance);
      expect(container.has<ContainerConcreteStub>(), isTrue);
      container.forgetInstance(ContainerConcreteStub);
      expect(container.has<ContainerConcreteStub>(), isFalse);
    });

    test('testForgetInstancesForgetsAllInstances', () {
      final instance1 = ContainerConcreteStub();
      final instance2 = ContainerImplementationStub();
      container.instance<ContainerConcreteStub>(instance1);
      container.instance<ContainerImplementationStub>(instance2);
      expect(container.has<ContainerConcreteStub>(), isTrue);
      expect(container.has<ContainerImplementationStub>(), isTrue);
      container.forgetInstances();
      expect(container.has<ContainerConcreteStub>(), isFalse);
      expect(container.has<ContainerImplementationStub>(), isFalse);
    });
  });
}
