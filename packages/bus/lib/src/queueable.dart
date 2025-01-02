import 'dart:async';

import 'package:platform_contracts/contracts.dart';

/// Mixin to add queueing functionality to jobs.
///
/// This mixin provides methods for configuring how a job should be queued
/// and processed.
mixin QueueableMixin implements QueueableJob {
  /// The name of the connection the job should be sent to.
  String? _connection;

  /// The name of the queue the job should be sent to.
  String? _queue;

  /// The number of seconds before the job should be processed.
  Duration? _delay;

  /// The number of times the job may be attempted.
  int? _maxTries;

  /// The number of seconds to wait before retrying the job.
  Duration? _retryAfter;

  /// The time at which the job should timeout.
  Duration? _timeout;

  @override
  String? get connection => _connection;

  @override
  String? get queue => _queue;

  @override
  Duration? get delay => _delay;

  @override
  int? get maxTries => _maxTries;

  @override
  Duration? get retryAfter => _retryAfter;

  @override
  Duration? get timeout => _timeout;

  @override
  QueueableJob onConnection(String connection) {
    _connection = connection;
    return this;
  }

  @override
  QueueableJob onQueue(String queue) {
    _queue = queue;
    return this;
  }

  @override
  QueueableJob withDelay(Duration delay) {
    _delay = delay;
    return this;
  }

  @override
  QueueableJob setTries(int count, {Duration? retryAfter}) {
    _maxTries = count;
    _retryAfter = retryAfter;
    return this;
  }

  @override
  QueueableJob withTimeout(Duration timeout) {
    _timeout = timeout;
    return this;
  }
}

/// Mixin to add queue interaction functionality to jobs.
///
/// This mixin provides methods for interacting with the queue system
/// during job execution.
mixin InteractsWithQueueMixin implements InteractsWithQueue {
  /// The underlying queue job instance.
  dynamic _job;

  /// Whether the job has been deleted.
  bool _deleted = false;

  /// Whether the job has been released.
  bool _released = false;

  @override
  dynamic get job => _job;

  @override
  set job(dynamic job) => _job = job;

  @override
  int get attempts => _job?.attempts ?? 0;

  @override
  String get queue => _job?.queue ?? 'default';

  @override
  bool get isDeleted => _deleted;

  @override
  bool get isReleased => _released;

  @override
  Future<void> delete() async {
    _deleted = true;
    await _job?.delete();
  }

  @override
  Future<void> release([Duration? delay]) async {
    _released = true;
    await _job?.release(delay);
  }

  @override
  void setJob(dynamic job) {
    _job = job;
  }
}
