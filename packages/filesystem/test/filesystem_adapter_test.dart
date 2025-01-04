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
    // Set default visibility
    if (!_visibilityMap.containsKey(path)) {
      _visibilityMap[path] = 'private';
    }
  }

  void writeStream(String path, Stream<List<int>> contents, [dynamic options]) {
    // For testing, we'll just store the stream's first value synchronously
    contents.listen((chunk) {
      write(path, utf8.decode(chunk));
    });
  }

  String visibility(String path) => _visibilityMap[path] ?? 'private';

  void setVisibility(String path, String visibility) {
    if (!storage.containsKey(path)) return;
    _visibilityMap[path] = visibility;
  }

  void delete(String path) {
    storage.remove(path);
    _visibilityMap.remove(path);
  }

  void copy(String from, String to) {
    if (!storage.containsKey(from)) return;
    storage[to] = storage[from];
    _visibilityMap[to] = _visibilityMap[from] ?? 'private';
  }

  void move(String from, String to) {
    if (!storage.containsKey(from)) return;
    copy(from, to);
    delete(from);
  }

  int fileSize(String path) => (storage[path] as String).length;

  int lastModified(String path) =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000;

  List<FileInfo> listContents(String directory, bool recursive) {
    final prefix = directory.isEmpty ? '' : '$directory/';
    final paths = storage.keys.where((path) {
      // Skip directories (paths ending with /)
      if (path.endsWith('/')) return false;

      // If no directory specified, include all files at root
      if (directory.isEmpty) {
        return !path.contains('/');
      }

      // Check if path is in the specified directory
      if (!path.startsWith(prefix)) return false;

      // For non-recursive, only include direct children
      if (!recursive) {
        final relativePath = path.substring(prefix.length);
        return !relativePath.contains('/');
      }

      return true;
    }).toList();

    // Sort paths
    paths.sort();

    // Create FileInfo objects with correct paths
    return paths.map((path) => FileInfo(path, isFile: true)).toList();
  }

  void createDirectory(String path) {
    // Mark as directory by adding trailing slash
    storage['$path/'] = '';
    _visibilityMap['$path/'] = 'private';
  }

  void deleteDirectory(String path) {
    final prefix = path.endsWith('/') ? path : '$path/';
    storage.removeWhere((key, _) => key.startsWith(prefix));
    _visibilityMap.removeWhere((key, _) => key.startsWith(prefix));
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
      driver.setVisibility('test.txt', 'private');
      expect(adapter.getVisibility('test.txt'),
          equals(FilesystemContract.visibilityPrivate));
    });

    test('setVisibility() updates file visibility', () {
      driver.write('test.txt', 'content');
      expect(
          adapter.setVisibility(
              'test.txt', FilesystemContract.visibilityPublic),
          isTrue);
      expect(driver.visibility('test.txt'), equals('public'));
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
      // Create test files
      driver.write('file1.txt', 'content');
      driver.write('file2.txt', 'content');
      driver.write('subdir/file3.txt', 'content');

      // Verify files were created
      expect(driver.storage.containsKey('file1.txt'), isTrue);
      expect(driver.storage.containsKey('file2.txt'), isTrue);
      expect(driver.storage.containsKey('subdir/file3.txt'), isTrue);

      // Test root directory listing (non-recursive)
      final files = adapter.files();
      expect(files, hasLength(2));
      expect(files, containsAll(['file1.txt', 'file2.txt']));

      // Test subdirectory listing
      final subFiles = adapter.files('subdir');
      expect(subFiles, hasLength(1));
      expect(subFiles, contains('file3.txt'));

      // Test recursive listing
      final allFiles = adapter.files('', true);
      expect(allFiles, hasLength(3));
      expect(allFiles,
          containsAll(['file1.txt', 'file2.txt', 'subdir/file3.txt']));
    });

    test('makeDirectory() creates directory in driver', () {
      expect(adapter.makeDirectory('test_dir'), isTrue);
      expect(driver.has('test_dir/'), isTrue);
    });

    test('deleteDirectory() removes directory from driver', () {
      driver.write('test_dir/file.txt', 'content');
      expect(adapter.deleteDirectory('test_dir'), isTrue);
      expect(driver.has('test_dir/file.txt'), isFalse);
    });
  });
}
