import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'package:illuminate_filesystem/filesystem.dart';
import 'mocks/view_mocks.mocks.dart';

class MockFilesystem extends Mock implements Filesystem {}

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
      when(files.exists('cache/views/foo_blade_html.dart')).thenReturn(false);

      expect(compiler.isExpired('foo.blade.html'), isTrue);

      verify(files.exists('cache/views/foo_blade_html.dart')).called(1);
    });

    test('isExpired returns true when source is newer than cache', () {
      when(files.exists('cache/views/foo_blade_html.dart')).thenReturn(true);
      when(files.lastModified('foo.blade.html')).thenReturn(200);
      when(files.lastModified('cache/views/foo_blade_html.dart'))
          .thenReturn(100);

      expect(compiler.isExpired('foo.blade.html'), isTrue);
    });

    test('isExpired returns false when cache is newer', () {
      when(files.exists('cache/views/foo_blade_html.dart')).thenReturn(true);
      when(files.lastModified('foo.blade.html')).thenReturn(100);
      when(files.lastModified('cache/views/foo_blade_html.dart'))
          .thenReturn(200);

      expect(compiler.isExpired('foo.blade.html'), isFalse);
    });

    test('getCompiledPath returns correct cache path', () {
      final path = compiler.getCompiledPath('foo.blade.html');
      expect(path, equals('cache/views/foo_blade_html.dart'));
    });

    test('compile processes template and saves to cache', () {
      when(files.get('foo.blade.html')).thenReturn('Hello {{ name }}');
      when(files.exists('cache/views')).thenReturn(true);

      compiler.compile('foo.blade.html');

      verify(files.get('foo.blade.html')).called(1);
      verify(files.put(
        'cache/views/foo_blade_html.dart',
        contains('buffer.write(e(data[\'name\']));'),
      )).called(1);
    });

    test('compile creates cache directory if needed', () {
      when(files.get('foo.blade.html')).thenReturn('Hello {{ name }}');
      when(files.exists('cache/views')).thenReturn(false);

      compiler.compile('foo.blade.html');

      verify(files.makeDirectory('cache/views')).called(1);
    });

    group('Directive Compilation', () {
      test('compiles if statements', () {
        final template = '''
          @if(user != null)
            Hello {{ user.name }}
          @else
            Hello Guest
          @endif
        ''';

        when(files.get('test.blade.html')).thenReturn(template);
        when(files.exists('cache/views')).thenReturn(true);
        compiler.compile('test.blade.html');

        verify(files.get('test.blade.html')).called(1);
        verify(files.put(
          'cache/views/test_blade_html.dart',
          allOf(
              contains('if (data[\'user\'] != null)'),
              contains('buffer.write(e(data[\'user\'][\'name\']))'),
              contains('} else {'),
              contains('buffer.write(\'Hello Guest\')')),
        )).called(1);
      });

      test('compiles foreach loops', () {
        final template = '''
          @foreach(items as item)
            <li>{{ item.name }}</li>
          @endforeach
        ''';

        when(files.get('test.blade.html')).thenReturn(template);
        when(files.exists('cache/views')).thenReturn(true);
        compiler.compile('test.blade.html');

        verify(files.get('test.blade.html')).called(1);
        verify(files.put(
          'cache/views/test_blade_html.dart',
          allOf(
              contains('for (var item in data[\'items\'])'),
              contains('buffer.write(\'<li>\')'),
              contains('buffer.write(e(item[\'name\']))'),
              contains('buffer.write(\'</li>\')')),
        )).called(1);
      });

      test('compiles sections', () {
        final template = '''
          @section('content')
            <h1>{{ title }}</h1>
          @endsection
        ''';

        when(files.get('test.blade.html')).thenReturn(template);
        when(files.exists('cache/views')).thenReturn(true);
        compiler.compile('test.blade.html');

        verify(files.get('test.blade.html')).called(1);
        verify(files.put(
          'cache/views/test_blade_html.dart',
          allOf(
              contains('factory.startSection(\'content\')'),
              contains('buffer.write(\'<h1>\')'),
              contains('buffer.write(e(data[\'title\']))'),
              contains('factory.stopSection()')),
        )).called(1);
      });

      test('compiles extends', () {
        final template = '''
          @extends('layouts.app')
          @section('content')
            Page Content
          @endsection
        ''';

        when(files.get('test.blade.html')).thenReturn(template);
        when(files.exists('cache/views')).thenReturn(true);
        compiler.compile('test.blade.html');

        verify(files.get('test.blade.html')).called(1);
        verify(files.put(
          'cache/views/test_blade_html.dart',
          allOf(
              contains('await factory.extendView(\'layouts.app\')'),
              contains('factory.startSection(\'content\')'),
              contains('buffer.write(\'Page Content\')')),
        )).called(1);
      });

      test('compiles includes', () {
        final template = "@include('header', {'title': 'Welcome'})";

        when(files.get('test.blade.html')).thenReturn(template);
        when(files.exists('cache/views')).thenReturn(true);
        compiler.compile('test.blade.html');

        verify(files.get('test.blade.html')).called(1);
        verify(files.put(
          'cache/views/test_blade_html.dart',
          allOf(contains('await factory.make(\'header\''),
              contains('\'title\': \'Welcome\'')),
        )).called(1);
      });

      test('compiles components', () {
        final template = '''
          @component('alert')
            @slot('title')
              Alert Title
            @endslot
            Alert content
          @endcomponent
        ''';

        when(files.get('test.blade.html')).thenReturn(template);
        when(files.exists('cache/views')).thenReturn(true);
        compiler.compile('test.blade.html');

        verify(files.get('test.blade.html')).called(1);
        verify(files.put(
          'cache/views/test_blade_html.dart',
          allOf(
              contains('factory.startComponent(\'alert\')'),
              contains('factory.slot(\'title\')'),
              contains('buffer.write(\'Alert Title\')'),
              contains('buffer.write(\'Alert content\')')),
        )).called(1);
      });
    });
  });
}
