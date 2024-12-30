import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:platform_process/process.dart';

/// Creates a temporary file with the given content.
Future<File> createTempFile(String content) async {
  final file = File(
      '${Directory.systemTemp.path}/test_${DateTime.now().millisecondsSinceEpoch}');
  await file.writeAsString(content);
  return file;
}

/// Creates a temporary directory.
Future<Directory> createTempDir() async {
  return Directory.systemTemp.createTemp('test_');
}

/// Cleans up temporary test files.
Future<void> cleanupTempFiles(List<FileSystemEntity> entities) async {
  for (final entity in entities) {
    if (await entity.exists()) {
      await entity.delete(recursive: true);
    }
  }
}

/// Creates a process factory with common fake commands.
Factory createTestFactory() {
  final factory = Factory();
  factory.fake({
    'echo': (process) => process.toString(),
    'cat': (process) => 'cat output',
    'ls': 'file1\nfile2\nfile3',
    'pwd': Directory.current.path,
    'grep': (process) => 'grep output',
    'wc': (process) => '1',
    'sort': (process) => 'sorted output',
    'head': (process) => 'head output',
    'printenv': (process) => 'environment output',
    'tr': (process) => 'transformed output',
    'sleep': (process) => '',
    'false': (process) => '',
  });
  return factory;
}

/// Waits for a condition to be true with timeout.
Future<bool> waitFor(
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (await condition()) {
      return true;
    }
    await Future.delayed(interval);
  }
  return false;
}

/// Creates a test file with given name and content in a temporary directory.
Future<File> createTestFile(String name, String content) async {
  final dir = await createTempDir();
  final file = File('${dir.path}/$name');
  await file.writeAsString(content);
  return file;
}

/// Creates a test directory structure.
Future<Directory> createTestDirectoryStructure(
    Map<String, String> files) async {
  final dir = await createTempDir();
  for (final entry in files.entries) {
    final file = File('${dir.path}/${entry.key}');
    await file.create(recursive: true);
    await file.writeAsString(entry.value);
  }
  return dir;
}

/// Runs a test with temporary directory that gets cleaned up.
Future<T> withTempDir<T>(Future<T> Function(Directory dir) test) async {
  final dir = await createTempDir();
  try {
    return await test(dir);
  } finally {
    await dir.delete(recursive: true);
  }
}

/// Creates a factory with custom fake handlers.
Factory createCustomFactory(Map<String, dynamic> fakes) {
  final factory = Factory();
  factory.fake(fakes);
  return factory;
}

/// Asserts that a process completed within the expected duration.
Future<void> assertCompletesWithin(
  Future<void> Function() action,
  Duration duration,
) async {
  final stopwatch = Stopwatch()..start();
  await action();
  stopwatch.stop();
  if (stopwatch.elapsed > duration) {
    fail(
      'Expected to complete within ${duration.inMilliseconds}ms '
      'but took ${stopwatch.elapsedMilliseconds}ms',
    );
  }
}
