import 'package:platform_container/container.dart';
import 'package:platform_events/events.dart';
import 'package:test/test.dart';

import 'support/test_reflector.dart';

void main() {
  group('EventDispatcher', () {
    late EventDispatcher dispatcher;
    late Container container;
    late TestReflector reflector;

    setUp(() {
      reflector = TestReflector();
      container = Container(reflector);
      // Register TestSubscriber type with container
      container.registerFactory<TestSubscriber>((c) => TestSubscriber([]));
      dispatcher = EventDispatcher(container);
    });

    test('listen registers event listener for string events', () {
      var called = false;
      dispatcher.listen('UserRegistered', (event, data) {
        called = true;
        expect(event, equals('UserRegistered'));
        expect(data, equals(['test-data']));
      });

      dispatcher.dispatch('UserRegistered', ['test-data']);
      expect(called, isTrue);
    });

    test('listen registers event listener for type events', () {
      var called = false;
      var subscriber = TestSubscriber([]);
      dispatcher.listen(TestSubscriber, (event, data) {
        called = true;
        expect(data[0], equals(subscriber));
      });

      dispatcher.dispatch(subscriber);
      expect(called, isTrue);
    });

    test('hasListeners returns true when event has listeners', () {
      dispatcher.listen('test-event', (event, data) {});
      expect(dispatcher.hasListeners('test-event'), isTrue);
    });

    test('hasListeners returns false when event has no listeners', () {
      expect(dispatcher.hasListeners('test-event'), isFalse);
    });

    test('wildcard listeners receive matching events', () {
      var calls = <String>[];
      dispatcher.listen('test.*', (event, data) {
        calls.add(event);
      });

      dispatcher.dispatch('test.one');
      dispatcher.dispatch('test.two');
      dispatcher.dispatch('other');

      expect(calls, equals(['test.one', 'test.two']));
    });

    test('until returns first non-null response', () {
      dispatcher.listen('test-event', (event, data) => null);
      dispatcher.listen('test-event', (event, data) => 'response1');
      dispatcher.listen('test-event', (event, data) => 'response2');

      var result = dispatcher.until('test-event');
      expect(result, equals('response1'));
    });

    test('forget removes event listeners', () {
      var called = false;
      dispatcher.listen('test-event', (event, data) {
        called = true;
      });

      dispatcher.forget('test-event');
      dispatcher.dispatch('test-event');
      expect(called, isFalse);
    });

    test('forgetPushed removes pushed event listeners', () {
      var called = false;
      dispatcher.push('test-event', ['data']);
      dispatcher.forgetPushed();

      dispatcher.dispatch('test-event_pushed');
      expect(called, isFalse);
    });

    test('push registers event to be fired later', () {
      var calls = <String>[];
      dispatcher.listen('test-event', (event, data) {
        calls.add('original');
      });

      dispatcher.push('test-event');
      expect(calls, isEmpty);

      dispatcher.dispatch('test-event_pushed');
      expect(calls, equals(['original']));
    });

    test('flush fires pushed event', () {
      var calls = <String>[];
      dispatcher.listen('test-event', (event, data) {
        calls.add('original');
      });

      dispatcher.push('test-event');
      dispatcher.flush('test-event');
      expect(calls, equals(['original']));
    });

    test('subscriber registers multiple event listeners', () {
      var calls = <String>[];
      var subscriber = TestSubscriber(calls);
      // Register the subscriber instance with the container
      container.registerSingleton<TestSubscriber>(subscriber);

      dispatcher.subscribe(subscriber);

      dispatcher.dispatch('event.one');
      dispatcher.dispatch('event.two');
      expect(calls, equals(['one', 'two']));
    });
  });
}
