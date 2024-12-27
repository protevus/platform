import 'package:platform_container/container.dart';
import 'package:test/test.dart';

abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) => print('Console: $message');
}

class FileLogger implements Logger {
  @override
  void log(String message) => print('File: $message');
}

class Service {
  final Logger logger;
  Service(this.logger);
}

class AnotherService {
  final Logger logger;
  AnotherService(this.logger);
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
    if (clazz == AnotherService) {
      return MockReflectedClass(
          'AnotherService',
          [],
          [],
          [
            MockConstructor('', [
              MockParameter('logger', Logger, true, false),
            ])
          ],
          AnotherService);
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
    if (type == AnotherService) {
      return MockReflectedClass(
          'AnotherService',
          [],
          [],
          [
            MockConstructor('', [
              MockParameter('logger', Logger, true, false),
            ])
          ],
          AnotherService);
    }
    if (type == ConsoleLogger) {
      return MockReflectedClass(
          'ConsoleLogger', [], [], [MockConstructor('', [])], ConsoleLogger);
    }
    if (type == FileLogger) {
      return MockReflectedClass(
          'FileLogger', [], [], [MockConstructor('', [])], FileLogger);
    }
    if (type == Logger) {
      return MockReflectedClass(
          'Logger', [], [], [MockConstructor('', [])], Logger);
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
        super(name, typeParameters, reflectedType);

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    if (reflectedType == Service) {
      return MockReflectedInstance(Service(positionalArguments[0] as Logger));
    }
    if (reflectedType == AnotherService) {
      return MockReflectedInstance(
          AnotherService(positionalArguments[0] as Logger));
    }
    if (reflectedType == ConsoleLogger) {
      return MockReflectedInstance(ConsoleLogger());
    }
    if (reflectedType == FileLogger) {
      return MockReflectedInstance(FileLogger());
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
  bool isAssignableTo(ReflectedType? other) => false;

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

  group('Array of Concrete Types Tests', () {
    test('can bind different implementations for different concrete types', () {
      container.when([Service]).needs<Logger>().give<ConsoleLogger>();
      container.when([AnotherService]).needs<Logger>().give<FileLogger>();

      var service = container.make<Service>();
      var anotherService = container.make<AnotherService>();

      expect(service.logger, isA<ConsoleLogger>());
      expect(anotherService.logger, isA<FileLogger>());
    });

    test('can bind same implementation for multiple concrete types', () {
      container
          .when([Service, AnotherService])
          .needs<Logger>()
          .give<ConsoleLogger>();

      var service = container.make<Service>();
      var anotherService = container.make<AnotherService>();

      expect(service.logger, isA<ConsoleLogger>());
      expect(anotherService.logger, isA<ConsoleLogger>());
    });

    test('later bindings override earlier ones', () {
      container
          .when([Service, AnotherService])
          .needs<Logger>()
          .give<ConsoleLogger>();
      container.when([AnotherService]).needs<Logger>().give<FileLogger>();

      var service = container.make<Service>();
      var anotherService = container.make<AnotherService>();

      expect(service.logger, isA<ConsoleLogger>());
      expect(anotherService.logger, isA<FileLogger>());
    });

    test('throws when no implementation is provided', () {
      container.when([Service]).needs<Logger>();

      expect(() => container.make<Service>(),
          throwsA(isA<BindingResolutionException>()));
    });
  });
}
