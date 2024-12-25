import 'package:test/test.dart';
import 'package:platform_service_container/service_container.dart';

void main() {
  group('ContainerTaggingTest', () {
    test('testContainerTags', () {
      var container = Container();
      container.tag(ContainerImplementationTaggedStub, 'foo');
      container.tag(ContainerImplementationTaggedStub, 'bar');
      container.tag(ContainerImplementationTaggedStubTwo, 'foo');

      expect(container.tagged('bar').length, 1);
      expect(container.tagged('foo').length, 2);

      var fooResults = [];
      for (var foo in container.tagged('foo')) {
        fooResults.add(foo);
      }

      var barResults = [];
      for (var bar in container.tagged('bar')) {
        barResults.add(bar);
      }

      expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
      expect(barResults[0], isA<ContainerImplementationTaggedStub>());
      expect(fooResults[1], isA<ContainerImplementationTaggedStubTwo>());

      container = Container();
      container.tag(ContainerImplementationTaggedStub, 'foo');
      container.tag(ContainerImplementationTaggedStubTwo, 'foo');
      expect(container.tagged('foo').length, 2);

      fooResults = [];
      for (var foo in container.tagged('foo')) {
        fooResults.add(foo);
      }

      expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
      expect(fooResults[1], isA<ContainerImplementationTaggedStubTwo>());

      expect(container.tagged('this_tag_does_not_exist').length, 0);
    });

    test('testTaggedServicesAreLazyLoaded', () {
      var container = Container();
      var makeCount = 0;
      container.bind('ContainerImplementationTaggedStub', (c) {
        makeCount++;
        return ContainerImplementationTaggedStub();
      });

      container.tag('ContainerImplementationTaggedStub', 'foo');
      container.tag('ContainerImplementationTaggedStubTwo', 'foo');

      var fooResults = [];
      for (var foo in container.tagged('foo')) {
        fooResults.add(foo);
        break;
      }

      expect(container.tagged('foo').length, 2);
      expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
      expect(makeCount, 1);
    });

    test('testLazyLoadedTaggedServicesCanBeLoopedOverMultipleTimes', () {
      var container = Container();
      container.tag('ContainerImplementationTaggedStub', 'foo');
      container.tag('ContainerImplementationTaggedStubTwo', 'foo');

      var services = container.tagged('foo');

      var fooResults = [];
      for (var foo in services) {
        fooResults.add(foo);
      }

      expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
      expect(fooResults[1], isA<ContainerImplementationTaggedStubTwo>());

      fooResults = [];
      for (var foo in services) {
        fooResults.add(foo);
      }

      expect(fooResults[0], isA<ContainerImplementationTaggedStub>());
      expect(fooResults[1], isA<ContainerImplementationTaggedStubTwo>());
    });
  });
}

abstract class IContainerTaggedContractStub {}

class ContainerImplementationTaggedStub
    implements IContainerTaggedContractStub {}

class ContainerImplementationTaggedStubTwo
    implements IContainerTaggedContractStub {}
