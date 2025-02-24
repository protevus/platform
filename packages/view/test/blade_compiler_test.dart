import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'package:illuminate_filesystem/filesystem.dart';

class MockFilesystem extends Mock implements Filesystem {
  final Map<String, String> _files = {};
  final Map<String, DateTime> _timestamps = {};
  final Set<String> _directories = {};

  @override
  bool exists(String path) => _files.containsKey(path);

  @override
  String? get(String path) => _files[path];

  @override
  bool put(String path, dynamic contents, [dynamic options]) {
    _files[path] = contents.toString();
    _timestamps[path] = DateTime.now();
    return true;
  }

  @override
  String path(String path) => path;

  @override
  bool makeDirectory(String path, [bool recursive = false]) {
    _directories.add(path);
    return true;
  }

  @override
  int lastModified(String path) {
    return _timestamps[path]?.millisecondsSinceEpoch ?? 0;
  }

  void setModifiedTime(String path, DateTime time) {
    _timestamps[path] = time;
  }
}

void main() {
  group('BladeCompiler Tests', () {
    late BladeCompiler compiler;
    late MockFilesystem files;
    late ViewFactory factory;

    setUp(() {
      files = MockFilesystem();
      factory = ViewFactory(EngineResolver(), FileViewFinder());
      compiler = BladeCompiler(files, 'cache/views', factory);
    });

    test('isExpired returns true if compiled file does not exist', () {
      expect(compiler.isExpired('test.blade.html'), isTrue);
    });

    test('isExpired returns true when source is newer than cache', () {
      // Setup source file
      files.put('test.blade.html', 'content');
      files.setModifiedTime('test.blade.html', DateTime.now());

      // Setup older cache file
      files.put('cache/views/test_blade_html.dart', 'compiled');
      files.setModifiedTime(
        'cache/views/test_blade_html.dart',
        DateTime.now().subtract(Duration(hours: 1)),
      );

      expect(compiler.isExpired('test.blade.html'), isTrue);
    });

    test('isExpired returns false when cache is newer', () {
      // Setup source file
      files.put('test.blade.html', 'content');
      files.setModifiedTime(
        'test.blade.html',
        DateTime.now().subtract(Duration(hours: 1)),
      );

      // Setup newer cache file
      files.put('cache/views/test_blade_html.dart', 'compiled');
      files.setModifiedTime('cache/views/test_blade_html.dart', DateTime.now());

      expect(compiler.isExpired('test.blade.html'), isFalse);
    });

    test('getCompiledPath returns correct cache path', () {
      expect(
        compiler.getCompiledPath('views/test.blade.html'),
        equals('cache/views/views_test_blade_html.dart'),
      );
    });

    test('compile processes template and saves to cache', () {
      files.put('test.blade.html', '@if (user) Hello @endif');
      compiler.compile('test.blade.html');

      final compiled = files.get('cache/views/test_blade_html.dart');
      expect(compiled, contains('if (data[\'user\'])'));
    });

    test('compile creates cache directory if needed', () {
      files.put('test.blade.html', 'content');
      compiler.compile('test.blade.html');

      expect(files.exists('cache/views/test_blade_html.dart'), isTrue);
    });

    group('Directive Compilation', () {
      test('compiles if statements', () {
        files.put('test.blade.html', '@if (user) Hello @endif');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('if (data[\'user\'])'));
      });

      test('compiles foreach loops', () {
        files.put(
          'test.blade.html',
          '@foreach (users as user) {{ user.name }} @endforeach',
        );
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('for (var user in data[\'users\'])'));
      });

      test('compiles sections', () {
        files.put(
          'test.blade.html',
          '@section(\'content\') Hello @endsection',
        );
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('factory.startSection(\'content\')'));
        expect(compiled, contains('factory.stopSection()'));
      });

      test('compiles extends', () {
        files.put('test.blade.html', '@extends(\'layout\')');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('await factory.extendView(\'layout\')'));
      });

      test('compiles includes', () {
        files.put('test.blade.html', '@include(\'header\')');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('await factory.make(\'header\')'));
      });

      test('compiles components', () {
        files.put(
          'test.blade.html',
          '@component(\'alert\') Message @endcomponent',
        );
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('factory.startComponent(\'alert\')'));
        expect(compiled, contains('factory.renderComponent()'));
      });
    });
  });
}
