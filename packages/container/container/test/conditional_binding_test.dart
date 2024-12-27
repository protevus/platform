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

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Conditional Binding Tests', () {
    test('bindIf registers binding when not bound', () {
      container.bindIf<Logger>(ConsoleLogger());
      expect(container.make<Logger>(), isA<ConsoleLogger>());
    });

    test('bindIf skips registration when already bound', () {
      container.bind(Logger).to(ConsoleLogger);
      container.bindIf<Logger>(FileLogger());
      expect(container.make<Logger>(), isA<ConsoleLogger>());
    });

    test('bindIf registers singleton when specified', () {
      container.bindIf<Logger>(ConsoleLogger(), singleton: true);
      var first = container.make<Logger>();
      var second = container.make<Logger>();
      expect(identical(first, second), isTrue);
    });

    test('singletonIf registers singleton when not bound', () {
      container.singletonIf<Logger>(ConsoleLogger());
      var first = container.make<Logger>();
      var second = container.make<Logger>();
      expect(identical(first, second), isTrue);
    });

    test('singletonIf skips registration when already bound', () {
      container.bind(Logger).to(ConsoleLogger);
      container.singletonIf<Logger>(FileLogger());
      expect(container.make<Logger>(), isA<ConsoleLogger>());
    });

    test('bindIf works with factory functions', () {
      container.bindIf<Logger>((c) => ConsoleLogger());
      expect(container.make<Logger>(), isA<ConsoleLogger>());
    });

    test('singletonIf works with factory functions', () {
      container.singletonIf<Logger>((c) => ConsoleLogger());
      var first = container.make<Logger>();
      var second = container.make<Logger>();
      expect(identical(first, second), isTrue);
    });
  });
}

class MockReflector extends Reflector {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClass? reflectClass(Type clazz) {
    if (clazz == Logger) {
      return MockReflectedClass('Logger', [], [], [], Logger);
    }
    if (clazz == ConsoleLogger) {
      return MockReflectedClass(
          'ConsoleLogger', [], [], [MockConstructor('', [])], ConsoleLogger);
    }
    if (clazz == FileLogger) {
      return MockReflectedClass(
          'FileLogger', [], [], [MockConstructor('', [])], FileLogger);
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
    if (reflectedType == FileLogger) {
      return MockReflectedInstance(FileLogger());
    }
    throw UnsupportedError('Unknown type: $reflectedType');
  }

  @override
  bool isAssignableTo(ReflectedType? other) {
    if (reflectedType == other?.reflectedType) {
      return true;
    }
    if ((reflectedType == ConsoleLogger || reflectedType == FileLogger) &&
        other?.reflectedType == Logger) {
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
