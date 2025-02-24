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
  group('Blade Directives Tests', () {
    late BladeCompiler compiler;
    late MockFilesystem files;
    late ViewFactory factory;

    setUp(() {
      files = MockFilesystem();
      factory = ViewFactory(EngineResolver(), FileViewFinder());
      compiler = BladeCompiler(files, 'cache/views', factory);
    });

    group('If Statements', () {
      test('compiles if statements', () {
        files.put('test.blade.html', '@if (user) Hello @endif');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('if (data[\'user\'])'));
      });

      test('compiles if-else statements', () {
        files.put('test.blade.html', '@if (user) Hello @else Bye @endif');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('if (data[\'user\'])'));
        expect(compiled, contains('} else {'));
      });

      test('compiles if-elseif statements', () {
        files.put(
          'test.blade.html',
          '@if (admin) Admin @elseif (user) User @endif',
        );
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('if (data[\'admin\'])'));
        expect(compiled, contains('} else if (data[\'user\'])'));
      });
    });

    group('Loops', () {
      test('compiles foreach loops', () {
        files.put(
          'test.blade.html',
          '@foreach (users as user) {{ user.name }} @endforeach',
        );
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('for (var user in data[\'users\'])'));
      });

      test('compiles for loops', () {
        files.put(
          'test.blade.html',
          '@for (i = 0; i < 10; i++) {{ i }} @endfor',
        );
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('for (i = 0; i < 10; i++)'));
      });

      test('compiles while loops', () {
        files.put('test.blade.html', '@while (true) {{ i++ }} @endwhile');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('while (true)'));
      });
    });

    group('Layout Directives', () {
      test('compiles extends', () {
        files.put('test.blade.html', '@extends(\'layout\')');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('await factory.extendView(\'layout\')'));
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

      test('compiles yields', () {
        files.put('test.blade.html', '@yield(\'content\')');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('factory.yieldContent(\'content\')'));
      });
    });

    group('Component Directives', () {
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

      test('compiles slots', () {
        files.put('test.blade.html', '@slot(\'title\') Hello @endslot');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('factory.slot(\'title\')'));
        expect(compiled, contains('factory.endSlot()'));
      });
    });

    group('Include Directives', () {
      test('compiles includes', () {
        files.put('test.blade.html', '@include(\'header\')');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('await factory.make(\'header\')'));
      });

      test('compiles includes with data', () {
        files.put(
          'test.blade.html',
          '@include(\'header\', [\'title\' => \'Hello\'])',
        );
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('await factory.make(\'header\''));
        expect(compiled, contains('\'title\': \'Hello\''));
      });
    });

    group('Stack Directives', () {
      test('compiles push', () {
        files.put(
          'test.blade.html',
          '@push(\'scripts\') <script></script> @endpush',
        );
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('factory.startPush(\'scripts\')'));
        expect(compiled, contains('factory.stopPush()'));
      });

      test('compiles stack', () {
        files.put('test.blade.html', '@stack(\'scripts\')');
        compiler.compile('test.blade.html');

        final compiled = files.get('cache/views/test_blade_html.dart');
        expect(compiled, contains('factory.yieldPushContent(\'scripts\')'));
      });
    });
  });
}
