import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_events/events.dart';
import 'package:test/test.dart';

void main() {
  group('InvokeQueuedClosure', () {
    late InvokeQueuedClosure invoker;
    late Container container;

    setUp(() {
      invoker = InvokeQueuedClosure();
      container = Container(MirrorsReflector());
    });

    test('handle invokes closure with arguments', () {
      var called = false;
      closure(String name) {
        called = true;
        return 'Hello $name';
      }

      final serializedClosure = SerializableClosure.create(
        closure,
        'test-closure',
        () => closure,
      );

      invoker.handle(serializedClosure.getClosure(), ['world']);
      expect(called, isTrue);
    });

    test('failed invokes catch callbacks with error', () {
      var caughtError;
      closure(String name) => throw Exception('test error');
      catchCallback(List<dynamic> args, dynamic error) {
        caughtError = error;
      }

      final serializedClosure = SerializableClosure.create(
        closure,
        'test-closure',
        () => closure,
      );
      final serializedCallback = SerializableClosure.create(
        catchCallback,
        'test-callback',
        () => catchCallback,
      );

      invoker.failed(
        serializedClosure.getClosure(),
        ['world'],
        [serializedCallback.getClosure()],
        Exception('test error'),
      );

      expect(caughtError, isA<Exception>());
      expect(caughtError.toString(), contains('test error'));
    });

    test('failed invokes multiple catch callbacks', () {
      var catchCount = 0;
      closure(String name) => throw Exception('test error');
      catchCallback1(List<dynamic> args, dynamic error) => catchCount++;
      catchCallback2(List<dynamic> args, dynamic error) => catchCount++;

      final serializedClosure = SerializableClosure.create(
        closure,
        'test-closure',
        () => closure,
      );
      final serializedCallback1 = SerializableClosure.create(
        catchCallback1,
        'test-callback-1',
        () => catchCallback1,
      );
      final serializedCallback2 = SerializableClosure.create(
        catchCallback2,
        'test-callback-2',
        () => catchCallback2,
      );

      invoker.failed(
        serializedClosure.getClosure(),
        ['world'],
        [
          serializedCallback1.getClosure(),
          serializedCallback2.getClosure(),
        ],
        Exception('test error'),
      );

      expect(catchCount, equals(2));
    });

    test('displayName returns Closure', () {
      expect(invoker.displayName(), equals('Closure'));
    });

    test('jobId returns null', () {
      expect(invoker.jobId(), isNull);
    });
  });
}
