import 'package:illuminate_container/container.dart';
import 'package:test/test.dart';

class InvokableClass {
  String call(String message) => 'Invoked with: $message';
  String invoke(String message) => 'Called invoke with: $message';
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
    if (name == 'InvokableClass') return InvokableClass;
    return null;
  }

  @override
  ReflectedFunction? findInstanceMethod(Object instance, String methodName) {
    if (instance is InvokableClass) {
      switch (methodName) {
        case '__invoke':
        case 'call':
          return MockMethod('call', (invocation) {
            var args = invocation.positionalArguments;
            if (args.isEmpty) {
              throw ArgumentError('Method call requires a message parameter');
            }
            return MockReflectedInstance(instance.call(args[0] as String));
          }, [MockParameter('message', String, true, false)]);
        case 'invoke':
          return MockMethod('invoke', (invocation) {
            var args = invocation.positionalArguments;
            if (args.isEmpty) {
              throw ArgumentError('Method invoke requires a message parameter');
            }
            return MockReflectedInstance(instance.invoke(args[0] as String));
          }, [MockParameter('message', String, true, false)]);
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

  @override
  void setField(String name, dynamic value) {
    // No-op for mock
  }
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
    container.registerSingleton(InvokableClass());
  });

  group('Invoke Tests', () {
    test('can call __invoke method', () {
      var result = container.call('InvokableClass@__invoke', ['Hello world']);
      expect(result, equals('Invoked with: Hello world'));
    });

    test('__invoke is alias for call method', () {
      var invokeResult = container.call('InvokableClass@__invoke', ['Test']);
      var callResult = container.call('InvokableClass@call', ['Test']);
      expect(invokeResult, equals(callResult));
    });

    test('can still call other methods', () {
      var result = container.call('InvokableClass@invoke', ['Hello world']);
      expect(result, equals('Called invoke with: Hello world'));
    });

    test('throws when required parameter is missing', () {
      expect(() => container.call('InvokableClass@__invoke'),
          throwsA(isA<BindingResolutionException>()));
    });
  });
}
