import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'mocks/view_mocks.mocks.dart';

void main() {
  group('View Tests', () {
    late View view;
    late MockViewFactoryContract factory;
    late MockViewEngine engine;

    setUp(() {
      factory = MockViewFactoryContract();
      engine = MockViewEngine();
    });

    test('data can be set on view', () {
      view = ViewImpl(factory, engine, 'view', 'path');

      view.withData('foo', 'bar');
      view.withManyData({'baz': 'boom'});

      expect(view.data, {'foo': 'bar', 'baz': 'boom'});

      // Test fluent interface
      view = ViewImpl(factory, engine, 'view', 'path')
        ..withData('foo', 'bar')
        ..withData('baz', 'boom');

      expect(view.data, {'foo': 'bar', 'baz': 'boom'});
    });

    test('render properly renders view', () async {
      view = ViewImpl(factory, engine, 'view', 'path', {'foo': 'bar'});

      when(factory.startRender(view)).thenReturn(null);
      when(factory.callComposer(view)).thenReturn(null);
      when(factory.shared).thenReturn({'shared': 'foo'});
      when(engine.get('path', {'foo': 'bar', 'shared': 'foo'}))
          .thenAnswer((_) async => 'contents');
      when(factory.stopRender()).thenReturn(null);
      when(factory.doneRendering).thenReturn(true);

      expect(await view.render(), 'contents');

      verify(factory.startRender(view)).called(1);
      verify(factory.callComposer(view)).called(1);
      verify(engine.get('path', {'foo': 'bar', 'shared': 'foo'})).called(1);
      verify(factory.stopRender()).called(1);
    });

    test('view getters setters', () {
      view = ViewImpl(factory, engine, 'view', 'path', {'foo': 'bar'});

      expect(view.name, 'view');
      expect(view.path, 'path');
      expect(view.data['foo'], 'bar');

      // Test parent view
      final parent = ViewImpl(factory, engine, 'parent', 'parent.path');
      view.parent = parent;

      expect(view.hasParent, true);
      expect(view.parent, parent);
    });

    test('view to array', () {
      view = ViewImpl(factory, engine, 'view', 'path', {'foo': 'bar'});

      expect(view.toArray(), {'foo': 'bar'});
    });

    test('view to html', () {
      view = ViewImpl(factory, engine, 'view', 'path');

      expect(view.toHtml(), 'View(view)');
    });

    test('view to string', () {
      view = ViewImpl(factory, engine, 'view', 'path');

      expect(view.toString(), 'View(view)');
    });
  });
}
