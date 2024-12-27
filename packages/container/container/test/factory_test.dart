import 'package:platform_container/container.dart';
import 'package:test/test.dart';

abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) => print('Console: $message');
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Factory Tests', () {
    test('factory creates deferred binding', () {
      var created = false;
      container.factory<Logger>(() {
        created = true;
        return ConsoleLogger();
      });

      // Verify binding is not created yet
      expect(created, isFalse);

      // Resolve the binding
      var logger = container.make<Logger>();

      // Verify binding was created
      expect(created, isTrue);
      expect(logger, isA<ConsoleLogger>());
    });

    test('factory creates new instance each time', () {
      container.factory<Logger>(() => ConsoleLogger());

      var logger1 = container.make<Logger>();
      var logger2 = container.make<Logger>();

      expect(logger1, isNot(same(logger2)));
    });

    test('factory throws when already bound', () {
      container.factory<Logger>(() => ConsoleLogger());

      expect(() => container.factory<Logger>(() => ConsoleLogger()),
          throwsA(isA<StateError>()));
    });

    test('factory works with interfaces', () {
      container.factory<Logger>(() => ConsoleLogger());

      var logger = container.make<Logger>();
      expect(logger, isA<Logger>());
      expect(logger, isA<ConsoleLogger>());
    });

    test('factory preserves parameter overrides', () {
      var paramValue = '';
      container.factory<Logger>(() {
        paramValue = container.getParameterOverride('level') as String;
        return ConsoleLogger();
      });

      container.withParameters({'level': 'debug'}, () {
        container.make<Logger>();
      });

      expect(paramValue, equals('debug'));
    });
  });
}

class MockReflector extends Reflector {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClass? reflectClass(Type clazz) {
    if (clazz == ConsoleLogger) {
      return MockReflectedClass(
          'ConsoleLogger', [], [], [MockConstructor('', [])], ConsoleLogger);
    }
    return null;
  }

  @override
  ReflectedType? reflectType(Type type) {
    return reflectClass(type);
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
  List<ReflectedInstance> getAnnotations(Type type) => [];

  @override
  List<ReflectedInstance> getParameterAnnotations(
          Type type, String constructorName, String parameterName) =>
      [];
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

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    if (reflectedType == ConsoleLogger) {
      return MockReflectedInstance(ConsoleLogger());
    }
    throw UnsupportedError('Unknown type: $reflectedType');
  }

  @override
  bool isAssignableTo(ReflectedType? other) {
    if (reflectedType == other?.reflectedType) {
      return true;
    }
    if (reflectedType == ConsoleLogger && other?.reflectedType == Logger) {
      return true;
    }
    return false;
  }
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
