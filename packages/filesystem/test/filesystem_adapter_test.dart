import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:platform_filesystem/filesystem.dart';
import 'package:platform_contracts/contracts.dart';

class MockDriver {
  final Map<String, dynamic> storage = {};
  final Map<String, String> _visibilityMap = {};

  bool has(String path) => storage.containsKey(path);

  String? read(String path) => storage[path] as String?;

  Stream<List<int>>? readStream(String path) {
    final content = storage[path];
    if (content == null) return null;
    return Stream.value(utf8.encode(content as String));
  }

  void write(String path, dynamic contents, [dynamic options]) {
    storage[path] = contents.toString();
  }

  void writeStream(String path, Stream<List<int>> contents, [dynamic options]) {
    // Not implemented in mock
  }

  String getVisibility(String path) => _visibilityMap[path] ?? 'private';

  void setVisibility(String path, String visibility) {
    _visibilityMap[path] = visibility;
  }

  void delete(String path) {
    storage.remove(path);
    _visibilityMap.remove(path);
  }

  void copy(String from, String to) {
    storage[to] = storage[from];
    _visibilityMap[to] = _visibilityMap[from] ?? 'private';
  }

  void move(String from, String to) {
    copy(from, to);
    delete(from);
  }

  int fileSize(String path) => (storage[path] as String).length;

  int lastModified(String path) =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000;

  List<FileInfo> listContents(String directory, bool recursive) {
    return storage.keys
        .where((path) => path.startsWith(directory))
        .map((path) => FileInfo(path, isFile: true))
        .toList();
  }

  void createDirectory(String path) {
    // Not implemented in mock
  }

  void deleteDirectory(String path) {
    storage.removeWhere((key, _) => key.startsWith(path));
    _visibilityMap.removeWhere((key, _) => key.startsWith(path));
  }
}

class FileInfo {
  final String path;
  final bool isFile;
  final bool isDir;

  FileInfo(this.path, {required this.isFile}) : isDir = !isFile;
}

void main() {
  late Directory tempDir;
  late MockDriver driver;
  late FilesystemAdapter adapter;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('filesystem_adapter_test_');
    driver = MockDriver();
    adapter = FilesystemAdapter(driver, null);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('FilesystemAdapter', () {
    test('exists() checks driver storage', () {
      driver.write('test.txt', 'content');
      expect(adapter.exists('test.txt'), isTrue);
      expect(adapter.exists('nonexistent.txt'), isFalse);
    });

    test('get() returns file contents', () {
      driver.write('test.txt', 'test content');
      expect(adapter.get('test.txt'), equals('test content'));
    });

    test('readStream() returns file stream', () {
      driver.write('test.txt', 'test content');
      final stream = adapter.readStream('test.txt');
      expect(stream, isNotNull);
      expect(
        stream!
            .toList()
            .then((chunks) => utf8.decode(chunks.expand((x) => x).toList())),
        completion(equals('test content')),
      );
    });

    test('put() writes to driver storage', () {
      expect(adapter.put('test.txt', 'test content'), isTrue);
      expect(driver.read('test.txt'), equals('test content'));
    });

    test('delete() removes from driver storage', () {
      driver.write('test.txt', 'content');
      expect(adapter.delete('test.txt'), isTrue);
      expect(driver.has('test.txt'), isFalse);
    });

    test('copy() duplicates in driver storage', () {
      driver.write('source.txt', 'content');
      expect(adapter.copy('source.txt', 'target.txt'), isTrue);
      expect(driver.read('target.txt'), equals('content'));
    });

    test('move() relocates in driver storage', () {
      driver.write('source.txt', 'content');
      expect(adapter.move('source.txt', 'target.txt'), isTrue);
      expect(driver.has('source.txt'), isFalse);
      expect(driver.read('target.txt'), equals('content'));
    });

    test('getVisibility() returns file visibility', () {
      driver.write('test.txt', 'content');
      driver.setVisibility('test.txt', 'public');
      expect(adapter.getVisibility('test.txt'),
          equals(FilesystemContract.visibilityPublic));
    });

    test('setVisibility() updates file visibility', () {
      driver.write('test.txt', 'content');
      expect(
          adapter.setVisibility(
              'test.txt', FilesystemContract.visibilityPublic),
          isTrue);
      expect(driver.getVisibility('test.txt'), equals('public'));
    });

    test('size() returns content length', () {
      driver.write('test.txt', 'test content');
      expect(adapter.size('test.txt'), equals('test content'.length));
    });

    test('lastModified() returns timestamp', () {
      driver.write('test.txt', 'content');
      expect(adapter.lastModified('test.txt'), isPositive);
    });

    test('files() lists files from driver', () {
      driver.write('file1.txt', 'content');
      driver.write('file2.txt', 'content');
      final files = adapter.files();
      expect(files, hasLength(2));
      expect(files, contains('file1.txt'));
      expect(files, contains('file2.txt'));
    });

    test('makeDirectory() creates directory in driver', () {
      expect(adapter.makeDirectory('test_dir'), isTrue);
    });

    test('deleteDirectory() removes directory from driver', () {
      driver.write('test_dir/file.txt', 'content');
      expect(adapter.deleteDirectory('test_dir'), isTrue);
      expect(driver.has('test_dir/file.txt'), isFalse);
    });
  });
}
