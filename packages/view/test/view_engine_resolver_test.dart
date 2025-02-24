import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'mocks/view_mocks.mocks.dart';

void main() {
  group('ViewEngineResolver Tests', () {
    late EngineResolver resolver;
    late MockViewEngine engine;

    setUp(() {
      resolver = EngineResolver();
      engine = MockViewEngine();
    });

    test('can register and resolve engine', () {
      resolver.register('php', () => engine);

      final resolved = resolver.resolve('php');
      expect(resolved, equals(engine));
    });

    test('throws error for unknown engine', () {
      expect(
        () => resolver.resolve('unknown'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('can register multiple engines', () {
      final engine1 = MockViewEngine();
      final engine2 = MockViewEngine();

      resolver.register('php', () => engine1);
      resolver.register('blade', () => engine2);

      expect(resolver.resolve('php'), equals(engine1));
      expect(resolver.resolve('blade'), equals(engine2));
    });

    test('resolver returns new instance each time', () {
      resolver.register('php', () => MockViewEngine());

      final first = resolver.resolve('php');
      final second = resolver.resolve('php');

      expect(first, isNot(same(second)));
    });

    test('can replace existing engine', () {
      final oldEngine = MockViewEngine();
      final newEngine = MockViewEngine();

      resolver.register('php', () => oldEngine);
      resolver.register('php', () => newEngine);

      expect(resolver.resolve('php'), equals(newEngine));
    });
  });
}
