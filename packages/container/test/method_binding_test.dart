import 'package:illuminate_container/container.dart';
import 'package:test/test.dart';
import 'common.dart';

class Calculator {
  int add(int a, int b) => a + b;
  int multiply(int a, int b) => a * b;
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Method Binding Tests', () {
    test('can bind and call method', () {
      var calculator = Calculator();
      container.bindMethod('add', calculator.add);

      var result = container.callMethod('add', [5, 3]);
      expect(result, equals(8));
    });

    test('can bind multiple methods', () {
      var calculator = Calculator();
      container.bindMethod('add', calculator.add);
      container.bindMethod('multiply', calculator.multiply);

      expect(container.callMethod('add', [5, 3]), equals(8));
      expect(container.callMethod('multiply', [5, 3]), equals(15));
    });

    test('throws when method not found', () {
      expect(
        () => container.callMethod('nonexistent'),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when binding duplicate method', () {
      var calculator = Calculator();
      container.bindMethod('add', calculator.add);

      expect(
        () => container.bindMethod('add', calculator.add),
        throwsA(isA<StateError>()),
      );
    });

    test('child container inherits parent methods', () {
      var calculator = Calculator();
      container.bindMethod('add', calculator.add);

      var childContainer = container.createChild();
      expect(childContainer.callMethod('add', [5, 3]), equals(8));
    });

    test('child container can override parent methods', () {
      var calculator = Calculator();
      container.bindMethod('add', calculator.add);

      var childContainer = container.createChild();
      childContainer.bindMethod('add', (a, b) => a * b); // Override to multiply

      expect(
          container.callMethod('add', [5, 3]), equals(8)); // Parent unchanged
      expect(childContainer.callMethod('add', [5, 3]),
          equals(15)); // Child overridden
    });
  });
}

// Minimal mock reflector for method binding tests
class MockReflector extends Reflector {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClass? reflectClass(Type clazz) => null;

  @override
  ReflectedType? reflectType(Type type) => null;

  @override
  ReflectedInstance? reflectInstance(Object? instance) => null;

  @override
  ReflectedFunction? reflectFunction(Function function) => null;

  @override
  ReflectedType reflectFutureOf(Type type) => throw UnimplementedError();
}
