import 'package:platform_container/container.dart';
import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';

// Test stubs
@reflectable
abstract class ResolvingContractStub {
  static String type() => 'ResolvingContractStub';
}

@reflectable
class ResolvingImplementationStub implements ResolvingContractStub {
  static String type() => 'ResolvingImplementationStub';
}

@reflectable
class ResolvingImplementationStubTwo implements ResolvingContractStub {
  static String type() => 'ResolvingImplementationStubTwo';
}

@reflectable
class TestObject {
  String? name;
  static String type() => 'TestObject';
}

void main() {
  setUp(() {
    // Register test classes using Container's static method
    Container.registerTypes([
      ResolvingContractStub,
      ResolvingImplementationStub,
      ResolvingImplementationStubTwo,
      TestObject,
    ]);
  });

  test('resolving callbacks are called for specific abstracts', () {
    final container = Container();
    container.resolving('foo', (object, container) {
      (object as dynamic).name = 'taylor';
      return object;
    });
    container.bind('foo', () => TestObject());
    final instance = container.make('foo');

    expect(instance.name, equals('taylor'));
  });

  test('resolving callbacks are called', () {
    final container = Container();
    container.resolving((object, container) {
      (object as dynamic).name = 'taylor';
      return object;
    });
    container.bind('foo', () => TestObject());
    final instance = container.make('foo');

    expect(instance.name, equals('taylor'));
  });

  test('resolving callbacks are called for type', () {
    final container = Container();
    container.resolving(TestObject.type(), (object, container) {
      (object as TestObject).name = 'taylor';
      return object;
    });
    container.bind('foo', () => TestObject());
    final instance = container.make('foo');

    expect(instance.name, equals('taylor'));
  });

  test('resolving callbacks should be fired when called with aliases', () {
    final container = Container();
    container.alias(TestObject.type(), 'std');
    container.resolving('std', (object, container) {
      (object as TestObject).name = 'taylor';
      return object;
    });
    container.bind('foo', () => TestObject());
    final instance = container.make('foo');

    expect(instance.name, equals('taylor'));
  });

  test('resolving callbacks are called once for implementation', () {
    final container = Container();
    var callCounter = 0;

    container.resolving(ResolvingContractStub.type(), (object, container) {
      callCounter++;
      return object;
    });

    container.bind(
      ResolvingContractStub.type(),
      ResolvingImplementationStub.type(),
    );

    container.make(ResolvingImplementationStub.type());
    expect(callCounter, equals(1));

    container.make(ResolvingImplementationStub.type());
    expect(callCounter, equals(2));
  });

  test('global resolving callbacks are called once for implementation', () {
    final container = Container();
    var callCounter = 0;

    container.resolving((object, container) {
      callCounter++;
      return object;
    });

    container.bind(
      ResolvingContractStub.type(),
      ResolvingImplementationStub.type(),
    );

    container.make(ResolvingImplementationStub.type());
    expect(callCounter, equals(1));

    container.make(ResolvingContractStub.type());
    expect(callCounter, equals(2));
  });

  test('before resolving callbacks are called', () {
    final container = Container();
    var callCounter = 0;

    container.bind(
      ResolvingContractStub.type(),
      ResolvingImplementationStub.type(),
    );

    container.beforeResolving(ResolvingContractStub.type(),
        (abstract, params, container) {
      callCounter++;
    });

    container.make(ResolvingImplementationStub.type());
    expect(callCounter, equals(1));

    container.make(ResolvingContractStub.type());
    expect(callCounter, equals(2));
  });

  test('global before resolving callbacks are called', () {
    final container = Container();
    var callCounter = 0;

    container.beforeResolving((abstract, params, container) {
      callCounter++;
    });

    container.make(ResolvingImplementationStub.type());
    expect(callCounter, equals(1));
  });

  test('after resolving callbacks are called once for implementation', () {
    final container = Container();
    var callCounter = 0;

    container.afterResolving(ResolvingContractStub.type(), (object, container) {
      callCounter++;
    });

    container.bind(
      ResolvingContractStub.type(),
      ResolvingImplementationStub.type(),
    );

    container.make(ResolvingImplementationStub.type());
    expect(callCounter, equals(1));

    container.make(ResolvingContractStub.type());
    expect(callCounter, equals(2));
  });

  test('parameters passed into resolving callbacks', () {
    final container = Container();

    container.resolving(ResolvingContractStub.type(), (obj, app) {
      expect(obj, isA<ResolvingImplementationStubTwo>());
      expect(app, same(container));
    });

    container.afterResolving(ResolvingContractStub.type(), (obj, app) {
      expect(obj, isA<ResolvingImplementationStubTwo>());
      expect(app, same(container));
    });

    container.afterResolving((obj, app) {
      expect(obj, isA<ResolvingImplementationStubTwo>());
      expect(app, same(container));
    });

    container.bind(
      ResolvingContractStub.type(),
      ResolvingImplementationStubTwo.type(),
    );
    container.make(ResolvingContractStub.type());
  });
}
