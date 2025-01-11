# Queue

A Dart implementation of Laravel's queue package with full feature parity and API compatibility.

## Features

- Multiple queue drivers (Redis support, more coming soon)
- Delayed job scheduling
- Job retries with backoff
- Job failure handling
- Worker process management
- Queue driver abstraction

## Installation

```yaml
dependencies:
  queue: ^1.0.0
```

## Usage

### Basic Usage

```dart
// Configure and get a queue instance
final manager = QueueManager();
manager.registerDefaultDrivers();
final queue = manager.connection();

// Push a job onto the queue
await queue.push('ProcessPodcast', data: {'id': 5});

// Push a delayed job
await queue.later(
  Duration(minutes: 10),
  'ProcessPodcast',
  data: {'id': 5},
);

// Process jobs
final worker = Worker(queue);
final options = WorkerOptions(
  timeout: Duration(minutes: 5),
  maxTries: 3,
);

await worker.daemon('default', options);
```

### Custom Jobs

```dart
class ProcessPodcast implements Job {
  final int podcastId;
  
  ProcessPodcast(this.podcastId);
  
  @override
  Future<void> fire() async {
    // Process the podcast...
  }
  
  // Implement other Job interface methods...
}
```

### Configuration

```dart
final config = {
  'driver': 'redis',
  'connection': redisClient,
  'queue': 'default',
  'retry_after': 90,
};

final queue = manager.connection('redis');
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is open-sourced software licensed under the MIT license.
