import 'package:platform_route/platform_route.dart';
import 'package:test/test.dart';

void main() {
  var router = Router<String>()
    ..chain(['a']).group('/b', (router) {
      router.chain(['c']).chain(['d']).group('/e', (router) {
        router.get('f', 'g');
      });
    })
    ..dumpTree();

  test('nested route groups with chain', () {
    var r = router.resolveAbsolute('/b/e/f').first.route;
    expect(r, isNotNull);
    expect(r.handlers, hasLength(4));
    expect(r.handlers, equals(['a', 'c', 'd', 'g']));
  });
}
