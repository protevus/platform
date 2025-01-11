import 'dart:convert';

import 'package:platform_queue/src/contracts/job.dart';
import 'package:platform_queue/src/drivers/redis_queue.dart';

/// A job that is stored in Redis.
class RedisJob implements Job {
  /// The Redis queue instance.
  final RedisQueue redisQueue;

  /// The raw job payload.
  final String rawJob;

  /// The reserved job payload.
  final String reservedJob;

  /// The name of the queue the job belongs to.
  final String _queueName;

  @override
  String get queue => _queueName;

  /// The name of the connection the job belongs to.
  @override
  final String connectionName;

  bool _deleted = false;
  bool _released = false;
  bool _failed = false;

  /// Create a new Redis job instance.
  RedisJob({
    required this.redisQueue,
    required this.rawJob,
    required this.reservedJob,
    required String queueName,
    required this.connectionName,
  }) : _queueName = queueName;

  @override
  String get jobId => payload['uuid'] as String;

  @override
  String get rawBody => rawJob;

  @override
  Map<String, dynamic> get payload =>
      jsonDecode(rawJob) as Map<String, dynamic>;

  @override
  int get attempts => payload['attempts'] as int;

  @override
  bool get isDeleted => _deleted;

  @override
  bool get isReleased => _released;

  @override
  bool get hasFailed => _failed;

  @override
  int? get maxTries => payload['maxTries'] as int?;

  @override
  Duration? get timeout {
    final seconds = payload['timeout'] as int?;
    return seconds != null ? Duration(seconds: seconds) : null;
  }

  @override
  Duration? get backoff {
    final seconds = payload['backoff'] as int?;
    return seconds != null ? Duration(seconds: seconds) : null;
  }

  @override
  DateTime? get retryUntil {
    final timestamp = payload['retryUntil'] as int?;
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : null;
  }

  @override
  Future<void> fire() async {
    // TODO: Implement job execution
  }

  @override
  Future<void> delete() async {
    _deleted = true;
    // TODO: Implement job deletion from Redis
  }

  @override
  Future<void> release([Duration? delay]) async {
    _released = true;
    // TODO: Implement job release back to queue
  }

  @override
  Future<void> fail([Object? exception, StackTrace? stackTrace]) async {
    _failed = true;
    // TODO: Implement job failure handling
  }

  /// Get the reserved raw job payload.
  String get reserved => reservedJob;
}
