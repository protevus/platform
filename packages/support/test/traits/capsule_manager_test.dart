import 'package:illuminate_container/container.dart';
import 'package:illuminate_container/mirrors.dart';
import 'package:illuminate_support/src/fluent.dart';
import 'package:illuminate_support/src/traits/capsule_manager.dart';
import 'package:test/test.dart';

class TestCapsule with CapsuleManager {}

void main() {
  group('CapsuleManager', () {
    late Container container;
    late TestCapsule capsule;

    setUp(() {
      container = Container(MirrorsReflector());
      capsule = TestCapsule();
    });

    test('can set and get container', () {
      capsule.setContainer(container);
      expect(capsule.getContainer(), equals(container));
    });

    test('setupContainer initializes config if not bound', () {
      capsule.setupContainer(container);
      expect(capsule.getContainer()!.make<Fluent>(), isA<Fluent>());
    });

    test('setupContainer preserves existing config if bound', () {
      var config = Fluent();
      container.registerSingleton(config, as: Fluent);
      capsule.setupContainer(container);
      expect(capsule.getContainer()!.make<Fluent>(), same(config));
    });

    test('can set as global instance', () {
      capsule.setAsGlobal();
      expect(CapsuleManager.getInstance(), same(capsule));
    });
  });
}
