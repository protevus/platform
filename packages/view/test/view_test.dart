import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'mocks/view_mocks.mocks.dart';

void main() {
  group('View Tests', () {
    late ViewImpl view;
    late MockViewEngine engine;
    late MockViewFactoryContract factory;

    setUp(() {
      engine = MockViewEngine();
      factory = MockViewFactoryContract();
      view = ViewImpl(factory, engine, 'view', 'view.blade.html');

      when(factory.shared).thenReturn({});
      when(engine.get(any, any)).thenAnswer((_) async => 'rendered');
    });

    test('data can be set on view', () {
      view.withData('key', 'value');
      expect(view.data['key'], equals('value'));

      view.withManyData({'foo': 'bar'});
      expect(view.data['foo'], equals('bar'));
    });

    test('render properly renders view', () async {
      await view.render();

      verifyInOrder([
        factory.startRender(view),
        engine.get('view.blade.html', view.data),
        factory.stopRender(),
      ]);
    });

    test('view getters setters', () {
      expect(view.name, equals('view'));
      expect(view.path, equals('view.blade.html'));

      view.parent = ViewImpl(factory, engine, 'parent', 'parent.blade.html');
      expect(view.parent?.name, equals('parent'));
    });

    test('view to array', () {
      view.withData('key', 'value');
      final data = view.toArray();
      expect(data['key'], equals('value'));
    });

    test('view to html', () async {
      when(engine.get('view.blade.html', any))
          .thenAnswer((_) async => '<h1>Hello</h1>');
      final html = await view.render();
      expect(html, equals('<h1>Hello</h1>'));
    });
  });
}
