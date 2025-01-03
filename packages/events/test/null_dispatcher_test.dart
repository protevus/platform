import 'package:platform_events/events.dart';
import 'package:test/test.dart';

void main() {
  group('NullDispatcher', () {
    late NullDispatcher dispatcher;

    setUp(() {
      dispatcher = NullDispatcher();
    });

    test('listen does nothing', () {
      // Should not throw
      dispatcher.listen('test-event', (event, data) {
        fail('Should not be called');
      });
    });

    test('hasListeners always returns false', () {
      dispatcher.listen('test-event', (event, data) {});
      expect(dispatcher.hasListeners('test-event'), isFalse);
    });

    test('subscribe does nothing', () {
      // Should not throw
      dispatcher.subscribe(Object());
    });

    test('until returns null', () {
      var result = dispatcher.until('test-event', ['data']);
      expect(result, isNull);
    });

    test('dispatch returns null', () {
      var result = dispatcher.dispatch('test-event', ['data']);
      expect(result, isNull);
    });

    test('push does nothing', () {
      // Should not throw
      dispatcher.push('test-event', ['data']);
    });

    test('flush does nothing', () {
      // Should not throw
      dispatcher.flush('test-event');
    });

    test('forget does nothing', () {
      // Should not throw
      dispatcher.forget('test-event');
    });

    test('forgetPushed does nothing', () {
      // Should not throw
      dispatcher.forgetPushed();
    });
  });
}
