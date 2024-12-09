import 'package:platform_container/container.dart';
import 'package:test/test.dart';
import '../lib/src/reflection.dart';

// Test stubs
@ContainerReflectable()
abstract class TestInterface {
  static String type() => 'TestInterface';
}

@ContainerReflectable()
class ParentClass {
  final int i;

  ParentClass([TestInterface? testObject, this.i = 0]);

  static String type() => 'ParentClass';
}

@ContainerReflectable()
class VariadicParentClass {
  final ChildClass child;
  final int i;

  VariadicParentClass(this.child, [this.i = 0]);

  static String type() => 'VariadicParentClass';
}

@ContainerReflectable()
class ChildClass {
  final List<TestInterface> objects;

  ChildClass(List<TestInterface> objects) : objects = objects;

  static String type() => 'ChildClass';
}

@ContainerReflectable()
class VariadicPrimitive {
  final List<dynamic> params;

  VariadicPrimitive([List<dynamic> params = const []]) : params = params;

  static String type() => 'VariadicPrimitive';
}

void main() {
  setUp(() {
    initializeReflection();

    // Register test classes
    registerTypes([
      TestInterface,
      ParentClass,
      VariadicParentClass,
      ChildClass,
      VariadicPrimitive,
    ]);
  });

  test('resolving non instantiable with default removes withs', () {
    final container = Container();
    final object = container.make(
      ParentClass.type(),
      ['i', 42],
    );

    expect((object as ParentClass).i, equals(42));
  });

  test('resolving non instantiable with variadic removes withs', () {
    final container = Container();
    final parent = container.make(
      VariadicParentClass.type(),
      ['i', 42],
    );

    expect((parent as VariadicParentClass).child.objects, isEmpty);
    expect(parent.i, equals(42));
  });

  test('resolve variadic primitive', () {
    final container = Container();
    final parent = container.make(VariadicPrimitive.type());

    expect((parent as VariadicPrimitive).params, isEmpty);
  });
}
