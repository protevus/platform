import 'dart:convert';

import 'package:test/test.dart';
import 'package:platform_queue/queue.dart';

void main() {
  group('QueueBase', () {
    late TestQueue queue;

    setUp(() {
      queue = TestQueue();
    });

    test('creates valid payload', () {
      final payload = queue.createPayload(
        'TestJob',
        'default',
        {'data': 'value'},
      );

      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      expect(decoded['job'], equals('TestJob'));
      expect(decoded['data'], equals({'data': 'value'}));
      expect(decoded['uuid'], isNotNull);
      expect(decoded['attempts'], equals(0));
    });

    test('pushes job to queue', () async {
      final jobId = await queue.push(
        'TestJob',
        data: {'data': 'value'},
      );

      expect(jobId, isNotNull);
      expect(queue.pushedJobs, hasLength(1));
      expect(queue.pushedJobs.first['job'], equals('TestJob'));
    });

    test('schedules delayed job', () async {
      final delay = Duration(minutes: 5);
      final jobId = await queue.later(
        delay,
        'TestJob',
        data: {'data': 'value'},
      );

      expect(jobId, isNotNull);
      expect(queue.delayedJobs, hasLength(1));
      expect(queue.delayedJobs.first['job'], equals('TestJob'));
      expect(queue.delayedJobs.first['delay'], equals(delay));
    });

    test('pushes multiple jobs in bulk', () async {
      await queue.bulk(
        ['Job1', 'Job2', 'Job3'],
        data: {'data': 'value'},
      );

      expect(queue.pushedJobs, hasLength(3));
      expect(queue.pushedJobs[0]['job'], equals('Job1'));
      expect(queue.pushedJobs[1]['job'], equals('Job2'));
      expect(queue.pushedJobs[2]['job'], equals('Job3'));
    });

    test('manages connection name', () {
      expect(queue.connectionName, equals('default'));

      queue.connectionName = 'test';
      expect(queue.connectionName, equals('test'));
    });
  });
}

/// Test implementation of QueueBase for testing.
class TestQueue extends QueueBase {
  final List<Map<String, dynamic>> pushedJobs = [];
  final List<Map<String, dynamic>> delayedJobs = [];

  @override
  Future<int> size([String? queue]) async => pushedJobs.length;

  @override
  Future<int> clear([String? queue]) async {
    final count = pushedJobs.length;
    pushedJobs.clear();
    delayedJobs.clear();
    return count;
  }

  @override
  Future<Job?> pop([String? queue]) async => null;

  @override
  Future<String?> pushRaw(String payload, [String? queue]) async {
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    pushedJobs.add(decoded);
    return decoded['uuid'] as String?;
  }

  @override
  Future<String?> laterRaw(Duration delay, String payload,
      [String? queue]) async {
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    delayedJobs.add({
      ...decoded,
      'delay': delay,
    });
    return decoded['uuid'] as String?;
  }
}
