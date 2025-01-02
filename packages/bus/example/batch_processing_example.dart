import 'package:platform_bus/platform_bus.dart';
import 'package:platform_collections/platform_collections.dart';

// Example job class that can be queued and processed
class EmailJob with QueueableMixin, InteractsWithQueueMixin {
  final String recipient;
  final String content;

  EmailJob(this.recipient, this.content);

  @override
  Future<void> handle() async {
    // Simulate sending email
    print('Sending email to $recipient: $content');
    await Future.delayed(Duration(milliseconds: 100)); // Simulate network delay
  }
}

void main() async {
  // Create a batch for processing multiple email jobs
  final batch = Batch(
    'email-batch-${DateTime.now().millisecondsSinceEpoch}',
    'Marketing Campaign',
    3, // Total number of jobs
    Collection([]), // No chained batches
    {'priority': 'high'}, // Custom options
  );

  // Set up batch callbacks
  batch
    ..then((b) {
      print('All emails sent successfully!');
      print('Processed ${b.processedJobs} jobs');
    })
    ..onError((b, error) {
      print('Error processing batch: $error');
      print('Failed jobs: ${b.failedJobs}');
    })
    ..onFinish((b) {
      print('Batch processing completed.');
      print('Final status: ${b.finished ? "Finished" : "Incomplete"}');
    });

  // Create an in-memory batch repository to store and manage batches
  final batchRepository = InMemoryBatchRepository();
  await batchRepository.store(batch);

  // Create and process email jobs
  final jobs = [
    EmailJob('user1@example.com', 'Welcome to our platform!'),
    EmailJob('user2@example.com', 'Check out our new features'),
    EmailJob('user3@example.com', 'Special offer just for you'),
  ];

  // Process each job and update batch progress
  for (final job in jobs) {
    try {
      await job.handle();
      batch.processedJobs++;

      // Update the batch in repository after each job
      await batchRepository.store(batch);
    } catch (error) {
      batch.failedJobs++;
      batch.invokeErrorCallback(error);
    }
  }

  // Invoke callbacks based on final status
  if (batch.failedJobs == 0) {
    await batch.invokeSuccessCallback();
  }
  batch.invokeFinallyCallback();

  // Clean up
  await batch.delete();

  // Example output:
  // Sending email to user1@example.com: Welcome to our platform!
  // Sending email to user2@example.com: Check out our new features
  // Sending email to user3@example.com: Special offer just for you
  // All emails sent successfully!
  // Processed 3 jobs
  // Batch processing completed.
  // Final status: Finished
}
