import 'package:illuminate_foundation/dox_core.dart';
import 'package:test/test.dart';

void main() {
  test('query_exception', () {
    QueryException exception = QueryException();

    dynamic res = exception.toResponse();
    expect(res, 'Error in sql query');
    expect(exception.code, 500);
  });
}
