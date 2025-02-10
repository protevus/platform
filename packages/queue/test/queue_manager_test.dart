import 'package:test/test.dart';
import 'package:illuminate_queue/queue.dart';

void main() {
  group('QueueManager', () {
    late QueueManager manager;

    setUp(() {
      manager = QueueManager();
    });

    test('registers and resolves queue driver', () {
      manager.registerDriver('test', (config) {
        expect(config['driver'], equals('test'));
        expect(config['connection'], equals('test-connection'));
        return TestQueue();
      });

      final queue = manager.connection('test-connection');
      expect(queue, isA<TestQueue>());
    });

    test('caches queue connections', () {
      var driverCalls = 0;
      manager.registerDriver('test', (config) {
        driverCalls++;
        return TestQueue();
      });

      final queue1 = manager.connection('test-connection');
      final queue2 = manager.connection('test-connection');

      expect(identical(queue1, queue2), isTrue);
      expect(driverCalls, equals(1));
    });

    test('manages default connection', () {
      manager.registerDriver('test', (config) => TestQueue());

      expect(manager.defaultConnection, equals('default'));

      manager.defaultConnection = 'test-connection';
      expect(manager.defaultConnection, equals('test-connection'));

      final queue = manager.connection();
      expect(queue, isA<TestQueue>());
    });

    test('throws on unsupported driver', () {
      expect(
        () => manager.connection('invalid'),
        throwsA(isA<QueueConnectionException>()),
      );
    });

    test('throws on missing connection config', () {
      manager.registerDriver('redis', (config) {
        if (config['connection'] == null) {
          throw QueueConnectionException('Redis connection not configured.');
        }
        return TestQueue();
      });

      expect(
        () => manager.connection('redis-connection'),
        throwsA(isA<QueueConnectionException>()),
      );
    });

    test('registers multiple drivers', () {
      manager.registerDriver('test1', (config) => TestQueue());
      manager.registerDriver('test2', (config) => TestQueue());

      final queue1 = manager.connection('test1-connection');
      final queue2 = manager.connection('test2-connection');

      expect(queue1, isA<TestQueue>());
      expect(queue2, isA<TestQueue>());
      expect(identical(queue1, queue2), isFalse);
    });

    test('provides access to all connections', () {
      manager.registerDriver('test', (config) => TestQueue());

      final queue1 = manager.connection('connection1');
      final queue2 = manager.connection('connection2');

      final connections = manager.connections;
      expect(connections.length, equals(2));
      expect(connections['connection1'], equals(queue1));
      expect(connections['connection2'], equals(queue2));
      expect(() => connections['connection3'], throwsA(anything));
    });
  });
}

class TestQueue extends QueueBase {
  @override
  Future<int> size([String? queue]) async => 0;

  @override
  Future<int> clear([String? queue]) async => 0;

  @override
  Future<Job?> pop([String? queue]) async => null;

  @override
  Future<String?> pushRaw(String payload, [String? queue]) async => null;

  @override
  Future<String?> laterRaw(Duration delay, String payload,
          [String? queue]) async =>
      null;
}
