import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

class TestClass {
  final String name;
  final int value;

  TestClass(Map<String, dynamic> config)
      : name = config['name'] as String,
        value = config['value'] as int;
}

void main() {
  group('MultipleInstanceManager', () {
    late MultipleInstanceManager<TestClass> manager;

    setUp(() {
      manager =
          MultipleInstanceManager<TestClass>((config) => TestClass(config));
    });

    test('creates instance with configuration', () {
      manager.configure({'name': 'test', 'value': 42});
      final instance = manager.instance();

      expect(instance.name, equals('test'));
      expect(instance.value, equals(42));
    });

    test('creates named instances', () {
      manager.configure({'name': 'first', 'value': 1}, 'one');
      manager.configure({'name': 'second', 'value': 2}, 'two');

      final first = manager.instance('one');
      final second = manager.instance('two');

      expect(first.name, equals('first'));
      expect(second.name, equals('second'));
    });

    test('reuses existing instances', () {
      manager.configure({'name': 'test', 'value': 42});
      final first = manager.instance();
      final second = manager.instance();

      expect(identical(first, second), isTrue);
    });

    test('extends configuration', () {
      manager.configure({'name': 'test', 'value': 42});
      manager.extend({'value': 100});

      final instance = manager.instance();
      expect(instance.value, equals(100));
    });

    test('gets instance names', () {
      manager.configure({'name': 'first', 'value': 1}, 'one');
      manager.configure({'name': 'second', 'value': 2}, 'two');

      expect(manager.names(), containsAll(['one', 'two']));
    });

    test('gets all instances', () {
      manager.configure({'name': 'first', 'value': 1}, 'one');
      manager.configure({'name': 'second', 'value': 2}, 'two');

      manager.instance('one');
      manager.instance('two');

      final instances = manager.instances();
      expect(instances.length, equals(2));
      expect(instances.map((i) => i.name), containsAll(['first', 'second']));
    });

    test('gets configurations', () {
      final config = {'name': 'test', 'value': 42};
      manager.configure(config);

      expect(manager.configurations()[MultipleInstanceManager.defaultName],
          equals(config));
    });

    test('resets instance', () {
      manager.configure({'name': 'test', 'value': 42});
      final first = manager.instance();

      manager.reset(MultipleInstanceManager.defaultName);
      final second = manager.instance();

      expect(identical(first, second), isFalse);
      expect(second.name, equals('test')); // Config preserved
    });

    test('resets instance without preserving config', () {
      manager.configure({'name': 'test', 'value': 42});
      manager.instance();

      manager.reset(MultipleInstanceManager.defaultName, preserveConfig: false);

      expect(
        () => manager.instance(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('is not configured'),
        )),
      );
    });

    test('resets all instances', () {
      manager.configure({'name': 'first', 'value': 1}, 'one');
      manager.configure({'name': 'second', 'value': 2}, 'two');

      final first = manager.instance('one');
      final second = manager.instance('two');

      manager.resetAll();

      final newFirst = manager.instance('one');
      final newSecond = manager.instance('two');

      expect(identical(first, newFirst), isFalse);
      expect(identical(second, newSecond), isFalse);
    });

    test('checks instance existence', () {
      manager.configure({'name': 'test', 'value': 42});
      expect(manager.has(MultipleInstanceManager.defaultName), isFalse);

      manager.instance();
      expect(manager.has(MultipleInstanceManager.defaultName), isTrue);
    });

    test('checks configuration existence', () {
      expect(manager.hasConfiguration('test'), isFalse);

      manager.configure({'name': 'test', 'value': 42}, 'test');
      expect(manager.hasConfiguration('test'), isTrue);
    });

    test('gets configuration', () {
      final config = {'name': 'test', 'value': 42};
      manager.configure(config, 'test');

      expect(manager.getConfiguration('test'), equals(config));
    });

    test('sets instance directly', () {
      final instance = TestClass({'name': 'test', 'value': 42});
      manager.set('test', instance);

      expect(identical(manager.instance('test'), instance), isTrue);
    });

    test('forgets instance and configuration', () {
      manager.configure({'name': 'test', 'value': 42});
      manager.instance();

      manager.forget(MultipleInstanceManager.defaultName);

      expect(manager.has(MultipleInstanceManager.defaultName), isFalse);
      expect(manager.hasConfiguration(MultipleInstanceManager.defaultName),
          isFalse);
    });

    test('counts instances and configurations', () {
      expect(manager.count, equals(0));
      expect(manager.instanceCount, equals(0));

      manager.configure({'name': 'first', 'value': 1}, 'one');
      manager.configure({'name': 'second', 'value': 2}, 'two');

      expect(manager.count, equals(2));
      expect(manager.instanceCount, equals(0));

      manager.instance('one');
      expect(manager.instanceCount, equals(1));

      manager.instance('two');
      expect(manager.instanceCount, equals(2));
    });

    test('throws when accessing unconfigured instance', () {
      expect(
        () => manager.instance('nonexistent'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('is not configured'),
        )),
      );
    });
  });
}
