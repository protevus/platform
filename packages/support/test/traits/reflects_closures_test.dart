import 'package:test/test.dart';
import 'package:platform_reflection/reflection.dart';
import 'package:platform_support/src/traits/reflects_closures.dart';

class TestClass with ReflectsClosures {}

typedef StringIntFunction = void Function(String, int);
typedef VoidFunction = void Function();
typedef AsyncVoidFunction = Future<void> Function();
typedef IntFunction = int Function();

void main() {
  late TestClass testClass;

  setUp(() {
    testClass = TestClass();

    // Register function types
    Reflector.register(StringIntFunction);
    Reflector.register(VoidFunction);
    Reflector.register(AsyncVoidFunction);
    Reflector.register(IntFunction);

    // Register method metadata for each function type
    Reflector.registerMethod(
      StringIntFunction,
      'call',
      [String, int],
      true,
      parameterNames: ['name', 'age'],
      isRequired: [true, true],
      isNamed: [false, false],
    );

    Reflector.registerMethod(
      VoidFunction,
      'call',
      [],
      true,
    );

    Reflector.registerMethod(
      AsyncVoidFunction,
      'call',
      [],
      true,
    );

    Reflector.registerMethod(
      IntFunction,
      'call',
      [],
      false,
    );
  });

  tearDown(() {
    Reflector.reset();
  });

  group('ReflectsClosures', () {
    test('getClosureParameterCount returns correct count', () {
      final closure = (String name, int age) {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [String, int],
        true,
        parameterNames: ['name', 'age'],
        isRequired: [true, true],
        isNamed: [false, false],
      );
      expect(testClass.getClosureParameterCount(closure), equals(2));
    });

    test('getClosureParameterCount returns 0 for no parameters', () {
      final closure = () {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        true,
      );
      expect(testClass.getClosureParameterCount(closure), equals(0));
    });

    test('getClosureParameterNames returns correct names', () {
      final closure = (String name, int age) {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [String, int],
        true,
        parameterNames: ['name', 'age'],
        isRequired: [true, true],
        isNamed: [false, false],
      );
      expect(
          testClass.getClosureParameterNames(closure), equals(['name', 'age']));
    });

    test('getClosureParameterNames returns empty list for no parameters', () {
      final closure = () {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        true,
      );
      expect(testClass.getClosureParameterNames(closure), isEmpty);
    });

    test('getClosureParameterTypes returns correct types', () {
      final closure = (String name, int age) {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [String, int],
        true,
        parameterNames: ['name', 'age'],
        isRequired: [true, true],
        isNamed: [false, false],
      );
      expect(
          testClass.getClosureParameterTypes(closure), equals([String, int]));
    });

    test('getClosureParameterTypes returns empty list for no parameters', () {
      final closure = () {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        true,
      );
      expect(testClass.getClosureParameterTypes(closure), isEmpty);
    });

    test('closureHasParameter returns true for existing parameter', () {
      final closure = (String name, int age) {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [String, int],
        true,
        parameterNames: ['name', 'age'],
        isRequired: [true, true],
        isNamed: [false, false],
      );
      expect(testClass.closureHasParameter(closure, 'name'), isTrue);
      expect(testClass.closureHasParameter(closure, 'age'), isTrue);
    });

    test('closureHasParameter returns false for non-existent parameter', () {
      final closure = (String name, int age) {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [String, int],
        true,
        parameterNames: ['name', 'age'],
        isRequired: [true, true],
        isNamed: [false, false],
      );
      expect(testClass.closureHasParameter(closure, 'email'), isFalse);
    });

    test('isClosureVoid returns true for void closure', () {
      final closure = () {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        true,
      );
      expect(testClass.isClosureVoid(closure), isTrue);
    });

    test('isClosureVoid returns false for non-void closure', () {
      final closure = () => 42;
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        false,
      );
      expect(testClass.isClosureVoid(closure), isFalse);
    });

    test('isClosureNullable returns true for nullable closure', () {
      final closure = () => null;
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        false,
      );
      expect(testClass.isClosureNullable(closure), isTrue);
    });

    test('isClosureNullable returns false for non-nullable closure', () {
      final closure = () {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        true,
      );
      expect(testClass.isClosureNullable(closure), isFalse);
    });

    test('isClosureAsync returns true for async closure', () {
      final closure = () async {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        true,
      );
      expect(testClass.isClosureAsync(closure), isTrue);
    });

    test('isClosureAsync returns false for sync closure', () {
      final closure = () {};
      Reflector.register(closure.runtimeType);
      Reflector.registerMethod(
        closure.runtimeType,
        'call',
        [],
        true,
      );
      expect(testClass.isClosureAsync(closure), isFalse);
    });
  });
}
