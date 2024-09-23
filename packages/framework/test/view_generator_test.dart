import 'package:platform_framework/platform_framework.dart';
import 'package:test/test.dart';

void main() {
  test('default view generator', () async {
    var app = Protevus();
    var view = await app.viewGenerator!('foo', {'bar': 'baz'});
    expect(view, contains('No view engine'));
  });
}
