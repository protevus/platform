import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'package:illuminate_filesystem/filesystem.dart';

class MockFilesystem extends Mock implements Filesystem {
  final Map<String, String> _files = {};
  final Map<String, DateTime> _timestamps = {};
  final Set<String> _directories = {};

  @override
  bool exists(String path) =>
      _files.containsKey(path) || _directories.contains(path);

  @override
  bool makeDirectory(String path, [bool recursive = false]) {
    if (recursive) {
      final parts = path.split('/');
      var currentPath = '';
      for (final part in parts) {
        currentPath = currentPath.isEmpty ? part : '$currentPath/$part';
        _directories.add(currentPath);
      }
    } else {
      _directories.add(path);
    }
    return true;
  }

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
  int lastModified(String path) {
    return _timestamps[path]?.millisecondsSinceEpoch ?? 0;
  }

  void setModifiedTime(String path, DateTime time) {
    _timestamps[path] = time;
  }
}

void main() {
  group('BladeEngine Tests', () {
    late BladeEngine engine;
    late MockFilesystem files;
    late ViewFactory factory;
    late BladeCompiler compiler;

    setUp(() {
      files = MockFilesystem();
      factory = ViewFactory(EngineResolver(), FileViewFinder());
      compiler = BladeCompiler(files, 'cache/views', factory);
      engine = BladeEngine(files, compiler, factory);
    });

    test('evaluates simple echo statements', () async {
      // Setup source template
      files.put('resources/views/test/echo.blade.html', 'Hello {{ name }}');

      // Setup compiled template
      files.put('cache/views/test_blade_html.dart', '''
Future<String> render(Map<String, dynamic> data, ViewFactory factory) async {
  final buffer = StringBuffer();
  buffer.write('Hello ');
  buffer.write(data['name']);
  return buffer.toString();
}
''');

      final result = await engine
          .get('resources/views/test/echo.blade.html', {'name': 'World'});
      expect(result, equals('Hello World'));
    });

    test('evaluates if statements', () async {
      // Setup source template
      files.put(
          'resources/views/test/if.blade.html', '@if (show) Hello @endif');

      // Setup compiled template
      files.put('cache/views/test_blade_html.dart', '''
Future<String> render(Map<String, dynamic> data, ViewFactory factory) async {
  final buffer = StringBuffer();
  if (data['show']) {
    buffer.write('Hello');
  }
  return buffer.toString();
}
''');

      final result = await engine
          .get('resources/views/test/if.blade.html', {'show': true});
      expect(result, equals('Hello'));
    });

    test('evaluates foreach loops', () async {
      // Setup source template
      files.put('resources/views/test/foreach.blade.html',
          '@foreach (items as item) {{ item }} @endforeach');

      // Setup compiled template
      files.put('cache/views/test_blade_html.dart', '''
Future<String> render(Map<String, dynamic> data, ViewFactory factory) async {
  final buffer = StringBuffer();
  for (var item in data['items']) {
    buffer.write(item);
    buffer.write(' ');
  }
  return buffer.toString();
}
''');

      final result =
          await engine.get('resources/views/test/foreach.blade.html', {
        'items': ['a', 'b', 'c']
      });
      expect(result, equals('a b c '));
    });

    test('evaluates nested data access', () async {
      // Setup source template
      files.put('resources/views/test/nested.blade.html', '{{ user.name }}');

      // Setup compiled template
      files.put('cache/views/test_blade_html.dart', '''
Future<String> render(Map<String, dynamic> data, ViewFactory factory) async {
  final buffer = StringBuffer();
  buffer.write(data['user']['name']);
  return buffer.toString();
}
''');

      final result =
          await engine.get('resources/views/test/nested.blade.html', {
        'user': {'name': 'John'}
      });
      expect(result, equals('John'));
    });

    test('handles missing data gracefully', () async {
      // Setup source template
      files.put('resources/views/test/missing.blade.html', '{{ missing }}');

      // Setup compiled template
      files.put('cache/views/test_blade_html.dart', '''
Future<String> render(Map<String, dynamic> data, ViewFactory factory) async {
  final buffer = StringBuffer();
  buffer.write(data['missing'] ?? '');
  return buffer.toString();
}
''');

      final result =
          await engine.get('resources/views/test/missing.blade.html', {});
      expect(result, equals(''));
    });

    test('evaluates compiled code with helper functions', () async {
      // Setup source template
      files.put('resources/views/test/helper.blade.html', '{{{ content }}}');

      // Setup compiled template
      files.put('cache/views/test_blade_html.dart', '''
Future<String> render(Map<String, dynamic> data, ViewFactory factory) async {
  final buffer = StringBuffer();
  
  String e(String value, [bool doubleEncode = true]) {
    if (!doubleEncode) {
      value = value.replaceAll('&amp;', '&');
    }
    return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }

  buffer.write(e(data['content'].toString()));
  return buffer.toString();
}
''');

      final result = await engine.get('resources/views/test/helper.blade.html',
          {'content': '<p>Hello</p>'});
      expect(result, equals('&lt;p&gt;Hello&lt;/p&gt;'));
    });
  });
}
