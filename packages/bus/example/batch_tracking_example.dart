import 'dart:async';

import 'package:platform_bus/platform_bus.dart' hide Dispatcher;
import 'package:platform_collections/platform_collections.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart'
    show Queue, ShouldQueue, QueueableJob;
import 'package:platform_bus/src/dispatcher.dart' show Dispatcher;

// Job that uses batch information for tracking
class DataProcessingJob
    with QueueableMixin, InteractsWithQueueMixin, Batchable {
  final String dataId;
  final Map<String, dynamic> data;

  DataProcessingJob(this.dataId, this.data);

  Future<Map<String, dynamic>> handle() async {
    print('\nProcessing data $dataId (Batch: $batchId, Index: $batchIndex)');

    // Simulate data processing
    await Future.delayed(Duration(milliseconds: 100));

    // Add some processed fields
    final result = Map<String, dynamic>.from(data);
    result['processed'] = true;
    result['processedAt'] = DateTime.now().toIso8601String();
    result['batchInfo'] = {
      'batchId': batchId,
      'batchIndex': batchIndex,
    };

    print('Completed processing data $dataId');
    return result;
  }
}

// Pipeline middleware that uses batch information for logging
class BatchAwareLoggingPipe {
  Future<dynamic> handle(
      dynamic command, FutureOr<dynamic> Function(dynamic) next) async {
    if (command is Batchable && command.inBatch) {
      print(
          '\n[Batch ${command.batchId}] Processing job ${(command.batchIndex ?? -1) + 1}');
    }

    final result = await next(command);

    if (command is Batchable && command.inBatch) {
      print(
          '[Batch ${command.batchId}] Completed job ${(command.batchIndex ?? -1) + 1}');
    }

    return result;
  }
}

void main() async {
  // Set up the container and dispatcher
  final container = Container(MirrorsReflector());
  final queue = InMemoryQueue();
  final dispatcher = Dispatcher(container, (connection) => queue);

  // Add batch-aware logging
  dispatcher.pipeThrough([BatchAwareLoggingPipe()]);

  // Create sample data to process
  final dataSet = [
    {'id': '1', 'value': 100},
    {'id': '2', 'value': 200},
    {'id': '3', 'value': 300},
  ];

  // Create jobs with the data
  final jobs = dataSet
      .map((data) => DataProcessingJob(data['id'].toString(), data))
      .toList();

  print('Starting batch processing of ${jobs.length} jobs');

  // Create and dispatch the batch
  final batch = await dispatcher.batch(jobs).dispatch();

  // Monitor batch progress
  while (!batch.finished) {
    await Future.delayed(Duration(milliseconds: 50));
    print('\nBatch Status:');
    print('- Processed: ${batch.processedJobs}/${batch.totalJobs}');
    print('- Failed: ${batch.failedJobs}');
    print('- Pending: ${batch.pendingJobs}');
  }

  print('\nBatch processing completed');
}

// Simple in-memory queue implementation
class InMemoryQueue implements Queue {
  final List<dynamic> _jobs = [];

  @override
  Future<int> size() async => _jobs.length;

  @override
  Future<void> clear() async {
    _jobs.clear();
  }

  @override
  Future<dynamic> push(dynamic job) async {
    _jobs.add(job);
    if (job is DataProcessingJob) {
      return await job.handle();
    }
    return job;
  }

  @override
  Future<dynamic> later(Duration delay, dynamic job) async {
    await Future.delayed(delay);
    return push(job);
  }

  @override
  Future<dynamic> pushOn(String queue, dynamic job) async {
    return push(job);
  }

  @override
  Future<dynamic> laterOn(String queue, Duration delay, dynamic job) async {
    await Future.delayed(delay);
    return pushOn(queue, job);
  }
}
