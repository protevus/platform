import 'dart:async';

import 'package:platform_bus/platform_bus.dart' hide Dispatcher;
import 'package:platform_collections/platform_collections.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_contracts/contracts.dart'
    show Queue, ShouldQueue, QueueableJob;
import 'package:platform_bus/src/dispatcher.dart' show Dispatcher;

// 1. Simple command that handles itself
class SendEmailCommand with QueueableMixin, InteractsWithQueueMixin {
  final String to;
  final String subject;
  final String content;

  SendEmailCommand(this.to, this.subject, this.content);

  Future<void> handle() async {
    print('Sending email to $to');
    print('Subject: $subject');
    print('Content: $content');
    await Future.delayed(Duration(milliseconds: 100)); // Simulate network delay
    print('Email sent successfully to $to');
  }
}

// 2. Command with dedicated handler
class ProcessPaymentCommand {
  final String orderId;
  final double amount;

  ProcessPaymentCommand(this.orderId, this.amount);
}

class ProcessPaymentHandler {
  Future<String> handle(ProcessPaymentCommand command) async {
    print('Processing payment for order ${command.orderId}');
    print('Amount: \$${command.amount}');
    await Future.delayed(Duration(milliseconds: 150)); // Simulate processing
    return 'Payment processed successfully for order ${command.orderId}';
  }
}

// 3. Queueable command for background processing
class GenerateReportCommand
    with QueueableMixin, InteractsWithQueueMixin
    implements ShouldQueue {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;

  GenerateReportCommand(this.reportType, this.startDate, this.endDate);

  Future<void> handle() async {
    print('Generating $reportType report');
    print(
        'Period: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
    await Future.delayed(Duration(seconds: 1)); // Simulate long-running task
    print('Report generated successfully');
  }
}

// Pipeline middleware for logging
class LoggingPipe {
  Future<dynamic> handle(
      dynamic command, FutureOr<dynamic> Function(dynamic) next) async {
    print('\n[${DateTime.now()}] Executing ${command.runtimeType}');
    final result = await next(command);
    print('[${DateTime.now()}] Completed ${command.runtimeType}\n');
    return result;
  }
}

void main() async {
  // Set up the container and dispatcher
  final container = Container(MirrorsReflector());

  // Create a simple in-memory queue
  final queue = InMemoryQueue();
  FutureOr<Queue> queueResolver(String? connection) => queue;

  // Create the dispatcher with queue support
  final dispatcher = Dispatcher(container, queueResolver);

  // Register the payment handler
  dispatcher.map({
    ProcessPaymentCommand: ProcessPaymentHandler,
  });

  // Add logging pipeline
  dispatcher.pipeThrough([LoggingPipe()]);

  // 1. Dispatch a command that handles itself
  print('Example 1: Direct command handling');
  await dispatcher.dispatchNow(
    SendEmailCommand(
      'user@example.com',
      'Welcome!',
      'Welcome to our platform.',
    ),
  );

  // 2. Dispatch a command through a handler
  print('\nExample 2: Handler-based command processing');
  final paymentResult = await dispatcher.dispatchNow<String>(
    ProcessPaymentCommand('ORDER-123', 99.99),
  );
  print('Result: $paymentResult');

  // 3. Dispatch a command to the queue
  print('\nExample 3: Queued command processing');
  await dispatcher.dispatch(
    GenerateReportCommand(
      'Monthly Sales',
      DateTime(2024, 1, 1),
      DateTime(2024, 1, 31),
    ),
  );

  // 4. Create and dispatch a batch of commands
  print('\nExample 4: Batch command processing');
  final batch = await dispatcher.batch([
    SendEmailCommand(
      'user1@example.com',
      'Batch Email 1',
      'First batch email content',
    ),
    SendEmailCommand(
      'user2@example.com',
      'Batch Email 2',
      'Second batch email content',
    ),
  ]).dispatch();

  // Wait for batch to complete
  while (!batch.finished) {
    await Future.delayed(Duration(milliseconds: 50));
    print('Batch progress: ${batch.processedJobs}/${batch.totalJobs}');
  }

  print('\nAll examples completed');
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
    if (job is GenerateReportCommand) {
      await job.handle();
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
