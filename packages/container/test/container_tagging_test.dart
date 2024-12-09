import 'package:platform_container/container.dart';
import 'package:test/test.dart';
import '../lib/src/reflection.dart';

// Test stubs
@ContainerReflectable()
abstract class IContainerTaggedContractStub {
  static String type() => 'IContainerTaggedContractStub';
}

@ContainerReflectable()
class ContainerImplementationTaggedStub
    implements IContainerTaggedContractStub {
  static String type() => 'ContainerImplementationTaggedStub';
}

@ContainerReflectable()
class ContainerImplementationTaggedStubTwo
    implements IContainerTaggedContractStub {
  static String type() => 'ContainerImplementationTaggedStubTwo';
}

void main() {
  setUp(() {
    initializeReflection();

    // Register test classes
    registerTypes([
      IContainerTaggedContractStub,
      ContainerImplementationTaggedStub,
      ContainerImplementationTaggedStubTwo,
    ]);
  });

  test('container tags', () {
    var container = Container();
    container.tag(
      ContainerImplementationTaggedStub.type(),
      'foo',
      ['bar'],
    );
    container.tag(ContainerImplementationTaggedStubTwo.type(), 'foo');

    expect(container.tagged('bar').length, equals(1));
    expect(container.tagged('foo').length, equals(2));

    final fooResults = container.tagged('foo').toList();
    final barResults = container.tagged('bar').toList();

    expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
    expect(barResults[0], isA<ContainerImplementationTaggedStub>());
    expect(fooResults[1], isA<ContainerImplementationTaggedStubTwo>());

    container = Container();
    container.tag([
      ContainerImplementationTaggedStub.type(),
      ContainerImplementationTaggedStubTwo.type(),
    ], 'foo');
    expect(container.tagged('foo').length, equals(2));

    final moreResults = container.tagged('foo').toList();
    expect(moreResults[0], isA<ContainerImplementationTaggedStub>());
    expect(moreResults[1], isA<ContainerImplementationTaggedStubTwo>());

    expect(container.tagged('this_tag_does_not_exist').length, equals(0));
  });

  test('tagged services are lazy loaded', () {
    var makeCount = 0;
    final container = Container();

    // Mock make behavior by counting calls
    container.bind(ContainerImplementationTaggedStub.type(), () {
      makeCount++;
      return ContainerImplementationTaggedStub();
    });

    container.tag(ContainerImplementationTaggedStub.type(), 'foo');
    container.tag(ContainerImplementationTaggedStubTwo.type(), 'foo');

    final fooResults = <dynamic>[];
    for (final foo in container.tagged('foo')) {
      fooResults.add(foo);
      break;
    }

    expect(container.tagged('foo').length, equals(2));
    expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
    expect(makeCount, equals(1)); // Only one service was actually created
  });

  test('lazy loaded tagged services can be looped over multiple times', () {
    final container = Container();
    container.tag(ContainerImplementationTaggedStub.type(), 'foo');
    container.tag(ContainerImplementationTaggedStubTwo.type(), 'foo');

    final services = container.tagged('foo');

    var fooResults = <dynamic>[];
    for (final foo in services) {
      fooResults.add(foo);
    }

    expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
    expect(fooResults[1], isA<ContainerImplementationTaggedStubTwo>());

    // Reset results and iterate again
    fooResults = <dynamic>[];
    for (final foo in services) {
      fooResults.add(foo);
    }

    expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
    expect(fooResults[1], isA<ContainerImplementationTaggedStubTwo>());
  });
}
