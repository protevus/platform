import 'package:platform_container/container.dart';
import 'package:test/test.dart';

void main() {
  test('returns the same instance', () {
    var container = Container(const EmptyReflector())
      ..registerLazySingleton<Dummy>((_) => Dummy('a'));

    var first = container.make<Dummy>();
    expect(container.make<Dummy>(), first);
  });
}

class Dummy {
  final String s;

  Dummy(this.s);
}
