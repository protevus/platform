import 'package:test/test.dart';
import 'package:platform_service_container/service_container.dart';

void main() {
  group('RewindableGeneratorTest', () {
    test('testCountUsesProvidedValue', () {
      var generator = RewindableGenerator(() sync* {
        yield 'foo';
      }, 999);

      expect(generator.length, 999);
    });

    test('testCountUsesProvidedValueAsCallback', () {
      var called = 0;

      var countCallback = () {
        called++;
        return 500;
      };

      var generator = RewindableGenerator(() sync* {
        yield 'foo';
      }, countCallback());

      // the count callback is called eagerly in this implementation
      expect(called, 1);

      expect(generator.length, 500);

      generator.length;

      // the count callback is called only once
      expect(called, 1);
    });
  });
}
