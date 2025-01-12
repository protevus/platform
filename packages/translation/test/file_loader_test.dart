import 'dart:io';
import 'package:path/path.dart' as path;
import 'test_helper.dart';

void main() {
  late Directory tempDir;
  late FileLoader loader;

  setUp(() async {
    // Create a temporary directory for test files
    tempDir = await Directory.systemTemp.createTemp('translation_test_');
    loader = FileLoader([tempDir.path]);
  });

  tearDown(() async {
    // Clean up temporary directory
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileLoader', () {
    test('loads JSON translations', () async {
      final file = File(path.join(tempDir.path, 'en.json'));
      await file.writeAsString('''
        {
          "hello": "Hello!",
          "welcome": "Welcome, :name!"
        }
      ''');

      final translations = loader.load('en', '*', '*');
      expect(translations, {
        'hello': 'Hello!',
        'welcome': 'Welcome, :name!',
      });
    });

    test('loads YAML translations', () async {
      final dir = Directory(path.join(tempDir.path, 'en'));
      await dir.create();
      final file = File(path.join(dir.path, 'messages.yaml'));
      await file.writeAsString('''
        hello: Hello!
        welcome: Welcome, :name!
      ''');

      final translations = loader.load('en', 'messages', null);
      expect(translations, {
        'hello': 'Hello!',
        'welcome': 'Welcome, :name!',
      });
    });

    test('handles namespaced translations', () async {
      // Create vendor namespace directory
      final vendorDir = Directory(path.join(tempDir.path, 'vendor', 'package'));
      await vendorDir.create(recursive: true);

      // Create namespaced translation file
      final file = File(path.join(vendorDir.path, 'en', 'messages.yaml'));
      await file.create(recursive: true);
      await file.writeAsString('''
        title: Package Title
        description: Package Description
      ''');

      // Add namespace to loader
      loader.addNamespace('package', vendorDir.path);

      final translations = loader.load('en', 'messages', 'package');
      expect(translations, {
        'title': 'Package Title',
        'description': 'Package Description',
      });
    });

    test('handles missing files gracefully', () {
      final translations = loader.load('en', 'missing', null);
      expect(translations, isEmpty);
    });

    test('handles invalid JSON files', () async {
      final file = File(path.join(tempDir.path, 'en.json'));
      await file.writeAsString('''
        { invalid json
      ''');

      expect(
        () => loader.load('en', '*', '*'),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles invalid YAML files', () async {
      final dir = Directory(path.join(tempDir.path, 'en'));
      await dir.create();
      final file = File(path.join(dir.path, 'messages.yaml'));
      await file.writeAsString('''
        invalid:
          yaml:
        - not valid
      ''');

      expect(
        () => loader.load('en', 'messages', null),
        throwsA(isA<FormatException>()),
      );
    });

    test('supports multiple paths', () async {
      // Create translations in first path
      final file1 = File(path.join(tempDir.path, 'en.json'));
      await file1.writeAsString('{"msg1": "Message 1"}');

      // Create second path with translations
      final dir2 = await Directory.systemTemp.createTemp('translation_test_2_');
      final file2 = File(path.join(dir2.path, 'en.json'));
      await file2.writeAsString('{"msg2": "Message 2"}');

      // Create loader with both paths
      final multiLoader = FileLoader([tempDir.path, dir2.path]);

      final translations = multiLoader.load('en', '*', '*');
      expect(translations, {
        'msg1': 'Message 1',
        'msg2': 'Message 2',
      });

      // Clean up second temp directory
      await dir2.delete(recursive: true);
    });

    test('manages JSON paths correctly', () {
      loader.addJsonPath('/path/1');
      loader.addJsonPath('/path/2');

      expect(loader.jsonPaths(), ['/path/1', '/path/2']);
    });

    test('manages namespaces correctly', () {
      loader.addNamespace('pkg1', '/path/1');
      loader.addNamespace('pkg2', '/path/2');

      expect(loader.namespaces(), {
        'pkg1': '/path/1',
        'pkg2': '/path/2',
      });
    });
  });
}
