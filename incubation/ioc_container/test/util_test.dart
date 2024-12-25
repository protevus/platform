import 'package:test/test.dart';
import 'package:ioc_container/container.dart';

void main() {
  group('UtilTest', () {
    test('testUnwrapIfClosure', () {
      expect(Util.unwrapIfClosure('foo'), 'foo');
      expect(Util.unwrapIfClosure(() => 'foo'), 'foo');
    });

    test('testArrayWrap', () {
      var string = 'a';
      var array = ['a'];
      var object = Object();
      (object as dynamic).value = 'a';

      expect(Util.arrayWrap(string), ['a']);
      expect(Util.arrayWrap(array), array);
      expect(Util.arrayWrap(object), [object]);
      expect(Util.arrayWrap(null), []);
      expect(Util.arrayWrap([null]), [null]);
      expect(Util.arrayWrap([null, null]), [null, null]);
      expect(Util.arrayWrap(''), ['']);
      expect(Util.arrayWrap(['']), ['']);
      expect(Util.arrayWrap(false), [false]);
      expect(Util.arrayWrap([false]), [false]);
      expect(Util.arrayWrap(0), [0]);

      var obj = Object();
      (obj as dynamic).value = 'a';
      var wrappedObj = Util.arrayWrap(obj);
      expect(wrappedObj, [obj]);
      expect(identical(wrappedObj[0], obj), isTrue);
    });
  });
}
