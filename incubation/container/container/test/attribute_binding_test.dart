import 'package:platformed_container/container.dart';
import 'package:test/test.dart';

abstract class Logger {
  void log(String message);
}

@Injectable(bindTo: Logger, tags: ['console'])
class ConsoleLogger implements Logger {
  final String level;

  ConsoleLogger({this.level = 'info'});

  @override
  void log(String message) => print('Console($level): $message');
}

@Injectable(bindTo: Logger, tags: ['file'])
class FileLogger implements Logger {
  final String filename;

  FileLogger({required this.filename});

  @override
  void log(String message) => print('File($filename): $message');
}

class Service {
  final Logger consoleLogger;
  final Logger fileLogger;
  final List<Logger> allLoggers;

  Service(
    @InjectTagged('console') this.consoleLogger,
    @Inject(FileLogger, config: {'filename': 'app.log'}) this.fileLogger,
    @InjectAll() this.allLoggers,
  );

  void logMessage(String message) {
    for (var logger in allLoggers) {
      logger.log(message);
    }
  }
}

@Injectable(singleton: true)
class SingletonService {
  static int instanceCount = 0;
  final int instanceNumber;

  SingletonService() : instanceNumber = ++instanceCount;
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
              MockParameter('consoleLogger', Logger, true, false),
              MockParameter('fileLogger', Logger, true, false),
              MockParameter('allLoggers', List<Logger>, true, false),
            ])
          ],
          Service);
    }
    if (clazz == SingletonService) {
      return MockReflectedClass('SingletonService', [], [],
          [MockConstructor('', [])], SingletonService);
    }
    return null;
  }

  @override
  ReflectedType? reflectType(Type type) {
    if (type == List<Logger>) {
      return MockReflectedClass('List<Logger>', [], [], [], List<Logger>);
    }
    if (type == Service) {
      return MockReflectedClass(
          'Service',
          [],
          [],
          [
            MockConstructor('', [
              MockParameter('consoleLogger', Logger, true, false),
              MockParameter('fileLogger', Logger, true, false),
              MockParameter('allLoggers', List<Logger>, true, false),
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
    if (type == SingletonService) {
      return MockReflectedClass('SingletonService', [], [],
          [MockConstructor('', [])], SingletonService);
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

  @override
  List<ReflectedInstance> getAnnotations(Type type) {
    if (type == ConsoleLogger) {
      return [
        MockReflectedInstance(Injectable(bindTo: Logger, tags: ['console']))
      ];
    }
    if (type == FileLogger) {
      return [
        MockReflectedInstance(Injectable(bindTo: Logger, tags: ['file']))
      ];
    }
    if (type == SingletonService) {
      return [MockReflectedInstance(Injectable(singleton: true))];
    }
    return [];
  }

  @override
  List<ReflectedInstance> getParameterAnnotations(
      Type type, String constructorName, String parameterName) {
    if (type == Service) {
      if (parameterName == 'consoleLogger') {
        return [MockReflectedInstance(InjectTagged('console'))];
      }
      if (parameterName == 'fileLogger') {
        return [
          MockReflectedInstance(
              Inject(FileLogger, config: {'filename': 'app.log'}))
        ];
      }
      if (parameterName == 'allLoggers') {
        return [MockReflectedInstance(InjectAll())];
      }
    }
    return [];
  }
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
    // Handle List<Logger> specially
    if (reflectedType == List<Logger>) {
      var loggers = <Logger>[];
      for (var arg in positionalArguments) {
        if (arg is Logger) {
          loggers.add(arg);
        }
      }
      return MockReflectedInstance(loggers);
    }

    // Find constructor
    var constructor = constructors.firstWhere((c) => c.name == constructorName,
        orElse: () => constructors.first);

    // Validate parameters
    _validateParameters(
        constructor.parameters, positionalArguments, namedArguments);

    if (reflectedType == Service) {
      var loggers = <Logger>[];
      if (positionalArguments[2] is List) {
        for (var item in positionalArguments[2] as List) {
          if (item is Logger) {
            loggers.add(item);
          }
        }
      }
      return MockReflectedInstance(Service(
        positionalArguments[0] as Logger,
        positionalArguments[1] as Logger,
        loggers,
      ));
    }
    if (reflectedType == ConsoleLogger) {
      return MockReflectedInstance(
          ConsoleLogger(level: namedArguments['level'] as String? ?? 'info'));
    }
    if (reflectedType == FileLogger) {
      return MockReflectedInstance(
          FileLogger(filename: namedArguments['filename'] as String));
    }
    if (reflectedType == SingletonService) {
      return MockReflectedInstance(SingletonService());
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
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Attribute Binding Tests', () {
    setUp(() {
      // Reset instance count
      SingletonService.instanceCount = 0;

      // Register implementations
      container.registerAttributeBindings(ConsoleLogger);
      container.registerAttributeBindings(FileLogger);
      container.registerAttributeBindings(SingletonService);

      // Set ConsoleLogger as default implementation for Logger
      container.bind(Logger).to(ConsoleLogger);
    });

    test('can bind implementation using @Injectable', () {
      var logger = container.make<Logger>();
      expect(logger, isA<ConsoleLogger>());
    });

    test('can bind implementation using @Injectable with tags', () {
      var consoleLogger = container.tagged('console').first;
      expect(consoleLogger, isA<ConsoleLogger>());

      var fileLogger = container.tagged('file').first;
      expect(fileLogger, isA<FileLogger>());
    });

    test('can inject tagged implementation using @InjectTagged', () {
      var service = container.make<Service>();
      expect(service.consoleLogger, isA<ConsoleLogger>());
    });

    test('can inject configured implementation using @Inject', () {
      var service = container.make<Service>();
      expect(service.fileLogger, isA<FileLogger>());
      expect((service.fileLogger as FileLogger).filename, equals('app.log'));
    });

    test('can inject all implementations using @InjectAll', () {
      var service = container.make<Service>();
      expect(service.allLoggers, hasLength(2));
      expect(service.allLoggers[0], isA<ConsoleLogger>());
      expect(service.allLoggers[1], isA<FileLogger>());
    });

    test('can bind singleton using @Injectable', () {
      var first = container.make<SingletonService>();
      var second = container.make<SingletonService>();
      expect(first.instanceNumber, equals(1));
      expect(second.instanceNumber, equals(1));
      expect(identical(first, second), isTrue);
    });
  });
}