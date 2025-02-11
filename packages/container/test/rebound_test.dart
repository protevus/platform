import 'package:illuminate_container/container.dart';
import 'package:test/test.dart';

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

class Service {
  String value = 'initial';
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Rebound Tests', () {
    test('rebinding callback is called when singleton is refreshed', () {
      var callCount = 0;
      var lastInstance;

      container.registerSingleton<Service>(Service());
      container.rebinding<Service>((instance, container) {
        callCount++;
        lastInstance = instance;
      });

      var refreshed = container.refresh<Service>();
      expect(callCount, equals(1));
      expect(lastInstance, equals(refreshed));
      expect(container.make<Service>(), equals(refreshed));
    });

    test('multiple rebound callbacks are called in order', () {
      var order = [];
      container.registerSingleton<Service>(Service());

      container.rebinding<Service>((instance, container) {
        order.add(1);
      });

      container.rebinding<Service>((instance, container) {
        order.add(2);
      });

      container.refresh<Service>();
      expect(order, equals([1, 2]));
    });

    test('child container inherits parent rebound callbacks', () {
      var parentCallCount = 0;
      var childCallCount = 0;

      container.registerSingleton<Service>(Service());
      container.rebinding<Service>((instance, container) {
        parentCallCount++;
      });

      var child = container.createChild();
      child.rebinding<Service>((instance, container) {
        childCallCount++;
      });

      child.refresh<Service>();
      expect(parentCallCount, equals(1));
      expect(childCallCount, equals(1));
    });

    test('refresh throws on circular dependency', () {
      container.registerSingleton<Service>(Service());
      container.rebinding<Service>((instance, container) {
        container.refresh<Service>();
      });

      expect(() => container.refresh<Service>(),
          throwsA(isA<CircularDependencyException>()));
    });

    test('refresh creates new instance for factory binding', () {
      var count = 0;
      container.registerFactory<Service>((c) {
        count++;
        return Service();
      });

      var first = container.make<Service>();
      var second = container.refresh<Service>();

      expect(count, equals(2));
      expect(first, isNot(equals(second)));
    });
  });
}
