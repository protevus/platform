import 'dart:convert';

import 'package:test/test.dart';
import 'package:illuminate_queue/queue.dart';

void main() {
  group('RedisJob', () {
    late MockRedis redis;
    late RedisQueue queue;
    late RedisJob job;
    late String payload;
    late String reservedPayload;

    setUp(() {
      redis = MockRedis();
      queue = RedisQueue(redis: redis);

      payload = jsonEncode({
        'uuid': 'test-uuid',
        'displayName': 'TestJob',
        'job': 'TestJob',
        'data': {'id': 1},
        'attempts': 2,
        'maxTries': 3,
        'timeout': 60,
        'backoff': 5,
        'retryUntil':
            DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/
                1000,
      });

      reservedPayload = jsonEncode({
        'attempts': 2,
        'reserved_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });

      job = RedisJob(
        redisQueue: queue,
        rawJob: payload,
        reservedJob: reservedPayload,
        queueName: 'default',
        connectionName: 'redis',
      );
    });

    test('provides access to job metadata', () {
      expect(job.jobId, equals('test-uuid'));
      expect(job.queue, equals('default'));
      expect(job.connectionName, equals('redis'));
      expect(job.attempts, equals(2));
      expect(job.maxTries, equals(3));
      expect(job.timeout, equals(Duration(seconds: 60)));
      expect(job.backoff, equals(Duration(seconds: 5)));
      expect(job.retryUntil, isNotNull);
    });

    test('provides access to job payload', () {
      expect(job.rawBody, equals(payload));
      expect(job.payload, equals(jsonDecode(payload)));
    });

    test('tracks job state', () {
      expect(job.isDeleted, isFalse);
      expect(job.isReleased, isFalse);
      expect(job.hasFailed, isFalse);

      job.delete();
      expect(job.isDeleted, isTrue);

      job.release();
      expect(job.isReleased, isTrue);

      job.fail();
      expect(job.hasFailed, isTrue);
    });

    test('deletes job from redis', () async {
      // Setup reserved job in Redis
      redis.zadd('queues:default:reserved', 0, reservedPayload);

      await job.delete();

      expect(job.isDeleted, isTrue);
      expect(redis.sortedSets['queues:default:reserved'], isEmpty);
    });

    test('releases job back to queue', () async {
      // Setup reserved job in Redis
      redis.zadd('queues:default:reserved', 0, reservedPayload);

      final delay = Duration(seconds: 30);
      await job.release(delay);

      expect(job.isReleased, isTrue);
      expect(redis.sortedSets['queues:default:reserved'], isEmpty);
      expect(redis.sortedSets['queues:default:delayed'], hasLength(1));

      final entry = redis.sortedSets['queues:default:delayed']!.first;
      expect(entry.score,
          greaterThan(DateTime.now().millisecondsSinceEpoch / 1000));
    });

    test('marks job as failed', () async {
      final exception = Exception('Test failure');
      final stackTrace = StackTrace.current;

      await job.fail(exception, stackTrace);

      expect(job.hasFailed, isTrue);
      // In a real implementation, this would log the failure or move the job
      // to a failed jobs table
    });

    test('handles null optional parameters', () {
      final rawPayload = jsonEncode({
        'uuid': 'test-uuid',
        'displayName': 'TestJob',
        'job': 'TestJob',
        'data': {'id': 1},
        'attempts': 1,
      });

      final job = RedisJob(
        redisQueue: queue,
        rawJob: rawPayload,
        reservedJob: reservedPayload,
        queueName: 'default',
        connectionName: 'redis',
      );

      expect(job.maxTries, isNull);
      expect(job.timeout, isNull);
      expect(job.backoff, isNull);
      expect(job.retryUntil, isNull);
    });
  });
}

class MockRedis {
  final Map<String, List<SortedSetEntry>> sortedSets = {};

  void zadd(String key, double score, String member) {
    final set = sortedSets.putIfAbsent(key, () => []);
    set.add(SortedSetEntry(score, member));
    set.sort((a, b) => a.score.compareTo(b.score));
  }

  void zrem(String key, String member) {
    final set = sortedSets[key];
    if (set != null) {
      set.removeWhere((e) => e.member == member);
    }
  }
}

class SortedSetEntry {
  final double score;
  final String member;

  SortedSetEntry(this.score, this.member);
}
