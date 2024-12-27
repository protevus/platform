import 'package:platform_container/container.dart';
import 'package:test/test.dart';

abstract class Logger {
  void log(String message);
  String get level;
}

class ConsoleLogger implements Logger {
  final String _level;

  ConsoleLogger(this._level);

  @override
  void log(String message) => print('Console: $message');

  @override
  String get level => _level;
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('MakeWith Tests', () {
    test('makeWith passes parameters to constructor', () {
      container.factory<Logger>(() =>
          ConsoleLogger(container.getParameterOverride('level') ?? 'info'));

      var logger = container.makeWith<Logger>({'level': 'debug'});
      expect(logger.level, equals('debug'));
    });

    test('makeWith works with type parameter', () {
      container.factory<Logger>(() =>
          ConsoleLogger(container.getParameterOverride('level') ?? 'info'));

      var logger = container.makeWith<Logger>({'level': 'debug'}, Logger);
      expect(logger.level, equals('debug'));
    });

    test('makeWith preserves parameters for nested dependencies', () {
      var level = '';
      container.factory<Logger>(() {
        level = container.getParameterOverride('level') ?? 'info';
        return ConsoleLogger(level);
      });

      container.makeWith<Logger>({'level': 'debug'});
      expect(level, equals('debug'));
    });

    test('makeWith throws when binding not found', () {
      expect(() => container.makeWith<Logger>({'level': 'debug'}),
          throwsA(isA<BindingResolutionException>()));
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
          'ConsoleLogger',
          [],
          [],
          [
            MockConstructor('', [
              MockParameter('level', String, true, false),
            ])
          ],
          ConsoleLogger);
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
      var level = namedArguments['level'] ?? positionalArguments[0];
      return MockReflectedInstance(ConsoleLogger(level));
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
    if (reflectedType == other?.reflectedType) {
      return true;
    }
    if (reflectedType == ConsoleLogger && other?.reflectedType == Logger) {
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
