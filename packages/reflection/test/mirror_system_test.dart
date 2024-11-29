import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';

@reflectable
class TestClass {
  String name;
  TestClass(this.name);
}

void main() {
  group('MirrorSystem', () {
    late RuntimeReflector reflector;
    late MirrorSystem mirrorSystem;

    setUp(() {
      reflector = RuntimeReflector.instance;
      mirrorSystem = reflector.currentMirrorSystem;

      // Register test class
      Reflector.registerType(TestClass);
      Reflector.registerPropertyMetadata(
        TestClass,
        'name',
        PropertyMetadata(
          name: 'name',
          type: String,
          isReadable: true,
          isWritable: true,
        ),
      );
    });

    test('currentMirrorSystem provides access to libraries', () {
      expect(mirrorSystem.libraries, isNotEmpty);
      expect(
          mirrorSystem.libraries.keys
              .any((uri) => uri.toString() == 'dart:core'),
          isTrue);
    });

    test('findLibrary returns correct library', () {
      final library = mirrorSystem.findLibrary(const Symbol('dart:core'));
      expect(library, isNotNull);
      expect(library.uri.toString(), equals('dart:core'));
    });

    test('findLibrary throws on non-existent library', () {
      expect(
        () => mirrorSystem.findLibrary(const Symbol('non:existent')),
        throwsArgumentError,
      );
    });

    test('reflectClass returns class mirror', () {
      final classMirror = mirrorSystem.reflectClass(TestClass);
      expect(classMirror, isNotNull);
      expect(classMirror.name, equals('TestClass'));
      expect(classMirror.declarations, isNotEmpty);
    });

    test('reflectClass throws on non-reflectable type', () {
      expect(
        () => mirrorSystem.reflectClass(Object),
        throwsArgumentError,
      );
    });

    test('reflectType returns type mirror', () {
      final typeMirror = mirrorSystem.reflectType(TestClass);
      expect(typeMirror, isNotNull);
      expect(typeMirror.name, equals('TestClass'));
      expect(typeMirror.hasReflectedType, isTrue);
      expect(typeMirror.reflectedType, equals(TestClass));
    });

    test('reflectType throws on non-reflectable type', () {
      expect(
        () => mirrorSystem.reflectType(Object),
        throwsArgumentError,
      );
    });

    test('isolate returns current isolate mirror', () {
      final isolateMirror = mirrorSystem.isolate;
      expect(isolateMirror, isNotNull);
      expect(isolateMirror.isCurrent, isTrue);
      expect(isolateMirror.debugName, equals('main'));
    });

    test('dynamicType returns dynamic type mirror', () {
      final typeMirror = mirrorSystem.dynamicType;
      expect(typeMirror, isNotNull);
      expect(typeMirror.name, equals('dynamic'));
    });

    test('voidType returns void type mirror', () {
      final typeMirror = mirrorSystem.voidType;
      expect(typeMirror, isNotNull);
      expect(typeMirror.name, equals('void'));
    });

    test('neverType returns Never type mirror', () {
      final typeMirror = mirrorSystem.neverType;
      expect(typeMirror, isNotNull);
      expect(typeMirror.name, equals('Never'));
    });

    test('type relationships work correctly', () {
      final dynamicMirror = mirrorSystem.dynamicType;
      final voidMirror = mirrorSystem.voidType;
      final neverMirror = mirrorSystem.neverType;
      final stringMirror = mirrorSystem.reflectType(String);

      // Never is a subtype of everything
      expect(neverMirror.isSubtypeOf(dynamicMirror), isTrue);
      expect(neverMirror.isSubtypeOf(stringMirror), isTrue);

      // Everything is assignable to dynamic
      expect(stringMirror.isAssignableTo(dynamicMirror), isTrue);
      expect(neverMirror.isAssignableTo(dynamicMirror), isTrue);

      // void is not assignable to anything (except itself)
      expect(voidMirror.isAssignableTo(stringMirror), isFalse);
      expect(voidMirror.isAssignableTo(dynamicMirror), isFalse);
      expect(voidMirror.isAssignableTo(voidMirror), isTrue);
    });

    test('library dependencies are tracked', () {
      final coreLibrary = mirrorSystem.findLibrary(const Symbol('dart:core'));
      expect(coreLibrary.libraryDependencies, isNotEmpty);

      final imports =
          coreLibrary.libraryDependencies.where((dep) => dep.isImport).toList();
      expect(imports, isNotEmpty);

      final exports =
          coreLibrary.libraryDependencies.where((dep) => dep.isExport).toList();
      expect(exports, isNotEmpty);
    });
  });
}
