import 'dart:async';

import 'package:test/test.dart';
import 'package:platform_queue/queue.dart';

void main() {
  group('Worker', () {
    late TestQueue queue;
    late Worker worker;
    late WorkerOptions options;

    setUp(() {
      queue = TestQueue();
      worker = Worker(queue);
      options = const WorkerOptions(
        maxTries: 3,
        backoff: Duration(seconds: 5),
        sleep: Duration(seconds: 1),
      );
    });

    test('processes jobs from queue', () async {
      final completer = Completer<void>();
      queue.addJob(TestJob(
        onFire: () async {
          completer.complete();
        },
      ));

      // Start worker in background
      unawaited(worker.daemon('default', options));

      // Wait for job to be processed
      await completer.future;

      expect(queue.processedJobs, hasLength(1));
      expect(worker.shouldQuit, isFalse);
    });

    test('retries failed jobs', () async {
      var attempts = 0;
      final completer = Completer<void>();

      queue.addJob(TestJob(
        onFire: () async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Job failed');
          }
          completer.complete();
        },
      ));

      // Start worker in background
      unawaited(worker.daemon('default', options));

      // Wait for job to succeed after retries
      await completer.future;

      expect(attempts, equals(3));
      expect(queue.processedJobs, hasLength(1));
    });

    test('respects max tries', () async {
      var attempts = 0;
      final failedJobs = <Job>[];

      queue.addJob(TestJob(
        onFire: () async {
          attempts++;
          throw Exception('Job failed');
        },
        onFail: (job) {
          failedJobs.add(job);
        },
      ));

      // Start worker with max 2 tries
      final options = WorkerOptions(maxTries: 2);
      await worker.runNextJob('default', options);

      expect(attempts, equals(2));
      expect(failedJobs, hasLength(1));
    });

    test('stops when shouldQuit is true', () async {
      queue.addJob(TestJob(
        onFire: () async {
          worker.shouldQuit = true;
        },
      ));

      final exitCode = await worker.daemon('default', options);

      expect(exitCode, equals(0));
      expect(queue.processedJobs, hasLength(1));
    });

    test('pauses processing when isPaused is true', () async {
      final processedJobs = <Job>[];

      queue.addJob(TestJob(
        onFire: () async {
          processedJobs.add(queue.lastProcessedJob!);
          worker.isPaused = true;
        },
      ));

      queue.addJob(TestJob(
        onFire: () async {
          processedJobs.add(queue.lastProcessedJob!);
        },
      ));

      // Start worker and wait a bit
      unawaited(worker.daemon('default', options));
      await Future.delayed(const Duration(seconds: 2));

      expect(processedJobs, hasLength(1));
      expect(worker.isPaused, isTrue);
    });
  });
}

class TestJob implements Job {
  final Future<void> Function() onFire;
  final void Function(Job)? onFail;

  bool _deleted = false;
  bool _released = false;
  bool _failed = false;
  int _attempts = 0;

  TestJob({
    required this.onFire,
    this.onFail,
  });

  @override
  Future<void> fire() async {
    _attempts++;
    await onFire();
  }

  @override
  Future<void> delete() async {
    _deleted = true;
  }

  @override
  Future<void> release([Duration? delay]) async {
    _released = true;
  }

  @override
  Future<void> fail([Object? exception, StackTrace? stackTrace]) async {
    _failed = true;
    onFail?.call(this);
  }

  @override
  String get jobId => 'test-job';

  @override
  String get rawBody => '{}';

  @override
  Map<String, dynamic> get payload => {};

  @override
  int get attempts => _attempts;

  @override
  String get queue => 'default';

  @override
  String get connectionName => 'default';

  @override
  bool get isDeleted => _deleted;

  @override
  bool get isReleased => _released;

  @override
  bool get hasFailed => _failed;

  @override
  int? get maxTries => null;

  @override
  Duration? get timeout => null;

  @override
  Duration? get backoff => null;

  @override
  DateTime? get retryUntil => null;
}

class TestQueue extends QueueBase {
  final List<Job> jobs = [];
  final List<Job> processedJobs = [];
  Job? lastProcessedJob;

  void addJob(Job job) {
    jobs.add(job);
  }

  @override
  Future<Job?> pop([String? queue]) async {
    if (jobs.isEmpty) return null;
    final job = jobs.removeAt(0);
    lastProcessedJob = job;
    processedJobs.add(job);
    return job;
  }

  @override
  Future<int> size([String? queue]) async => jobs.length;

  @override
  Future<int> clear([String? queue]) async {
    final count = jobs.length;
    jobs.clear();
    return count;
  }

  @override
  Future<String?> pushRaw(String payload, [String? queue]) async => null;

  @override
  Future<String?> laterRaw(Duration delay, String payload,
          [String? queue]) async =>
      null;
}
