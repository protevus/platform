import 'package:test/test.dart';
import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_mirrors/mirrors.dart';
import 'package:illuminate_support/support.dart';

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
  late ClassMirror testClassMirror;

  setUp(() {
    // Create type mirrors
    final voidType = TypeMirror(
      type: Null, // Using Null as a stand-in for void
      name: 'void',
      owner: null,
      metadata: const [],
    );
    final stringType = TypeMirror(
      type: String,
      name: 'String',
      owner: null,
      metadata: const [],
    );
    final invocationType = TypeMirror(
      type: Invocation,
      name: 'Invocation',
      owner: null,
      metadata: const [],
    );
    final objectType = TypeMirror(
      type: Object,
      name: 'Object',
      owner: null,
      metadata: const [],
    );

    // Create class mirrors
    testClassMirror = ClassMirror(
      type: TestClass,
      name: 'TestClass',
      owner: null,
      declarations: {},
      instanceMembers: {},
      staticMembers: {},
      metadata: const [],
    );

    // Create parameter mirrors
    final selfParam = ParameterMirror(
      name: 'self',
      type: objectType, // Using Object type for inheritance test
      owner: testClassMirror,
    );

    final invocationParam = ParameterMirror(
      name: 'invocation',
      type: invocationType,
      owner: testClassMirror,
    );

    // Create method mirrors
    final publicMethodMirror = MethodMirror(
      name: 'publicMethod',
      owner: testClassMirror,
      returnType: voidType,
      parameters: [selfParam],
    );

    final privateMethodMirror = MethodMirror(
      name: '_privateMethod',
      owner: testClassMirror,
      returnType: voidType,
      parameters: [selfParam],
    );

    final noSuchMethodMirror = MethodMirror(
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
    ReflectionRegistry.register(TestClass);
    ReflectionRegistry.registerMethod(
      TestClass,
      'publicMethod',
      [TestClass],
      true,
      parameterNames: ['self'],
      isRequired: [true],
      isNamed: [false],
      isStatic: false,
    );
    ReflectionRegistry.registerMethod(
      TestClass,
      '_privateMethod',
      [TestClass],
      true,
      parameterNames: ['self'],
      isRequired: [true],
      isNamed: [false],
      isStatic: false,
    );
    ReflectionRegistry.registerMethod(
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
    ReflectionRegistry.register(SimpleEnum);
    ReflectionRegistry.registerProperty(
      SimpleEnum,
      'values',
      List<SimpleEnum>,
    );

    ReflectionRegistry.register(BackedEnum);
    ReflectionRegistry.registerProperty(
      BackedEnum,
      'values',
      List<BackedEnum>,
    );
    ReflectionRegistry.registerProperty(
      BackedEnum,
      'name',
      String,
      isReadable: true,
      isWritable: false,
    );
  });

  tearDown(() {
    ReflectionRegistry.reset();
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
      final method = testClassMirror.declarations[Symbol('publicMethod')]
          as MethodMirrorContract;
      final param = method.parameters.first;

      expect(SupportReflector.getParameterClassName(param), equals('Object'));
    });

    test('getParameterClassNames handles union types', () {
      final method = testClassMirror.declarations[Symbol('publicMethod')]
          as MethodMirrorContract;
      final param = method.parameters.first;

      final classNames = SupportReflector.getParameterClassNames(param);
      expect(classNames, isNotEmpty);
      expect(classNames.first, equals('Object'));
    });

    test('isParameterSubclassOf checks inheritance correctly', () {
      final method = testClassMirror.declarations[Symbol('publicMethod')]
          as MethodMirrorContract;
      final param = method.parameters.first;

      expect(SupportReflector.isParameterSubclassOf(param, 'Object'), isTrue);
    });

    test(
        'isParameterBackedEnumWithStringBackingType returns true for backed enums',
        () {
      final type = TypeMirror(
        type: BackedEnum,
        name: 'BackedEnum',
        owner: null,
        metadata: const [],
      );
      final param = ParameterMirror(
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
      final type = TypeMirror(
        type: SimpleEnum,
        name: 'SimpleEnum',
        owner: null,
        metadata: const [],
      );
      final param = ParameterMirror(
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
      final type = TypeMirror(
        type: String,
        name: 'String',
        owner: null,
        metadata: const [],
      );
      final param = ParameterMirror(
        name: 'param',
        type: type,
        owner: testClassMirror,
      );

      expect(SupportReflector.isParameterBackedEnumWithStringBackingType(param),
          isFalse);
    });
  });
}
