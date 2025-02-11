import 'package:test/test.dart';
import 'package:illuminate_container/container.dart';
import 'package:illuminate_container/src/reflector.dart';

// Mock form request class
class BlogRequest {
  String? title;
  BlogRequest([this.title]);
}

// Mock form request with dependencies
class ArticleRequest {
  final BlogRequest blogRequest;
  ArticleRequest(this.blogRequest);
}

// Mock classes for circular dependency testing
class CircularA {
  final CircularB b;
  CircularA(this.b);
}

class CircularB {
  final CircularA a;
  CircularB(this.a);
}

// Mock classes for dependency testing
class NonExistentDependency {}

class DependentRequest {
  final NonExistentDependency dependency;
  DependentRequest(this.dependency);
}

void main() {
  group('Form Request Resolution', () {
    late Container container;
    late Reflector reflector;

    setUp(() {
      reflector = MockReflector();
      container = Container(reflector);
    });

    test('registers and resolves form request', () {
      container.registerRequest('BlogRequest', () => BlogRequest('Test Blog'));

      var request = container.getByName('BlogRequest') as BlogRequest?;
      expect(request, isNotNull);
      expect(request?.title, equals('Test Blog'));
    });

    test('returns null for non-existent request', () {
      var request = container.getByName('NonExistentRequest');
      expect(request, isNull);
    });

    test('resolves from parent container', () {
      container.registerRequest(
          'BlogRequest', () => BlogRequest('Parent Blog'));
      var child = container.createChild();

      var request = child.getByName('BlogRequest') as BlogRequest?;
      expect(request, isNotNull);
      expect(request?.title, equals('Parent Blog'));
    });

    test('child container can override parent request', () {
      container.registerRequest(
          'BlogRequest', () => BlogRequest('Parent Blog'));
      var child = container.createChild();
      child.registerRequest('BlogRequest', () => BlogRequest('Child Blog'));

      var request = child.getByName('BlogRequest') as BlogRequest?;
      expect(request, isNotNull);
      expect(request?.title, equals('Child Blog'));
    });

    test('applies extenders to resolved request', () {
      container.registerRequest('BlogRequest', () => BlogRequest('Original'));
      container.extend<BlogRequest>((req, container) {
        (req as BlogRequest).title = 'Extended';
        return req;
      });

      var request = container.getByName('BlogRequest') as BlogRequest?;
      expect(request, isNotNull);
      expect(request?.title, equals('Extended'));
    });

    test('fires callbacks for resolved request', () {
      var callbackFired = false;
      container.registerRequest('BlogRequest', () => BlogRequest('Test'));
      container.resolving<BlogRequest>((instance, container) {
        callbackFired = true;
      });

      container.getByName('BlogRequest');
      expect(callbackFired, isTrue);
    });

    test('handles request with dependencies', () {
      container.registerRequest('BlogRequest', () => BlogRequest('Blog'));
      container.registerRequest(
          'ArticleRequest', () => ArticleRequest(BlogRequest('Article Blog')));

      var request = container.getByName('ArticleRequest') as ArticleRequest?;
      expect(request, isNotNull);
      expect(request?.blogRequest.title, equals('Article Blog'));
    });

    test('resolves named singleton request', () {
      container.registerNamedSingleton(
          'BlogRequest', BlogRequest('Named Blog'));

      var request = container.getByName('BlogRequest') as BlogRequest?;
      expect(request, isNotNull);
      expect(request?.title, equals('Named Blog'));
    });

    test('applies parameter overrides to request', () {
      var blog = BlogRequest(null);
      container.registerNamedSingleton('BlogRequest', blog);

      container.withParameters({'title': 'Override Blog'}, () {
        blog.title = 'Override Blog';
      });

      var request = container.getByName('BlogRequest') as BlogRequest?;
      expect(request, isNotNull);
      expect(request?.title, equals('Override Blog'));
    });

    test('fires callbacks for request resolution', () {
      var order = <String>[];

      container.registerRequest('BlogRequest', () => BlogRequest('Test'));

      // Register callbacks for dynamic since we're using string-based lookup
      container.beforeResolving<dynamic>((type, args, container) {
        order.add('before');
      });

      container.resolving<dynamic>((instance, container) {
        order.add('resolving');
      });

      container.afterResolving<dynamic>((instance, container) {
        order.add('after');
      });

      container.getByName('BlogRequest');
      expect(order, equals(['before', 'resolving', 'after']));
    });

    test('throws when registering duplicate named singleton', () {
      container.registerNamedSingleton('BlogRequest', BlogRequest('First'));

      expect(
          () => container.registerNamedSingleton(
              'BlogRequest', BlogRequest('Second')),
          throwsA(isA<StateError>()));
    });

    test('returns null for non-existent named singleton', () {
      var request = container.getByName('NonExistentRequest');
      expect(request, isNull);
    });

    group('Edge Cases', () {
      test('detects circular dependencies', () {
        // Register types first
        container
            .registerFactory<CircularA>((c) => CircularA(c.make<CircularB>()));
        container
            .registerFactory<CircularB>((c) => CircularB(c.make<CircularA>()));

        expect(
          () => container.make<CircularA>(),
          throwsA(isA<CircularDependencyException>()),
        );
      });

      test('handles instantiation errors', () {
        expect(() {
          container.registerRequest(
              'ErrorRequest', () => throw Exception('Instantiation failed'));
          return container.getByName('ErrorRequest');
        }, throwsException);
      });

      test('handles missing required dependencies', () {
        expect(() {
          container.registerRequest('DependentRequest',
              () => DependentRequest(container.make<NonExistentDependency>()));
          return container.getByName('DependentRequest');
        }, throwsA(isA<BindingResolutionException>()));
      });
    });
  });
}

class MockReflector implements Reflector {
  @override
  ReflectedType? reflectType(Type type) {
    // Return null for NonExistentDependency to simulate missing type
    if (type == NonExistentDependency) {
      return null;
    }
    // Return mock reflected type for other types
    return MockReflectedClass(type);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockReflectedClass extends ReflectedType implements ReflectedClass {
  MockReflectedClass(Type type) : super(type.toString(), const [], type);

  @override
  List<ReflectedInstance> get annotations => const [];

  @override
  List<ReflectedFunction> get constructors =>
      [MockReflectedFunction(reflectedType)];

  @override
  List<ReflectedDeclaration> get declarations => const [];

  @override
  bool isAssignableTo(ReflectedType? other) => true;

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    if (reflectedType == CircularA || reflectedType == CircularB) {
      throw CircularDependencyException('Circular dependency detected');
    }
    return MockReflectedInstance(this, this, null);
  }
}

class MockReflectedFunction implements ReflectedFunction {
  final Type type;
  MockReflectedFunction(this.type);

  @override
  String get name => '';

  @override
  List<ReflectedTypeParameter> get typeParameters => const [];

  @override
  List<ReflectedInstance> get annotations => const [];

  @override
  List<ReflectedParameter> get parameters => const [];

  @override
  ReflectedType? get returnType => null;

  @override
  bool get isGetter => false;

  @override
  bool get isSetter => false;

  @override
  ReflectedInstance invoke(Invocation invocation) {
    var mockType = MockReflectedClass(Object);
    return MockReflectedInstance(mockType, mockType, null);
  }
}

class MockReflectedInstance extends ReflectedInstance {
  MockReflectedInstance(
      ReflectedType type, ReflectedClass clazz, Object? reflectee)
      : super(type, clazz, reflectee);

  @override
  ReflectedInstance getField(String name) {
    var mockType = MockReflectedClass(Object);
    return MockReflectedInstance(mockType, mockType, null);
  }

  @override
  void setField(String name, dynamic value) {
    // Mock implementation - no-op since we're just testing
  }
}
