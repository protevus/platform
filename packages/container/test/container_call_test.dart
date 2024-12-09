import 'package:platform_container/container.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:test/test.dart';
import '../lib/src/reflection.dart';

// Test stubs
@ContainerReflectable()
class ContainerCallConcreteStub {}

@ContainerReflectable()
class ContainerTestCallStub {
  List<dynamic> work(List<dynamic> args) {
    return args;
  }

  List<dynamic> inject(ContainerCallConcreteStub stub,
      [String default_ = 'taylor']) {
    return [stub, default_];
  }

  List<dynamic> unresolvable(String foo, String bar) {
    return [foo, bar];
  }

  static String type() => 'ContainerTestCallStub';
}

@ContainerReflectable()
class ContainerStaticMethodStub {
  static List<dynamic> inject(ContainerCallConcreteStub stub,
      [String default_ = 'taylor']) {
    return [stub, default_];
  }

  static String type() => 'ContainerStaticMethodStub';
}

@ContainerReflectable()
List<dynamic> containerTestInject(ContainerCallConcreteStub stub,
    [String default_ = 'taylor']) {
  return [stub, default_];
}

@ContainerReflectable()
class ContainerCallCallableStub {
  List<dynamic> call(ContainerCallConcreteStub stub,
      [String default_ = 'jeffrey']) {
    return [stub, default_];
  }

  static String type() => 'ContainerCallCallableStub';
}

@ContainerReflectable()
class ContainerCallCallableClassStringStub {
  final ContainerCallConcreteStub stub;
  final String default_;

  ContainerCallCallableClassStringStub(this.stub, [this.default_ = 'jeffrey']);

  List<dynamic> call(ContainerTestCallStub dependency) {
    return [stub, default_, dependency];
  }

  static String type() => 'ContainerCallCallableClassStringStub';
}

void main() {
  setUp(() {
    initializeReflection();

    // Register test classes
    registerTypes([
      ContainerCallConcreteStub,
      ContainerTestCallStub,
      ContainerStaticMethodStub,
      ContainerCallCallableStub,
      ContainerCallCallableClassStringStub,
    ]);
  });

  test(
      'call with at sign based class references without method throws exception',
      () {
    final container = Container();
    expect(
      () => container.call('ContainerTestCallStub'),
      throwsA(isA<Error>()),
    );
  });

  test('call with at sign based class references', () {
    var container = Container();
    var result =
        container.call('${ContainerTestCallStub}@work', ['foo', 'bar']);
    expect(result, equals(['foo', 'bar']));

    container = Container();
    result = container.call('${ContainerTestCallStub}@inject');
    expect(result[0], isA<ContainerCallConcreteStub>());
    expect(result[1], equals('taylor'));

    container = Container();
    result =
        container.call('${ContainerTestCallStub}@inject', ['default', 'foo']);
    expect(result[0], isA<ContainerCallConcreteStub>());
    expect(result[1], equals('foo'));

    container = Container();
    result = container.call(ContainerTestCallStub, ['foo', 'bar'], 'work');
    expect(result, equals(['foo', 'bar']));
  });

  test('call with callable array', () {
    final container = Container();
    final stub = ContainerTestCallStub();
    final result = container.call([stub, 'work'], ['foo', 'bar']);
    expect(result, equals(['foo', 'bar']));
  });

  test('call with static method name string', () {
    final container = Container();
    final result = container.call('${ContainerStaticMethodStub}::inject');
    expect(result[0], isA<ContainerCallConcreteStub>());
    expect(result[1], equals('taylor'));
  });

  test('call with global method name', () {
    final container = Container();
    final result = container.call('containerTestInject');
    expect(result[0], isA<ContainerCallConcreteStub>());
    expect(result[1], equals('taylor'));
  });

  test('call with bound method', () {
    var container = Container();
    container.bindMethod('${ContainerTestCallStub}@unresolvable', (stub) {
      return stub.unresolvable('foo', 'bar');
    });
    var result = container.call('${ContainerTestCallStub}@unresolvable');
    expect(result, equals(['foo', 'bar']));

    container = Container();
    container.bindMethod('${ContainerTestCallStub}@unresolvable', (stub) {
      return stub.unresolvable('foo', 'bar');
    });
    result = container.call([ContainerTestCallStub(), 'unresolvable']);
    expect(result, equals(['foo', 'bar']));

    container = Container();
    result = container.call(
      [ContainerTestCallStub(), 'inject'],
      ['_stub', 'foo', 'default', 'bar'],
    );
    expect(result[0], isA<ContainerCallConcreteStub>());
    expect(result[1], equals('bar'));

    container = Container();
    result = container.call(
      [ContainerTestCallStub(), 'inject'],
      ['_stub', 'foo'],
    );
    expect(result[0], isA<ContainerCallConcreteStub>());
    expect(result[1], equals('taylor'));
  });

  test('bind method accepts an array', () {
    var container = Container();
    container.bindMethod([ContainerTestCallStub, 'unresolvable'], (stub) {
      return stub.unresolvable('foo', 'bar');
    });
    var result = container.call('${ContainerTestCallStub}@unresolvable');
    expect(result, equals(['foo', 'bar']));

    container = Container();
    container.bindMethod([ContainerTestCallStub, 'unresolvable'], (stub) {
      return stub.unresolvable('foo', 'bar');
    });
    result = container.call([ContainerTestCallStub(), 'unresolvable']);
    expect(result, equals(['foo', 'bar']));
  });

  test('closure call with injected dependency', () {
    final container = Container();
    container.call((ContainerCallConcreteStub stub) {
      // No assertions needed, just testing injection
    }, ['foo', 'bar']);

    container.call((ContainerCallConcreteStub stub) {
      // No assertions needed, just testing injection
    }, ['foo', 'bar', 'stub', ContainerCallConcreteStub()]);
  });

  test('call with dependencies', () {
    final container = Container();
    var result = container.call((Object foo, [List<dynamic> bar = const []]) {
      return [foo, bar];
    });

    expect(result[0], isA<Object>());
    expect(result[1], equals([]));

    result = container.call((Object foo, [List<dynamic> bar = const []]) {
      return [foo, bar];
    }, ['bar', 'taylor']);

    expect(result[0], isA<Object>());
    expect(result[1], equals('taylor'));

    final stub = ContainerCallConcreteStub();
    result = container.call((Object foo, ContainerCallConcreteStub bar) {
      return [foo, bar];
    }, [ContainerCallConcreteStub, stub]);

    expect(result[0], isA<Object>());
    expect(result[1], same(stub));
  });

  test('call with callable object', () {
    final container = Container();
    final callable = ContainerCallCallableStub();
    final result = container.call(callable);
    expect(result[0], isA<ContainerCallConcreteStub>());
    expect(result[1], equals('jeffrey'));
  });

  test('call with callable class string', () {
    final container = Container();
    final result = container.call(ContainerCallCallableClassStringStub);
    expect(result[0], isA<ContainerCallConcreteStub>());
    expect(result[1], equals('jeffrey'));
    expect(result[2], isA<ContainerTestCallStub>());
  });

  test('call without required params throws exception', () {
    final container = Container();
    expect(
      () => container.call('${ContainerTestCallStub}@unresolvable'),
      throwsA(isA<BindingResolutionException>()),
    );
  });

  test('call with unnamed parameters throws exception', () {
    final container = Container();
    expect(
      () => container
          .call([ContainerTestCallStub(), 'unresolvable'], ['foo', 'bar']),
      throwsA(isA<BindingResolutionException>()),
    );
  });

  test('call without required params on closure throws exception', () {
    final container = Container();
    expect(
      () => container.call((String foo, [String bar = 'default']) => foo),
      throwsA(isA<BindingResolutionException>()),
    );
  });
}
