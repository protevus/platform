import 'package:platform_container/container.dart';
import 'package:test/test.dart';

class TestObject {
  String value;
  TestObject(this.value);
}

void main() {
  group('Util', () {
    test('unwrapIfClosure returns value if not closure', () {
      expect(Util.unwrapIfClosure('foo'), equals('foo'));
    });

    test('unwrapIfClosure executes closure and returns result', () {
      expect(Util.unwrapIfClosure(() => 'foo'), equals('foo'));
    });

    test('unwrapIfClosure executes closure with arguments', () {
      expect(
        Util.unwrapIfClosure((a, b) => '$a$b', ['foo', 'bar']),
        equals('foobar'),
      );
    });

    group('arrayWrap', () {
      test('wraps string in array', () {
        expect(Util.arrayWrap('a'), equals(['a']));
      });

      test('returns original array', () {
        final array = ['a'];
        expect(Util.arrayWrap(array), equals(array));
      });

      test('wraps object in array', () {
        final object = TestObject('a');
        expect(Util.arrayWrap(object), equals([object]));
      });

      test('returns empty array for null', () {
        expect(Util.arrayWrap(null), equals([]));
      });

      test('preserves array with null', () {
        expect(Util.arrayWrap([null]), equals([null]));
      });

      test('preserves array with multiple nulls', () {
        expect(Util.arrayWrap([null, null]), equals([null, null]));
      });

      test('wraps empty string in array', () {
        expect(Util.arrayWrap(''), equals(['']));
      });

      test('preserves array with empty string', () {
        expect(Util.arrayWrap(['']), equals(['']));
      });

      test('wraps false in array', () {
        expect(Util.arrayWrap(false), equals([false]));
      });

      test('preserves array with false', () {
        expect(Util.arrayWrap([false]), equals([false]));
      });

      test('wraps zero in array', () {
        expect(Util.arrayWrap(0), equals([0]));
      });

      test('preserves object identity', () {
        final object = TestObject('a');
        final wrapped = Util.arrayWrap(object);
        expect(wrapped[0], same(object));
      });
    });
  });
}
