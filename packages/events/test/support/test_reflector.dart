import 'package:illuminate_container/container.dart';

/// A test reflector that doesn't rely on dart:mirrors.
class TestReflector implements Reflector {
  /// Map of registered types.
  final Map<String, Type> _types = {};

  /// Map of class instances.
  final Map<Type, Object Function()> _factories = {};

  /// Map of singleton instances.
  final Map<Type, Object> _instances = {};

  TestReflector() {
    // Pre-register TestSubscriber
    registerClass(TestSubscriber, () => TestSubscriber([]));
  }

  /// Register a class with the reflector.
  void registerClass(Type type, Object Function() factory) {
    _types[type.toString()] = type;
    _factories[type] = factory;
  }

  /// Register a singleton instance
  void registerInstance(Type type, Object instance) {
    _instances[type] = instance;
  }

  @override
  Type? findTypeByName(String name) {
    return _types[name];
  }

  dynamic createInstance(Type type, [List<dynamic>? args]) {
    // Return singleton instance if registered
    if (_instances.containsKey(type)) {
      return _instances[type];
    }
    // Otherwise create new instance
    final factory = _factories[type];
    if (factory != null) {
      return factory();
    }
    return null;
  }

  @override
  ReflectedFunction? findInstanceMethod(Object instance, String name) {
    // For test purposes, we only need to handle the types used in tests
    if (instance is TestSubscriber) {
      switch (name) {
        case 'handleOne':
          return TestReflectedFunction(
            'handleOne',
            [],
            [],
            [
              TestReflectedParameter(
                  'data', [], TestReflectedType('List', [], List))
            ],
            false,
            false,
            returnType: TestReflectedType('void', [], Null),
            instance: instance,
            implementation: (args) => instance.handleOne(args[0] as List),
          );
        case 'handleTwo':
          return TestReflectedFunction(
            'handleTwo',
            [],
            [],
            [
              TestReflectedParameter(
                  'data', [], TestReflectedType('List', [], List))
            ],
            false,
            false,
            returnType: TestReflectedType('void', [], Null),
            instance: instance,
            implementation: (args) => instance.handleTwo(args[0] as List),
          );
      }
    }
    return null;
  }

  @override
  List<ReflectedInstance> getAnnotations(Type type) {
    // Not used in tests
    return [];
  }

  @override
  String? getName(Symbol symbol) {
    return symbol.toString().replaceAll('"', '');
  }

  @override
  List<ReflectedInstance> getParameterAnnotations(
      Type type, String constructorName, String parameterName) {
    // Not used in tests
    return [];
  }

  List<Type> getParameterTypes(Function function) {
    // Not used in tests
    return [];
  }

  Type? getReturnType(Function function) {
    // Not used in tests
    return null;
  }

  bool hasDefaultConstructor(Type type) {
    return _factories.containsKey(type) || _instances.containsKey(type);
  }

  bool isClass(Type type) {
    return _factories.containsKey(type) || _instances.containsKey(type);
  }

  @override
  ReflectedClass? reflectClass(Type type) {
    // For test purposes, we only need to handle the types used in tests
    if (type == TestSubscriber) {
      return TestReflectedClass(
        'TestSubscriber',
        [],
        [],
        [
          TestReflectedFunction(
            '',
            [],
            [],
            [
              TestReflectedParameter(
                  'calls', [], TestReflectedType('List<String>', [], List))
            ],
            false,
            false,
            returnType: TestReflectedType('void', [], Null),
          )
        ],
        [
          TestReflectedDeclaration('handleOne', false, null),
          TestReflectedDeclaration('handleTwo', false, null),
        ],
        type,
      );
    }
    return null;
  }

  @override
  ReflectedFunction? reflectFunction(Function function) {
    // Not used in tests
    return null;
  }

  @override
  ReflectedType reflectFutureOf(Type type) {
    // Not used in tests
    throw UnsupportedError('reflectFutureOf not supported in tests');
  }

  @override
  ReflectedInstance? reflectInstance(Object instance) {
    // For test purposes, we only need to handle the types used in tests
    if (instance is TestSubscriber) {
      var type = TestReflectedType('TestSubscriber', [], instance.runtimeType);
      var clazz = TestReflectedClass(
        'TestSubscriber',
        [],
        [],
        [
          TestReflectedFunction(
            '',
            [],
            [],
            [
              TestReflectedParameter(
                  'calls', [], TestReflectedType('List<String>', [], List))
            ],
            false,
            false,
            returnType: TestReflectedType('void', [], Null),
          )
        ],
        [
          TestReflectedDeclaration('handleOne', false, null),
          TestReflectedDeclaration('handleTwo', false, null),
        ],
        instance.runtimeType,
      );
      return TestReflectedInstance(type, clazz, instance);
    }
    return null;
  }

  @override
  ReflectedType? reflectType(Type type) {
    // For test purposes, we only need to handle the types used in tests
    if (type == TestSubscriber) {
      return TestReflectedType('TestSubscriber', [], type);
    }
    return null;
  }
}

/// Test subscriber class used in tests.
class TestSubscriber {
  final List<String> calls;

  TestSubscriber(this.calls);

  Map<String, dynamic> subscribe(dynamic events) {
    return {
      'event.one': 'handleOne',
      'event.two': 'handleTwo',
    };
  }

  void handleOne(List<dynamic> data) => calls.add('one');
  void handleTwo(List<dynamic> data) => calls.add('two');
}

/// Test implementation of ReflectedType.
class TestReflectedType implements ReflectedType {
  @override
  final String name;
  @override
  final List<ReflectedTypeParameter> typeParameters;
  @override
  final Type reflectedType;

  TestReflectedType(this.name, this.typeParameters, this.reflectedType);

  @override
  bool isAssignableTo(ReflectedType? other) => true;

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    throw UnsupportedError('newInstance not supported in tests');
  }
}

/// Test implementation of ReflectedClass.
class TestReflectedClass extends TestReflectedType implements ReflectedClass {
  @override
  final List<ReflectedInstance> annotations;
  @override
  final List<ReflectedFunction> constructors;
  @override
  final List<ReflectedDeclaration> declarations;

  TestReflectedClass(
    String name,
    List<ReflectedTypeParameter> typeParameters,
    this.annotations,
    this.constructors,
    this.declarations,
    Type reflectedType,
  ) : super(name, typeParameters, reflectedType);
}

/// Test implementation of ReflectedInstance.
class TestReflectedInstance implements ReflectedInstance {
  @override
  final ReflectedType type;
  @override
  final ReflectedClass clazz;
  @override
  final Object reflectee;

  TestReflectedInstance(this.type, this.clazz, this.reflectee);

  @override
  ReflectedInstance getField(String name) {
    throw UnsupportedError('getField not supported in tests');
  }

  dynamic invoke(String name,
      [List<dynamic>? positionalArguments,
      Map<Symbol, dynamic>? namedArguments]) {
    if (reflectee is TestSubscriber) {
      switch (name) {
        case 'handleOne':
          return (reflectee as TestSubscriber)
              .handleOne(positionalArguments ?? []);
        case 'handleTwo':
          return (reflectee as TestSubscriber)
              .handleTwo(positionalArguments ?? []);
      }
    }
    return null;
  }

  @override
  void setField(String name, value) {
    // TODO: implement setField
  }
}

/// Test implementation of ReflectedFunction.
class TestReflectedFunction implements ReflectedFunction {
  @override
  final String name;
  @override
  final List<ReflectedTypeParameter> typeParameters;
  @override
  final List<ReflectedInstance> annotations;
  @override
  final List<ReflectedParameter> parameters;
  @override
  final bool isGetter;
  @override
  final bool isSetter;
  @override
  final ReflectedType? returnType;
  final Object? instance;
  final Function(List<dynamic>)? implementation;

  TestReflectedFunction(this.name, this.typeParameters, this.annotations,
      this.parameters, this.isGetter, this.isSetter,
      {this.returnType, this.instance, this.implementation});

  @override
  ReflectedInstance invoke(Invocation invocation) {
    if (implementation != null) {
      implementation!(invocation.positionalArguments);
      return TestReflectedInstance(
        returnType!,
        TestReflectedClass('void', [], [], [], [], Null),
        0,
      );
    }
    throw UnsupportedError('invoke not supported for this method');
  }
}

/// Test implementation of ReflectedParameter.
class TestReflectedParameter implements ReflectedParameter {
  @override
  final String name;
  @override
  final List<ReflectedInstance> annotations;
  @override
  final ReflectedType type;
  @override
  final bool isRequired;
  @override
  final bool isNamed;
  @override
  final bool isVariadic;

  TestReflectedParameter(this.name, this.annotations, this.type,
      {this.isRequired = true, this.isNamed = false, this.isVariadic = false});
}

/// Test implementation of ReflectedDeclaration.
class TestReflectedDeclaration implements ReflectedDeclaration {
  @override
  final String name;
  @override
  final bool isStatic;
  @override
  final ReflectedFunction? function;

  TestReflectedDeclaration(this.name, this.isStatic, this.function);
}

/// Test implementation of ReflectedTypeParameter.
class TestReflectedTypeParameter implements ReflectedTypeParameter {
  @override
  final String name;

  final List<ReflectedInstance> annotations;

  final ReflectedType? bound;

  TestReflectedTypeParameter(this.name, this.annotations, this.bound);
}
