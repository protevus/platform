import 'package:platform_container/container.dart';
import 'package:test/test.dart';
import '../lib/src/reflection.dart';

// Test stubs
@ContainerReflectable()
class ContainerLazyExtendStub {
  static bool initialized = false;

  void init() {
    initialized = true;
  }

  static String type() => 'ContainerLazyExtendStub';
}

void main() {
  setUp(() {
    initializeReflection();

    // Register test classes
    registerTypes([
      ContainerLazyExtendStub,
    ]);

    ContainerLazyExtendStub.initialized = false;
  });

  test('extended bindings', () {
    var container = Container();
    container.bind('foo', () => 'foo');
    container.extend('foo', (old) {
      return '${old}bar';
    });

    expect(container.make('foo'), equals('foobar'));

    container = Container();
    container.singleton('foo', () => {'name': 'taylor'});
    container.extend('foo', (old) {
      final map = old as Map;
      map['age'] = 26;
      return map;
    });

    final result = container.make('foo') as Map;
    expect(result['name'], equals('taylor'));
    expect(result['age'], equals(26));
    expect(result, same(container.make('foo')));
  });

  test('extend instances are preserved', () {
    final container = Container();
    container.bind('foo', () {
      return {'foo': 'bar'};
    });

    final obj = {'foo': 'foo'};
    container.instance('foo', obj);
    container.extend('foo', (obj) {
      final map = obj as Map;
      map['bar'] = 'baz';
      return map;
    });
    container.extend('foo', (obj) {
      final map = obj as Map;
      map['baz'] = 'foo';
      return map;
    });

    expect(container.make('foo')['foo'], equals('foo'));
    expect(container.make('foo')['bar'], equals('baz'));
    expect(container.make('foo')['baz'], equals('foo'));
  });

  test('extend is lazy initialized', () {
    final container = Container();
    container.bind(
        ContainerLazyExtendStub.type(), () => ContainerLazyExtendStub());
    container.extend(ContainerLazyExtendStub.type(), (obj) {
      (obj as ContainerLazyExtendStub).init();
      return obj;
    });

    expect(ContainerLazyExtendStub.initialized, isFalse);
    container.make(ContainerLazyExtendStub.type());
    expect(ContainerLazyExtendStub.initialized, isTrue);
  });

  test('extend can be called before bind', () {
    final container = Container();
    container.extend('foo', (old) {
      return '${old}bar';
    });
    container.bind('foo', () => 'foo');

    expect(container.make('foo'), equals('foobar'));
  });

  test('extend instance rebinding callback', () {
    var rebound = false;

    final container = Container();
    container.rebinding('foo', (instance) {
      rebound = true;
    });

    final obj = {};
    container.instance('foo', obj);

    container.extend('foo', (obj) {
      return obj;
    });

    expect(rebound, isTrue);
  });

  test('extend bind rebinding callback', () {
    var rebound = false;

    final container = Container();
    container.rebinding('foo', (instance) {
      rebound = true;
    });
    container.bind('foo', () => {});

    expect(rebound, isFalse);

    container.make('foo');

    container.extend('foo', (obj) {
      return obj;
    });

    expect(rebound, isTrue);
  });

  test('extension works on aliased bindings', () {
    final container = Container();
    container.singleton('something', () => 'some value');
    container.alias('something', 'something-alias');
    container.extend('something-alias', (value) {
      return '$value extended';
    });

    expect(container.make('something'), equals('some value extended'));
  });

  test('multiple extends', () {
    final container = Container();
    container.bind('foo', () => 'foo');
    container.extend('foo', (old) {
      return '${old}bar';
    });
    container.extend('foo', (old) {
      return '${old}baz';
    });

    expect(container.make('foo'), equals('foobarbaz'));
  });

  test('unset extend', () {
    final container = Container();
    container.bind('foo', () {
      return {'foo': 'bar'};
    });

    container.extend('foo', (obj) {
      final map = obj as Map;
      map['bar'] = 'baz';
      return map;
    });

    // Equivalent to PHP's unset($container['foo'])
    container.bind('foo', null);
    container.forgetExtenders('foo');

    container.bind('foo', () => 'foo');

    expect(container.make('foo'), equals('foo'));
  });
}
