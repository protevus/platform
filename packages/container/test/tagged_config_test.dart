import 'package:illuminate_container/container.dart';
import 'package:test/test.dart';

abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  final String level;
  ConsoleLogger({this.level = 'info'});
  @override
  void log(String message) => print('Console($level): $message');
}

class FileLogger implements Logger {
  final String filename;
  FileLogger({required this.filename});
  @override
  void log(String message) => print('File($filename): $message');
}

class Service {
  final Logger logger;
  Service(this.logger);
}

class MockReflector extends Reflector {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClass? reflectClass(Type clazz) {
    if (clazz == Service) {
      return MockReflectedClass(
          'Service',
          [],
          [],
          [
            MockConstructor('', [
              MockParameter('logger', Logger, true, false),
            ])
          ],
          Service);
    }
    return null;
  }

  @override
  ReflectedType? reflectType(Type type) {
    if (type == Service) {
      return MockReflectedClass(
          'Service',
          [],
          [],
          [
            MockConstructor('', [
              MockParameter('logger', Logger, true, false),
            ])
          ],
          Service);
    }
    if (type == ConsoleLogger) {
      return MockReflectedClass(
          'ConsoleLogger',
          [],
          [],
          [
            MockConstructor('', [
              MockParameter('level', String, false, true),
            ])
          ],
          ConsoleLogger);
    }
    if (type == FileLogger) {
      return MockReflectedClass(
          'FileLogger',
          [],
          [],
          [
            MockConstructor('', [
              MockParameter('filename', String, true, true),
            ])
          ],
          FileLogger);
    }
    if (type == Logger) {
      return MockReflectedClass(
          'Logger', [], [], [MockConstructor('', [])], Logger);
    }
    if (type == String) {
      return MockReflectedClass(
          'String', [], [], [MockConstructor('', [])], String);
    }
    return null;
  }

  @override
  ReflectedInstance? reflectInstance(Object? instance) => null;

  @override
  ReflectedFunction? reflectFunction(Function function) => null;

  @override
  ReflectedType reflectFutureOf(Type type) => throw UnimplementedError();

  @override
  Type? findTypeByName(String name) => null;

  @override
  ReflectedFunction? findInstanceMethod(Object instance, String methodName) =>
      null;
}

class MockReflectedClass extends ReflectedType implements ReflectedClass {
  @override
  final List<ReflectedInstance> annotations;
  @override
  final List<ReflectedFunction> constructors;
  @override
  final List<ReflectedDeclaration> declarations;

  MockReflectedClass(
    String name,
    List<ReflectedTypeParameter> typeParameters,
    this.annotations,
    this.constructors,
    Type reflectedType,
  )   : declarations = [],
        super(reflectedType.toString(), typeParameters, reflectedType);

  void _validateParameters(List<ReflectedParameter> parameters,
      List positionalArguments, Map<String, dynamic> namedArguments) {
    var paramIndex = 0;
    for (var param in parameters) {
      if (param.isNamed) {
        if (param.isRequired && !namedArguments.containsKey(param.name)) {
          throw BindingResolutionException(
              'Required parameter ${param.name} is missing');
        }
      } else {
        if (param.isRequired && paramIndex >= positionalArguments.length) {
          throw BindingResolutionException(
              'Required parameter ${param.name} is missing');
        }
        paramIndex++;
      }
    }
  }

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    // Find constructor
    var constructor = constructors.firstWhere((c) => c.name == constructorName,
        orElse: () => constructors.first);

    // Validate parameters
    _validateParameters(
        constructor.parameters, positionalArguments, namedArguments);

    if (reflectedType == Service) {
      return MockReflectedInstance(Service(positionalArguments[0] as Logger));
    }
    if (reflectedType == ConsoleLogger) {
      return MockReflectedInstance(
          ConsoleLogger(level: namedArguments['level'] as String? ?? 'info'));
    }
    if (reflectedType == FileLogger) {
      return MockReflectedInstance(
          FileLogger(filename: namedArguments['filename'] as String));
    }
    if (reflectedType == Logger) {
      throw BindingResolutionException(
          'No implementation was provided for Logger');
    }
    throw UnsupportedError('Unknown type: $reflectedType');
  }

  @override
  bool isAssignableTo(ReflectedType? other) {
    if (reflectedType == ConsoleLogger && other?.reflectedType == Logger) {
      return true;
    }
    if (reflectedType == FileLogger && other?.reflectedType == Logger) {
      return true;
    }
    return false;
  }
}

class MockConstructor implements ReflectedFunction {
  final String constructorName;
  final List<ReflectedParameter> constructorParameters;

  MockConstructor(this.constructorName, this.constructorParameters);

  @override
  List<ReflectedInstance> get annotations => [];

  @override
  bool get isGetter => false;

  @override
  bool get isSetter => false;

  @override
  String get name => constructorName;

  @override
  List<ReflectedParameter> get parameters => constructorParameters;

  @override
  ReflectedType? get returnType => null;

  @override
  List<ReflectedTypeParameter> get typeParameters => [];

  @override
  ReflectedInstance invoke(Invocation invocation) => throw UnimplementedError();
}

class MockParameter implements ReflectedParameter {
  @override
  final String name;
  @override
  final bool isRequired;
  @override
  final bool isNamed;
  final Type paramType;
  final bool isVariadic;

  MockParameter(this.name, this.paramType, this.isRequired, this.isNamed,
      {this.isVariadic = false});

  @override
  List<ReflectedInstance> get annotations => [];

  @override
  ReflectedType get type => MockReflectedType(paramType);
}

class MockReflectedType implements ReflectedType {
  @override
  final String name;
  @override
  final Type reflectedType;

  MockReflectedType(this.reflectedType) : name = reflectedType.toString();

  @override
  List<ReflectedTypeParameter> get typeParameters => [];

  @override
  bool isAssignableTo(ReflectedType? other) {
    // Handle primitive types
    if (reflectedType == other?.reflectedType) {
      return true;
    }
    return false;
  }

  @override
  ReflectedInstance newInstance(
          String constructorName, List positionalArguments,
          [Map<String, dynamic> namedArguments = const {},
          List<Type> typeArguments = const []]) =>
      throw UnimplementedError();
}

class MockReflectedInstance implements ReflectedInstance {
  final dynamic value;

  MockReflectedInstance(this.value);

  @override
  ReflectedClass get clazz => throw UnimplementedError();

  @override
  ReflectedInstance getField(String name) => throw UnimplementedError();

  @override
  dynamic get reflectee => value;

  @override
  ReflectedType get type => throw UnimplementedError();

  @override
  void setField(String name, dynamic value) {
    // No-op for mock
  }
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Tagged and Config Tests', () {
    test('can bind implementation from tagged type', () {
      container.tag([ConsoleLogger], 'loggers');
      container.when([Service]).needs<Logger>().giveTagged('loggers');

      var service = container.make<Service>();
      expect(service.logger, isA<ConsoleLogger>());
    });

    test('throws when tag has no implementations', () {
      container.when([Service]).needs<Logger>().giveTagged('loggers');

      expect(
          () => container.make<Service>(),
          throwsA(predicate((e) =>
              e is BindingResolutionException &&
              e.toString().contains('No implementations found for tag'))));
    });

    test('can bind implementation with config', () {
      container
          .when([Service])
          .needs<Logger>()
          .giveConfig(ConsoleLogger, {'level': 'debug'});

      var service = container.make<Service>();
      expect(service.logger, isA<ConsoleLogger>());
      expect((service.logger as ConsoleLogger).level, equals('debug'));
    });

    test('throws when required config is missing', () {
      container.when([Service]).needs<Logger>().giveConfig(FileLogger, {});

      expect(
          () => container.make<Service>(),
          throwsA(predicate((e) =>
              e is BindingResolutionException &&
              e.toString().contains(
                  'Required parameter filename is missing for FileLogger'))));
    });

    test('can mix tagged and config bindings', () {
      container.tag([ConsoleLogger], 'console');
      container.tag([FileLogger], 'file');

      container.when([Service]).needs<Logger>().giveTagged('console');
      container
          .when([Service])
          .needs<Logger>()
          .giveConfig(FileLogger, {'filename': 'app.log'});

      var service = container.make<Service>();
      expect(service.logger, isA<FileLogger>());
      expect((service.logger as FileLogger).filename, equals('app.log'));
    });
  });
}
