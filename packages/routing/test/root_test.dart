import 'package:platform_routing/route.dart';
import 'package:test/test.dart';

void main() {
  test('resolve / on /', () {
    var router = Router()
      ..group('/', (router) {
        router.group('/', (router) {
          router.get('/', 'ok');
        });
      });

    expect(router.resolveAbsolute('/'), isNotNull);
  });
}
