import 'package:platform_container/container.dart';
import 'package:test/test.dart';
import '../lib/src/reflection.dart';

// Test stubs
@ContainerReflectable()
abstract class IContainerContextContractStub {
  static String type() => 'IContainerContextContractStub';
}

@ContainerReflectable()
class ContainerContextNonContractStub {
  static String type() => 'ContainerContextNonContractStub';
}

@ContainerReflectable()
class ContainerContextImplementationStub
    implements IContainerContextContractStub {
  static String type() => 'ContainerContextImplementationStub';
}

@ContainerReflectable()
class ContainerContextImplementationStubTwo
    implements IContainerContextContractStub {
  static String type() => 'ContainerContextImplementationStubTwo';
}

@ContainerReflectable()
class ContainerTestContextInjectInstantiations
    implements IContainerContextContractStub {
  static int instantiations = 0;

  ContainerTestContextInjectInstantiations() {
    instantiations++;
  }

  static String type() => 'ContainerTestContextInjectInstantiations';
}

@ContainerReflectable()
class ContainerTestContextInjectOne {
  final IContainerContextContractStub impl;

  ContainerTestContextInjectOne(this.impl);

  static String type() => 'ContainerTestContextInjectOne';
}

@ContainerReflectable()
class ContainerTestContextInjectTwo {
  final IContainerContextContractStub impl;

  ContainerTestContextInjectTwo(this.impl);

  static String type() => 'ContainerTestContextInjectTwo';
}

@ContainerReflectable()
class ContainerTestContextInjectThree {
  final IContainerContextContractStub impl;

  ContainerTestContextInjectThree(this.impl);

  static String type() => 'ContainerTestContextInjectThree';
}

@ContainerReflectable()
class ContainerTestContextWithOptionalInnerDependency {
  final ContainerTestContextInjectOne? inner;

  ContainerTestContextWithOptionalInnerDependency([this.inner]);

  static String type() => 'ContainerTestContextWithOptionalInnerDependency';
}

@ContainerReflectable()
class ContainerTestContextInjectTwoInstances {
  final ContainerTestContextWithOptionalInnerDependency implOne;
  final ContainerTestContextInjectTwo implTwo;

  ContainerTestContextInjectTwoInstances(this.implOne, this.implTwo);

  static String type() => 'ContainerTestContextInjectTwoInstances';
}

@ContainerReflectable()
class ContainerTestContextInjectArray {
  final List<dynamic> stubs;

  ContainerTestContextInjectArray(this.stubs);

  static String type() => 'ContainerTestContextInjectArray';
}

@ContainerReflectable()
class ContainerTestContextInjectVariadic {
  final List<IContainerContextContractStub> stubs;

  ContainerTestContextInjectVariadic(this.stubs);

  static String type() => 'ContainerTestContextInjectVariadic';
}

@ContainerReflectable()
class ContainerTestContextInjectVariadicAfterNonVariadic {
  final ContainerContextNonContractStub other;
  final List<IContainerContextContractStub> stubs;

  ContainerTestContextInjectVariadicAfterNonVariadic(this.other, this.stubs);

  static String type() => 'ContainerTestContextInjectVariadicAfterNonVariadic';
}

@ContainerReflectable()
class ContainerTestContextInjectMethodArgument {
  IContainerContextContractStub method(
      IContainerContextContractStub dependency) {
    return dependency;
  }

  static String type() => 'ContainerTestContextInjectMethodArgument';
}

void main() {
  setUp(() {
    initializeReflection();

    // Register test classes
    registerTypes([
      IContainerContextContractStub,
      ContainerContextNonContractStub,
      ContainerContextImplementationStub,
      ContainerContextImplementationStubTwo,
      ContainerTestContextInjectInstantiations,
      ContainerTestContextInjectOne,
      ContainerTestContextInjectTwo,
      ContainerTestContextInjectThree,
      ContainerTestContextWithOptionalInnerDependency,
      ContainerTestContextInjectTwoInstances,
      ContainerTestContextInjectArray,
      ContainerTestContextInjectVariadic,
      ContainerTestContextInjectVariadicAfterNonVariadic,
      ContainerTestContextInjectMethodArgument,
    ]);
  });

  test('container can inject different implementations depending on context',
      () {
    var container = Container();

    container.bind(
      IContainerContextContractStub.type(),
      ContainerContextImplementationStub.type(),
    );

    container
        .when(ContainerTestContextInjectOne.type())
        .needs(IContainerContextContractStub.type())
        .give(ContainerContextImplementationStub.type());

    container
        .when(ContainerTestContextInjectTwo.type())
        .needs(IContainerContextContractStub.type())
        .give(ContainerContextImplementationStubTwo.type());

    final one = container.make(ContainerTestContextInjectOne.type());
    final two = container.make(ContainerTestContextInjectTwo.type());

    expect(one.impl, isA<ContainerContextImplementationStub>());
    expect(two.impl, isA<ContainerContextImplementationStubTwo>());

    // Test with closures
    container = Container();

    container.bind(
      IContainerContextContractStub.type(),
      ContainerContextImplementationStub.type(),
    );

    container
        .when(ContainerTestContextInjectOne.type())
        .needs(IContainerContextContractStub.type())
        .give(ContainerContextImplementationStub.type());

    container
        .when(ContainerTestContextInjectTwo.type())
        .needs(IContainerContextContractStub.type())
        .give((container) =>
            container.make(ContainerContextImplementationStubTwo.type()));

    final oneWithClosure = container.make(ContainerTestContextInjectOne.type());
    final twoWithClosure = container.make(ContainerTestContextInjectTwo.type());

    expect(oneWithClosure.impl, isA<ContainerContextImplementationStub>());
    expect(twoWithClosure.impl, isA<ContainerContextImplementationStubTwo>());
  });

  test('contextual binding works for existing instanced bindings', () {
    final container = Container();

    container.instance(
      IContainerContextContractStub.type(),
      ContainerContextImplementationStub(),
    );

    container
        .when(ContainerTestContextInjectOne.type())
        .needs(IContainerContextContractStub.type())
        .give(ContainerContextImplementationStubTwo.type());

    final instance = container.make(ContainerTestContextInjectOne.type());
    expect(instance.impl, isA<ContainerContextImplementationStubTwo>());
  });

  test('contextual binding works for newly instanced bindings', () {
    final container = Container();

    container
        .when(ContainerTestContextInjectOne.type())
        .needs(IContainerContextContractStub.type())
        .give(ContainerContextImplementationStubTwo.type());

    container.instance(
      IContainerContextContractStub.type(),
      ContainerContextImplementationStub(),
    );

    final instance = container.make(ContainerTestContextInjectOne.type());
    expect(instance.impl, isA<ContainerContextImplementationStubTwo>());
  });

  test('contextually bound instances are not unnecessarily recreated', () {
    ContainerTestContextInjectInstantiations.instantiations = 0;

    final container = Container();

    container.instance(
      IContainerContextContractStub.type(),
      ContainerContextImplementationStub(),
    );

    container.instance(
      ContainerTestContextInjectInstantiations.type(),
      ContainerTestContextInjectInstantiations(),
    );

    expect(ContainerTestContextInjectInstantiations.instantiations, equals(1));

    container
        .when(ContainerTestContextInjectOne.type())
        .needs(IContainerContextContractStub.type())
        .give(ContainerTestContextInjectInstantiations.type());

    container.make(ContainerTestContextInjectOne.type());
    container.make(ContainerTestContextInjectOne.type());
    container.make(ContainerTestContextInjectOne.type());
    container.make(ContainerTestContextInjectOne.type());

    expect(ContainerTestContextInjectInstantiations.instantiations, equals(1));
  });

  test('contextual binding works for multiple classes', () {
    final container = Container();

    container.bind(
      IContainerContextContractStub.type(),
      ContainerContextImplementationStub.type(),
    );

    container
        .when([
          ContainerTestContextInjectTwo.type(),
          ContainerTestContextInjectThree.type(),
        ])
        .needs(IContainerContextContractStub.type())
        .give(ContainerContextImplementationStubTwo.type());

    final one = container.make(ContainerTestContextInjectOne.type());
    final two = container.make(ContainerTestContextInjectTwo.type());
    final three = container.make(ContainerTestContextInjectThree.type());

    expect(one.impl, isA<ContainerContextImplementationStub>());
    expect(two.impl, isA<ContainerContextImplementationStubTwo>());
    expect(three.impl, isA<ContainerContextImplementationStubTwo>());
  });

  test('contextual binding works for method invocation', () {
    final container = Container();

    container
        .when(ContainerTestContextInjectMethodArgument.type())
        .needs(IContainerContextContractStub.type())
        .give(ContainerContextImplementationStub.type());

    final object = ContainerTestContextInjectMethodArgument();

    // Array callable syntax
    final valueResolvedUsingArraySyntax = container.call(
      [object, 'method'],
    );
    expect(valueResolvedUsingArraySyntax,
        isA<ContainerContextImplementationStub>());
  });
}
