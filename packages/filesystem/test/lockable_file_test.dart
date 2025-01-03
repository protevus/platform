import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:platform_filesystem/filesystem.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('lockable_file_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('LockableFile', () {
    test('creates file with read mode', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('test content');

      final file = LockableFile(path, 'r');
      expect(file.read(), equals(utf8.encode('test content')));
      file.close();
    });

    test('creates file with write mode', () {
      final path = '${tempDir.path}/test.txt';
      final file = LockableFile(path, 'w');
      file.write('test content');
      file.close();

      expect(File(path).readAsStringSync(), equals('test content'));
    });

    test('creates file with append mode', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('initial ');

      final file = LockableFile(path, 'a');
      file.write('content');
      file.close();

      expect(File(path).readAsStringSync(), equals('initial content'));
    });

    test('creates parent directories if needed', () {
      final path = '${tempDir.path}/subdir/test.txt';
      final file = LockableFile(path, 'w');
      file.write('test');
      file.close();

      expect(File(path).existsSync(), isTrue);
      expect(File(path).readAsStringSync(), equals('test'));
    });

    test('reads file size', () {
      final path = '${tempDir.path}/test.txt';
      final content = 'test content';
      File(path).writeAsStringSync(content);

      final file = LockableFile(path, 'r');
      expect(file.size(), equals(content.length));
      file.close();
    });

    test('truncates file', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('test content');

      final file = LockableFile(path, 'w');
      file.truncate();
      file.close();

      expect(File(path).readAsStringSync(), isEmpty);
    });

    test('acquires shared lock', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('test');

      final file = LockableFile(path, 'r');
      expect(() => file.getSharedLock(), returnsNormally);
      file.close();
    });

    test('acquires exclusive lock', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('test');

      final file = LockableFile(path, 'w');
      expect(() => file.getExclusiveLock(), returnsNormally);
      file.close();
    });

    test('releases lock', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('test');

      final file = LockableFile(path, 'w');
      file.getExclusiveLock();
      expect(() => file.releaseLock(), returnsNormally);
      file.close();
    });

    test('releases lock on close', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('test');

      final file = LockableFile(path, 'w');
      file.getExclusiveLock();
      expect(() => file.close(), returnsNormally);
    });

    test('throws when reading closed file', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('test');

      final file = LockableFile(path, 'r');
      file.close();
      expect(() => file.read(), throwsStateError);
    });

    test('throws when writing closed file', () {
      final path = '${tempDir.path}/test.txt';
      final file = LockableFile(path, 'w');
      file.close();
      expect(() => file.write('test'), throwsStateError);
    });

    test('throws when truncating closed file', () {
      final path = '${tempDir.path}/test.txt';
      final file = LockableFile(path, 'w');
      file.close();
      expect(() => file.truncate(), throwsStateError);
    });

    test('throws when locking closed file', () {
      final path = '${tempDir.path}/test.txt';
      final file = LockableFile(path, 'w');
      file.close();
      expect(() => file.getSharedLock(), throwsStateError);
      expect(() => file.getExclusiveLock(), throwsStateError);
    });

    test('throws when releasing lock on closed file', () {
      final path = '${tempDir.path}/test.txt';
      final file = LockableFile(path, 'w');
      file.close();
      expect(() => file.releaseLock(), throwsStateError);
    });

    test('throws on invalid mode', () {
      final path = '${tempDir.path}/test.txt';
      expect(() => LockableFile(path, 'x'), throwsArgumentError);
    });

    test('throws LockTimeoutException when lock cannot be acquired', () {
      final path = '${tempDir.path}/test.txt';
      File(path).writeAsStringSync('test');

      final file1 = LockableFile(path, 'w');
      file1.getExclusiveLock();

      final file2 = LockableFile(path, 'w');
      expect(() => file2.getExclusiveLock(false),
          throwsA(isA<LockTimeoutException>()));

      file1.close();
      file2.close();
    });
  });
}
