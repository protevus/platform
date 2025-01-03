import 'package:platform_events/events.dart';
import 'package:test/test.dart';

void main() {
  group('QueuedClosure', () {
    late QueuedClosure queuedClosure;
    late Function testClosure;

    setUp(() {
      testClosure = (String name) => 'Hello $name';
      queuedClosure = QueuedClosure(testClosure);
    });

    test('stores original closure', () {
      expect(queuedClosure.closure, equals(testClosure));
    });

    test('onConnection sets connection', () {
      queuedClosure.onConnection('redis');
      expect(queuedClosure.connection, equals('redis'));
    });

    test('onQueue sets queue', () {
      queuedClosure.onQueue('emails');
      expect(queuedClosure.queue, equals('emails'));
    });

    test('withDelay sets delay', () {
      final delay = Duration(seconds: 5);
      queuedClosure.withDelay(delay);
      expect(queuedClosure.delay, equals(delay));
    });

    test('catchError adds catch callback', () {
      final callback = (error) {};
      queuedClosure.catchError(callback);
      expect(queuedClosure.catchCallbacks, contains(callback));
    });

    test('resolve returns callable that creates queued job', () {
      final resolved = queuedClosure.resolve();
      final job = resolved(['world']) as CallQueuedListener;

      expect(job.className, equals('InvokeQueuedClosure'));
      expect(job.method, equals('handle'));
      expect(job.data[1], equals(['world'])); // arguments
    });

    test('resolved job includes connection settings', () {
      queuedClosure.onConnection('redis');
      queuedClosure.onQueue('emails');
      queuedClosure.withDelay(Duration(seconds: 5));

      final resolved = queuedClosure.resolve();
      final job = resolved(['world']) as CallQueuedListener;

      expect(job.connection, equals('redis'));
      expect(job.queue, equals('emails'));
      expect(job.delay, equals(Duration(seconds: 5)));
    });

    test('resolved job includes catch callbacks', () {
      final callback = (error) {};
      queuedClosure.catchError(callback);

      final resolved = queuedClosure.resolve();
      final job = resolved(['world']) as CallQueuedListener;

      expect(job.data[2], isA<List>()); // catch callbacks
      expect(job.data[2].length, equals(1));
    });

    test('create static method creates instance', () {
      final instance = QueuedClosure.create(testClosure);
      expect(instance, isA<QueuedClosure>());
      expect(instance.closure, equals(testClosure));
    });

    test('method chaining works', () {
      final instance = QueuedClosure.create(testClosure)
          .onConnection('redis')
          .onQueue('emails')
          .withDelay(Duration(seconds: 5))
          .catchError((error) {});

      expect(instance.connection, equals('redis'));
      expect(instance.queue, equals('emails'));
      expect(instance.delay, equals(Duration(seconds: 5)));
      expect(instance.catchCallbacks, hasLength(1));
    });
  });
}
