import 'package:test/test.dart';
import 'package:ioc_container/container.dart';

class ContainerLazyExtendStub {
  static bool initialized = false;

  void init() {
    ContainerLazyExtendStub.initialized = true;
  }
}

void main() {
  group('ContainerExtendTest', () {
    test('extendedBindings', () {
      var container = Container();
      container['foo'] = 'foo';
      container.extend('foo', (old) => '${old}bar');

      var result1 = container.make('foo');
      expect(result1, equals('foobar'), reason: 'Actual result: $result1');

      container = Container();
      container.singleton(
          'foo', (container) => <String, dynamic>{'name': 'taylor'});
      container.extend('foo', (old) {
        (old as Map<String, dynamic>)['age'] = 26;
        return old;
      });

      var result2 = container.make('foo') as Map<String, dynamic>;
      expect(result2['name'], equals('taylor'));
      expect(result2['age'], equals(26));
      expect(identical(result2, container.make('foo')), isTrue);
    });

    test('extendInstancesArePreserved', () {
      var container = Container();
      container.bind('foo', (container) {
        var obj = {};
        obj['foo'] = 'bar';
        return obj;
      });

      var obj = {'foo': 'foo'};
      container.instance('foo', obj);
      container.extend('foo', (obj) {
        (obj as Map<String, dynamic>)['bar'] = 'baz';
        return obj;
      });
      container.extend('foo', (obj) {
        (obj as Map<String, dynamic>)['baz'] = 'foo';
        return obj;
      });

      expect(container.make('foo')['foo'], equals('foo'));
      expect(container.make('foo')['bar'], equals('baz'));
      expect(container.make('foo')['baz'], equals('foo'));
    });

    test('extendIsLazyInitialized', () {
      ContainerLazyExtendStub.initialized = false;

      var container = Container();
      container.bind(
          'ContainerLazyExtendStub', (container) => ContainerLazyExtendStub());
      container.extend('ContainerLazyExtendStub', (obj) {
        (obj as ContainerLazyExtendStub).init();
        return obj;
      });
      expect(ContainerLazyExtendStub.initialized, isFalse);
      container.make('ContainerLazyExtendStub');
      expect(ContainerLazyExtendStub.initialized, isTrue);
    });

    test('extendCanBeCalledBeforeBind', () {
      var container = Container();
      container.extend('foo', (old) => '${old}bar');
      container['foo'] = 'foo';

      var result = container.make('foo');
      expect(result, equals('foobar'), reason: 'Actual result: $result');
    });

    // TODO: Implement rebinding functionality
    // test('extendInstanceRebindingCallback', () {
    //   var rebindCalled = false;

    //   var container = Container();
    //   container.rebinding('foo', (container) {
    //     rebindCalled = true;
    //   });

    //   var obj = {};
    //   container.instance('foo', obj);

    //   container.extend('foo', (obj, container) => obj);

    //   expect(rebindCalled, isTrue);
    // });

    // test('extendBindRebindingCallback', () {
    //   var rebindCalled = false;

    //   var container = Container();
    //   container.rebinding('foo', (container) {
    //     rebindCalled = true;
    //   });
    //   container.bind('foo', (container) => {});

    //   expect(rebindCalled, isFalse);

    //   container.make('foo');

    //   container.extend('foo', (obj, container) => obj);

    //   expect(rebindCalled, isTrue);
    // });

    test('extensionWorksOnAliasedBindings', () {
      var container = Container();
      container.singleton('something', (container) => 'some value');
      container.alias('something', 'something-alias');
      container.extend('something-alias', (value) => '$value extended');

      expect(container.make('something'), equals('some value extended'));
    });

    test('multipleExtends', () {
      var container = Container();
      container['foo'] = 'foo';
      container.extend('foo', (old) => '${old}bar');
      container.extend('foo', (old) => '${old}baz');

      expect(container.make('foo'), equals('foobarbaz'));
    });

    test('unsetExtend', () {
      var container = Container();
      container.bind('foo', (container) {
        var obj = {};
        obj['foo'] = 'bar';
        return obj;
      });

      container.extend('foo', (obj) {
        (obj as Map<String, dynamic>)['bar'] = 'baz';
        return obj;
      });

      container.forgetInstance('foo');
      container.forgetExtenders('foo');

      container.bind('foo', (container) => 'foo');

      expect(container.make('foo'), equals('foo'));
    });
  });
}
