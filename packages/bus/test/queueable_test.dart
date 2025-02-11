import 'package:illuminate_bus/platform_bus.dart';
import 'package:illuminate_contracts/contracts.dart';
import 'package:test/test.dart';

// Test job that uses both mixins
class TestQueueableJob with QueueableMixin, InteractsWithQueueMixin {
  final String id;
  String? _configuredQueue;

  TestQueueableJob(this.id);

  Future<void> handle() async {
    // Simulate job processing
  }

  @override
  String get queue => _configuredQueue ?? super.queue;

  @override
  QueueableJob onQueue(String queue) {
    _configuredQueue = queue;
    return super.onQueue(queue);
  }
}

// Mock queue job for testing interactions
class MockQueueJob {
  int attempts = 0;
  String queue = 'default';
  bool deleted = false;
  bool released = false;
  Duration? releaseDelay;

  Future<void> delete() async {
    deleted = true;
  }

  Future<void> release([Duration? delay]) async {
    released = true;
    releaseDelay = delay;
  }
}

void main() {
  group('QueueableMixin', () {
    late TestQueueableJob job;

    setUp(() {
      job = TestQueueableJob('test-job');
    });

    test('initializes with default values', () {
      expect(job.connection, isNull);
      expect(job.delay, isNull);
      expect(job.maxTries, isNull);
      expect(job.retryAfter, isNull);
      expect(job.timeout, isNull);
    });

    test('configures connection', () {
      job.onConnection('redis');
      expect(job.connection, equals('redis'));
    });

    test('configures queue', () {
      expect(job.queue, equals('default')); // Initial default
      job.onQueue('high-priority');
      expect(job.queue, equals('high-priority')); // After configuration
    });

    test('configures delay', () {
      final delay = Duration(minutes: 5);
      job.withDelay(delay);
      expect(job.delay, equals(delay));
    });

    test('configures retry settings', () {
      final retryAfter = Duration(minutes: 1);
      job.setTries(3, retryAfter: retryAfter);

      expect(job.maxTries, equals(3));
      expect(job.retryAfter, equals(retryAfter));
    });

    test('configures timeout', () {
      final timeout = Duration(minutes: 10);
      job.withTimeout(timeout);
      expect(job.timeout, equals(timeout));
    });

    test('maintains fluent interface', () {
      final configuredJob = job
          .onConnection('redis')
          .onQueue('high-priority')
          .withDelay(Duration(minutes: 5))
          .setTries(3, retryAfter: Duration(minutes: 1))
          .withTimeout(Duration(minutes: 10));

      expect(configuredJob, equals(job)); // Should return same instance
      expect(job.connection, equals('redis'));
      expect(job.queue, equals('high-priority'));
      expect(job.delay, equals(Duration(minutes: 5)));
      expect(job.maxTries, equals(3));
      expect(job.retryAfter, equals(Duration(minutes: 1)));
      expect(job.timeout, equals(Duration(minutes: 10)));
    });
  });

  group('InteractsWithQueueMixin', () {
    late TestQueueableJob job;
    late MockQueueJob mockQueueJob;

    setUp(() {
      job = TestQueueableJob('test-job');
      mockQueueJob = MockQueueJob();
    });

    test('initializes with default values', () {
      expect(job.job, isNull);
      expect(job.attempts, equals(0));
      expect(job.queue, equals('default'));
      expect(job.isDeleted, isFalse);
      expect(job.isReleased, isFalse);
    });

    test('manages underlying queue job', () {
      job.setJob(mockQueueJob);
      expect(job.job, equals(mockQueueJob));

      final newMockJob = MockQueueJob();
      job.job = newMockJob;
      expect(job.job, equals(newMockJob));
    });

    test('reflects queue job properties', () {
      mockQueueJob.attempts = 3;
      mockQueueJob.queue = 'test-queue';
      job.setJob(mockQueueJob);

      expect(job.attempts, equals(3));
      expect(job.queue, equals('test-queue'));
    });

    test('deletes job', () async {
      job.setJob(mockQueueJob);
      await job.delete();

      expect(job.isDeleted, isTrue);
      expect(mockQueueJob.deleted, isTrue);
    });

    test('releases job', () async {
      job.setJob(mockQueueJob);
      final delay = Duration(minutes: 5);
      await job.release(delay);

      expect(job.isReleased, isTrue);
      expect(mockQueueJob.released, isTrue);
      expect(mockQueueJob.releaseDelay, equals(delay));
    });

    test('handles null queue job gracefully', () async {
      // Operations should not throw when no queue job is set
      await job.delete();
      await job.release();

      expect(job.attempts, equals(0));
      expect(job.queue, equals('default'));
      expect(job.isDeleted, isTrue);
      expect(job.isReleased, isTrue);
    });

    test('maintains state through job changes', () async {
      // Set initial job and perform operations
      job.setJob(mockQueueJob);
      await job.delete();
      await job.release();

      // Change to new job
      final newMockJob = MockQueueJob();
      job.setJob(newMockJob);

      // State should persist
      expect(job.isDeleted, isTrue);
      expect(job.isReleased, isTrue);

      // But new job should be unaffected
      expect(newMockJob.deleted, isFalse);
      expect(newMockJob.released, isFalse);
    });
  });
}
