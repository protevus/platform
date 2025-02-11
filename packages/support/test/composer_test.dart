import 'dart:io';
import 'package:test/test.dart';
import 'package:illuminate_support/src/composer.dart';
import 'package:path/path.dart' as path;

void main() {
  group('Composer', () {
    late Directory tempDir;
    late String pubspecPath;
    late Composer composer;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('composer_test_');
      pubspecPath = path.join(tempDir.path, 'pubspec.yaml');

      // Create a test pubspec.yaml
      await File(pubspecPath).writeAsString('''
name: test_package
description: A test package
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  test_dep: ^1.0.0

dev_dependencies:
  test_dev_dep: ^1.0.0
''');

      composer = Composer(pubspecPath);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('reads package information correctly', () {
      expect(composer.name, equals('test_package'));
      expect(composer.version, equals('1.0.0'));
      expect(composer.description, equals('A test package'));
    });

    test('reads dependencies correctly', () {
      expect(composer.dependencies, containsPair('test_dep', '^1.0.0'));
      expect(composer.devDependencies, containsPair('test_dev_dep', '^1.0.0'));
    });

    test('adds a dependency', () async {
      await composer.require('new_dep', version: '^2.0.0');

      // Reload composer to verify changes were saved
      composer = Composer(pubspecPath);
      expect(composer.dependencies, containsPair('new_dep', '^2.0.0'));
    });

    test('adds a dev dependency', () async {
      await composer.require('new_dev_dep', version: '^2.0.0', dev: true);

      composer = Composer(pubspecPath);
      expect(composer.devDependencies, containsPair('new_dev_dep', '^2.0.0'));
    });

    test('removes a dependency', () async {
      await composer.remove('test_dep');

      composer = Composer(pubspecPath);
      expect(composer.dependencies, isNot(contains('test_dep')));
    });

    test('removes a dev dependency', () async {
      await composer.remove('test_dev_dep', dev: true);

      composer = Composer(pubspecPath);
      expect(composer.devDependencies, isNot(contains('test_dev_dep')));
    });

    test('checks if package is installed', () {
      expect(composer.hasPackage('test_dep'), isTrue);
      expect(composer.hasPackage('test_dev_dep', dev: true), isTrue);
      expect(composer.hasPackage('nonexistent'), isFalse);
    });

    test('handles missing pubspec.yaml', () {
      expect(
        () => Composer('nonexistent.yaml'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('preserves file formatting', () async {
      final originalContent = await File(pubspecPath).readAsString();
      await composer.require('new_dep', version: '^2.0.0');
      final newContent = await File(pubspecPath).readAsString();

      // Verify that the basic structure is preserved
      expect(newContent, contains('name: test_package'));
      expect(newContent, contains('description: A test package'));
      expect(newContent, contains('version: 1.0.0'));
      expect(newContent, contains('dependencies:'));
      expect(newContent, contains('dev_dependencies:'));
    });

    test('handles empty dependencies sections', () async {
      // Create pubspec without dependencies
      await File(pubspecPath).writeAsString('''
name: test_package
version: 1.0.0
environment:
  sdk: ">=3.0.0 <4.0.0"
''');

      composer = Composer(pubspecPath);
      await composer.require('new_dep', version: '^1.0.0');

      composer = Composer(pubspecPath);
      expect(composer.dependencies, containsPair('new_dep', '^1.0.0'));
    });

    test('maintains dependency order', () async {
      await composer.require('a_dep', version: '^1.0.0');
      await composer.require('b_dep', version: '^1.0.0');
      await composer.require('c_dep', version: '^1.0.0');

      final content = await File(pubspecPath).readAsString();
      final aIndex = content.indexOf('a_dep:');
      final bIndex = content.indexOf('b_dep:');
      final cIndex = content.indexOf('c_dep:');

      expect(aIndex, lessThan(bIndex));
      expect(bIndex, lessThan(cIndex));
    });

    test('validates version constraints', () async {
      // Valid version constraints
      await composer.require('valid_dep1', version: '^1.0.0');
      await composer.require('valid_dep2', version: '>=2.0.0 <3.0.0');
      await composer.require('valid_dep3', version: 'any');

      composer = Composer(pubspecPath);
      expect(composer.dependencies['valid_dep1'], equals('^1.0.0'));
      expect(composer.dependencies['valid_dep2'], equals('>=2.0.0 <3.0.0'));
      expect(composer.dependencies['valid_dep3'], equals('any'));
    });

    test('handles path dependencies', () async {
      await composer.require('path_dep', version: 'path: ../path_dep');

      composer = Composer(pubspecPath);
      expect(composer.dependencies['path_dep'], equals('path: ../path_dep'));
    });

    test('handles git dependencies', () async {
      const gitUrl = 'git: https://github.com/user/repo.git';
      await composer.require('git_dep', version: gitUrl);

      composer = Composer(pubspecPath);
      expect(composer.dependencies['git_dep'], equals(gitUrl));
    });

    test('preserves dependency overrides', () async {
      // Create pubspec with dependency overrides
      await File(pubspecPath).writeAsString('''
name: test_package
version: 1.0.0
environment:
  sdk: ">=3.0.0 <4.0.0"

dependency_overrides:
  test_override: ^2.0.0
''');

      composer = Composer(pubspecPath);
      await composer.require('new_dep', version: '^1.0.0');

      final content = await File(pubspecPath).readAsString();
      expect(content, contains('dependency_overrides:'));
      expect(content, contains('test_override: ^2.0.0'));
    });
  });
}
