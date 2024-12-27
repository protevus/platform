import 'package:platformed_container/container.dart';
import 'package:test/test.dart';

class Config {
  final String environment;
  Config(this.environment);
}

class Logger {
  String log(String message) => message;
  void configure(Config config) {}
  String format(String message, {int? level}) => '$message (level: $level)';
  void setup(Config config, String name) {}
}

class MockReflector extends Reflector {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClass? reflectClass(Type clazz) => null;

  @override
  ReflectedType? reflectType(Type type) => null;

  @override
  ReflectedInstance? reflectInstance(Object? instance) => null;

  @override
  ReflectedFunction? reflectFunction(Function function) => null;

  @override
  ReflectedType reflectFutureOf(Type type) => throw UnimplementedError();

  @override
  Type? findTypeByName(String name) {
    if (name == 'Logger') return Logger;
    return null;
  }

  @override
  ReflectedFunction? findInstanceMethod(Object instance, String methodName) {
    if (instance is Logger) {
      switch (methodName) {
        case 'log':
          return MockMethod('log', (invocation) {
            var args = invocation.positionalArguments;
            return MockReflectedInstance(instance.log(args[0] as String));
          }, [MockParameter('message', String, true, false)]);
        case 'configure':
          return MockMethod('configure', (invocation) {
            var args = invocation.positionalArguments;
            instance.configure(args[0] as Config);
            return MockReflectedInstance(null);
          }, [MockParameter('config', Config, true, false)]);
        case 'format':
          return MockMethod('format', (invocation) {
            var args = invocation.positionalArguments;
            var namedArgs = invocation.namedArguments;
            return MockReflectedInstance(instance.format(args[0] as String,
                level: namedArgs[#level] as int?));
          }, [
            MockParameter('message', String, true, false),
            MockParameter('level', int, false, true)
          ]);
        case 'setup':
          return MockMethod('setup', (invocation) {
            var args = invocation.positionalArguments;
            instance.setup(args[0] as Config, args[1] as String);
            return MockReflectedInstance(null);
          }, [
            MockParameter('config', Config, true, false),
            MockParameter('name', String, true, false)
          ]);
      }
    }
    return null;
  }
}

class MockMethod implements ReflectedFunction {
  final String methodName;
  final ReflectedInstance Function(Invocation) handler;
  final List<ReflectedParameter> methodParameters;

  MockMethod(this.methodName, this.handler, this.methodParameters);

  @override
  List<ReflectedInstance> get annotations => [];

  @override
  bool get isGetter => false;

  @override
  bool get isSetter => false;

  @override
  String get name => methodName;

  @override
  List<ReflectedParameter> get parameters => methodParameters;

  @override
  ReflectedType? get returnType => null;

  @override
  List<ReflectedTypeParameter> get typeParameters => [];

  @override
  ReflectedInstance invoke(Invocation invocation) => handler(invocation);
}

class MockParameter implements ReflectedParameter {
  @override
  final String name;
  @override
  final bool isRequired;
  @override
  final bool isNamed;
  final Type paramType;

  MockParameter(this.name, this.paramType, this.isRequired, this.isNamed);

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
    container.registerSingleton(Logger());
    container.registerSingleton(Config('test'));
  });

  group('Parameter Dependency Injection', () {
    test('can inject dependencies into method parameters', () {
      expect(() => container.call('Logger@configure'), returnsNormally);
    });

    test('uses provided parameters over container bindings', () {
      var prodConfig = Config('production');
      container.call('Logger@configure', [prodConfig]);
    });

    test('throws when required parameter is missing', () {
      expect(() => container.call('Logger@setup', [Config('test')]),
          throwsA(isA<BindingResolutionException>()));
    });

    test('handles mix of injected and provided parameters', () {
      // When null is provided for a parameter that can be resolved from container,
      // the container should resolve it
      container.call('Logger@setup', [null, 'test-logger']);
    });

    test('handles optional parameters', () {
      var result = container.call('Logger@format', ['test message']);
      expect(result, equals('test message (level: null)'));
    });

    test('handles optional parameters with provided values', () {
      var result =
          container.call('Logger@format', ['test message'], {#level: 1});
      expect(result, equals('test message (level: 1)'));
    });
  });
}
