import 'dart:io';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'mocks/view_mocks.mocks.dart';

void main() {
  group('ViewFactory Tests', () {
    late ViewFactory factory;
    late MockViewEngine engine;
    late MockViewFactoryContract mockFactory;
    late FileViewFinder finder;
    late EngineResolver engines;

    Future<void> createView(String name, [String content = '']) async {
      // Create base views directory
      final baseDir = Directory('views');
      if (!baseDir.existsSync()) {
        baseDir.createSync();
      }

      final segments = name.split('/');
      var currentPath = baseDir.path;

      // Create all parent directories if needed
      for (var i = 0; i < segments.length - 1; i++) {
        currentPath = '$currentPath/${segments[i]}';
        final dir = Directory(currentPath);
        if (!dir.existsSync()) {
          dir.createSync();
        }
      }

      // Create the view file
      final file = File('views/$name.blade.html');
      await file.writeAsString(content);
    }

    setUp(() async {
      engines = EngineResolver();
      finder = FileViewFinder();
      factory = ViewFactory(engines, finder);
      engine = MockViewEngine();
      mockFactory = MockViewFactoryContract();

      // Register test engine and extension
      engines.register('blade', () => engine);
      factory.addExtension('blade.html', 'blade');
      finder.addLocation('views');

      when(engine.get(any, any)).thenAnswer((_) async => 'rendered');

      // Create test views
      await createView('view');
    });

    tearDown(() {
      // Clean up test views
      final dir = Directory('views');
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('make creates new view instance with proper path and engine',
        () async {
      when(engine.get(any, any)).thenAnswer((_) async => 'contents');

      final view = await factory.make('view', {'foo': 'bar'});
      expect(view, isA<View>());
      expect(view.name, equals('view'));
      expect(view.data['foo'], equals('bar'));
    });

    test('exists passes and fails views', () {
      expect(factory.exists('nonexistent'), false);
      expect(factory.exists('view'), true);
    });

    test('shared data is merged with view data', () async {
      // Setup shared data
      factory.share('shared', 'data');
      when(factory.shared).thenReturn({'shared': 'data'});

      final view = await factory.make('view', {'foo': 'bar'});
      expect(view.toArray()['shared'], equals('data'));
      expect(view.toArray()['foo'], equals('bar'));
    });

    test('composers are properly registered', () async {
      var called = false;

      factory.composer('view', (String event, List<dynamic> args) {
        called = true;
        (args[0] as View).withData('composed', true);
      });

      final view = await factory.make('view');
      factory.callComposer(view);

      expect(called, isTrue);
      expect(view.data['composed'], isTrue);
    });

    test('sections are properly managed', () {
      factory.startSection('header', 'default');
      expect(factory.hasSection('header'), isTrue);
      expect(factory.getSection('header'), equals('default'));

      factory.startSection('content');
      factory.stopSection();
      expect(factory.hasSection('content'), isTrue);

      factory.flushSections();
      expect(factory.hasSection('header'), isFalse);
    });

    test('parent placeholder is replaced', () {
      factory.startSection('content', 'parent content');
      final content = factory.yieldContent('content', 'child content');
      expect(content, equals('child content'));
      expect(factory.getSection('content'), equals('parent content'));
    });

    test('stacks are properly managed', () {
      factory.startPush('scripts', '<script>first</script>');
      factory.stopPush();

      factory.startPush('scripts', '<script>second</script>');
      factory.stopPush();

      final content = factory.yieldPushContent('scripts');
      expect(content, contains('first'));
      expect(content, contains('second'));
    });

    test('rendering state is properly managed', () {
      expect(factory.renderCount, equals(0));

      final view = ViewImpl(factory, engine, 'test', 'test.blade.html');
      factory.startRender(view);
      expect(factory.renderCount, equals(1));

      factory.stopRender();
      expect(factory.renderCount, equals(0));
      expect(factory.doneRendering, isTrue);
    });
  });
}
