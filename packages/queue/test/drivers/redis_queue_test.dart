import 'dart:convert';

import 'package:test/test.dart';
import 'package:illuminate_queue/queue.dart';

void main() {
  group('RedisQueue', () {
    late MockRedis redis;
    late RedisQueue queue;

    setUp(() {
      redis = MockRedis();
      queue = RedisQueue(
        redis: redis,
        defaultQueue: 'default',
        retryAfter: 60,
        blockFor: 5,
      );
    });

    test('pushes job to redis list', () async {
      final jobId = await queue.push(
        'TestJob',
        data: {'id': 1},
      );

      expect(jobId, isNotNull);
      expect(redis.lists['queues:default'], hasLength(1));

      final payload = jsonDecode(redis.lists['queues:default']!.first);
      expect(payload['job'], equals('TestJob'));
      expect(payload['data'], equals({'id': 1}));
    });

    test('schedules delayed job in redis sorted set', () async {
      final delay = Duration(minutes: 5);
      final jobId = await queue.later(
        delay,
        'TestJob',
        data: {'id': 1},
      );

      expect(jobId, isNotNull);
      expect(redis.sortedSets['queues:default:delayed'], isNotNull);
      expect(redis.sortedSets['queues:default:delayed']!.length, equals(1));

      final entry = redis.sortedSets['queues:default:delayed']!.first;
      final payload = jsonDecode(entry.member);
      expect(payload['job'], equals('TestJob'));
      expect(payload['data'], equals({'id': 1}));
    });

    test('pops and reserves job', () async {
      // Add a job to the queue
      await queue.push('TestJob', data: {'id': 1});

      // Pop the job
      final job = await queue.pop();

      expect(job, isA<RedisJob>());
      expect(job?.payload['job'], equals('TestJob'));
      expect(job?.payload['data'], equals({'id': 1}));
      expect(redis.lists['queues:default'], isEmpty);
      expect(redis.sortedSets['queues:default:reserved']!.length, equals(1));
    });

    test('migrates expired delayed jobs', () async {
      // Add a delayed job that's now expired
      final now = DateTime.now();
      final payload = queue.createPayload('TestJob', 'default', {'id': 1});
      redis.zadd(
        'queues:default:delayed',
        now.subtract(Duration(minutes: 5)).millisecondsSinceEpoch / 1000,
        payload,
      );

      // Pop should migrate the expired job
      final job = await queue.pop();

      expect(job, isA<RedisJob>());
      expect(job?.payload['job'], equals('TestJob'));
      expect(redis.sortedSets['queues:default:delayed'], isEmpty);
      expect(redis.sortedSets['queues:default:reserved']!.length, equals(1));
    });

    test('migrates expired reserved jobs', () async {
      // Add a reserved job that's now expired
      final now = DateTime.now();
      final payload = queue.createPayload('TestJob', 'default', {'id': 1});
      redis.zadd(
        'queues:default:reserved',
        now.subtract(Duration(minutes: 5)).millisecondsSinceEpoch / 1000,
        payload,
      );

      // Pop should migrate the expired job
      final job = await queue.pop();

      expect(job, isA<RedisJob>());
      expect(job?.payload['job'], equals('TestJob'));
      expect(redis.sortedSets['queues:default:reserved'], isEmpty);
      expect(redis.lists['queues:default'], isEmpty);
      expect(redis.sortedSets['queues:default:reserved']!.length, equals(1));
    });

    test('clears all queue lists', () async {
      // Add jobs to various lists
      await queue.push('Job1');
      await queue.later(Duration(minutes: 5), 'Job2');
      await queue.pop(); // This will create a reserved job

      final cleared = await queue.clear();

      expect(cleared, equals(3));
      expect(redis.lists['queues:default'], isEmpty);
      expect(redis.sortedSets['queues:default:delayed'], isEmpty);
      expect(redis.sortedSets['queues:default:reserved'], isEmpty);
    });
  });
}

class MockRedis {
  final Map<String, List<String>> lists = {};
  final Map<String, List<SortedSetEntry>> sortedSets = {};

  void lpush(String key, String value) {
    lists.putIfAbsent(key, () => []).insert(0, value);
  }

  String? lpop(String key) {
    final list = lists[key];
    if (list == null || list.isEmpty) return null;
    return list.removeAt(0);
  }

  void zadd(String key, double score, String member) {
    final set = sortedSets.putIfAbsent(key, () => []);
    set.add(SortedSetEntry(score, member));
    set.sort((a, b) => a.score.compareTo(b.score));
  }

  List<String> zrangebyscore(String key, double min, double max) {
    final set = sortedSets[key] ?? [];
    return set
        .where((e) => e.score >= min && e.score <= max)
        .map((e) => e.member)
        .toList();
  }

  void zrem(String key, String member) {
    final set = sortedSets[key];
    if (set != null) {
      set.removeWhere((e) => e.member == member);
    }
  }

  void del(String key) {
    lists.remove(key);
    sortedSets.remove(key);
  }
}

class SortedSetEntry {
  final double score;
  final String member;

  SortedSetEntry(this.score, this.member);
}
