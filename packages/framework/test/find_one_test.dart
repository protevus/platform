import 'package:platform_framework/platform_framework.dart';
import 'package:test/test.dart';
import 'common.dart';

void main() {
  var throwsAnHttpException = throwsA(const IsInstanceOf<HttpException>());

  /*
  test('throw 404 on null', () {
    var service = AnonymousService(index: ([p]) => null);
    expect(() => service.findOne(), throwsAnHttpException);
  });
  */

  test('throw 404 on empty iterable', () {
    var service = AnonymousService(index: ([p]) => []);
    expect(() => service.findOne(), throwsAnHttpException);
  });

  test('return first element of iterable', () async {
    var service = AnonymousService(index: ([p]) => [2]);
    expect(await service.findOne(), 2);
  });
}
