import 'package:platform_foundation/core.dart';
import 'dart:convert';
import 'package:test/test.dart';

void main() {
  test('named constructors', () {
    expect(PlatformHttpException.badRequest(),
        isException(400, '400 Bad Request'));
    expect(PlatformHttpException.notAuthenticated(),
        isException(401, '401 Not Authenticated'));
    expect(PlatformHttpException.paymentRequired(),
        isException(402, '402 Payment Required'));
    expect(
        PlatformHttpException.forbidden(), isException(403, '403 Forbidden'));
    expect(PlatformHttpException.notFound(), isException(404, '404 Not Found'));
    expect(PlatformHttpException.methodNotAllowed(),
        isException(405, '405 Method Not Allowed'));
    expect(PlatformHttpException.notAcceptable(),
        isException(406, '406 Not Acceptable'));
    expect(
        PlatformHttpException.methodTimeout(), isException(408, '408 Timeout'));
    expect(PlatformHttpException.conflict(), isException(409, '409 Conflict'));
    expect(PlatformHttpException.notProcessable(),
        isException(422, '422 Not Processable'));
    expect(PlatformHttpException.notImplemented(),
        isException(501, '501 Not Implemented'));
    expect(PlatformHttpException.unavailable(),
        isException(503, '503 Unavailable'));
  });

  test('fromMap', () {
    expect(PlatformHttpException.fromMap({'status_code': -1, 'message': 'ok'}),
        isException(-1, 'ok'));
  });

  test('toMap = toJson', () {
    var exc = PlatformHttpException.badRequest();
    expect(exc.toMap(), exc.toJson());
    var json_ = json.encode(exc.toJson());
    var exc2 = PlatformHttpException.fromJson(json_);
    expect(exc2.toJson(), exc.toJson());
  });

  test('toString', () {
    expect(
        PlatformHttpException(statusCode: 420, message: 'Blaze It').toString(),
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
    return item is PlatformHttpException &&
        item.statusCode == statusCode &&
        item.message == message;
  }
}
