import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:queue/src/contracts/queue.dart';
import 'package:queue/src/exceptions/invalid_payload_exception.dart';

/// Base class for queue implementations.
abstract class QueueBase implements Queue {
  final _uuid = const Uuid();
  String _connectionName = 'default';

  @override
  String get connectionName => _connectionName;

  @override
  set connectionName(String name) {
    _connectionName = name;
  }

  /// Create a payload string from the given job and data.
  String createPayload(
    String job,
    String? queue,
    Map<String, dynamic>? data,
  ) {
    final payload = createPayloadArray(job, queue ?? 'default', data);

    try {
      return jsonEncode(payload);
    } catch (e) {
      throw InvalidPayloadException(
        'Unable to JSON encode payload: ${e.toString()}',
        payload,
      );
    }
  }

  /// Create a payload array from the given job and data.
  Map<String, dynamic> createPayloadArray(
    String job,
    String queue,
    Map<String, dynamic>? data,
  ) {
    return {
      'uuid': _uuid.v4(),
      'displayName': job,
      'job': job,
      'maxTries': null,
      'maxExceptions': null,
      'failOnTimeout': false,
      'backoff': null,
      'timeout': null,
      'data': data ?? {},
      'attempts': 0,
    };
  }

  /// Push a job onto a specific queue.
  @override
  Future<String?> push(
    String job, {
    Map<String, dynamic>? data,
    String? queue,
  }) async {
    final payload = createPayload(job, queue, data);
    return pushRaw(payload, queue);
  }

  /// Push a raw payload onto the queue.
  Future<String?> pushRaw(String payload, [String? queue]);

  /// Push a job onto the queue after a delay.
  @override
  Future<String?> later(
    Duration delay,
    String job, {
    Map<String, dynamic>? data,
    String? queue,
  }) async {
    final payload = createPayload(job, queue, data);
    return laterRaw(delay, payload, queue);
  }

  /// Push a raw payload onto the queue after a delay.
  Future<String?> laterRaw(Duration delay, String payload, [String? queue]);

  /// Push multiple jobs onto the queue.
  @override
  Future<void> bulk(
    List<String> jobs, {
    Map<String, dynamic>? data,
    String? queue,
  }) async {
    for (final job in jobs) {
      await push(job, data: data, queue: queue);
    }
  }

  /// Get the queue name, using the default if none specified.
  String getQueue(String? queue) => queue ?? 'default';
}
