import 'package:platformed_container/container.dart';
import 'package:test/test.dart';
import 'common.dart';

// Test interfaces and implementations
abstract class Logger {
  void log(String message);
}

class FileLogger implements Logger {
  final String filename;
  FileLogger(this.filename);
  @override
  void log(String message) => print('File($filename): $message');
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) => print('Console: $message');
}

class LoggerClient {
  final Logger logger;
  LoggerClient(this.logger);
}

class SpecialLoggerClient {
  final Logger logger;
  SpecialLoggerClient(this.logger);
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Contextual Binding Tests', () {
    test('basic contextual binding resolves correctly', () {
      // Register default binding
      container.registerSingleton<Logger>(ConsoleLogger());

      // Register contextual binding
      container.when(LoggerClient).needs<Logger>().give<FileLogger>();

      // The default binding should be used here
      var logger = container.make<Logger>();
      expect(logger, isA<ConsoleLogger>());

      // The contextual binding should be used here
      var client = container.make<LoggerClient>();
      expect(client.logger, isA<FileLogger>());
    });

    test('multiple contextual bindings work independently', () {
      container.registerSingleton<Logger>(ConsoleLogger());

      container.when(LoggerClient).needs<Logger>().give<FileLogger>();
      container.when(SpecialLoggerClient).needs<Logger>().give<ConsoleLogger>();

      var client1 = container.make<LoggerClient>();
      var client2 = container.make<SpecialLoggerClient>();

      expect(client1.logger, isA<FileLogger>());
      expect(client2.logger, isA<ConsoleLogger>());
    });

    test('contextual binding with factory function works', () {
      container.registerSingleton<Logger>(ConsoleLogger());

      container
          .when(LoggerClient)
          .needs<Logger>()
          .giveFactory((container) => FileLogger('test.log'));

      var client = container.make<LoggerClient>();
      expect(client.logger, isA<FileLogger>());
      expect((client.logger as FileLogger).filename, equals('test.log'));
    });

    test('contextual binding throws when implementation not found', () {
      container.when(LoggerClient).needs<Logger>().give<FileLogger>();

      expect(
        () => container.make<LoggerClient>(),
        throwsA(isA<BindingResolutionException>()),
      );
    });

    test('contextual bindings are inherited by child containers', () {
      container.registerSingleton<Logger>(ConsoleLogger());
      container.when(LoggerClient).needs<Logger>().give<FileLogger>();

      var childContainer = container.createChild();
      var client = childContainer.make<LoggerClient>();

      expect(client.logger, isA<FileLogger>());
    });

    test('child container can override parent contextual binding', () {
      container.registerSingleton<Logger>(ConsoleLogger());
      container.when(LoggerClient).needs<Logger>().give<FileLogger>();

      var childContainer = container.createChild();
      childContainer
          .when(LoggerClient)
          .needs<Logger>()
          .giveFactory((container) => FileLogger('child.log'));

      var client = childContainer.make<LoggerClient>();
      expect(client.logger, isA<FileLogger>());
      expect((client.logger as FileLogger).filename, equals('child.log'));
    });
  });
}

// Mock reflector implementation for testing
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
    } else if (type == SpecialLoggerClient) {
      return MockReflectedClass(
        'SpecialLoggerClient',
        [],
        [],
        [
          MockConstructor([MockParameter('logger', Logger)])
        ],
        [],
        type,
        (name, positional, named, typeArgs) =>
            SpecialLoggerClient(positional[0]),
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
