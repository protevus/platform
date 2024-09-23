import 'package:platform_framework/platform_framework.dart';
import 'dart:convert';
import 'package:test/test.dart';

void main() {
  test('named constructors', () {
    expect(HttpException.badRequest(), isException(400, '400 Bad Request'));
    expect(HttpException.notAuthenticated(),
        isException(401, '401 Not Authenticated'));
    expect(HttpException.paymentRequired(),
        isException(402, '402 Payment Required'));
    expect(HttpException.forbidden(), isException(403, '403 Forbidden'));
    expect(HttpException.notFound(), isException(404, '404 Not Found'));
    expect(HttpException.methodNotAllowed(),
        isException(405, '405 Method Not Allowed'));
    expect(
        HttpException.notAcceptable(), isException(406, '406 Not Acceptable'));
    expect(HttpException.methodTimeout(), isException(408, '408 Timeout'));
    expect(HttpException.conflict(), isException(409, '409 Conflict'));
    expect(HttpException.notProcessable(),
        isException(422, '422 Not Processable'));
    expect(HttpException.notImplemented(),
        isException(501, '501 Not Implemented'));
    expect(HttpException.unavailable(), isException(503, '503 Unavailable'));
  });

  test('fromMap', () {
    expect(HttpException.fromMap({'status_code': -1, 'message': 'ok'}),
        isException(-1, 'ok'));
  });

  test('toMap = toJson', () {
    var exc = HttpException.badRequest();
    expect(exc.toMap(), exc.toJson());
    var json_ = json.encode(exc.toJson());
    var exc2 = HttpException.fromJson(json_);
    expect(exc2.toJson(), exc.toJson());
  });

  test('toString', () {
    expect(HttpException(statusCode: 420, message: 'Blaze It').toString(),
        '420: Blaze It');
  });
}

Matcher isException(int statusCode, String message) =>
    _IsException(statusCode, message);

class _IsException extends Matcher {
  final int statusCode;
  final String message;

  _IsException(this.statusCode, this.message);

  @override
  Description describe(Description description) =>
      description.add('has status code $statusCode and message "$message"');

  @override
  bool matches(item, Map matchState) {
    return item is HttpException &&
        item.statusCode == statusCode &&
        item.message == message;
  }
}
