import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';
import 'package:platform_reflection/reflection.dart';
import 'package:platform_reflection/src/core/reflector.dart';
import 'package:platform_reflection/src/mirrors/method_mirror_impl.dart';
import 'package:platform_reflection/src/mirrors/parameter_mirror_impl.dart';
import 'package:platform_reflection/src/mirrors/type_mirror_impl.dart';
import 'package:platform_reflection/src/mirrors/class_mirror_impl.dart';

class TestClass {
  void publicMethod() {}
  void _privateMethod() {}

  String get publicProperty => '';
  String get _privateProperty => '';

  void noSuchMethod(Invocation invocation) {}
}

enum SimpleEnum { one, two }

enum BackedEnum {
  one('1'),
  two('2');

  final String name;
  const BackedEnum(this.name);
}

void main() {
  late ClassMirrorImpl testClassMirror;

  setUp(() {
    // Create type mirrors
    final voidType = TypeMirrorImpl(
      type: Null, // Using Null as a stand-in for void
      name: 'void',
      owner: null,
      metadata: const [],
    );
    final stringType = TypeMirrorImpl(
      type: String,
      name: 'String',
      owner: null,
      metadata: const [],
    );
    final invocationType = TypeMirrorImpl(
      type: Invocation,
      name: 'Invocation',
      owner: null,
      metadata: const [],
    );
    final objectType = TypeMirrorImpl(
      type: Object,
      name: 'Object',
      owner: null,
      metadata: const [],
    );

    // Create class mirrors
    testClassMirror = ClassMirrorImpl(
      type: TestClass,
      name: 'TestClass',
      owner: null,
      declarations: {},
      instanceMembers: {},
      staticMembers: {},
      metadata: const [],
    );

    // Create parameter mirrors
    final selfParam = ParameterMirrorImpl(
      name: 'self',
      type: objectType, // Using Object type for inheritance test
      owner: testClassMirror,
    );

    final invocationParam = ParameterMirrorImpl(
      name: 'invocation',
      type: invocationType,
      owner: testClassMirror,
    );

    // Create method mirrors
    final publicMethodMirror = MethodMirrorImpl(
      name: 'publicMethod',
      owner: testClassMirror,
      returnType: voidType,
      parameters: [selfParam],
    );

    final privateMethodMirror = MethodMirrorImpl(
      name: '_privateMethod',
      owner: testClassMirror,
      returnType: voidType,
      parameters: [selfParam],
    );

    final noSuchMethodMirror = MethodMirrorImpl(
      name: 'noSuchMethod',
      owner: testClassMirror,
      returnType: voidType,
      parameters: [invocationParam],
    );

    // Add declarations to test class mirror
    testClassMirror.declarations[Symbol('publicMethod')] = publicMethodMirror;
    testClassMirror.declarations[Symbol('_privateMethod')] =
        privateMethodMirror;
    testClassMirror.declarations[Symbol('noSuchMethod')] = noSuchMethodMirror;

    // Register test classes
    Reflector.register(TestClass);
    Reflector.registerMethod(
      TestClass,
      'publicMethod',
      [TestClass],
      true,
      parameterNames: ['self'],
      isRequired: [true],
      isNamed: [false],
      isStatic: false,
    );
    Reflector.registerMethod(
      TestClass,
      '_privateMethod',
      [TestClass],
      true,
      parameterNames: ['self'],
      isRequired: [true],
      isNamed: [false],
      isStatic: false,
    );
    Reflector.registerMethod(
      TestClass,
      'noSuchMethod',
      [Invocation],
      true,
      parameterNames: ['invocation'],
      isRequired: [true],
      isNamed: [false],
      isStatic: false,
    );

    // Register enums
    Reflector.register(SimpleEnum);
    Reflector.registerProperty(
      SimpleEnum,
      'values',
      List<SimpleEnum>,
    );

    Reflector.register(BackedEnum);
    Reflector.registerProperty(
      BackedEnum,
      'values',
      List<BackedEnum>,
    );
    Reflector.registerProperty(
      BackedEnum,
      'name',
      String,
      isReadable: true,
      isWritable: false,
    );
  });

  tearDown(() {
    Reflector.reset();
  });

  group('SupportReflector', () {
    test('isCallable returns true for functions', () {
      expect(SupportReflector.isCallable(() {}), isTrue);
    });

    test('isCallable returns true for public methods', () {
      expect(
          SupportReflector.isCallable([TestClass(), 'publicMethod']), isTrue);
    });

    test('isCallable returns false for private methods', () {
      expect(SupportReflector.isCallable([TestClass(), '_privateMethod']),
          isFalse);
    });

    test('isCallable returns false for invalid method names', () {
      expect(SupportReflector.isCallable([TestClass(), 'nonExistentMethod']),
          isFalse);
    });

    test('isCallable returns true for objects with noSuchMethod', () {
      expect(SupportReflector.isCallable([TestClass(), 'anyMethod']), isTrue);
    });

    test('isCallable returns false for non-callable values', () {
      expect(SupportReflector.isCallable('not callable'), isFalse);
      expect(SupportReflector.isCallable([]), isFalse);
      expect(SupportReflector.isCallable(['invalid']), isFalse);
      expect(SupportReflector.isCallable([1, 2, 3]), isFalse);
    });

    test('isCallable handles syntax-only check', () {
      expect(
          SupportReflector.isCallable([TestClass(), 'method'], true), isTrue);
      expect(SupportReflector.isCallable(['string', 'method'], true), isTrue);
      expect(SupportReflector.isCallable([123, 'method'], false), isFalse);
    });

    test('getParameterClassName returns correct class name', () {
      final method =
          testClassMirror.declarations[Symbol('publicMethod')] as MethodMirror;
      final param = method.parameters.first;

      expect(SupportReflector.getParameterClassName(param), equals('Object'));
    });

    test('getParameterClassNames handles union types', () {
      final method =
          testClassMirror.declarations[Symbol('publicMethod')] as MethodMirror;
      final param = method.parameters.first;

      final classNames = SupportReflector.getParameterClassNames(param);
      expect(classNames, isNotEmpty);
      expect(classNames.first, equals('Object'));
    });

    test('isParameterSubclassOf checks inheritance correctly', () {
      final method =
          testClassMirror.declarations[Symbol('publicMethod')] as MethodMirror;
      final param = method.parameters.first;

      expect(SupportReflector.isParameterSubclassOf(param, 'Object'), isTrue);
    });

    test(
        'isParameterBackedEnumWithStringBackingType returns true for backed enums',
        () {
      final type = TypeMirrorImpl(
        type: BackedEnum,
        name: 'BackedEnum',
        owner: null,
        metadata: const [],
      );
      final param = ParameterMirrorImpl(
        name: 'param',
        type: type,
        owner: testClassMirror,
      );

      expect(SupportReflector.isParameterBackedEnumWithStringBackingType(param),
          isTrue);
    });

    test(
        'isParameterBackedEnumWithStringBackingType returns false for simple enums',
        () {
      final type = TypeMirrorImpl(
        type: SimpleEnum,
        name: 'SimpleEnum',
        owner: null,
        metadata: const [],
      );
      final param = ParameterMirrorImpl(
        name: 'param',
        type: type,
        owner: testClassMirror,
      );

      expect(SupportReflector.isParameterBackedEnumWithStringBackingType(param),
          isFalse);
    });

    test(
        'isParameterBackedEnumWithStringBackingType returns false for non-enums',
        () {
      final type = TypeMirrorImpl(
        type: String,
        name: 'String',
        owner: null,
        metadata: const [],
      );
      final param = ParameterMirrorImpl(
        name: 'param',
        type: type,
        owner: testClassMirror,
      );

      expect(SupportReflector.isParameterBackedEnumWithStringBackingType(param),
          isFalse);
    });
  });
}
