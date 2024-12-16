import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';
import 'package:platform_macroable/platform_macroable.dart';

@reflectable
class TestClass with Macroable {}

@reflectable
class MixinSource implements MacroProvider {
  String greet(String name) => 'Hello, $name!';
  int add(int a, int b) => a + b;

  @override
  Map<String, Function> getMethods() {
    return {
      'greet': greet,
      'add': add,
    };
  }
}

void main() {
  group('Macroable', () {
    late TestClass instance;

    setUp(() {
      instance = TestClass();
      Macroable.flushMacros<TestClass>();
    });

    test('can register and call a macro', () {
      Macroable.macro<TestClass>(
          'customMethod', (String arg) => 'Result: $arg');

      expect(
        (instance as dynamic).customMethod('test'),
        equals('Result: test'),
      );
    });

    test('can check if macro exists', () {
      Macroable.macro<TestClass>('existingMethod', () => 'exists');

      expect(Macroable.hasMacro<TestClass>('existingMethod'), isTrue);
      expect(Macroable.hasMacro<TestClass>('nonExistentMethod'), isFalse);
    });

    test('can flush macros', () {
      Macroable.macro<TestClass>('method1', () => 'one');
      Macroable.macro<TestClass>('method2', () => 'two');

      Macroable.flushMacros<TestClass>();

      expect(Macroable.hasMacro<TestClass>('method1'), isFalse);
      expect(Macroable.hasMacro<TestClass>('method2'), isFalse);
    });

    test('can mix in methods from another object', () {
      final source = MixinSource();
      Macroable.mixin<TestClass>(source);

      expect(
        (instance as dynamic).greet('John'),
        equals('Hello, John!'),
      );
      expect(
        (instance as dynamic).add(2, 3),
        equals(5),
      );
    });

    test('mixin respects replace parameter', () {
      Macroable.macro<TestClass>('greet', (String name) => 'Hi, $name!');

      final source = MixinSource();
      Macroable.mixin<TestClass>(source, replace: false);

      expect(
        (instance as dynamic).greet('John'),
        equals('Hi, John!'),
      );
    });

    test('handles named parameters', () {
      Macroable.macro<TestClass>(
        'formatName',
        ({String? title, required String first, required String last}) =>
            '${title ?? ''} $first $last'.trim(),
      );

      expect(
        (instance as dynamic).formatName(first: 'John', last: 'Doe'),
        equals('John Doe'),
      );

      expect(
        (instance as dynamic).formatName(
          title: 'Mr.',
          first: 'John',
          last: 'Doe',
        ),
        equals('Mr. John Doe'),
      );
    });

    test('throws NoSuchMethodError for undefined macros', () {
      expect(
        () => (instance as dynamic).undefinedMethod(),
        throwsNoSuchMethodError,
      );
    });
  });
}
