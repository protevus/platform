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

  group('Flush Tests', () {
    test('flush clears all bindings', () {
      container.factory<Logger>(() => ConsoleLogger());
      container.registerSingleton<String>('test');
      container.registerNamedSingleton('logger', ConsoleLogger());
      container.alias<Logger>(ConsoleLogger);
      container.tag([Logger], 'logging');

      container.flush();

      expect(container.has<Logger>(), isFalse);
      expect(container.has<String>(), isFalse);
      expect(container.hasNamed('logger'), isFalse);
      expect(container.isAlias(Logger), isFalse);
      expect(container.tagged('logging'), isEmpty);
    });

    test('flush clears callbacks', () {
      var beforeResolvingCalled = false;
      var resolvingCalled = false;
      var afterResolvingCalled = false;
      var reboundCalled = false;

      container.beforeResolving<Logger>((type, args, container) {
        beforeResolvingCalled = true;
      });

      container.resolving<Logger>((instance, container) {
        resolvingCalled = true;
      });

      container.afterResolving<Logger>((instance, container) {
        afterResolvingCalled = true;
      });

      container.rebinding<Logger>((instance, container) {
        reboundCalled = true;
      });

      container.flush();
      container.factory<Logger>(() => ConsoleLogger());
      container.make<Logger>();
      container.refresh<Logger>();

      expect(beforeResolvingCalled, isFalse);
      expect(resolvingCalled, isFalse);
      expect(afterResolvingCalled, isFalse);
      expect(reboundCalled, isFalse);
    });

    test('flush clears contextual bindings', () {
      container.bind(Logger).to(ConsoleLogger);
      container.flush();

      expect(() => container.make<Logger>(),
          throwsA(isA<BindingResolutionException>()));
    });

    test('flush preserves parent bindings', () {
      var parent = Container(MockReflector());
      parent.registerSingleton<String>('parent');
      var child = parent.createChild();
      child.registerSingleton<Logger>(ConsoleLogger());

      child.flush();

      expect(child.has<String>(), isTrue);
      expect(child.has<Logger>(), isFalse);
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
