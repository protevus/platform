import 'package:test/test.dart';
import 'package:platform_service_container/service_container.dart';

void main() {
  group('ResolvingCallbackTest', () {
    test('testResolvingCallbacksAreCalledForSpecificAbstracts', () {
      var container = Container();
      container.resolving('foo', (object) {
        (object as dynamic).name = 'taylor';
        return object;
      });
      container.bind('foo', (c) => Object());
      var instance = container.make('foo');

      expect((instance as dynamic).name, 'taylor');
    });

    test('testResolvingCallbacksAreCalled', () {
      var container = Container();
      container.resolving((object) {
        (object as dynamic).name = 'taylor';
        return object;
      });
      container.bind('foo', (c) => Object());
      var instance = container.make('foo');

      expect((instance as dynamic).name, 'taylor');
    });

    test('testResolvingCallbacksAreCalledForType', () {
      var container = Container();
      container.resolving('Object', (object) {
        (object as dynamic).name = 'taylor';
        return object;
      });
      container.bind('foo', (c) => Object());
      var instance = container.make('foo');

      expect((instance as dynamic).name, 'taylor');
    });

    test('testResolvingCallbacksShouldBeFiredWhenCalledWithAliases', () {
      var container = Container();
      container.alias('Object', 'std');
      container.resolving('std', (object) {
        (object as dynamic).name = 'taylor';
        return object;
      });
      container.bind('foo', (c) => Object());
      var instance = container.make('foo');

      expect((instance as dynamic).name, 'taylor');
    });

    test('testResolvingCallbacksAreCalledOnceForImplementation', () {
      var container = Container();

      var callCounter = 0;
      container.resolving('ResolvingContractStub', (_, __) {
        callCounter++;
      });

      container.bind(
          'ResolvingContractStub', (c) => ResolvingImplementationStub());

      container.make('ResolvingImplementationStub');
      expect(callCounter, 1);

      container.make('ResolvingImplementationStub');
      expect(callCounter, 2);
    });

    test('testGlobalResolvingCallbacksAreCalledOnceForImplementation', () {
      var container = Container();

      var callCounter = 0;
      container.resolving((_, __) {
        callCounter++;
      });

      container.bind(
          'ResolvingContractStub', (c) => ResolvingImplementationStub());

      container.make('ResolvingImplementationStub');
      expect(callCounter, 1);

      container.make('ResolvingContractStub');
      expect(callCounter, 2);
    });

    test('testResolvingCallbacksAreCalledOnceForSingletonConcretes', () {
      var container = Container();

      var callCounter = 0;
      container.resolving('ResolvingContractStub', (_, __) {
        callCounter++;
      });

      container.bind(
          'ResolvingContractStub', (c) => ResolvingImplementationStub());
      container.bind(
          'ResolvingImplementationStub', (c) => ResolvingImplementationStub());

      container.make('ResolvingImplementationStub');
      expect(callCounter, 1);

      container.make('ResolvingImplementationStub');
      expect(callCounter, 2);

      container.make('ResolvingContractStub');
      expect(callCounter, 3);
    });

    test('testResolvingCallbacksCanStillBeAddedAfterTheFirstResolution', () {
      var container = Container();

      container.bind(
          'ResolvingContractStub', (c) => ResolvingImplementationStub());

      container.make('ResolvingImplementationStub');

      var callCounter = 0;
      container.resolving('ResolvingContractStub', (_, __) {
        callCounter++;
      });

      container.make('ResolvingImplementationStub');
      expect(callCounter, 1);
    });

    test('testParametersPassedIntoResolvingCallbacks', () {
      var container = Container();

      container.resolving('ResolvingContractStub', (obj, app) {
        expect(obj, isA<ResolvingContractStub>());
        expect(obj, isA<ResolvingImplementationStubTwo>());
        expect(app, same(container));
      });

      container.afterResolving('ResolvingContractStub', (obj, app) {
        expect(obj, isA<ResolvingContractStub>());
        expect(obj, isA<ResolvingImplementationStubTwo>());
        expect(app, same(container));
      });

      container.afterResolving((obj, app) {
        expect(obj, isA<ResolvingContractStub>());
        expect(obj, isA<ResolvingImplementationStubTwo>());
        expect(app, same(container));
      });

      container.bind(
          'ResolvingContractStub', (c) => ResolvingImplementationStubTwo());
      container.make('ResolvingContractStub');
    });

    // Add all remaining tests here...
  });
}

abstract class ResolvingContractStub {}

class ResolvingImplementationStub implements ResolvingContractStub {}

class ResolvingImplementationStubTwo implements ResolvingContractStub {}
