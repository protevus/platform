import 'package:platform_bus/platform_bus.dart';
import 'package:test/test.dart';

void main() {
  group('SyncJob', () {
    late SyncJob job;
    final container = Object();
    final payload = 'test-payload';
    final connectionName = 'test-connection';
    final queueName = 'test-queue';

    setUp(() {
      job = SyncJob(container, payload, connectionName, queueName);
    });

    test('initializes with correct properties', () {
      expect(job.container, equals(container));
      expect(job.payload, equals(payload));
      expect(job.connectionName, equals(connectionName));
      expect(job.queue, equals(queueName));
      expect(job.attempts, equals(0));
      expect(job.isDeleted, isFalse);
      expect(job.isReleased, isFalse);
    });

    test('job property returns self', () {
      expect(job.job, equals(job));
    });

    test('setting job property has no effect', () {
      final otherJob = SyncJob(container, 'other', connectionName, queueName);
      job.job = otherJob;
      expect(job.job, equals(job)); // Should still return self
    });

    test('can be deleted', () async {
      expect(job.isDeleted, isFalse);
      await job.delete();
      expect(job.isDeleted, isTrue);
    });

    test('can be released', () async {
      expect(job.isReleased, isFalse);
      await job.release();
      expect(job.isReleased, isTrue);
    });

    test('can be released with delay', () async {
      expect(job.isReleased, isFalse);
      await job.release(Duration(seconds: 1));
      expect(job.isReleased, isTrue);
    });

    test('setJob has no effect', () {
      final otherJob = SyncJob(container, 'other', connectionName, queueName);
      job.setJob(otherJob);
      expect(job.job, equals(job)); // Should still return self
    });

    test('maintains attempt count', () {
      expect(job.attempts, equals(0));
      job.attempts = 1;
      expect(job.attempts, equals(1));
    });

    test('deletion and release states are independent', () async {
      expect(job.isDeleted, isFalse);
      expect(job.isReleased, isFalse);

      await job.delete();
      expect(job.isDeleted, isTrue);
      expect(job.isReleased, isFalse);

      await job.release();
      expect(job.isDeleted, isTrue);
      expect(job.isReleased, isTrue);
    });
  });
}
