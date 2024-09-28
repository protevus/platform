import 'package:platform_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('default view generator', () async {
    var app = Application();
    var view = await app.viewGenerator!('foo', {'bar': 'baz'});
    expect(view, contains('No view engine'));
  });
}
