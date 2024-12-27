import 'package:platformed_container/container.dart';
import 'package:test/test.dart';

class Logger {
  String log(String prefix, String message) => '$prefix: $message';
  String logMany(String prefix, List<String> messages) =>
      '$prefix: ${messages.join(", ")}';
  String format(String message, {List<String> tags = const []}) =>
      '$message [${tags.join(", ")}]';
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
            if (args.length < 2) {
              throw ArgumentError(
                  'Method log requires prefix and message parameters');
            }
            return MockReflectedInstance(
                instance.log(args[0] as String, args[1] as String));
          }, [
            MockParameter('prefix', String, true, false),
            MockParameter('message', String, true, false)
          ]);
        case 'logMany':
          return MockMethod('logMany', (invocation) {
            var args = invocation.positionalArguments;
            if (args.isEmpty) {
              throw ArgumentError('Method logMany requires a prefix parameter');
            }
            var prefix = args[0] as String;
            var messages = args.length > 1
                ? args.skip(1).map((e) => e.toString()).toList()
                : <String>[];
            return MockReflectedInstance(instance.logMany(prefix, messages));
          }, [
            MockParameter('prefix', String, true, false),
            MockParameter('messages', List<String>, true, false,
                isVariadic: true)
          ]);
        case 'format':
          return MockMethod('format', (invocation) {
            var args = invocation.positionalArguments;
            var namedArgs = invocation.namedArguments;
            if (args.isEmpty) {
              throw ArgumentError('Method format requires a message parameter');
            }
            var tags = (namedArgs[#tags] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const <String>[];
            return MockReflectedInstance(
                instance.format(args[0] as String, tags: tags));
          }, [
            MockParameter('message', String, true, false),
            MockParameter('tags', List<String>, false, true, isVariadic: true)
          ]);
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
    container.registerSingleton(Logger());
  });

  group('Variadic Parameter Tests', () {
    test('can call method with variadic positional parameters', () {
      var result = container.call('Logger@logMany',
          ['INFO', 'first message', 'second message', 'third message']);
      expect(result,
          equals('INFO: [first message, second message, third message]'));
    });

    test('can call method with variadic named parameters', () {
      var result = container.call('Logger@format', [
        'Hello world'
      ], {
        #tags: ['info', 'debug', 'test']
      });
      expect(result, equals('Hello world [info, debug, test]'));
    });

    test('variadic parameters are optional', () {
      var result = container.call('Logger@format', ['Hello world']);
      expect(result, equals('Hello world []'));
    });

    test('can mix regular and variadic parameters', () {
      var result =
          container.call('Logger@logMany', ['DEBUG', 'single message']);
      expect(result, equals('DEBUG: [single message]'));
    });
  });
}
