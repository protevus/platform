import 'package:test/test.dart';
import 'package:illuminate_view/src/engines/engine.dart';
import 'package:illuminate_view/src/engines/factory.dart';
import 'package:illuminate_view/src/engines/blade_engine.dart';
import 'package:illuminate_view/src/engines/finder.dart';
import 'package:illuminate_view/src/core/renderer.dart';

void main() {
  group('ViewFactory', () {
    late ViewFactory factory;
    late BladeEngine bladeEngine;

    setUp(() {
      factory = ViewFactory();
      final renderer = const Renderer();
      final finder = ViewFinder(['test/views'], ['.blade.html']);
      bladeEngine = BladeEngine(renderer, finder);
    });

    test('can register engine', () {
      factory.register(bladeEngine);
      expect(factory.engine('blade'), equals(bladeEngine));
    });

    test('returns default engine when no extension match', () {
      factory.register(bladeEngine);
      expect(factory.defaultEngine, equals(bladeEngine));
    });

    test('resolves engine by extension', () {
      factory.register(bladeEngine);

      // Should use blade engine for .blade.html
      expect(factory.engine('blade'), equals(bladeEngine));
      expect(factory.defaultEngine, equals(bladeEngine));
    });

    test('shares data with all engines', () {
      factory.register(bladeEngine);
      factory.share('key', 'value');

      expect(bladeEngine.shared['key'], equals('value'));
    });

    test('throws when no engines registered', () {
      expect(() => factory.defaultEngine, throwsException);
    });

    test('returns null when engine not found', () {
      factory.register(bladeEngine);
      expect(factory.engine('invalid'), isNull);
    });
  });
}
