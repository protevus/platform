import 'package:platform_container/container.dart';
import 'package:test/test.dart';

class FileLogger {
  final String filename;
  FileLogger(this.filename);
}

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

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Parameter Override Tests', () {
    test('can override constructor parameters', () {
      container.registerFactory<FileLogger>((c) {
        var filename =
            c.getParameterOverride('filename') as String? ?? 'default.log';
        return FileLogger(filename);
      });

      var logger = container.withParameters(
          {'filename': 'custom.log'}, () => container.make<FileLogger>());

      expect(logger.filename, equals('custom.log'));
    });

    test('parameter overrides are scoped', () {
      container.registerFactory<FileLogger>((c) {
        var filename =
            c.getParameterOverride('filename') as String? ?? 'default.log';
        return FileLogger(filename);
      });

      var customLogger = container.withParameters(
          {'filename': 'custom.log'}, () => container.make<FileLogger>());

      var defaultLogger = container.make<FileLogger>();

      expect(customLogger.filename, equals('custom.log'));
      expect(defaultLogger.filename, equals('default.log'));
    });

    test('nested parameter overrides', () {
      container.registerFactory<FileLogger>((c) {
        var filename =
            c.getParameterOverride('filename') as String? ?? 'default.log';
        return FileLogger(filename);
      });

      var logger = container.withParameters(
          {'filename': 'outer.log'},
          () => container.withParameters(
              {'filename': 'inner.log'}, () => container.make<FileLogger>()));

      expect(logger.filename, equals('inner.log'));
    });

    test('parameter overrides in child container', () {
      container.registerFactory<FileLogger>((c) {
        var filename =
            c.getParameterOverride('filename') as String? ?? 'default.log';
        return FileLogger(filename);
      });
      var child = container.createChild();

      var logger = child.withParameters(
          {'filename': 'custom.log'}, () => child.make<FileLogger>());

      expect(logger.filename, equals('custom.log'));
    });

    test('parameter overrides with multiple parameters', () {
      container.registerFactory<FileLogger>((c) {
        var filename =
            c.getParameterOverride('filename') as String? ?? 'default.log';
        return FileLogger(filename);
      });

      var logger = container.withParameters(
          {'filename': 'custom.log', 'level': 'debug', 'maxSize': 1024},
          () => container.make<FileLogger>());

      expect(logger.filename, equals('custom.log'));
    });
  });
}
