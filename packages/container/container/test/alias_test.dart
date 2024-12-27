import 'package:platform_container/container.dart';
import 'package:test/test.dart';
import 'common.dart';

// Test interfaces and implementations
abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) => print('Console: $message');
}

class FileLogger implements Logger {
  final String filename;
  FileLogger(this.filename);
  @override
  void log(String message) => print('File($filename): $message');
}

class LoggerClient {
  final Logger logger;
  LoggerClient(this.logger);
}

class MockReflector extends Reflector {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClass? reflectClass(Type clazz) => null;

  @override
  ReflectedType? reflectType(Type type) {
    if (type == LoggerClient) {
      return MockReflectedClass(
        'LoggerClient',
        [],
        [],
        [
          MockConstructor([MockParameter('logger', Logger)])
        ],
        [],
        type,
        (name, positional, named, typeArgs) => LoggerClient(positional[0]),
      );
    } else if (type == FileLogger) {
      return MockReflectedClass(
        'FileLogger',
        [],
        [],
        [
          MockConstructor([MockParameter('filename', String)])
        ],
        [],
        type,
        (name, positional, named, typeArgs) => FileLogger(positional[0]),
      );
    }
    return null;
  }

  @override
  ReflectedInstance? reflectInstance(Object? instance) => null;

  @override
  ReflectedFunction? reflectFunction(Function function) => null;

  @override
  ReflectedType reflectFutureOf(Type type) => throw UnimplementedError();
}

class MockReflectedClass extends ReflectedClass {
  final Function instanceBuilder;

  MockReflectedClass(
    String name,
    List<ReflectedTypeParameter> typeParameters,
    List<ReflectedInstance> annotations,
    List<ReflectedFunction> constructors,
    List<ReflectedDeclaration> declarations,
    Type reflectedType,
    this.instanceBuilder,
  ) : super(name, typeParameters, annotations, constructors, declarations,
            reflectedType);

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    var instance = instanceBuilder(
        constructorName, positionalArguments, namedArguments, typeArguments);
    return MockReflectedInstance(this, instance);
  }

  @override
  bool isAssignableTo(ReflectedType? other) {
    if (other == null) return false;
    return reflectedType == other.reflectedType;
  }
}

class MockReflectedInstance extends ReflectedInstance {
  MockReflectedInstance(ReflectedClass clazz, Object? reflectee)
      : super(clazz, clazz, reflectee);

  @override
  ReflectedInstance getField(String name) {
    throw UnimplementedError();
  }
}

class MockConstructor extends ReflectedFunction {
  final List<ReflectedParameter> params;

  MockConstructor(this.params)
      : super('', [], [], params, false, false,
            returnType: MockReflectedType('void', [], dynamic));

  @override
  ReflectedInstance invoke(Invocation invocation) {
    throw UnimplementedError();
  }
}

class MockParameter extends ReflectedParameter {
  MockParameter(String name, Type type)
      : super(name, [], MockReflectedType(type.toString(), [], type), true,
            false);
}

class MockReflectedType extends ReflectedType {
  MockReflectedType(String name, List<ReflectedTypeParameter> typeParameters,
      Type reflectedType)
      : super(name, typeParameters, reflectedType);

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    throw UnimplementedError();
  }

  @override
  bool isAssignableTo(ReflectedType? other) {
    if (other == null) return false;
    return reflectedType == other.reflectedType;
  }
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Alias Tests', () {
    test('alias resolves to concrete type', () {
      container.registerSingleton<ConsoleLogger>(ConsoleLogger());
      container.alias<Logger>(ConsoleLogger);

      var logger = container.make<Logger>();
      expect(logger, isA<ConsoleLogger>());
    });

    test('isAlias returns true for aliased type', () {
      container.alias<Logger>(ConsoleLogger);
      expect(container.isAlias(Logger), isTrue);
    });

    test('isAlias returns false for non-aliased type', () {
      expect(container.isAlias(ConsoleLogger), isFalse);
    });

    test('getAlias returns concrete type for aliased type', () {
      container.alias<Logger>(ConsoleLogger);
      expect(container.getAlias(Logger), equals(ConsoleLogger));
    });

    test('getAlias returns same type for non-aliased type', () {
      expect(container.getAlias(ConsoleLogger), equals(ConsoleLogger));
    });

    test('alias works with contextual bindings', () {
      // Register both logger implementations
      container.registerSingleton<ConsoleLogger>(ConsoleLogger());
      container.registerSingleton<FileLogger>(FileLogger('test.log'));

      // Set up the alias
      container.alias<Logger>(ConsoleLogger);

      // Set up contextual binding for the interface
      container.when(LoggerClient).needs<Logger>().give<FileLogger>();

      var logger = container.make<Logger>();
      expect(logger, isA<ConsoleLogger>());

      var client = container.make<LoggerClient>();
      expect(client.logger, isA<FileLogger>());
    });

    test('child container inherits parent aliases', () {
      container.registerSingleton<ConsoleLogger>(ConsoleLogger());
      container.alias<Logger>(ConsoleLogger);

      var child = container.createChild();
      var logger = child.make<Logger>();
      expect(logger, isA<ConsoleLogger>());
    });

    test('child container can override parent aliases', () {
      container.registerSingleton<ConsoleLogger>(ConsoleLogger());
      container.registerSingleton<FileLogger>(FileLogger('test.log'));
      container.alias<Logger>(ConsoleLogger);

      var child = container.createChild();
      child.alias<Logger>(FileLogger);

      var parentLogger = container.make<Logger>();
      expect(parentLogger, isA<ConsoleLogger>());

      var childLogger = child.make<Logger>();
      expect(childLogger, isA<FileLogger>());
    });
  });
}
