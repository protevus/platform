# Queue Package Specification

## Overview

The Queue package provides a robust job queueing system that matches Laravel's queue functionality. It supports multiple queue drivers, job retries, rate limiting, and job batching while integrating with our Event and Bus packages.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Events Package Specification](events_package_specification.md) for event integration
> - See [Bus Package Specification](bus_package_specification.md) for command bus integration

## Core Features

### 1. Queue Manager

```dart
/// Core queue manager implementation
class QueueManager implements QueueContract {
  /// Available queue connections
  final Map<String, QueueConnection> _connections = {};
  
  /// Default connection name
  final String _defaultConnection;
  
  /// Configuration repository
  final ConfigContract _config;
  
  QueueManager(this._config)
      : _defaultConnection = _config.get('queue.default', 'sync');
  
  @override
  Future<String> push(dynamic job, [String? queue]) async {
    return await connection().push(job, queue);
  }
  
  @override
  Future<String> later(Duration delay, dynamic job, [String? queue]) async {
    return await connection().later(delay, job, queue);
  }
  
  @override
  Future<Job?> pop([String? queue]) async {
    return await connection().pop(queue);
  }
  
  @override
  QueueConnection connection([String? name]) {
    name ??= _defaultConnection;
    
    return _connections.putIfAbsent(name, () {
      var config = _getConfig(name!);
      return _createConnection(config);
    });
  }
  
  /// Creates a queue connection
  QueueConnection _createConnection(Map<String, dynamic> config) {
    switch (config['driver']) {
      case 'sync':
        return SyncConnection(config);
      case 'database':
        return DatabaseConnection(config);
      case 'redis':
        return RedisConnection(config);
      case 'sqs':
        return SqsConnection(config);
      default:
        throw UnsupportedError(
          'Unsupported queue driver: ${config["driver"]}'
        );
    }
  }
  
  /// Gets connection config
  Map<String, dynamic> _getConfig(String name) {
    var config = _config.get<Map>('queue.connections.$name');
    if (config == null) {
      throw ArgumentError('Queue connection [$name] not configured.');
    }
    return config;
  }
}
```

### 2. Queue Connections

```dart
/// Database queue connection
class DatabaseConnection implements QueueConnection {
  /// Database connection
  final DatabaseConnection _db;
  
  /// Table name
  final String _table;
  
  DatabaseConnection(Map<String, dynamic> config)
      : _db = DatabaseManager.connection(config['connection']),
        _table = config['table'] ?? 'jobs';
  
  @override
  Future<String> push(dynamic job, [String? queue]) async {
    queue ??= 'default';
    var id = Uuid().v4();
    
    await _db.table(_table).insert({
      'id': id,
      'queue': queue,
      'payload': _serialize(job),
      'attempts': 0,
      'reserved_at': null,
      'available_at': DateTime.now(),
      'created_at': DateTime.now()
    });
    
    return id;
  }
  
  @override
  Future<String> later(Duration delay, dynamic job, [String? queue]) async {
    queue ??= 'default';
    var id = Uuid().v4();
    
    await _db.table(_table).insert({
      'id': id,
      'queue': queue,
      'payload': _serialize(job),
      'attempts': 0,
      'reserved_at': null,
      'available_at': DateTime.now().add(delay),
      'created_at': DateTime.now()
    });
    
    return id;
  }
  
  @override
  Future<Job?> pop([String? queue]) async {
    queue ??= 'default';
    
    var job = await _db.transaction((tx) async {
      var job = await tx.table(_table)
        .where('queue', queue)
        .whereNull('reserved_at')
        .where('available_at', '<=', DateTime.now())
        .orderBy('id')
        .first();
        
      if (job != null) {
        await tx.table(_table)
          .where('id', job['id'])
          .update({
            'reserved_at': DateTime.now(),
            'attempts': job['attempts'] + 1
          });
      }
      
      return job;
    });
    
    if (job == null) return null;
    
    return DatabaseJob(
      connection: this,
      queue: queue,
      job: job
    );
  }
  
  /// Serializes job payload
  String _serialize(dynamic job) {
    return jsonEncode({
      'type': job.runtimeType.toString(),
      'data': job.toMap()
    });
  }
}

/// Redis queue connection
class RedisConnection implements QueueConnection {
  /// Redis client
  final RedisClient _redis;
  
  /// Key prefix
  final String _prefix;
  
  RedisConnection(Map<String, dynamic> config)
      : _redis = RedisClient(
          host: config['host'],
          port: config['port'],
          db: config['database']
        ),
        _prefix = config['prefix'] ?? 'queues';
  
  @override
  Future<String> push(dynamic job, [String? queue]) async {
    queue ??= 'default';
    var id = Uuid().v4();
    
    await _redis.rpush(
      _getKey(queue),
      _serialize(id, job)
    );
    
    return id;
  }
  
  @override
  Future<String> later(Duration delay, dynamic job, [String? queue]) async {
    queue ??= 'default';
    var id = Uuid().v4();
    
    await _redis.zadd(
      _getDelayedKey(queue),
      DateTime.now().add(delay).millisecondsSinceEpoch.toDouble(),
      _serialize(id, job)
    );
    
    return id;
  }
  
  @override
  Future<Job?> pop([String? queue]) async {
    queue ??= 'default';
    
    // Move delayed jobs
    var now = DateTime.now().millisecondsSinceEpoch;
    var jobs = await _redis.zrangebyscore(
      _getDelayedKey(queue),
      '-inf',
      now.toString()
    );
    
    for (var job in jobs) {
      await _redis.rpush(_getKey(queue), job);
      await _redis.zrem(_getDelayedKey(queue), job);
    }
    
    // Get next job
    var payload = await _redis.lpop(_getKey(queue));
    if (payload == null) return null;
    
    return RedisJob(
      connection: this,
      queue: queue,
      payload: payload
    );
  }
  
  /// Gets queue key
  String _getKey(String queue) => '$_prefix:$queue';
  
  /// Gets delayed queue key
  String _getDelayedKey(String queue) => '$_prefix:$queue:delayed';
  
  /// Serializes job payload
  String _serialize(String id, dynamic job) {
    return jsonEncode({
      'id': id,
      'type': job.runtimeType.toString(),
      'data': job.toMap(),
      'attempts': 0
    });
  }
}
```

### 3. Queue Jobs

```dart
/// Core job interface
abstract class Job {
  /// Job ID
  String get id;
  
  /// Job queue
  String get queue;
  
  /// Number of attempts
  int get attempts;
  
  /// Maximum tries
  int get maxTries => 3;
  
  /// Timeout in seconds
  int get timeout => 60;
  
  /// Executes the job
  Future<void> handle();
  
  /// Releases the job back onto queue
  Future<void> release([Duration? delay]);
  
  /// Deletes the job
  Future<void> delete();
  
  /// Fails the job
  Future<void> fail([Exception? exception]);
}

/// Database job implementation
class DatabaseJob implements Job {
  /// Database connection
  final DatabaseConnection _connection;
  
  /// Job data
  final Map<String, dynamic> _data;
  
  /// Job queue
  @override
  final String queue;
  
  DatabaseJob({
    required DatabaseConnection connection,
    required String queue,
    required Map<String, dynamic> job
  }) : _connection = connection,
       _data = job,
       queue = queue;
  
  @override
  String get id => _data['id'];
  
  @override
  int get attempts => _data['attempts'];
  
  @override
  Future<void> handle() async {
    var payload = jsonDecode(_data['payload']);
    var job = _deserialize(payload);
    await job.handle();
  }
  
  @override
  Future<void> release([Duration? delay]) async {
    await _connection._db.table(_connection._table)
      .where('id', id)
      .update({
        'reserved_at': null,
        'available_at': delay != null
          ? DateTime.now().add(delay)
          : DateTime.now()
      });
  }
  
  @override
  Future<void> delete() async {
    await _connection._db.table(_connection._table)
      .where('id', id)
      .delete();
  }
  
  @override
  Future<void> fail([Exception? exception]) async {
    await _connection._db.table(_connection._table)
      .where('id', id)
      .update({
        'failed_at': DateTime.now()
      });
      
    if (exception != null) {
      await _connection._db.table('failed_jobs').insert({
        'id': Uuid().v4(),
        'connection': _connection.name,
        'queue': queue,
        'payload': _data['payload'],
        'exception': exception.toString(),
        'failed_at': DateTime.now()
      });
    }
  }
  
  /// Deserializes job payload
  dynamic _deserialize(Map<String, dynamic> payload) {
    var type = payload['type'];
    var data = payload['data'];
    
    return _connection._container.make(type)
      ..fromMap(data);
  }
}
```

### 4. Job Batching

```dart
/// Job batch
class Batch {
  /// Batch ID
  final String id;
  
  /// Queue connection
  final QueueConnection _connection;
  
  /// Jobs in batch
  final List<Job> _jobs;
  
  /// Options
  final BatchOptions _options;
  
  Batch(this.id, this._connection, this._jobs, this._options);
  
  /// Gets total jobs
  int get totalJobs => _jobs.length;
  
  /// Gets pending jobs
  Future<int> get pendingJobs async {
    return await _connection.table('job_batches')
      .where('id', id)
      .value('pending_jobs');
  }
  
  /// Gets failed jobs
  Future<int> get failedJobs async {
    return await _connection.table('job_batches')
      .where('id', id)
      .value('failed_jobs');
  }
  
  /// Adds jobs to batch
  Future<void> add(List<Job> jobs) async {
    _jobs.addAll(jobs);
    
    await _connection.table('job_batches')
      .where('id', id)
      .increment('total_jobs', jobs.length)
      .increment('pending_jobs', jobs.length);
      
    for (var job in jobs) {
      await _connection.push(job);
    }
  }
  
  /// Cancels the batch
  Future<void> cancel() async {
    await _connection.table('job_batches')
      .where('id', id)
      .update({
        'cancelled_at': DateTime.now()
      });
  }
  
  /// Deletes the batch
  Future<void> delete() async {
    await _connection.table('job_batches')
      .where('id', id)
      .delete();
  }
}
```

## Integration Examples

### 1. Basic Queue Usage
```dart
// Define job
class ProcessPodcast implements Job {
  final Podcast podcast;
  
  @override
  Future<void> handle() async {
    await podcast.process();
  }
}

// Push job to queue
await queue.push(ProcessPodcast(podcast));

// Push delayed job
await queue.later(
  Duration(minutes: 10),
  ProcessPodcast(podcast)
);
```

### 2. Job Batching
```dart
// Create batch
var batch = await queue.batch([
  ProcessPodcast(podcast1),
  ProcessPodcast(podcast2),
  ProcessPodcast(podcast3)
])
.allowFailures()
.dispatch();

// Add more jobs
await batch.add([
  ProcessPodcast(podcast4),
  ProcessPodcast(podcast5)
]);

// Check progress
print('Pending: ${await batch.pendingJobs}');
print('Failed: ${await batch.failedJobs}');
```

### 3. Queue Worker
```dart
// Start worker
var worker = QueueWorker(connection)
  ..onJob((job) async {
    print('Processing job ${job.id}');
  })
  ..onException((job, exception) async {
    print('Job ${job.id} failed: $exception');
  });

await worker.daemon([
  'default',
  'emails',
  'podcasts'
]);
```

## Testing

```dart
void main() {
  group('Queue Manager', () {
    test('pushes jobs to queue', () async {
      var queue = QueueManager(config);
      var job = ProcessPodcast(podcast);
      
      var id = await queue.push(job);
      
      expect(id, isNotEmpty);
      verify(() => connection.push(job, null)).called(1);
    });
    
    test('handles delayed jobs', () async {
      var queue = QueueManager(config);
      var job = ProcessPodcast(podcast);
      var delay = Duration(minutes: 5);
      
      await queue.later(delay, job);
      
      verify(() => connection.later(delay, job, null)).called(1);
    });
  });
  
  group('Job Batching', () {
    test('processes job batches', () async {
      var batch = await queue.batch([
        ProcessPodcast(podcast1),
        ProcessPodcast(podcast2)
      ]).dispatch();
      
      expect(batch.totalJobs, equals(2));
      expect(await batch.pendingJobs, equals(2));
      expect(await batch.failedJobs, equals(0));
    });
  });
}
```

## Next Steps

1. Implement core queue features
2. Add queue connections
3. Add job batching
4. Add queue worker
5. Write tests
6. Add benchmarks

## Development Guidelines

### 1. Getting Started
Before implementing queue features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Events Package Specification](events_package_specification.md)
6. Review [Bus Package Specification](bus_package_specification.md)

### 2. Implementation Process
For each queue feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Support event integration (see [Events Package Specification](events_package_specification.md))
5. Support bus integration (see [Bus Package Specification](bus_package_specification.md))

### 4. Integration Considerations
When implementing queue features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)

### 5. Performance Guidelines
Queue system must:
1. Handle high job throughput
2. Process batches efficiently
3. Support concurrent workers
4. Scale horizontally
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Queue tests must:
1. Cover all queue operations
2. Test job processing
3. Verify batching
4. Check worker behavior
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Queue documentation must:
1. Explain queue patterns
2. Show job examples
3. Cover error handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
