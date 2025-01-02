import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';

// First job type: Data processing
class ProcessDataJob with QueueableMixin, InteractsWithQueueMixin {
  final String dataId;

  ProcessDataJob(this.dataId);

  @override
  Future<void> handle() async {
    print('Processing data $dataId');
    await Future.delayed(Duration(milliseconds: 100));
    print('Data $dataId processed');
  }
}

// Second job type: Notification sending
class NotifyJob with QueueableMixin, InteractsWithQueueMixin {
  final String userId;
  final String message;

  NotifyJob(this.userId, this.message);

  @override
  Future<void> handle() async {
    print('Sending notification to user $userId: $message');
    await Future.delayed(Duration(milliseconds: 50));
    print('Notification sent to user $userId');
  }
}

void main() async {
  final repository = InMemoryBatchRepository();

  // Create first batch for data processing
  final processingBatch = Batch(
    'process-batch-${DateTime.now().millisecondsSinceEpoch}',
    'Data Processing',
    2,
    Collection([]), // Will be chained to notification batch
    {'type': 'processing'},
  );

  // Create second batch for notifications
  final notificationBatch = Batch(
    'notify-batch-${DateTime.now().millisecondsSinceEpoch}',
    'User Notifications',
    2,
    Collection([]),
    {'type': 'notification'},
  );

  // Chain the notification batch to run after processing batch
  final chainedProcessingBatch = processingBatch.withChainedBatches(
    Collection([notificationBatch.id]),
  );

  // Store both batches
  await repository.store(chainedProcessingBatch);
  await repository.store(notificationBatch);

  // Set up callbacks for processing batch
  chainedProcessingBatch
    ..then((b) {
      print('All data processed successfully!');
      print('Processed ${b.processedJobs} data items');
    })
    ..onError((b, error) {
      print('Error processing data: $error');
    })
    ..onFinish((b) {
      print('Data processing completed');
    });

  // Set up callbacks for notification batch
  notificationBatch
    ..then((b) {
      print('All notifications sent successfully!');
      print('Sent ${b.processedJobs} notifications');
    })
    ..onError((b, error) {
      print('Error sending notifications: $error');
    })
    ..onFinish((b) {
      print('Notification sending completed');
    });

  // Create and process data jobs
  final dataJobs = [
    ProcessDataJob('data1'),
    ProcessDataJob('data2'),
  ];

  // Process data jobs
  print('\nStarting data processing batch...');
  for (final job in dataJobs) {
    try {
      await job.handle();
      chainedProcessingBatch.processedJobs++;
      await repository.store(chainedProcessingBatch);
    } catch (error) {
      chainedProcessingBatch.failedJobs++;
      chainedProcessingBatch.invokeErrorCallback(error);
    }
  }

  // If data processing successful, process notification jobs
  if (chainedProcessingBatch.failedJobs == 0) {
    await chainedProcessingBatch.invokeSuccessCallback();
    chainedProcessingBatch.invokeFinallyCallback();

    // Create and process notification jobs
    final notificationJobs = [
      NotifyJob('user1', 'Your data1 has been processed'),
      NotifyJob('user2', 'Your data2 has been processed'),
    ];

    print('\nStarting notification batch...');
    for (final job in notificationJobs) {
      try {
        await job.handle();
        notificationBatch.processedJobs++;
        await repository.store(notificationBatch);
      } catch (error) {
        notificationBatch.failedJobs++;
        notificationBatch.invokeErrorCallback(error);
      }
    }

    if (notificationBatch.failedJobs == 0) {
      await notificationBatch.invokeSuccessCallback();
    }
    notificationBatch.invokeFinallyCallback();
  }

  // Clean up
  await chainedProcessingBatch.delete();
  await notificationBatch.delete();

  // Example output:
  // Starting data processing batch...
  // Processing data data1
  // Data data1 processed
  // Processing data data2
  // Data data2 processed
  // All data processed successfully!
  // Processed 2 data items
  // Data processing completed
  //
  // Starting notification batch...
  // Sending notification to user user1: Your data1 has been processed
  // Notification sent to user user1
  // Sending notification to user user2: Your data2 has been processed
  // Notification sent to user user2
  // All notifications sent successfully!
  // Sent 2 notifications
  // Notification sending completed
}
