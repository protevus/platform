import 'package:platformed_container/container.dart';
import 'package:test/test.dart';
import 'common.dart';

// Test interfaces and implementations
abstract class Repository {
  String getName();
}

class UserRepository implements Repository {
  @override
  String getName() => 'users';
}

class ProductRepository implements Repository {
  @override
  String getName() => 'products';
}

class OrderRepository implements Repository {
  @override
  String getName() => 'orders';
}

void main() {
  late Container container;

  setUp(() {
    container = Container(MockReflector());
  });

  group('Tag Tests', () {
    test('can tag and resolve multiple bindings', () {
      container.registerSingleton<Repository>(UserRepository(),
          as: UserRepository);
      container.registerSingleton<Repository>(ProductRepository(),
          as: ProductRepository);
      container.registerSingleton<Repository>(OrderRepository(),
          as: OrderRepository);

      container.tag([UserRepository, ProductRepository], 'basic');
      container.tag([OrderRepository], 'advanced');
      container.tag([UserRepository, OrderRepository], 'critical');

      var basicRepos = container.tagged('basic');
      expect(basicRepos, hasLength(2));
      expect(basicRepos.map((r) => r.getName()),
          containsAll(['users', 'products']));

      var advancedRepos = container.tagged('advanced');
      expect(advancedRepos, hasLength(1));
      expect(advancedRepos.first.getName(), equals('orders'));

      var criticalRepos = container.tagged('critical');
      expect(criticalRepos, hasLength(2));
      expect(criticalRepos.map((r) => r.getName()),
          containsAll(['users', 'orders']));
    });

    test('can tag same binding with multiple tags', () {
      container.registerSingleton<Repository>(UserRepository(),
          as: UserRepository);

      container.tag([UserRepository], 'tag1');
      container.tag([UserRepository], 'tag2');

      expect(container.tagged('tag1'), hasLength(1));
      expect(container.tagged('tag2'), hasLength(1));
      expect(container.tagged('tag1').first, isA<UserRepository>());
      expect(container.tagged('tag2').first, isA<UserRepository>());
    });

    test('returns empty list for unknown tag', () {
      var repos = container.tagged('nonexistent');
      expect(repos, isEmpty);
    });

    test('child container inherits parent tags', () {
      container.registerSingleton<Repository>(UserRepository(),
          as: UserRepository);
      container.registerSingleton<Repository>(ProductRepository(),
          as: ProductRepository);
      container.tag([UserRepository, ProductRepository], 'basic');

      var childContainer = container.createChild();
      var basicRepos = childContainer.tagged('basic');
      expect(basicRepos, hasLength(2));
      expect(basicRepos.map((r) => r.getName()),
          containsAll(['users', 'products']));
    });

    test('child container can add new tags', () {
      container.registerSingleton<Repository>(UserRepository(),
          as: UserRepository);
      container.tag([UserRepository], 'parent-tag');

      var childContainer = container.createChild();
      childContainer.registerSingleton<Repository>(ProductRepository(),
          as: ProductRepository);
      childContainer.tag([ProductRepository], 'child-tag');

      expect(childContainer.tagged('parent-tag'), hasLength(1));
      expect(childContainer.tagged('child-tag'), hasLength(1));
      expect(childContainer.tagged('parent-tag').first, isA<UserRepository>());
      expect(
          childContainer.tagged('child-tag').first, isA<ProductRepository>());
    });

    test('child container can extend parent tags', () {
      container.registerSingleton<Repository>(UserRepository(),
          as: UserRepository);
      container.tag([UserRepository], 'repositories');

      var childContainer = container.createChild();
      childContainer.registerSingleton<Repository>(ProductRepository(),
          as: ProductRepository);
      childContainer.tag([ProductRepository], 'repositories');

      var repos = childContainer.tagged('repositories');
      expect(repos, hasLength(2));
      expect(repos.map((r) => r.getName()), containsAll(['users', 'products']));
    });
  });
}

// Minimal mock reflector for tag tests
class MockReflector extends Reflector {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClass? reflectClass(Type clazz) => null;

  @override
  ReflectedType? reflectType(Type type) {
    if (type == UserRepository ||
        type == ProductRepository ||
        type == OrderRepository) {
      return MockReflectedClass(
        type.toString(),
        [],
        [],
        [MockConstructor([])],
        [],
        type,
        (name, positional, named, typeArgs) => _createInstance(type),
      );
    }
    return null;
  }

  dynamic _createInstance(Type type) {
    if (type == UserRepository) return UserRepository();
    if (type == ProductRepository) return ProductRepository();
    if (type == OrderRepository) return OrderRepository();
    throw StateError('Unknown type: $type');
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
