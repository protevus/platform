import 'package:test/test.dart';
import 'package:illuminate_view/src/engines/engine.dart';
import 'package:illuminate_view/src/engines/blade_engine.dart';
import 'package:illuminate_view/src/engines/finder.dart';
import 'package:illuminate_view/src/core/renderer.dart';

void main() {
  group('ViewEngine', () {
    late BladeEngine engine;
    late ViewFinder finder;
    late Renderer renderer;

    setUp(() {
      renderer = const Renderer();
      finder = ViewFinder(['test/views'], ['.blade.html']);
      engine = BladeEngine(renderer, finder);
    });

    test('has correct name', () {
      expect(engine.name, equals('blade'));
    });

    test('has correct extensions', () {
      expect(engine.extensions, equals(['.blade.html']));
    });

    test('can share data', () {
      engine.share('key', 'value');
      expect(engine.shared['key'], equals('value'));
    });

    test('shared data is immutable', () {
      engine.share('key', 'value');
      expect(() => engine.shared['key'] = 'new value', throwsUnsupportedError);
    });

    test('can cache paths', () {
      engine.creator('test', () {});
      expect(engine.isCached('test'), isFalse);

      final path = engine.find('test');
      expect(path, isNull);

      engine.flushCache();
      expect(engine.isCached('test'), isFalse);
    });

    test('can register creators', () {
      var called = false;
      engine.creator('test', () => called = true);

      // Test single creator
      expect(called, isFalse);

      // Test multiple creators
      engine.creators({
        () => called = true: ['test1', 'test2']
      });
    });

    test('can register composers', () {
      var called = false;
      engine.composer('test', () => called = true);

      // Test single composer
      expect(called, isFalse);

      // Test multiple composers
      engine.composers({
        () => called = true: ['test1', 'test2']
      });
    });
  });
}
