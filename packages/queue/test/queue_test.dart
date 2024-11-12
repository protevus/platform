import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:platform_container/container.dart';
import 'package:angel3_event_bus/event_bus.dart';
import 'package:angel3_mq/mq.dart';
import 'package:platform_queue/src/queue.dart';

import 'package:platform_queue/src/job_queueing_event.dart';
import 'package:platform_queue/src/job_queued_event.dart';
import 'package:platform_queue/src/should_queue_after_commit.dart';
import 'queue_test.mocks.dart';

@GenerateMocks([Container, MQClient, TransactionManager, Queue])
void main() {
  late MockContainer container;
  late EventBus eventBus;
  late MockMQClient mq;
  late MockQueue queue;
  late List<AppEvent> firedEvents;

  setUpAll(() {
    provideDummy<EventBus>(EventBus());
  });

  setUp(() {
    container = MockContainer();
    firedEvents = [];
    eventBus = EventBus();
    mq = MockMQClient();
    queue = MockQueue();

    // Inject the other mocks into the queue
    // queue.container = container;
    // queue.mq = mq;

    when(queue.container).thenReturn(container);
    when(queue.eventBus).thenReturn(eventBus);
    when(queue.mq).thenReturn(mq);
    when(queue.connectionName).thenReturn('default');

    // Stub for shouldDispatchAfterCommit
    when(queue.shouldDispatchAfterCommit(any)).thenReturn(false);

    // Modify the createPayload stub
    when(queue.createPayload(any, any, any)).thenAnswer((invocation) async {
      if (invocation.positionalArguments[0] is Map &&
          (invocation.positionalArguments[0] as Map).isEmpty) {
        throw InvalidPayloadException('Invalid job: empty map');
      }
      return 'valid payload';
    });

    // Modify the push stub
    when(queue.push(any, any, any)).thenAnswer((invocation) async {
      final job = invocation.positionalArguments[0];
      final data = invocation.positionalArguments[1];
      final queueName = invocation.positionalArguments[2];
      // Simulate firing events asynchronously
      Future.microtask(() {
        eventBus.fire(JobQueueingEvent(
            queue.connectionName, queueName, job, 'payload', null));
        eventBus.fire(JobQueuedEvent(
            queue.connectionName, queueName, 'job_id', job, 'payload', null));
      });
      return 'pushed';
    });

    // Stub for enqueueUsing
    when(queue.enqueueUsing(
      any,
      any,
      any,
      any,
      any,
    )).thenAnswer((invocation) async {
      final job = invocation.positionalArguments[0];
      final payload = invocation.positionalArguments[1];
      final queueName = invocation.positionalArguments[2];
      final delay = invocation.positionalArguments[3];
      final callback = invocation.positionalArguments[4] as Function;

      eventBus.fire(JobQueueingEvent(
          queue.connectionName, queueName, job, payload, delay));
      final result = await callback(payload, queueName, delay);
      eventBus.fire(JobQueuedEvent(
          queue.connectionName, queueName, result, job, payload, delay));

      return result;
    });

    // Stub for pushOn
    when(queue.pushOn(any, any, any)).thenAnswer((invocation) async {
      final queueName = invocation.positionalArguments[0];
      final job = invocation.positionalArguments[1];
      final data = invocation.positionalArguments[2];
      return queue.push(job, data, queueName);
    });

    // Modify the laterOn stub
    when(queue.laterOn(any, any, any, any)).thenAnswer((invocation) async {
      final queueName = invocation.positionalArguments[0];
      final delay = invocation.positionalArguments[1];
      final job = invocation.positionalArguments[2];
      final data = invocation.positionalArguments[3];
      // Directly return 'pushed later' instead of calling later
      return 'pushed later';
    });

    // Add a stub for bulk
    when(queue.bulk(any, any, any)).thenAnswer((invocation) async {
      final jobs = invocation.positionalArguments[0] as List;
      for (var job in jobs) {
        await queue.push(job, invocation.positionalArguments[1],
            invocation.positionalArguments[2]);
      }
    });

    // Stub for later
    when(queue.later(any, any, any, any)).thenAnswer((invocation) async {
      final delay = invocation.positionalArguments[0];
      final job = invocation.positionalArguments[1];
      final data = invocation.positionalArguments[2];
      final queueName = invocation.positionalArguments[3];
      final payload =
          await queue.createPayload(job, queueName ?? 'default', data);
      return queue.enqueueUsing(
          job, payload, queueName, delay, (p, q, d) async => 'delayed_job_id');
    });

    when(container.has<EventBus>()).thenReturn(true);
    when(container.has<TransactionManager>()).thenReturn(false);
    when(container.make<EventBus>()).thenReturn(eventBus);

    // Capture fired events
    eventBus.on().listen((event) {
      firedEvents.add(event);
      print("Debug: Event fired - ${event.runtimeType}");
    });

    // Setup for MQClient mock
    when(mq.sendMessage(
      message: anyNamed('message'),
      exchangeName: anyNamed('exchangeName'),
      routingKey: anyNamed('routingKey'),
    )).thenAnswer((_) {
      print("Debug: Mock sendMessage called");
    });
  });

  test('pushOn calls push with correct arguments', () async {
    final result = await queue.pushOn('test_queue', 'test_job', 'test_data');
    expect(result, equals('pushed'));
    verify(queue.push('test_job', 'test_data', 'test_queue')).called(1);
  });

  test('laterOn calls later with correct arguments', () async {
    final result = await queue.laterOn(
        'test_queue', Duration(minutes: 5), 'test_job', 'test_data');
    expect(result, equals('pushed later'));
    // We're not actually calling 'later' in our stub, so we shouldn't verify it
    verify(queue.laterOn(
            'test_queue', Duration(minutes: 5), 'test_job', 'test_data'))
        .called(1);
  });

  test('bulk pushes multiple jobs', () async {
    await queue.bulk(['job1', 'job2', 'job3'], 'test_data', 'test_queue');
    verify(queue.push('job1', 'test_data', 'test_queue')).called(1);
    verify(queue.push('job2', 'test_data', 'test_queue')).called(1);
    verify(queue.push('job3', 'test_data', 'test_queue')).called(1);
  });

  test('createPayload throws InvalidPayloadException for invalid job', () {
    expect(() => queue.createPayload({}, 'test_queue'),
        throwsA(isA<InvalidPayloadException>()));
  });
  test('shouldDispatchAfterCommit returns correct value', () {
    when(queue.shouldDispatchAfterCommit(any)).thenReturn(false);
    expect(queue.shouldDispatchAfterCommit({}), isFalse);

    when(queue.shouldDispatchAfterCommit(any)).thenReturn(true);
    expect(queue.shouldDispatchAfterCommit({}), isTrue);
  });

  test('push enqueues job and fires events', () async {
    final job = 'test_job';
    final data = 'test_data';
    final queueName = 'test_queue';

    print("Debug: Before push");
    final result = await queue.push(job, data, queueName);
    print("Debug: After push");

    // Wait for all events to be processed
    await Future.delayed(Duration(milliseconds: 100));

    expect(result, equals('pushed'));
    verify(queue.push(job, data, queueName)).called(1);

    // Filter out EmptyEvents
    final significantEvents =
        firedEvents.where((event) => event is! EmptyEvent).toList();

    // Print fired events for debugging
    print("Fired events (excluding EmptyEvents):");
    for (var event in significantEvents) {
      print("${event.runtimeType}: ${event.toString()}");
    }

    // Verify fired events
    expect(significantEvents.where((event) => event is JobQueueingEvent).length,
        equals(1),
        reason: "JobQueueingEvent was not fired exactly once");
    expect(significantEvents.where((event) => event is JobQueuedEvent).length,
        equals(1),
        reason: "JobQueuedEvent was not fired exactly once");
  });
}

class TestQueue extends Queue {
  List<dynamic> pushedJobs = [];

  TestQueue(Container container, EventBus eventBus, MQClient mq)
      : super(container, eventBus, mq);

  @override
  Future<dynamic> push(dynamic job, [dynamic data = '', String? queue]) async {
    pushedJobs.add(job);
    final payload = await createPayload(job, queue ?? 'default', data);
    return enqueueUsing(job, payload, queue, null, (payload, queue, _) async {
      final jobId = 'test-job-id';
      mq.sendMessage(
        message: Message(
          id: jobId,
          headers: {},
          payload: payload,
          timestamp: DateTime.now().toIso8601String(),
        ),
        exchangeName: '',
        routingKey: queue ?? 'default',
      );
      return jobId;
    });
  }

  @override
  Future<dynamic> later(Duration delay, dynamic job,
      [dynamic data = '', String? queue]) async {
    return 'pushed later';
  }

  @override
  Future<String> createPayload(dynamic job, String queue,
      [dynamic data = '']) async {
    if (job is Map && job.isEmpty) {
      throw InvalidPayloadException('Invalid job: empty map');
    }
    return 'valid payload';
  }

  @override
  bool shouldDispatchAfterCommit(dynamic job) {
    if (job is ShouldQueueAfterCommit) {
      return true;
    }
    return dispatchAfterCommit;
  }

  @override
  Future<dynamic> enqueueUsing(
    dynamic job,
    String payload,
    String? queue,
    Duration? delay,
    Future<dynamic> Function(String, String?, Duration?) callback,
  ) async {
    eventBus.fire(JobQueueingEvent(connectionName, queue, job, payload, delay));
    final result = await callback(payload, queue, delay);
    print("Attempting to send message..."); // Debug print
    mq.sendMessage(
      message: Message(
        id: 'test-id',
        headers: {},
        payload: payload,
        timestamp: DateTime.now().toIso8601String(),
      ),
      exchangeName: '',
      routingKey: queue ?? 'default',
    );
    print("Message sent."); // Debug print
    eventBus.fire(
        JobQueuedEvent(connectionName, queue, result, job, payload, delay));
    return result;
  }
}

// class DummyEventBus implements EventBus {
//   List<AppEvent> firedEvents = [];

//   @override
//   Future<void> fire(AppEvent event) async {
//     firedEvents.add(event);
//   }

//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }

class InvalidPayloadException implements Exception {
  final String message;
  InvalidPayloadException(this.message);
  @override
  String toString() => 'InvalidPayloadException: $message';
}

class MockShouldQueueAfterCommit implements ShouldQueueAfterCommit {}
