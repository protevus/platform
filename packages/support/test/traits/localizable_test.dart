import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_support/src/fluent.dart';
import 'package:platform_support/src/traits/localizable.dart';
import 'package:test/test.dart';

class TestLocalizable with Localizable {
  final Container _container;

  TestLocalizable(this._container);

  @override
  Container get container => _container;
}

void main() {
  group('Localizable', () {
    late Container container;
    late TestLocalizable localizable;
    late Fluent config;

    setUp(() {
      container = Container(MirrorsReflector());
      config = Fluent();
      config['locale'] = 'en';
      container.registerSingleton(config);
      localizable = TestLocalizable(container);
    });

    test('executes callback with given locale', () {
      var result = localizable.withLocale('es', () {
        expect(config['locale'], equals('es'));
        return 'done';
      });
      expect(result, equals('done'));
    });

    test('restores original locale after callback', () {
      localizable.withLocale('es', () {});
      expect(config['locale'], equals('en'));
    });

    test('restores original locale even if callback throws', () {
      try {
        localizable.withLocale('es', () => throw Exception('test'));
      } catch (_) {}
      expect(config['locale'], equals('en'));
    });

    test('executes callback with current locale if no locale provided', () {
      var result = localizable.withLocale(null, () {
        expect(config['locale'], equals('en'));
        return 'done';
      });
      expect(result, equals('done'));
    });
  });
}
