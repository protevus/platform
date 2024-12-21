import 'package:platform_reflection/mirrors.dart';
import 'package:test/test.dart';
import 'package:platform_collections/src/collection.dart';
import 'package:platform_collections/src/higher_order_collection_proxy.dart';

@reflectable
class TestModel {
  String? name;
  int? age;

  TestModel(this.name, this.age);

  String greet() => 'Hello, ${name ?? "Anonymous"}!';

  void setAge(int newAge) {
    age = newAge;
  }
}

void main() {
  group('HigherOrderCollectionProxy', () {
    late Collection<TestModel> collection;
    late HigherOrderCollectionProxy<TestModel> proxy;

    setUp(() {
      // Register TestModel for reflection
      Reflector.registerType(TestModel);

      // Register properties
      Reflector.registerProperty(TestModel, 'name', String,
          isReadable: true, isWritable: true);
      Reflector.registerProperty(TestModel, 'age', int,
          isReadable: true, isWritable: true);

      // Register methods with proper return types
      Reflector.registerMethod(
        TestModel,
        'greet',
        [], // no parameters
        false, // not void
        isStatic: false,
      );

      Reflector.registerMethod(
        TestModel,
        'setAge',
        [int], // takes an int parameter
        true, // returns void
        isStatic: false,
        parameterNames: ['newAge'],
        isRequired: [true],
      );

      collection = Collection([
        TestModel('John', 30),
        TestModel('Jane', 25),
        TestModel('Bob', 35),
      ]);
      proxy = HigherOrderCollectionProxy(collection, 'greet');
    });

    test('reflection registration is correct', () {
      expect(Reflector.isReflectable(TestModel), isTrue,
          reason: 'TestModel should be reflectable');

      final props = Reflector.getPropertyMetadata(TestModel);
      expect(props, isNotNull, reason: 'Property metadata should exist');
      expect(props!['name'], isNotNull,
          reason: 'name property should be registered');
      expect(props['age'], isNotNull,
          reason: 'age property should be registered');

      final methods = Reflector.getMethodMetadata(TestModel);
      expect(methods, isNotNull, reason: 'Method metadata should exist');
      expect(methods!['greet'], isNotNull,
          reason: 'greet method should be registered');
      expect(methods['setAge'], isNotNull,
          reason: 'setAge method should be registered');
    });

    test('can access properties using array syntax', () {
      final names = proxy['name'];
      expect(names, equals(['John', 'Jane', 'Bob']));
    });

    test('can access properties using get method', () {
      final ages = proxy.get('age');
      expect(ages, equals([30, 25, 35]));
    });

    test('can set properties', () {
      proxy.set('age', 40);
      expect(proxy['age'], everyElement(40));
    });

    test('can call methods', () {
      final greetings = proxy.call();
      expect(
          greetings, equals(['Hello, John!', 'Hello, Jane!', 'Hello, Bob!']));
    });

    test('can call methods with arguments', () {
      final ageProxy = HigherOrderCollectionProxy(collection, 'setAge');
      ageProxy.call([50]);
      expect(proxy['age'], everyElement(50));
    });

    test('can check property existence', () {
      final hasName = proxy.contains('name');
      final hasEmail = proxy.contains('email');
      expect(hasName, everyElement(true));
      expect(hasEmail, everyElement(false));
    });

    test('can unset properties', () {
      proxy.unset('name');
      expect(proxy['name'], everyElement(null));
    });

    test('handles null values gracefully', () {
      final nullCollection = Collection<TestModel?>(
          [TestModel('John', 30), null, TestModel('Bob', 35)]);
      final nullProxy = HigherOrderCollectionProxy(nullCollection, 'greet');

      final names = nullProxy['name'];
      expect(names, equals(['John', null, 'Bob']));
    });

    test('handles non-existent properties gracefully', () {
      final values = proxy['nonexistent'];
      expect(values, everyElement(null));
    });

    test('handles non-existent methods gracefully', () {
      final badProxy = HigherOrderCollectionProxy(collection, 'nonexistent');
      final results = badProxy.call();
      expect(results, everyElement(null));
    });

    test('supports dynamic property access', () {
      final values = proxy['age'];
      expect(values, equals([30, 25, 35]));
    });

    test('supports dynamic property setting', () {
      proxy.set('age', 60);
      expect(proxy['age'], everyElement(60));
    });

    test('supports method chaining', () {
      final greetings = HigherOrderCollectionProxy(collection, 'greet').call();
      expect(
          greetings, equals(['Hello, John!', 'Hello, Jane!', 'Hello, Bob!']));
    });

    tearDown(() {
      // Clean up reflection metadata after each test
      Reflector.reset();
    });
  });
}
