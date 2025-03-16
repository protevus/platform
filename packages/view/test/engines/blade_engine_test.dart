import 'dart:io';
import 'package:test/test.dart';
import 'package:illuminate_view/src/engines/blade_engine.dart';
import 'package:illuminate_view/src/engines/finder.dart';
import 'package:illuminate_view/src/core/renderer.dart';
import 'package:path/path.dart' as path;

void main() {
  group('BladeEngine', () {
    late BladeEngine engine;
    late ViewFinder finder;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('blade_test_');
      finder = ViewFinder([tempDir.path], ['.blade.html']);
      engine = BladeEngine(const Renderer(), finder);

      // Create test views
      await File(path.join(tempDir.path, 'test.blade.html')).writeAsString('''
          <div>
            Hello {{ name }}
            <div if="showMessage">
              Message: {{ message }}
            </div>
          </div>
        ''');

      await File(path.join(tempDir.path, 'nested/view.blade.html'))
          .create(recursive: true)
        ..writeAsString('''
          <ul for-each="items" as="item">
            <li>{{ item }}</li>
          </ul>
        ''');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('renders basic template', () async {
      final html = await engine.get(path.join(tempDir.path, 'test.blade.html'),
          {'name': 'John', 'showMessage': true, 'message': 'Hello'});

      expect(html, contains('Hello John'));
      expect(html, contains('Message: Hello'));
    });

    test('handles conditional rendering', () async {
      final html = await engine.get(path.join(tempDir.path, 'test.blade.html'),
          {'name': 'John', 'showMessage': false, 'message': 'Hello'});

      expect(html, contains('Hello John'));
      expect(html, isNot(contains('Message: Hello')));
    });

    test('handles loops', () async {
      final html =
          await engine.get(path.join(tempDir.path, 'nested/view.blade.html'), {
        'items': ['one', 'two', 'three']
      });

      expect(html, contains('<li>\n    one\n  </li>'));
      expect(html, contains('<li>\n    two\n  </li>'));
      expect(html, contains('<li>\n    three\n  </li>'));
    });

    test('handles shared data', () async {
      engine.share('app_name', 'My App');

      final html = await engine
          .get(path.join(tempDir.path, 'test.blade.html'), {'name': 'John'});

      expect(html, contains('Hello John'));
    });

    test('handles creators', () async {
      var called = false;
      engine.creator('test', () {
        called = true;
        return {'name': 'Creator'};
      });

      await engine.get(path.join(tempDir.path, 'test.blade.html'), {});

      expect(called, isTrue);
    });

    test('handles composers', () async {
      var called = false;
      engine.composer('test', (view) {
        called = true;
        view['name'] = 'Composer';
      });

      await engine.get(path.join(tempDir.path, 'test.blade.html'), {});

      expect(called, isTrue);
    });

    test('caches view paths', () {
      final path = engine.find('test');
      expect(path, isNotNull);
      expect(engine.isCached('test'), isTrue);
      expect(engine.getCachedPath('test'), equals(path));
    });

    test('can flush cache', () {
      final path = engine.find('test');
      expect(path, isNotNull);
      expect(engine.isCached('test'), isTrue);

      engine.flushCache();
      expect(engine.isCached('test'), isFalse);
      expect(engine.getCachedPath('test'), isNull);
    });
  });
}
