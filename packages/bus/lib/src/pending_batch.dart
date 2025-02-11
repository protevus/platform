import 'dart:async';

import 'package:illuminate_collections/collections.dart';
import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_support/support.dart';

import 'batch.dart';
import 'batch_repository.dart';
import 'batchable.dart';

/// A batch that is being configured before being dispatched.
class PendingBatch implements PendingBatchContract {
  /// The container instance.
  final dynamic _container;

  /// The jobs in this batch.
  final Collection<dynamic> _jobs;

  /// The name assigned to this batch.
  String? _name;

  /// Whether the batch should be allowed to fail.
  bool _allowFailures = false;

  /// The number of times the batch may be retried.
  int? _tries;

  /// The number of seconds after which the batch's jobs will be released.
  Duration? _timeout;

  /// The number of seconds to wait before retrying the batch.
  Duration? _retryAfter;

  /// The batches to be run after this batch completes successfully.
  final List<List<dynamic>> _chainedBatches = [];

  /// The callback to execute after all jobs have executed successfully.
  FutureOr<void> Function(BatchContract batch)? _then;

  /// The callback to execute after the first failing job.
  void Function(BatchContract batch, dynamic error)? _catch;

  /// The callback to execute after the batch has finished executing.
  void Function(BatchContract batch)? _finally;

  /// Creates a new pending batch instance.
  ///
  /// [container] The container instance.
  /// [jobs] The jobs in this batch.
  PendingBatch(this._container, this._jobs);

  @override
  PendingBatchContract name(String name) {
    _name = name;
    return this;
  }

  @override
  PendingBatchContract allowFailures() {
    _allowFailures = true;
    return this;
  }

  @override
  PendingBatchContract tries(int times) {
    _tries = times;
    return this;
  }

  @override
  PendingBatchContract timeout(Duration duration) {
    _timeout = duration;
    return this;
  }

  @override
  PendingBatchContract retryAfter(Duration duration) {
    _retryAfter = duration;
    return this;
  }

  @override
  PendingBatchContract chain(List<dynamic> jobs) {
    _chainedBatches.add(jobs);
    return this;
  }

  @override
  PendingBatchContract then(
      FutureOr<void> Function(BatchContract batch) handler) {
    _then = handler;
    return this;
  }

  @override
  PendingBatchContract onError(
      void Function(BatchContract batch, dynamic error) handler) {
    _catch = handler;
    return this;
  }

  @override
  PendingBatchContract onFinish(void Function(BatchContract batch) handler) {
    _finally = handler;
    return this;
  }

  @override
  Future<BatchContract> dispatch() async {
    final id = Str.random(32);
    final options = <String, dynamic>{
      'allowFailures': _allowFailures,
      if (_tries != null) 'tries': _tries,
      if (_timeout != null) 'timeout': _timeout!.inSeconds,
      if (_retryAfter != null) 'retryAfter': _retryAfter!.inSeconds,
    };

    final batch = Batch(
      id,
      _name,
      _jobs.length,
      Collection<String>([]),
      options,
    );

    if (_then != null) {
      batch.then(_then!);
    }

    if (_catch != null) {
      batch.onError(_catch!);
    }

    if (_finally != null) {
      batch.onFinish(_finally!);
    }

    final repository = _container.make<BatchRepository>();
    await repository.store(batch);

    // Store the jobs in the repository
    final processedJobs = <dynamic>[];
    for (var i = 0; i < _jobs.length; i++) {
      final job = _jobs[i];
      if (job is Batchable) {
        job.withBatch(id, i);
      }
      if (job is QueueableJob) {
        if (_tries != null) {
          job.setTries(_tries!, retryAfter: _retryAfter);
        }
        if (_timeout != null) {
          job.withTimeout(_timeout!);
        }
      }
      processedJobs.add(job);
    }
    await repository.storeJobs(id, Collection(processedJobs));

    // Create and chain any batches that should run after this one
    if (_chainedBatches.isNotEmpty) {
      final dispatcher = _container.make<Dispatcher>();
      final chainedBatchIds = <String>[];

      for (final jobs in _chainedBatches) {
        final chainedBatch = await dispatcher.batch(jobs).dispatch();
        chainedBatchIds.add(chainedBatch.id);
      }

      final updatedBatch =
          batch.withChainedBatches(Collection(chainedBatchIds));
      await repository.store(updatedBatch);
      return updatedBatch;
    }

    return batch;
  }
}
