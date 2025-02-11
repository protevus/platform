import 'package:illuminate_container/container.dart';
import 'package:test/test.dart';

class Logger {
  String log(String message) => message;
  void debug(String message, {int? level}) {}
  int count(List<String> items) => items.length;
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
            if (args.isEmpty) {
              throw ArgumentError('Method log requires a message parameter');
            }
            return MockReflectedInstance(instance.log(args[0] as String));
          }, [MockParameter('message', String, true, false)]);
        case 'debug':
          return MockMethod('debug', (invocation) {
            var args = invocation.positionalArguments;
            if (args.isEmpty) {
              throw ArgumentError('Method debug requires a message parameter');
            }
            instance.debug(args[0] as String);
            return MockReflectedInstance(null);
          }, [
            MockParameter('message', String, true, false),
            MockParameter('level', int, false, true)
          ]);
        case 'count':
          return MockMethod('count', (invocation) {
            var args = invocation.positionalArguments;
            if (args.isEmpty) {
              throw ArgumentError('Method count requires a list parameter');
            }
            return MockReflectedInstance(
                instance.count(args[0] as List<String>));
          }, [MockParameter('items', List<String>, true, false)]);
      }
    }
    return null;
  }
}

class MockMethod implements ReflectedFunction {
  final String methodName;
  final ReflectedInstance Function(Invocation) handler;
  final List<ReflectedParameter> _parameters;

  MockMethod(this.methodName, this.handler,
      [List<ReflectedParameter>? parameters])
      : _parameters = parameters ?? [];

  @override
  List<ReflectedInstance> get annotations => [];

  @override
  bool get isGetter => false;

  @override
  bool get isSetter => false;

  @override
  String get name => methodName;

  @override
  List<ReflectedParameter> get parameters => _parameters;

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
  @override
  final bool isVariadic;
  final Type paramType;

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

  @override
  void setField(String name, dynamic value) {
    // No-op for mock
  }
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
    container.registerSingleton(Logger());
  });

  group('Class@method syntax', () {
    test('can call method with return value', () {
      var result = container.call('Logger@log', ['Hello world']);
      expect(result, equals('Hello world'));
    });

    test('can call void method', () {
      expect(() => container.call('Logger@debug', ['Debug message']),
          returnsNormally);
    });

    test('can call method with list parameter', () {
      var result = container.call('Logger@count', [
        ['one', 'two', 'three']
      ]);
      expect(result, equals(3));
    });

    test('throws on invalid syntax', () {
      expect(() => container.call('Logger'), throwsArgumentError);
      expect(() => container.call('Logger@'), throwsArgumentError);
      expect(() => container.call('@log'), throwsArgumentError);
    });

    test('throws on unknown class', () {
      expect(() => container.call('Unknown@method'), throwsArgumentError);
    });

    test('throws on unknown method', () {
      expect(() => container.call('Logger@unknown'), throwsArgumentError);
    });
  });
}
