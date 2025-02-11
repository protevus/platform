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

abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) => print(message);
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Array Access Tests', () {
    test('can get instance using array syntax', () {
      container.registerSingleton<Logger>(ConsoleLogger());
      var logger = container[Logger];
      expect(logger, isA<ConsoleLogger>());
    });

    test('can register singleton using array syntax', () {
      container[Logger] = ConsoleLogger();
      var logger = container.make<Logger>();
      expect(logger, isA<ConsoleLogger>());
    });

    test('can register factory using array syntax', () {
      container[Logger] = (Container c) => ConsoleLogger();
      var logger = container.make<Logger>();
      expect(logger, isA<ConsoleLogger>());
    });

    test('array access works with parameter overrides', () {
      container[Logger] = (Container c) {
        var level = c.getParameterOverride('level') as String? ?? 'info';
        return ConsoleLogger();
      };

      var logger =
          container.withParameters({'level': 'debug'}, () => container[Logger]);
      expect(logger, isA<ConsoleLogger>());
    });

    test('array access works with child containers', () {
      container[Logger] = ConsoleLogger();
      var child = container.createChild();
      var logger = child[Logger];
      expect(logger, isA<ConsoleLogger>());
    });
  });
}
