import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';

// Top-level function for testing
int add(int a, int b) => a + b;

// Top-level variable for testing
const String greeting = 'Hello';

void main() {
  group('Library Reflection', () {
    late RuntimeReflector reflector;

    setUp(() {
      reflector = RuntimeReflector.instance;
    });

    test('reflectLibrary returns library mirror', () {
      final libraryMirror = reflector.reflectLibrary(
        Uri.parse('package:reflection/test/library_reflection_test.dart'),
      );

      expect(libraryMirror, isNotNull);
      expect(libraryMirror.uri.toString(),
          contains('library_reflection_test.dart'));
    });

    test('library mirror provides correct metadata', () {
      final libraryMirror = reflector.reflectLibrary(
        Uri.parse('package:reflection/test/library_reflection_test.dart'),
      );

      expect(libraryMirror.isPrivate, isFalse);
      expect(libraryMirror.isTopLevel, isTrue);
      expect(libraryMirror.metadata, isEmpty);
    });

    test('library mirror provides access to declarations', () {
      final libraryMirror = reflector.reflectLibrary(
        Uri.parse('package:reflection/test/library_reflection_test.dart'),
      );

      final declarations = libraryMirror.declarations;
      expect(declarations, isNotEmpty);

      // Check for top-level function
      final addFunction = declarations[const Symbol('add')] as MethodMirror;
      expect(addFunction, isNotNull);
      expect(addFunction.isStatic, isTrue);
      expect(addFunction.parameters.length, equals(2));

      // Check for top-level variable
      final greetingVar =
          declarations[const Symbol('greeting')] as VariableMirror;
      expect(greetingVar, isNotNull);
      expect(greetingVar.isStatic, isTrue);
      expect(greetingVar.isConst, isTrue);
      expect(greetingVar.type.reflectedType, equals(String));
    });

    test('library mirror provides access to dependencies', () {
      final libraryMirror = reflector.reflectLibrary(
        Uri.parse('package:reflection/test/library_reflection_test.dart'),
      );

      final dependencies = libraryMirror.libraryDependencies;
      expect(dependencies, isNotEmpty);

      // Check for test package import
      final testImport = dependencies.firstWhere((dep) =>
          dep.isImport &&
          dep.targetLibrary?.uri.toString().contains('package:test/') == true);
      expect(testImport, isNotNull);
      expect(testImport.isDeferred, isFalse);
      expect(testImport.prefix, isNull);

      // Check for reflection package import
      final reflectionImport = dependencies.firstWhere((dep) =>
          dep.isImport &&
          dep.targetLibrary?.uri
                  .toString()
                  .contains('package:platform_reflection/') ==
              true);
      expect(reflectionImport, isNotNull);
      expect(reflectionImport.isDeferred, isFalse);
      expect(reflectionImport.prefix, isNull);
    });

    test('library mirror allows invoking top-level functions', () {
      final libraryMirror = reflector.reflectLibrary(
        Uri.parse('package:reflection/test/library_reflection_test.dart'),
      );

      final result = libraryMirror.invoke(
        const Symbol('add'),
        [2, 3],
      ).reflectee as int;

      expect(result, equals(5));
    });

    test('library mirror allows accessing top-level variables', () {
      final libraryMirror = reflector.reflectLibrary(
        Uri.parse('package:reflection/test/library_reflection_test.dart'),
      );

      final value =
          libraryMirror.getField(const Symbol('greeting')).reflectee as String;
      expect(value, equals('Hello'));
    });

    test('library mirror throws on non-existent members', () {
      final libraryMirror = reflector.reflectLibrary(
        Uri.parse('package:reflection/test/library_reflection_test.dart'),
      );

      expect(
        () => libraryMirror.invoke(const Symbol('nonexistent'), []),
        throwsA(isA<NoSuchMethodError>()),
      );

      expect(
        () => libraryMirror.getField(const Symbol('nonexistent')),
        throwsA(isA<NoSuchMethodError>()),
      );
    });
  });
}
