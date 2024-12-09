import 'package:platform_container/container.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';

// Test stubs
@reflectable
class ContainerConcreteStub {
  @override
  String toString() => runtimeType.toString();
}

@reflectable
abstract class IContainerContractStub {
  String get something;
}

@reflectable
class ContainerImplementationStub implements IContainerContractStub {
  @override
  final String something = '';

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class ContainerImplementationStubTwo implements IContainerContractStub {
  @override
  final String something = '';

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class ContainerDependentStub {
  final IContainerContractStub impl;

  ContainerDependentStub(this.impl);

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class ContainerNestedDependentStub {
  final ContainerDependentStub inner;

  ContainerNestedDependentStub(this.inner);

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class ContainerDefaultValueStub {
  final ContainerConcreteStub stub;
  final String default_;

  ContainerDefaultValueStub(this.stub, [this.default_ = 'taylor']);

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class ContainerMixedPrimitiveStub {
  final int first;
  final ContainerConcreteStub stub;
  final int last;

  ContainerMixedPrimitiveStub(this.first, this.stub, this.last);

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class ContainerInjectVariableStub {
  final String something;

  ContainerInjectVariableStub(ContainerConcreteStub concrete, this.something);

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class ContainerInjectVariableStubWithInterfaceImplementation
    implements IContainerContractStub {
  @override
  final String something;

  ContainerInjectVariableStubWithInterfaceImplementation(
      ContainerConcreteStub concrete, this.something);

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class ContainerContextualBindingCallTarget {
  IContainerContractStub work(IContainerContractStub stub) => stub;

  @override
  String toString() => runtimeType.toString();
}

// Circular dependency stubs
@reflectable
class CircularAStub {
  CircularAStub(CircularBStub b);

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class CircularBStub {
  CircularBStub(CircularCStub c);

  @override
  String toString() => runtimeType.toString();
}

@reflectable
class CircularCStub {
  CircularCStub(CircularAStub a);

  @override
  String toString() => runtimeType.toString();
}

void main() {
  setUp(() {
    // Register test classes using Container's static method
    Container.registerTypes([
      ContainerConcreteStub,
      IContainerContractStub,
      ContainerImplementationStub,
      ContainerImplementationStubTwo,
      ContainerDependentStub,
      ContainerNestedDependentStub,
      ContainerDefaultValueStub,
      ContainerMixedPrimitiveStub,
      ContainerInjectVariableStub,
      ContainerInjectVariableStubWithInterfaceImplementation,
      ContainerContextualBindingCallTarget,
      CircularAStub,
      CircularBStub,
      CircularCStub,
    ]);
  });

  tearDown(() {
    Container.setInstance(null);
  });

  test('container singleton', () {
    final container = Container.setInstance(Container());
    expect(container, equals(Container.getInstance()));

    Container.setInstance(null);
    final container2 = Container.getInstance();

    expect(container2, isA<Container>());
    expect(container2, isNot(same(container)));
  });

  test('closure resolution', () {
    final container = Container();
    container.bind('name', () => 'Taylor');
    expect(container.make('name'), equals('Taylor'));
  });

  test('bind if doesnt register if service already registered', () {
    final container = Container();
    container.bind('name', () => 'Taylor');
    container.bindIf('name', () => 'Dayle');

    expect(container.make('name'), equals('Taylor'));
  });

  test('bind if does register if service not registered yet', () {
    final container = Container();
    container.bind('surname', () => 'Taylor');
    container.bindIf('name', () => 'Dayle');

    expect(container.make('name'), equals('Dayle'));
  });

  test('singleton if doesnt register if binding already registered', () {
    final container = Container();
    container.singleton('class', () => ContainerConcreteStub());
    final firstInstantiation = container.make('class');
    container.singletonIf(
        'class', () => ContainerDependentStub(ContainerImplementationStub()));
    final secondInstantiation = container.make('class');
    expect(firstInstantiation, same(secondInstantiation));
  });

  test('singleton if does register if binding not registered yet', () {
    final container = Container();
    container.singleton('class', () => ContainerConcreteStub());
    container.singletonIf('otherClass',
        () => ContainerDependentStub(ContainerImplementationStub()));
    final firstInstantiation = container.make('otherClass');
    final secondInstantiation = container.make('otherClass');
    expect(firstInstantiation, same(secondInstantiation));
  });

  test('shared closure resolution', () {
    final container = Container();
    container.singleton('class', () => ContainerConcreteStub());
    final firstInstantiation = container.make('class');
    final secondInstantiation = container.make('class');
    expect(firstInstantiation, same(secondInstantiation));
  });

  test('auto concrete resolution', () {
    final container = Container();
    final concrete = container.make(ContainerConcreteStub().toString());
    expect(concrete, isA<ContainerConcreteStub>());
  });

  test('shared concrete resolution', () {
    final container = Container();
    container.singleton(ContainerConcreteStub().toString());

    final var1 = container.make(ContainerConcreteStub().toString());
    final var2 = container.make(ContainerConcreteStub().toString());
    expect(var1, same(var2));
  });

  test('abstract to concrete resolution', () {
    final container = Container();
    final impl = ContainerImplementationStub();
    container.bind(impl.toString(), impl.toString());
    final class_ = container.make(ContainerDependentStub(impl).toString());
    expect(class_.impl, isA<ContainerImplementationStub>());
  });

  test('nested dependency resolution', () {
    final container = Container();
    final impl = ContainerImplementationStub();
    container.bind(impl.toString(), impl.toString());
    final class_ = container.make(ContainerNestedDependentStub(
      ContainerDependentStub(impl),
    ).toString());
    expect(class_.inner, isA<ContainerDependentStub>());
    expect(class_.inner.impl, isA<ContainerImplementationStub>());
  });

  test('container is passed to resolvers', () {
    final container = Container();
    container.bind('something', (c) => c);
    final c = container.make('something');
    expect(c, same(container));
  });

  test('aliases', () {
    final container = Container();
    container.bind('foo', () => 'bar');
    container.alias('foo', 'baz');
    container.alias('baz', 'bat');
    expect(container.make('foo'), equals('bar'));
    expect(container.make('baz'), equals('bar'));
    expect(container.make('bat'), equals('bar'));
  });

  test('bindings can be overridden', () {
    final container = Container();
    container.bind('foo', () => 'bar');
    container.bind('foo', () => 'baz');
    expect(container.make('foo'), equals('baz'));
  });

  test('binding an instance returns the instance', () {
    final container = Container();
    final bound = ContainerConcreteStub();
    final resolved = container.instance('foo', bound);
    expect(resolved, same(bound));
  });

  test('binding an instance as shared', () {
    final container = Container();
    final bound = ContainerConcreteStub();
    container.instance('foo', bound);
    final object = container.make('foo');
    expect(object, same(bound));
  });

  test('resolution of default parameters', () {
    final container = Container();
    final instance = container
        .make(ContainerDefaultValueStub(ContainerConcreteStub()).toString());
    expect(instance.stub, isA<ContainerConcreteStub>());
    expect(instance.default_, equals('taylor'));
  });

  test('resolving with array of parameters', () {
    final container = Container();
    final instance = container.make(
      ContainerDefaultValueStub(ContainerConcreteStub()).toString(),
      ['default', 'adam'],
    );
    expect(instance.default_, equals('adam'));

    final instance2 = container
        .make(ContainerDefaultValueStub(ContainerConcreteStub()).toString());
    expect(instance2.default_, equals('taylor'));

    container.bind('foo', (app, config) => config);
    expect(container.make('foo', [1, 2, 3]), equals([1, 2, 3]));
  });

  test('resolving with using an interface', () {
    final container = Container();
    final impl = ContainerInjectVariableStubWithInterfaceImplementation(
      ContainerConcreteStub(),
      'something',
    );
    container.bind(impl.toString(), impl.toString());
    final instance = container.make(
      impl.toString(),
      ['something', 'laurence'],
    );
    expect(instance.something, equals('laurence'));
  });

  test('nested parameter override', () {
    final container = Container();
    container.bind('foo', (app, config) {
      return app.make('bar', ['name', 'Taylor']);
    });
    container.bind('bar', (app, config) => config);
    expect(
      container.make('foo', ['something']),
      equals(['name', 'Taylor']),
    );
  });

  test('container knows entry', () {
    final container = Container();
    final impl = ContainerImplementationStub();
    container.bind(impl.toString(), impl.toString());
    expect(container.has(impl.toString()), isTrue);
  });

  test('container can bind any word', () {
    final container = Container();
    container.bind('Taylor', ContainerConcreteStub().toString());
    expect(container.get('Taylor'), isA<ContainerConcreteStub>());
  });

  test('container can dynamically set service', () {
    final container = Container();
    expect(container.bound('name'), isFalse);
    container.bind('name', () => 'Taylor');
    expect(container.bound('name'), isTrue);
    expect(container.make('name'), equals('Taylor'));
  });

  test('unknown entry throws exception', () {
    final container = Container();
    expect(
      () => container.get('Taylor'),
      throwsA(isA<EntryNotFoundException>()),
    );
  });

  test('bound entries throws container exception when not resolvable', () {
    final container = Container();
    final impl = ContainerImplementationStub();
    container.bind('Taylor', impl.toString());
    expect(
      () => container.get('Taylor'),
      throwsA(isA<BindingResolutionException>()),
    );
  });

  test('container can resolve classes', () {
    final container = Container();
    final class_ = container.get(ContainerConcreteStub().toString());
    expect(class_, isA<ContainerConcreteStub>());
  });

  test('method level contextual binding', () {
    final container = Container();
    final impl = ContainerImplementationStubTwo();
    container.bind(impl.toString(), impl.toString());
    container
        .when(ContainerContextualBindingCallTarget().toString())
        .needs(impl.toString())
        .give(ContainerImplementationStub().toString());

    final result = container.call(
      [ContainerContextualBindingCallTarget(), 'work'],
    );
    expect(result, isA<ContainerImplementationStub>());
  });
}
