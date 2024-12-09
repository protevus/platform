import 'package:platform_container/container.dart';
import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';

// Test stubs
@reflectable
abstract class TestInterface {
  static String type() => 'TestInterface';
}

@reflectable
class ParentClass {
  final int i;

  ParentClass([TestInterface? testObject, this.i = 0]);

  static String type() => 'ParentClass';
}

@reflectable
class VariadicParentClass {
  final ChildClass child;
  final int i;

  VariadicParentClass(this.child, [this.i = 0]);

  static String type() => 'VariadicParentClass';
}

@reflectable
class ChildClass {
  final List<TestInterface> objects;

  ChildClass(List<TestInterface> objects) : objects = objects;

  static String type() => 'ChildClass';
}

@reflectable
class VariadicPrimitive {
  final List<dynamic> params;

  VariadicPrimitive([List<dynamic> params = const []]) : params = params;

  static String type() => 'VariadicPrimitive';
}

void main() {
  setUp(() {
    // Register test classes using Container's static method
    Container.registerTypes([
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
