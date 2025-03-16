import 'dart:io';
import 'package:test/test.dart';
import 'package:illuminate_view/src/engines/finder.dart';
import 'package:path/path.dart' as path;

void main() {
  group('ViewFinder', () {
    late ViewFinder finder;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('view_test_');
      finder = ViewFinder([tempDir.path], ['.blade.html']);

      // Create test views
      // Create test directory structure
      final testFile = File(path.join(tempDir.path, 'test.blade.html'));
      final nestedFile =
          File(path.join(tempDir.path, 'nested', 'view.blade.html'));

      // Create parent directories
      await testFile.parent.create(recursive: true);
      await nestedFile.parent.create(recursive: true);

      // Write test files
      await testFile.writeAsString('test');
      await nestedFile.writeAsString('nested');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('finds view by name', () {
      final path = finder.find('test');
      expect(path, isNotNull);
      expect(path, contains('test.blade.html'));
    });

    test('finds view with explicit extension', () {
      final path = finder.find('test.blade.html');
      expect(path, isNotNull);
      expect(path, contains('test.blade.html'));
    });

    test('finds nested view using dots', () {
      final path = finder.find('nested.view');
      expect(path, isNotNull);
      expect(path, contains('nested${Platform.pathSeparator}view.blade.html'));
    });

    test('returns null for non-existent view', () {
      final path = finder.find('missing');
      expect(path, isNull);
    });

    test('can add new path', () {
      final newPath = path.join(tempDir.path, 'new');
      finder.addPath(newPath);
      expect(finder.paths, contains(newPath));
    });

    test('can add new extension', () {
      finder.addExtension('.custom');
      expect(finder.extensions, contains('.custom'));
    });

    test('clears cache when adding path', () {
      final existingPath = finder.find('test');
      expect(existingPath, isNotNull);

      finder.addPath('new/path');
      final cachedPath = finder.find('test');
      expect(cachedPath, isNotNull);
      expect(cachedPath, equals(existingPath));
    });

    test('clears cache when adding extension', () {
      final existingPath = finder.find('test');
      expect(existingPath, isNotNull);

      finder.addExtension('.custom');
      final cachedPath = finder.find('test');
      expect(cachedPath, isNotNull);
      expect(cachedPath, equals(existingPath));
    });

    test('can flush cache', () {
      final existingPath = finder.find('test');
      expect(existingPath, isNotNull);

      finder.flush();
      final cachedPath = finder.find('test');
      expect(cachedPath, isNotNull);
      expect(cachedPath, equals(existingPath));
    });
  });
}
