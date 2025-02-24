import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'package:illuminate_filesystem/filesystem.dart';
import 'package:illuminate_contracts/contracts.dart';
import '../mocks/view_mocks.mocks.dart';

class MockFilesystem extends Mock implements Filesystem {
  @override
  String? get(String path) => '';

  @override
  bool exists(String path) => true;

  @override
  bool put(String path, dynamic contents, [dynamic options]) => true;

  @override
  String path(String path) => path;
}

void main() {
  group('Blade Directives Tests', () {
    late BladeCompiler compiler;
    late MockFilesystem files;
    late ViewFactory factory;
    late String compiledOutput;

    setUp(() {
      compiledOutput = '';
      files = MockFilesystem();
      factory = ViewFactory(EngineResolver(), FileViewFinder());
      compiler = BladeCompiler(files, 'cache/views', factory);

      // Setup default mocks
      when(files.exists('cache/views')).thenReturn(true);
      when(files.put('cache/views/test_blade_html.dart', any))
          .thenAnswer((invocation) {
        compiledOutput = invocation.positionalArguments[1] as String;
        return true;
      });
    });

    group('If Statements', () {
      test('compiles if statements', () {
        when(files.get('test.blade.html'))
            .thenReturn('@if (user) Hello @endif');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('if (data[\'user\'])'));
      });

      test('compiles if-else statements', () {
        when(files.get('test.blade.html'))
            .thenReturn('@if (user) Hello @else Bye @endif');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('if (data[\'user\'])'));
        expect(compiledOutput, contains('} else {'));
      });

      test('compiles if-elseif statements', () {
        when(files.get('test.blade.html'))
            .thenReturn('@if (admin) Admin @elseif (user) User @endif');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('if (data[\'admin\'])'));
        expect(compiledOutput, contains('} else if (data[\'user\'])'));
      });
    });

    group('Loops', () {
      test('compiles foreach loops', () {
        when(files.get('test.blade.html'))
            .thenReturn('@foreach (users as user) {{ user.name }} @endforeach');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('for (var user in data[\'users\'])'));
      });

      test('compiles for loops', () {
        when(files.get('test.blade.html'))
            .thenReturn('@for (i = 0; i < 10; i++) {{ i }} @endfor');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('for (i = 0; i < 10; i++)'));
      });

      test('compiles while loops', () {
        when(files.get('test.blade.html'))
            .thenReturn('@while (true) {{ i++ }} @endwhile');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('while (true)'));
      });
    });

    group('Layout Directives', () {
      test('compiles extends', () {
        when(files.get('test.blade.html')).thenReturn('@extends(\'layout\')');

        compiler.compile('test.blade.html');

        expect(
            compiledOutput, contains('await factory.extendView(\'layout\')'));
      });

      test('compiles sections', () {
        when(files.get('test.blade.html'))
            .thenReturn('@section(\'content\') Hello @endsection');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('factory.startSection(\'content\')'));
        expect(compiledOutput, contains('factory.stopSection()'));
      });

      test('compiles yields', () {
        when(files.get('test.blade.html')).thenReturn('@yield(\'content\')');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('factory.yieldContent(\'content\')'));
      });
    });

    group('Component Directives', () {
      test('compiles components', () {
        when(files.get('test.blade.html'))
            .thenReturn('@component(\'alert\') Message @endcomponent');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('factory.startComponent(\'alert\')'));
        expect(compiledOutput, contains('factory.renderComponent()'));
      });

      test('compiles slots', () {
        when(files.get('test.blade.html'))
            .thenReturn('@slot(\'title\') Hello @endslot');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('factory.slot(\'title\')'));
        expect(compiledOutput, contains('factory.endSlot()'));
      });
    });

    group('Include Directives', () {
      test('compiles includes', () {
        when(files.get('test.blade.html')).thenReturn('@include(\'header\')');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('await factory.make(\'header\')'));
      });

      test('compiles includes with data', () {
        when(files.get('test.blade.html'))
            .thenReturn('@include(\'header\', [\'title\' => \'Hello\'])');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('await factory.make(\'header\''));
        expect(compiledOutput, contains('\'title\': \'Hello\''));
      });
    });

    group('Stack Directives', () {
      test('compiles push', () {
        when(files.get('test.blade.html'))
            .thenReturn('@push(\'scripts\') <script></script> @endpush');

        compiler.compile('test.blade.html');

        expect(compiledOutput, contains('factory.startPush(\'scripts\')'));
        expect(compiledOutput, contains('factory.stopPush()'));
      });

      test('compiles stack', () {
        when(files.get('test.blade.html')).thenReturn('@stack(\'scripts\')');

        compiler.compile('test.blade.html');

        expect(
            compiledOutput, contains('factory.yieldPushContent(\'scripts\')'));
      });
    });
  });
}
