import 'package:test/test.dart';
import 'package:ioc_container/container.dart';

void main() {
  group('ContainerResolveNonInstantiableTest', () {
    test('testResolvingNonInstantiableWithDefaultRemovesWiths', () {
      var container = Container();
      var object = container.make('ParentClass', [null, 42]);

      expect(object, isA<ParentClass>());
      expect(object.i, equals(42));
    });

    test('testResolvingNonInstantiableWithVariadicRemovesWiths', () {
      var container = Container();
      var parent = container.make('VariadicParentClass', [
        container.make('ChildClass', [[]]),
        42
      ]);

      expect(parent, isA<VariadicParentClass>());
      expect(parent.child.objects, isEmpty);
      expect(parent.i, equals(42));
    });

    test('testResolveVariadicPrimitive', () {
      var container = Container();
      var parent = container.make('VariadicPrimitive');

      expect(parent, isA<VariadicPrimitive>());
      expect(parent.params, isEmpty);
    });
  });
}

abstract class TestInterface {}

class ParentClass {
  int i;

  ParentClass([TestInterface? testObject, this.i = 0]);
}

class VariadicParentClass {
  ChildClass child;
  int i;

  VariadicParentClass(this.child, [this.i = 0]);
}

class ChildClass {
  List<TestInterface> objects;

  ChildClass(this.objects);
}

class VariadicPrimitive {
  List params;

  VariadicPrimitive([this.params = const []]);
}
