import 'package:platformed_container/container.dart';
import 'package:test/test.dart';
import 'common.dart';

class RequestScope {
  final String id;
  RequestScope(this.id);
}

class UserService {
  final RequestScope scope;
  UserService(this.scope);
}

class OrderService {
  final RequestScope scope;
  OrderService(this.scope);
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Scoped Instance Tests', () {
    test('scoped instances are shared within scope', () {
      container.scoped<RequestScope>((c) => RequestScope('request-1'));
      container.registerFactory<UserService>(
          (c) => UserService(c.make<RequestScope>()));
      container.registerFactory<OrderService>(
          (c) => OrderService(c.make<RequestScope>()));

      var userService = container.make<UserService>();
      var orderService = container.make<OrderService>();

      expect(userService.scope, same(orderService.scope));
      expect(userService.scope.id, equals('request-1'));
    });

    test('scoped instances are cleared after clearScoped', () {
      container.scoped<RequestScope>((c) => RequestScope('request-1'));
      var scope1 = container.make<RequestScope>();

      container.clearScoped();
      container.scoped<RequestScope>((c) => RequestScope('request-2'));
      var scope2 = container.make<RequestScope>();

      expect(scope1.id, equals('request-1'));
      expect(scope2.id, equals('request-2'));
      expect(scope1, isNot(same(scope2)));
    });

    test('child container inherits parent scoped instances', () {
      container.scoped<RequestScope>((c) => RequestScope('request-1'));
      var childContainer = container.createChild();

      var parentScope = container.make<RequestScope>();
      var childScope = childContainer.make<RequestScope>();

      expect(parentScope, same(childScope));
    });

    test('child container can override parent scoped instances', () {
      container.scoped<RequestScope>((c) => RequestScope('parent-request'));
      var childContainer = container.createChild();
      childContainer.scoped<RequestScope>((c) => RequestScope('child-request'));

      var parentScope = container.make<RequestScope>();
      var childScope = childContainer.make<RequestScope>();

      expect(parentScope.id, equals('parent-request'));
      expect(childScope.id, equals('child-request'));
      expect(parentScope, isNot(same(childScope)));
    });

    test('clearing parent scoped instances affects child containers', () {
      container.scoped<RequestScope>((c) => RequestScope('request-1'));
      var childContainer = container.createChild();

      var beforeClear = childContainer.make<RequestScope>();
      container.clearScoped();
      container.scoped<RequestScope>((c) => RequestScope('request-2'));
      var afterClear = childContainer.make<RequestScope>();

      expect(beforeClear.id, equals('request-1'));
      expect(afterClear.id, equals('request-2'));
      expect(beforeClear, isNot(same(afterClear)));
    });
  });

  group('Resolution Lifecycle Tests', () {
    test('before resolving callbacks are called', () {
      var callLog = <String>[];
      container.beforeResolving<RequestScope>((type, args, container) {
        callLog.add('before:${type.toString()}');
      });

      container.registerSingleton(RequestScope('test'));
      container.make<RequestScope>();

      expect(callLog, contains('before:RequestScope'));
    });

    test('resolving callbacks are called', () {
      var callLog = <String>[];
      container.resolving<RequestScope>((instance, container) {
        callLog.add('resolving:${(instance as RequestScope).id}');
      });

      container.registerSingleton(RequestScope('test'));
      container.make<RequestScope>();

      expect(callLog, contains('resolving:test'));
    });

    test('after resolving callbacks are called', () {
      var callLog = <String>[];
      container.afterResolving<RequestScope>((instance, container) {
        callLog.add('after:${(instance as RequestScope).id}');
      });

      container.registerSingleton(RequestScope('test'));
      container.make<RequestScope>();

      expect(callLog, contains('after:test'));
    });

    test('callbacks are called in correct order', () {
      var callOrder = <String>[];

      container.beforeResolving<RequestScope>((type, args, container) {
        callOrder.add('before');
      });

      container.resolving<RequestScope>((instance, container) {
        callOrder.add('resolving');
      });

      container.afterResolving<RequestScope>((instance, container) {
        callOrder.add('after');
      });

      container.registerSingleton(RequestScope('test'));
      container.make<RequestScope>();

      expect(callOrder, orderedEquals(['before', 'resolving', 'after']));
    });

    test('child container inherits parent callbacks', () {
      var callLog = <String>[];
      container.beforeResolving<RequestScope>((type, args, container) {
        callLog.add('parent-before');
      });

      var childContainer = container.createChild();
      childContainer.registerSingleton(RequestScope('test'));
      childContainer.make<RequestScope>();

      expect(callLog, contains('parent-before'));
    });

    test('child container can add its own callbacks', () {
      var callLog = <String>[];

      container.beforeResolving<RequestScope>((type, args, container) {
        callLog.add('parent-before');
      });

      var childContainer = container.createChild();
      childContainer.beforeResolving<RequestScope>((type, args, container) {
        callLog.add('child-before');
      });

      childContainer.registerSingleton(RequestScope('test'));
      childContainer.make<RequestScope>();

      expect(callLog, containsAll(['parent-before', 'child-before']));
    });
  });
}

// Minimal mock reflector for scoped and lifecycle tests
class MockReflector extends Reflector {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClass? reflectClass(Type clazz) => null;

  @override
  ReflectedType? reflectType(Type type) {
    if (type == RequestScope) {
      return MockReflectedClass(
        'RequestScope',
        [],
        [],
        [
          MockConstructor([MockParameter('id', String)])
        ],
        [],
        type,
        (name, positional, named, typeArgs) => RequestScope(positional[0]),
      );
    } else if (type == UserService) {
      return MockReflectedClass(
        'UserService',
        [],
        [],
        [
          MockConstructor([MockParameter('scope', RequestScope)])
        ],
        [],
        type,
        (name, positional, named, typeArgs) => UserService(positional[0]),
      );
    } else if (type == OrderService) {
      return MockReflectedClass(
        'OrderService',
        [],
        [],
        [
          MockConstructor([MockParameter('scope', RequestScope)])
        ],
        [],
        type,
        (name, positional, named, typeArgs) => OrderService(positional[0]),
      );
    }
    return null;
  }

  @override
  ReflectedInstance? reflectInstance(Object? instance) => null;

  @override
  ReflectedFunction? reflectFunction(Function function) => null;

  @override
  ReflectedType reflectFutureOf(Type type) => throw UnimplementedError();
}

class MockReflectedClass extends ReflectedClass {
  final Function instanceBuilder;

  MockReflectedClass(
    String name,
    List<ReflectedTypeParameter> typeParameters,
    List<ReflectedInstance> annotations,
    List<ReflectedFunction> constructors,
    List<ReflectedDeclaration> declarations,
    Type reflectedType,
    this.instanceBuilder,
  ) : super(name, typeParameters, annotations, constructors, declarations,
            reflectedType);

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    var instance = instanceBuilder(
        constructorName, positionalArguments, namedArguments, typeArguments);
    return MockReflectedInstance(this, instance);
  }

  @override
  bool isAssignableTo(ReflectedType? other) {
    if (other == null) return false;
    return reflectedType == other.reflectedType;
  }
}

class MockReflectedInstance extends ReflectedInstance {
  MockReflectedInstance(ReflectedClass clazz, Object? reflectee)
      : super(clazz, clazz, reflectee);

  @override
  ReflectedInstance getField(String name) {
    throw UnimplementedError();
  }
}

class MockConstructor extends ReflectedFunction {
  final List<ReflectedParameter> params;

  MockConstructor(this.params)
      : super('', [], [], params, false, false,
            returnType: MockReflectedType('void', [], dynamic));

  @override
  ReflectedInstance invoke(Invocation invocation) {
    throw UnimplementedError();
  }
}

class MockParameter extends ReflectedParameter {
  MockParameter(String name, Type type)
      : super(name, [], MockReflectedType(type.toString(), [], type), true,
            false);
}

class MockReflectedType extends ReflectedType {
  MockReflectedType(String name, List<ReflectedTypeParameter> typeParameters,
      Type reflectedType)
      : super(name, typeParameters, reflectedType);

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    throw UnimplementedError();
  }

  @override
  bool isAssignableTo(ReflectedType? other) {
    if (other == null) return false;
    return reflectedType == other.reflectedType;
  }
}
