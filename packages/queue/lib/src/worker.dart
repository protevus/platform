import 'dart:async';

import 'package:queue/src/contracts/job.dart';
import 'package:queue/src/contracts/queue.dart';
import 'package:queue/src/worker_options.dart';

/// A queue worker that processes jobs.
class Worker {
  /// The queue manager instance.
  final Queue queue;

  /// Whether the worker should exit.
  bool shouldQuit = false;

  /// Whether the worker is paused.
  bool isPaused = false;

  /// Create a new queue worker.
  Worker(this.queue);

  /// Listen to the given queue in a loop.
  Future<int> daemon(String queueName, WorkerOptions options) async {
    final lastRestart = DateTime.now();
    int jobsProcessed = 0;

    while (true) {
      if (!_shouldRun(options)) {
        if (isPaused) {
          await _sleep(options.sleep);
          continue;
        }
        return _exit(0);
      }

      final job = await _getNextJob(queueName);

      if (job != null) {
        jobsProcessed++;
        await _processJob(job, options);

        if (options.rest > Duration.zero) {
          await _sleep(options.rest);
        }
      } else {
        await _sleep(options.sleep);
      }

      final status = _shouldStop(options, lastRestart, jobsProcessed, job);
      if (status != null) {
        return _exit(status);
      }
    }
  }

  /// Process the next job on the queue.
  Future<void> runNextJob(String queueName, WorkerOptions options) async {
    final job = await _getNextJob(queueName);

    if (job != null) {
      await _processJob(job, options);
    } else {
      await _sleep(options.sleep);
    }
  }

  /// Get the next job from the queue.
  Future<Job?> _getNextJob(String queueName) async {
    try {
      return await queue.pop(queueName);
    } catch (e) {
      // Log error
      await _sleep(const Duration(seconds: 1));
      return null;
    }
  }

  /// Process the given job.
  Future<void> _processJob(Job job, WorkerOptions options) async {
    try {
      if (_exceedsMaxAttempts(job, options.maxTries)) {
        await _markJobAsFailed(job);
        return;
      }

      await job.fire();
    } catch (e, stackTrace) {
      await _handleJobException(job, options, e, stackTrace);
    }
  }

  /// Handle an exception that occurred while processing a job.
  Future<void> _handleJobException(
    Job job,
    WorkerOptions options,
    Object exception,
    StackTrace stackTrace,
  ) async {
    if (!job.hasFailed) {
      if (_exceedsMaxAttempts(job, options.maxTries)) {
        await _markJobAsFailed(job, exception, stackTrace);
      } else if (!job.isDeleted && !job.isReleased) {
        await job.release(_calculateBackoff(job, options));
      }
    }
  }

  /// Mark the job as failed.
  Future<void> _markJobAsFailed(Job job,
      [Object? exception, StackTrace? stackTrace]) async {
    try {
      await job.fail(exception, stackTrace);
    } catch (e) {
      // Log error
    }
  }

  /// Calculate the backoff for the given job.
  Duration _calculateBackoff(Job job, WorkerOptions options) {
    return job.backoff ?? options.backoff;
  }

  /// Determine if the job has exceeded its maximum attempts.
  bool _exceedsMaxAttempts(Job job, int maxTries) {
    return maxTries > 0 && job.attempts >= maxTries;
  }

  /// Determine if the daemon should process on this iteration.
  bool _shouldRun(WorkerOptions options) {
    return !shouldQuit && !isPaused;
  }

  /// Determine if the worker should stop.
  int? _shouldStop(WorkerOptions options, DateTime lastRestart,
      int jobsProcessed, Job? lastJob) {
    if (shouldQuit) return 0;
    if (options.maxJobs > 0 && jobsProcessed >= options.maxJobs) return 0;
    if (options.maxTime > Duration.zero &&
        DateTime.now().difference(lastRestart) >= options.maxTime) return 0;
    if (options.stopWhenEmpty && lastJob == null) return 0;
    return null;
  }

  /// Sleep for the given duration.
  Future<void> _sleep(Duration duration) async {
    if (duration < const Duration(seconds: 1)) {
      await Future.delayed(duration);
    } else {
      // Use sleep for longer durations to prevent event loop blocking
      await Future.delayed(duration);
    }
  }

  /// Stop the worker with the given status code.
  int _exit(int status) {
    return status;
  }
}
