import 'package:platformed_container/container.dart';
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

  group('Wrap Tests', () {
    test('wrap injects dependencies into closure', () {
      container.bind(Logger).to(ConsoleLogger);
      var messages = <String>[];

      var wrapped = container.wrap((Logger logger, String message) {
        messages.add(message);
      });

      wrapped('Hello world'); // Pass message directly
      expect(messages, contains('Hello world'));
    });

    test('wrap preserves provided arguments', () {
      container.bind(Logger).to(ConsoleLogger);
      var messages = <String>[];

      var wrapped = container.wrap((Logger logger, String message) {
        messages.add(message);
      });

      wrapped('Custom message'); // Pass message directly
      expect(messages, contains('Custom message'));
    });

    test('wrap throws when required dependency is missing', () {
      var wrapped = container.wrap((Logger logger) {});

      expect(() => wrapped(), throwsA(isA<BindingResolutionException>()));
    });

    test('wrap works with optional parameters', () {
      container.bind(Logger).to(ConsoleLogger);
      var messages = <String>[];

      var wrapped = container.wrap((Logger logger, [String? message]) {
        messages.add(message ?? 'default');
      });

      wrapped(); // No arguments needed
      expect(messages, contains('default'));
    });

    test('wrap works with named parameters', () {
      container.bind(Logger).to(ConsoleLogger);
      var messages = <String>[];

      var wrapped =
          container.wrap((Logger logger, {String message = 'default'}) {
        messages.add(message);
      });

      wrapped(); // No arguments needed
      expect(messages, contains('default'));
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
  ReflectedFunction? reflectFunction(Function function) {
    // Create mock parameters based on the function's runtime type
    var parameters = <ReflectedParameter>[];

    // First parameter is always Logger
    parameters.add(MockParameter('logger', Logger, true, false));

    // Add message parameter based on function signature
    if (function.toString().contains('String message')) {
      parameters.add(MockParameter('message', String, true, false));
    } else if (function.toString().contains('String? message')) {
      parameters.add(MockParameter('message', String, false, false));
    } else if (function.toString().contains('{String message')) {
      parameters.add(MockParameter('message', String, false, true));
    }

    return MockFunction('', parameters);
  }

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

class MockFunction implements ReflectedFunction {
  final String functionName;
  final List<ReflectedParameter> functionParameters;

  MockFunction(this.functionName, this.functionParameters);

  @override
  List<ReflectedInstance> get annotations => [];

  @override
  bool get isGetter => false;

  @override
  bool get isSetter => false;

  @override
  String get name => functionName;

  @override
  List<ReflectedParameter> get parameters => functionParameters;

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
