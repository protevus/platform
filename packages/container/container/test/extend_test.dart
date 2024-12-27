import 'package:platform_container/container.dart';
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
  LogLevel get level;
  set level(LogLevel value);
  void log(String message);
}

enum LogLevel { debug, info, warning, error }

class ConsoleLogger implements Logger {
  LogLevel _level = LogLevel.info;

  @override
  LogLevel get level => _level;

  @override
  set level(LogLevel value) => _level = value;

  @override
  void log(String message) => print('Console: $message');
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Service Extender Tests', () {
    test('can extend a service after resolution', () {
      container.registerSingleton<Logger>(ConsoleLogger());
      container.extend<Logger>((logger, container) {
        logger.level = LogLevel.debug;
        return logger;
      });

      var logger = container.make<Logger>();
      expect(logger.level, equals(LogLevel.debug));
    });

    test('can apply multiple extenders in order', () {
      container.registerSingleton<Logger>(ConsoleLogger());

      container.extend<Logger>((logger, container) {
        logger.level = LogLevel.debug;
        return logger;
      });

      container.extend<Logger>((logger, container) {
        logger.level = LogLevel.error;
        return logger;
      });

      var logger = container.make<Logger>();
      expect(logger.level, equals(LogLevel.error));
    });

    test('child container inherits parent extenders', () {
      container.registerSingleton<Logger>(ConsoleLogger());
      container.extend<Logger>((logger, container) {
        logger.level = LogLevel.debug;
        return logger;
      });

      var child = container.createChild();
      var logger = child.make<Logger>();
      expect(logger.level, equals(LogLevel.debug));
    });

    test('child container can add its own extenders', () {
      container.registerSingleton<Logger>(ConsoleLogger());
      container.extend<Logger>((logger, container) {
        logger.level = LogLevel.debug;
        return logger;
      });

      var child = container.createChild();
      child.extend<Logger>((logger, container) {
        logger.level = LogLevel.error;
        return logger;
      });

      var parentLogger = container.make<Logger>();
      expect(parentLogger.level, equals(LogLevel.debug));

      var childLogger = child.make<Logger>();
      expect(childLogger.level, equals(LogLevel.error));
    });
  });
}
