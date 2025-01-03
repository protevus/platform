import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:platform_filesystem/filesystem.dart';
import 'package:platform_contracts/contracts.dart';

void main() {
  late Directory tempDir;
  late Filesystem fs;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('filesystem_test_');
    fs = Filesystem();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('Filesystem', () {
    test('exists() returns true for existing file', () {
      final file = File('${tempDir.path}/test.txt');
      file.writeAsStringSync('test');
      expect(fs.exists(file.path), isTrue);
    });

    test('exists() returns false for non-existing file', () {
      expect(fs.exists('${tempDir.path}/nonexistent.txt'), isFalse);
    });

    test('readStream() returns file stream', () {
      final file = File('${tempDir.path}/test.txt');
      file.writeAsStringSync('test content');

      final stream = fs.readStream(file.path);
      expect(stream, isNotNull);

      final bytes = stream!.toList().then((chunks) {
        final allBytes = <int>[];
        for (var chunk in chunks) {
          allBytes.addAll(chunk);
        }
        return allBytes;
      });

      expect(bytes, completion(equals(utf8.encode('test content'))));
    });

    test('readStream() returns null for non-existing file', () {
      expect(fs.readStream('${tempDir.path}/nonexistent.txt'), isNull);
    });

    test('get() returns file contents', () {
      final file = File('${tempDir.path}/test.txt');
      file.writeAsStringSync('test content');
      expect(fs.get(file.path), equals('test content'));
    });

    test('get() returns null for non-existing file', () {
      expect(fs.get('${tempDir.path}/nonexistent.txt'), isNull);
    });

    test('putFile() stores file on disk', () {
      final sourcePath = '${tempDir.path}/source.txt';
      final targetPath = '${tempDir.path}/target.txt';
      File(sourcePath).writeAsStringSync('test content');

      final result = fs.putFile(targetPath, File(sourcePath));
      expect(result, equals(targetPath));
      expect(File(targetPath).readAsStringSync(), equals('test content'));
    });

    test('putFileAs() stores file with custom name', () {
      final sourcePath = '${tempDir.path}/source.txt';
      final targetDir = '${tempDir.path}/subdir';
      File(sourcePath).writeAsStringSync('test content');

      final result = fs.putFileAs(targetDir, File(sourcePath), 'custom.txt');
      expect(result, equals('$targetDir/custom.txt'));
      expect(File('$targetDir/custom.txt').readAsStringSync(),
          equals('test content'));
    });

    test('writeStream() writes stream to file', () async {
      final path = '${tempDir.path}/test.txt';
      final content = 'test content';
      final stream = Stream.value(utf8.encode(content));

      expect(fs.writeStream(path, stream), isTrue);
      expect(File(path).readAsStringSync(), equals(content));
    });

    test('getVisibility() returns file visibility', () {
      final path = '${tempDir.path}/test.txt';
      fs.put(path, 'test');
      expect(
          fs.getVisibility(path), equals(FilesystemContract.visibilityPrivate));
    });

    test('setVisibility() changes file visibility', () {
      final path = '${tempDir.path}/test.txt';
      fs.put(path, 'test');
      expect(
          fs.setVisibility(path, FilesystemContract.visibilityPublic), isTrue);
      expect(
          fs.getVisibility(path), equals(FilesystemContract.visibilityPublic));
    });

    test('put() writes content to file', () {
      final path = '${tempDir.path}/test.txt';
      fs.put(path, 'test content');
      expect(File(path).readAsStringSync(), equals('test content'));
    });

    test('delete() removes file', () {
      final file = File('${tempDir.path}/test.txt');
      file.writeAsStringSync('test');
      expect(fs.delete(file.path), isTrue);
      expect(file.existsSync(), isFalse);
    });

    test('copy() duplicates file', () {
      final source = '${tempDir.path}/source.txt';
      final target = '${tempDir.path}/target.txt';
      fs.put(source, 'test content');

      expect(fs.copy(source, target), isTrue);
      expect(File(target).readAsStringSync(), equals('test content'));
    });

    test('move() relocates file', () {
      final source = '${tempDir.path}/source.txt';
      final target = '${tempDir.path}/target.txt';
      fs.put(source, 'test content');

      expect(fs.move(source, target), isTrue);
      expect(File(source).existsSync(), isFalse);
      expect(File(target).readAsStringSync(), equals('test content'));
    });

    test('size() returns file size', () {
      final path = '${tempDir.path}/test.txt';
      fs.put(path, 'test content');
      expect(fs.size(path), equals('test content'.length));
    });

    test('lastModified() returns timestamp', () {
      final path = '${tempDir.path}/test.txt';
      fs.put(path, 'test');
      expect(fs.lastModified(path), isPositive);
    });

    test('makeDirectory() creates directory', () {
      final path = '${tempDir.path}/newdir';
      expect(fs.makeDirectory(path), isTrue);
      expect(Directory(path).existsSync(), isTrue);
    });

    test('deleteDirectory() removes directory', () {
      final path = '${tempDir.path}/newdir';
      Directory(path).createSync();
      expect(fs.deleteDirectory(path), isTrue);
      expect(Directory(path).existsSync(), isFalse);
    });

    test('files() lists files in directory', () {
      fs.put('${tempDir.path}/file1.txt', 'test');
      fs.put('${tempDir.path}/file2.txt', 'test');
      Directory('${tempDir.path}/subdir').createSync();

      final files = fs.files(tempDir.path);
      expect(files, hasLength(2));
      expect(files, contains(endsWith('file1.txt')));
      expect(files, contains(endsWith('file2.txt')));
    });

    test('directories() lists directories', () {
      Directory('${tempDir.path}/dir1').createSync();
      Directory('${tempDir.path}/dir2').createSync();
      fs.put('${tempDir.path}/file.txt', 'test');

      final dirs = fs.directories(tempDir.path);
      expect(dirs, hasLength(2));
      expect(dirs, contains(endsWith('dir1')));
      expect(dirs, contains(endsWith('dir2')));
    });

    test('allFiles() lists files recursively', () {
      fs.put('${tempDir.path}/file1.txt', 'test');
      Directory('${tempDir.path}/subdir').createSync();
      fs.put('${tempDir.path}/subdir/file2.txt', 'test');

      final files = fs.allFiles(tempDir.path);
      expect(files, hasLength(2));
      expect(files, contains(endsWith('file1.txt')));
      expect(files, contains(endsWith('file2.txt')));
    });

    test('prepend() adds content to start of file', () {
      final path = '${tempDir.path}/test.txt';
      fs.put(path, 'world');
      fs.prepend(path, 'hello ');
      expect(File(path).readAsStringSync(), equals('hello world'));
    });

    test('append() adds content to end of file', () {
      final path = '${tempDir.path}/test.txt';
      fs.put(path, 'hello');
      fs.append(path, ' world');
      expect(File(path).readAsStringSync(), equals('hello world'));
    });

    test('isFile() returns true for files', () {
      final path = '${tempDir.path}/test.txt';
      fs.put(path, 'test');
      expect(fs.isFile(path), isTrue);
    });

    test('isFile() returns false for directories', () {
      final path = '${tempDir.path}/dir';
      Directory(path).createSync();
      expect(fs.isFile(path), isFalse);
    });
  });
}
