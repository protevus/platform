import 'package:platform_macroable/macroable.dart';
import 'package:test/test.dart';

class TestClass with Macroable {
  String regularMethod() => 'regular method';
}

class TestMixin {
  String mixinMethod() => 'mixin method';
}

void main() {
  group('Macroable', () {
    late TestClass instance;

    setUp(() {
      instance = TestClass();
    });

    tearDown(() {
      Macroable.flushMacros(TestClass);
    });

    test('regular methods work', () {
      expect(instance.regularMethod(), equals('regular method'));
    });

    test('can add and call macro methods', () {
      Macroable.macro(TestClass, 'macroMethod', () => 'macro method');
      expect((instance as dynamic).macroMethod(), equals('macro method'));
    });

    test('can check if macro exists', () {
      Macroable.macro(TestClass, 'existingMacro', () => 'exists');
      expect(Macroable.hasMacro(TestClass, 'existingMacro'), isTrue);
      expect(Macroable.hasMacro(TestClass, 'nonExistingMacro'), isFalse);
    });

    test('can mix in methods from other classes', () {
      Macroable.mixin(TestClass, TestMixin());
      expect((instance as dynamic).mixinMethod(), equals('mixin method'));
    });

    test('can flush macros', () {
      Macroable.macro(TestClass, 'flushMe', () => 'flush me');
      expect(Macroable.hasMacro(TestClass, 'flushMe'), isTrue);
      Macroable.flushMacros(TestClass);
      expect(Macroable.hasMacro(TestClass, 'flushMe'), isFalse);
    });

    test('throws NoSuchMethodError for non-existent methods', () {
      expect(() => (instance as dynamic).nonExistentMethod(),
          throwsNoSuchMethodError);
    });

    test('can add macros with parameters', () {
      Macroable.macro(
          TestClass, 'paramMacro', (String param) => 'Hello, $param!');
      expect(
          (instance as dynamic).paramMacro('World'), equals('Hello, World!'));
    });

    test('can override existing macros', () {
      Macroable.macro(TestClass, 'overrideMacro', () => 'original');
      Macroable.macro(TestClass, 'overrideMacro', () => 'overridden');
      expect((instance as dynamic).overrideMacro(), equals('overridden'));
    });
  });
}
