import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:illuminate_mirrors/mirrors.dart';
import 'package:test/test.dart';

// Test classes
@reflectable
class TestUser {
  final String id;
  String name;
  int? age;
  List<String> tags;

  TestUser(this.id, this.name, {this.age, List<String>? tags})
      : tags = tags ?? [];

  static TestUser create(String id, String name) => TestUser(id, name);

  void addTag(String tag) {
    tags.add(tag);
  }

  String greet() => 'Hello, $name!';
}

@reflectable
abstract class BaseEntity {
  String get id;
  Map<String, dynamic> toJson();
}

@reflectable
class TestProduct implements BaseEntity {
  @override
  final String id;
  final String name;
  final double price;

  const TestProduct(this.id, this.name, this.price);

  factory TestProduct.create(String name, double price) {
    return TestProduct(DateTime.now().toString(), name, price);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };
}

void main() {
  group('PackageAnalyzer Tests', () {
    late Directory tempDir;
    late String libPath;

    setUp(() async {
      // Create temporary directory structure
      tempDir = await Directory.systemTemp.createTemp('package_analyzer_test_');
      libPath = path.join(tempDir.path, 'lib');
      await Directory(libPath).create();

      // Create test files
      await File(path.join(libPath, 'test_user.dart')).writeAsString('''
import 'package:illuminate_mirrors/mirrors.dart';

@reflectable
class TestUser {
  final String id;
  String name;
  int? age;
  List<String> tags;

  TestUser(this.id, this.name, {this.age, List<String>? tags})
      : tags = tags ?? [];

  static TestUser create(String id, String name) => TestUser(id, name);

  void addTag(String tag) {
    tags.add(tag);
  }

  String greet() => 'Hello, \$name!';
}
''');

      await File(path.join(libPath, 'test_product.dart')).writeAsString('''
import 'package:illuminate_mirrors/mirrors.dart';

@reflectable
abstract class BaseEntity {
  String get id;
  Map<String, dynamic> toJson();
}

@reflectable
class TestProduct implements BaseEntity {
  @override
  final String id;
  final String name;
  final double price;

  const TestProduct(this.id, this.name, this.price);

  factory TestProduct.create(String name, double price) {
    return TestProduct(DateTime.now().toString(), name, price);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };
}
''');
    });

    tearDown(() async {
      // Clean up temporary directory
      await tempDir.delete(recursive: true);
      // Reset reflection registry
      ReflectionRegistry.reset();
    });

    test('discovers all types in package', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      expect(types, isNotEmpty);

      // Verify type names are registered
      final typeNames =
          types.map((t) => PackageAnalyzer.getTypeName(t)).toSet();
      expect(typeNames, containsAll(['TestUser', 'BaseEntity', 'TestProduct']));
    });

    test('analyzes class properties correctly', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      final userType =
          types.firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'TestUser');

      final metadata = ReflectionRegistry.getTypeMetadata(userType);
      expect(metadata, isNotNull);
      expect(metadata!.properties, hasLength(4));

      final idProperty = metadata.properties['id']!;
      expect(PackageAnalyzer.getTypeName(idProperty.type), equals('String'));
      expect(idProperty.isWritable, isFalse);

      final nameProperty = metadata.properties['name']!;
      expect(PackageAnalyzer.getTypeName(nameProperty.type), equals('String'));
      expect(nameProperty.isWritable, isTrue);
    });

    test('analyzes class methods correctly', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      final userType =
          types.firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'TestUser');

      final metadata = ReflectionRegistry.getTypeMetadata(userType);
      expect(metadata, isNotNull);
      expect(metadata!.methods, hasLength(3)); // addTag, greet, create

      final addTagMethod = metadata.methods['addTag']!;
      expect(PackageAnalyzer.getTypeName(addTagMethod.parameterTypes.first),
          equals('String'));
      expect(addTagMethod.returnsVoid, isTrue);

      final greetMethod = metadata.methods['greet']!;
      expect(greetMethod.parameterTypes, isEmpty);
      expect(PackageAnalyzer.getTypeName(greetMethod.returnType),
          equals('String'));
    });

    // test('analyzes constructors correctly', () {
    //   final types = PackageAnalyzer.discoverTypes(tempDir.path);
    //   final userType =
    //       types.firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'TestUser');

    //   final metadata = ReflectionRegistry.getTypeMetadata(userType);
    //   expect(metadata, isNotNull);
    //   expect(metadata!.constructors, hasLength(1));

    //   final constructor = metadata.constructors.first;
    //   expect(constructor.parameterTypes, hasLength(4));
    //   expect(constructor.parameters.where((p) => p.isNamed), hasLength(2));
    // });

    test('analyzes inheritance correctly', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      final productType = types
          .firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'TestProduct');

      final metadata = ReflectionRegistry.getTypeMetadata(productType);
      expect(metadata, isNotNull);
      expect(metadata!.interfaces, hasLength(1));
      expect(metadata.interfaces.first.name, equals('BaseEntity'));
    });

    test('handles abstract classes correctly', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      final baseEntityType = types
          .firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'BaseEntity');

      final metadata = ReflectionRegistry.getTypeMetadata(baseEntityType);
      expect(metadata, isNotNull);
      expect(metadata!.methods['toJson'], isNotNull);
      expect(metadata.properties['id'], isNotNull);
    });

    test('handles factory constructors correctly', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      final productType = types
          .firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'TestProduct');

      final metadata = ReflectionRegistry.getTypeMetadata(productType);
      expect(metadata, isNotNull);

      final factoryConstructor =
          metadata!.constructors.firstWhere((c) => c.name == 'create');
      expect(factoryConstructor, isNotNull);
      expect(
          factoryConstructor.parameterTypes
              .map((t) => PackageAnalyzer.getTypeName(t)),
          equals(['String', 'double']));
    });

    test('handles static methods correctly', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      final userType =
          types.firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'TestUser');

      final metadata = ReflectionRegistry.getTypeMetadata(userType);
      expect(metadata, isNotNull);

      final createMethod = metadata!.methods['create']!;
      expect(createMethod.isStatic, isTrue);
      expect(
          createMethod.parameterTypes
              .map((t) => PackageAnalyzer.getTypeName(t)),
          equals(['String', 'String']));
    });

    test('handles nullable types correctly', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      final userType =
          types.firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'TestUser');

      final metadata = ReflectionRegistry.getTypeMetadata(userType);
      expect(metadata, isNotNull);

      final ageProperty = metadata!.properties['age']!;
      expect(PackageAnalyzer.getTypeName(ageProperty.type), equals('int'));
      // Note: Currently we don't track nullability information
      // This could be enhanced in future versions
    });

    test('caches discovered types', () {
      final firstRun = PackageAnalyzer.discoverTypes(tempDir.path);
      final secondRun = PackageAnalyzer.discoverTypes(tempDir.path);

      expect(identical(firstRun, secondRun), isTrue);
    });

    test('handles generic types correctly', () {
      final types = PackageAnalyzer.discoverTypes(tempDir.path);
      final userType =
          types.firstWhere((t) => PackageAnalyzer.getTypeName(t) == 'TestUser');

      final metadata = ReflectionRegistry.getTypeMetadata(userType);
      expect(metadata, isNotNull);

      final tagsProperty = metadata!.properties['tags']!;
      expect(PackageAnalyzer.getTypeName(tagsProperty.type), equals('List'));
      // Note: Currently we don't track generic type arguments
      // This could be enhanced in future versions
    });
  });
}
