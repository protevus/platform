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

    setUp(() {
      engines = EngineResolver();
      finder = FileViewFinder();
      factory = ViewFactory(engines, finder);
      engine = MockViewEngine();
      mockFactory = MockViewFactoryContract();

      // Register test engine
      engines.register('php', () => engine);
      finder.addExtension('php');
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
      expect(factory.exists('view'), false);

      factory.addLocation('views');
      finder.addExtension('php');

      expect(factory.exists('view'), true);
    });

    test('shared data is merged with view data', () async {
      factory.share('shared', 'data');

      final view = await factory.make('view', {'foo': 'bar'});
      expect(view.data['shared'], equals('data'));
      expect(view.data['foo'], equals('bar'));
    });

    test('composers are properly registered', () async {
      var called = false;

      factory.composer('view', (view) {
        called = true;
        view.withData('composed', true);
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
      expect(content, contains('child content'));
      expect(content, contains('parent content'));
    });

    test('stacks are properly managed', () {
      factory.startPush('scripts');
      factory.stopPush();

      factory.startPush('scripts');
      factory.stopPush();

      final content = factory.yieldPushContent('scripts');
      expect(content.isNotEmpty, isTrue);
    });

    test('rendering state is properly managed', () {
      expect(factory.renderCount, equals(0));

      final view = ViewImpl(factory, engine, 'test', 'test.php');
      factory.startRender(view);
      expect(factory.renderCount, equals(1));

      factory.stopRender();
      expect(factory.renderCount, equals(0));
      expect(factory.doneRendering, isTrue);
    });
  });
}
