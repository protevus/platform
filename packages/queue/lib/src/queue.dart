// lib/src/queue.dart

import 'dart:async';
import 'dart:convert';

import 'package:platform_container/container.dart';
import 'package:angel3_event_bus/event_bus.dart';
import 'package:angel3_mq/mq.dart';
import 'package:angel3_reactivex/angel3_reactivex.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import 'job_queueing_event.dart';
import 'job_queued_event.dart';
import 'should_be_encrypted.dart';
import 'should_queue_after_commit.dart';

abstract class Queue with InteractsWithTime {
  /// The IoC container instance.
  final Container container;
  final EventBus eventBus;
  final MQClient mq;
  final Subject<dynamic> jobSubject;
  final Uuid uuid = Uuid();

  /// The connection name for the queue.
  String _connectionName;

  /// Indicates that jobs should be dispatched after all database transactions have committed.
  bool dispatchAfterCommit;

  /// The create payload callbacks.
  static final List<Function> _createPayloadCallbacks = [];

  Queue(this.container, this.eventBus, this.mq,
      {String connectionName = 'default', this.dispatchAfterCommit = false})
      : _connectionName = connectionName,
        jobSubject = PublishSubject<dynamic>() {
    _setupJobObservable();
  }

  void _setupJobObservable() {
    jobSubject.stream.listen((job) {
      // Process the job
      print('Processing job: $job');
      // Implement your job processing logic here
    });
  }

  Future<dynamic> pushOn(String queue, dynamic job, [dynamic data = '']) {
    return push(job, data, queue);
  }

  Future<dynamic> laterOn(String queue, Duration delay, dynamic job,
      [dynamic data = '']) {
    return later(delay, job, data, queue);
  }

  Future<void> bulk(List<dynamic> jobs,
      [dynamic data = '', String? queue]) async {
    for (var job in jobs) {
      await push(job, data, queue);
    }
  }

  // Add this method
  void setContainer(Container container) {
    // This method might not be necessary in Dart, as we're using final for container
    // But we can implement it for API compatibility
    throw UnsupportedError(
        'Container is final and cannot be changed after initialization');
  }

  // Update createPayload method to include exception handling
  Future<String> createPayload(dynamic job, String queue,
      [dynamic data = '']) async {
    if (job is Function) {
      // TODO: Implement CallQueuedClosure equivalent
      throw UnimplementedError('Closure jobs are not yet supported');
    }

    try {
      final payload = jsonEncode(await createPayloadMap(job, queue, data));
      return payload;
    } catch (e) {
      throw InvalidPayloadException('Unable to JSON encode payload: $e');
    }
  }

  Future<Map<String, dynamic>> createPayloadMap(dynamic job, String queue,
      [dynamic data = '']) async {
    if (job is Object) {
      return createObjectPayload(job, queue);
    } else {
      return createStringPayload(job.toString(), queue, data);
    }
  }

  Future<Map<String, dynamic>> createObjectPayload(
      Object job, String queue) async {
    final payload = await withCreatePayloadHooks(queue, {
      'uuid': const Uuid().v4(),
      'displayName': getDisplayName(job),
      'job': 'CallQueuedHandler@call', // TODO: Implement CallQueuedHandler
      'maxTries': getJobTries(job),
      'maxExceptions': job is HasMaxExceptions ? job.maxExceptions : null,
      'failOnTimeout': job is HasFailOnTimeout ? job.failOnTimeout : false,
      'backoff': getJobBackoff(job),
      'timeout': job is HasTimeout ? job.timeout : null,
      'retryUntil': getJobExpiration(job),
      'data': {
        'commandName': job.runtimeType.toString(),
        'command': job,
      },
    });

    final command = jobShouldBeEncrypted(job) && container.has<Encrypter>()
        ? container.make<Encrypter>().encrypt(jsonEncode(job))
        : jsonEncode(job);

    payload['data'] = {
      ...payload['data'] as Map<String, dynamic>,
      'commandName': job.runtimeType.toString(),
      'command': command,
    };

    return payload;
  }

  String getDisplayName(Object job) {
    if (job is HasDisplayName) {
      return job.displayName();
    }
    return job.runtimeType.toString();
  }

  int? getJobTries(dynamic job) {
    if (job is HasTries) {
      return job.tries;
    }
    return null;
  }

  String? getJobBackoff(dynamic job) {
    if (job is HasBackoff) {
      final backoff = job.backoff;
      if (backoff == null) return null;
      if (backoff is Duration) {
        return backoff.inSeconds.toString();
      }
      if (backoff is List<Duration>) {
        return backoff.map((d) => d.inSeconds).join(',');
      }
    }
    return null;
  }

  int? getJobExpiration(dynamic job) {
    if (job is HasRetryUntil) {
      final retryUntil = job.retryUntil;
      if (retryUntil == null) return null;
      return retryUntil.millisecondsSinceEpoch ~/ 1000;
    }
    return null;
  }

  bool jobShouldBeEncrypted(Object job) {
    return job is ShouldBeEncrypted ||
        (job is HasShouldBeEncrypted && job.shouldBeEncrypted);
  }

  Future<Map<String, dynamic>> createStringPayload(
      String job, String queue, dynamic data) async {
    return withCreatePayloadHooks(queue, {
      'uuid': const Uuid().v4(),
      'displayName': job.split('@')[0],
      'job': job,
      'maxTries': null,
      'maxExceptions': null,
      'failOnTimeout': false,
      'backoff': null,
      'timeout': null,
      'data': data,
    });
  }

  static void createPayloadUsing(Function? callback) {
    if (callback == null) {
      _createPayloadCallbacks.clear();
    } else {
      _createPayloadCallbacks.add(callback);
    }
  }

  Future<Map<String, dynamic>> withCreatePayloadHooks(
      String queue, Map<String, dynamic> payload) async {
    if (_createPayloadCallbacks.isNotEmpty) {
      for (var callback in _createPayloadCallbacks) {
        final result = await callback(_connectionName, queue, payload);
        if (result is Map<String, dynamic>) {
          payload = {...payload, ...result};
        }
      }
    }
    return payload;
  }

  Future<dynamic> enqueueUsing(
    dynamic job,
    String payload,
    String? queue,
    Duration? delay,
    Future<dynamic> Function(String, String?, Duration?) callback,
  ) async {
    final String jobId = uuid.v4(); // Generate a unique job ID

    if (shouldDispatchAfterCommit(job) && container.has<TransactionManager>()) {
      return container.make<TransactionManager>().addCallback(() async {
        await raiseJobQueueingEvent(queue, job, payload, delay);
        final result = await callback(payload, queue, delay);
        await raiseJobQueuedEvent(queue, jobId, job, payload, delay);
        return result;
      });
    }

    await raiseJobQueueingEvent(queue, job, payload, delay);
    final result = await callback(payload, queue, delay);
    await raiseJobQueuedEvent(queue, jobId, job, payload, delay);

    // Use angel3_mq to publish the job
    mq.sendMessage(
      message: Message(
        headers: {'jobId': jobId}, // Include jobId in headers
        payload: payload,
        timestamp: DateTime.now().toIso8601String(),
      ),
      exchangeName: '', // Use default exchange
      routingKey: queue ?? 'default',
    );

    // Use angel3_reactivex to add the job to the subject
    jobSubject.add(job);

    return result;
  }

  bool shouldDispatchAfterCommit(dynamic job) {
    if (job is ShouldQueueAfterCommit) {
      return true;
    }
    if (job is HasAfterCommit) {
      return job.afterCommit;
    }
    return dispatchAfterCommit;
  }

  Future<void> raiseJobQueueingEvent(
      String? queue, dynamic job, String payload, Duration? delay) async {
    if (container.has<EventBus>()) {
      final eventBus = container.make<EventBus>();
      eventBus
          .fire(JobQueueingEvent(_connectionName, queue, job, payload, delay));
    }
  }

  Future<void> raiseJobQueuedEvent(String? queue, dynamic jobId, dynamic job,
      String payload, Duration? delay) async {
    if (container.has<EventBus>()) {
      final eventBus = container.make<EventBus>();
      eventBus.fire(
          JobQueuedEvent(_connectionName, queue, jobId, job, payload, delay));
    }
  }

  String get connectionName => _connectionName;

  set connectionName(String name) {
    _connectionName = name;
  }

  Container getContainer() => container;

  // Abstract methods to be implemented by subclasses
  // Implement the push method
  Future<dynamic> push(dynamic job, [dynamic data = '', String? queue]) async {
    final payload = await createPayload(job, queue ?? 'default', data);
    return enqueueUsing(job, payload, queue, null, (payload, queue, _) async {
      final jobId = Uuid().v4();
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

  // Implement the later method
  Future<dynamic> later(Duration delay, dynamic job,
      [dynamic data = '', String? queue]) async {
    final payload = await createPayload(job, queue ?? 'default', data);
    return enqueueUsing(job, payload, queue, delay,
        (payload, queue, delay) async {
      final jobId = Uuid().v4();
      await Future.delayed(delay!);
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

  // Cleanup method
  void dispose() {
    jobSubject.close();
  }
}

// Additional interfaces and classes

abstract class HasMaxExceptions {
  int? get maxExceptions;
}

abstract class HasFailOnTimeout {
  bool get failOnTimeout;
}

abstract class HasTimeout {
  Duration? get timeout;
}

abstract class HasDisplayName {
  String displayName();
}

abstract class HasTries {
  int? get tries;
}

abstract class HasBackoff {
  dynamic get backoff;
}

abstract class HasRetryUntil {
  DateTime? get retryUntil;
}

abstract class HasAfterCommit {
  bool get afterCommit;
}

abstract class HasShouldBeEncrypted {
  bool get shouldBeEncrypted;
}

abstract class Encrypter {
  String encrypt(String data);
}

abstract class TransactionManager {
  Future<T> addCallback<T>(Future<T> Function() callback);
}

// Add this mixin to the Queue class
mixin InteractsWithTime {
  int secondsUntil(DateTime dateTime) {
    return dateTime.difference(DateTime.now()).inSeconds;
  }

  int availableAt(Duration delay) {
    return DateTime.now().add(delay).millisecondsSinceEpoch ~/ 1000;
  }
}

// First, define the InvalidPayloadException class
class InvalidPayloadException implements Exception {
  final String message;

  InvalidPayloadException(this.message);

  @override
  String toString() => 'InvalidPayloadException: $message';
}
