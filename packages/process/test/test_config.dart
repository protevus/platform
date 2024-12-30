import 'dart:io';
import 'package:test/test.dart';
import 'package:platform_process/process.dart';
import 'helpers/test_helpers.dart';

/// Test configuration and utilities.
class TestConfig {
  /// List of temporary files created during tests.
  static final List<FileSystemEntity> _tempFiles = [];

  /// Configure test environment and add common test utilities.
  static void configure() {
    setUp(() {
      // Clear temp files list at start of each test
      _tempFiles.clear();
    });

    tearDown(() async {
      // Clean up any test files created during the test
      await cleanupTempFiles(_tempFiles);

      // Clean up any remaining test files in temp directory
      final tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          if (entity.path.contains('test_')) {
            await entity.delete(recursive: true);
          }
        }
      }
    });
  }

  /// Creates a temporary file that will be cleaned up after the test.
  static Future<File> createTrackedTempFile(String content) async {
    final file = await createTempFile(content);
    _tempFiles.add(file);
    return file;
  }

  /// Creates a temporary directory that will be cleaned up after the test.
  static Future<Directory> createTrackedTempDir() async {
    final dir = await createTempDir();
    _tempFiles.add(dir);
    return dir;
  }

  /// Creates a test directory structure that will be cleaned up after the test.
  static Future<Directory> createTrackedTestDirectoryStructure(
    Map<String, String> files,
  ) async {
    final dir = await createTestDirectoryStructure(files);
    _tempFiles.add(dir);
    return dir;
  }

  /// Runs a test with a temporary directory that gets cleaned up.
  static Future<T> withTrackedTempDir<T>(
    Future<T> Function(Directory dir) test,
  ) async {
    final dir = await createTrackedTempDir();
    return test(dir);
  }

  /// Creates a factory with test-specific fake handlers.
  static Factory createTestFactoryWithFakes(Map<String, dynamic> fakes) {
    final factory = createTestFactory();
    factory.fake(fakes);
    return factory;
  }
}

/// Extension methods for test utilities.
extension TestUtilsExtension on Directory {
  /// Creates a file in this directory with the given name and content.
  Future<File> createFile(String name, String content) async {
    final file = File('${path}/$name');
    await file.writeAsString(content);
    return file;
  }

  /// Creates multiple files in this directory.
  Future<List<File>> createFiles(Map<String, String> files) async {
    final createdFiles = <File>[];
    for (final entry in files.entries) {
      createdFiles.add(await createFile(entry.key, entry.value));
    }
    return createdFiles;
  }
}
