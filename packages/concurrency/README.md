# Platform Concurrency

A Laravel-style concurrency package for Dart applications, providing task scheduling, job throttling, mutex locks, and rate limiting capabilities.

## Features

- **Multiple Concurrency Drivers**
  - IsolateDriver: Uses Dart isolates for true parallel execution
  - ProcessDriver: Uses system processes for CPU-intensive tasks
  - SyncDriver: Sequential execution for testing and debugging

- **Mutex Locks**
  - Prevent concurrent access to shared resources
  - Support for timeouts and automatic lock release
  - Guard pattern for cleaner resource protection

- **Rate Limiting**
  - Token bucket algorithm for precise rate control
  - Support for per-second, per-minute, and per-hour limits
  - Configurable burst limits

- **Task Scheduling**
  - Cron-style expressions for complex schedules
  - Interval-based scheduling
  - Support for immediate and delayed execution

- **Request Throttling**
  - Control execution rates with minimum intervals
  - Optional request combining for high-frequency events
  - Support for timeouts and cancellation

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  platform_concurrency: ^0.0.1
```

## Usage

### Concurrency Drivers

```dart
import 'package:platform_concurrency/platform_concurrency.dart';

// Create a manager with default settings
final manager = ConcurrencyManager();

// Run tasks concurrently
final results = await manager.runAll([
  () => computeIntensive(),
  () => anotherTask(),
]);

// Use specific driver
manager.setDefaultDriver('process');
await manager.run(() => cpuBoundTask());
```

### Mutex Locks

```dart
final mutex = Mutex();

// Synchronize access to shared resources
await mutex.synchronized(() async {
  await sharedResource.update();
});

// Use guard pattern
final guard = mutex.guard(() => sharedResource.update());
await guard.withTimeout(Duration(seconds: 5)).protect();
```

### Rate Limiting

```dart
final limiter = RateLimiter.perSecond(10);

// Try to acquire a token
if (limiter.tryAcquire()) {
  await makeApiCall();
}

// Wait for available token
await limiter.acquire();
await makeApiCall();

// Execute with rate limiting
await limiter.execute(() => makeApiCall());
```

### Task Scheduling

```dart
final scheduler = Scheduler(SyncDriver());

// Schedule with cron expression
scheduler.schedule(
  () => dailyTask(),
  cron: '0 0 * * *', // Midnight every day
);

// Schedule with interval
scheduler.schedule(
  () => periodicTask(),
  interval: Duration(minutes: 5),
);

scheduler.start();
```

### Request Throttling

```dart
final throttle = Throttle(
  minInterval: Duration(seconds: 1),
  combineRequests: true,
);

// Execute with throttling
await throttle.execute(() => handleUserInput());

// Run void tasks
await throttle.run(() => updateUI());
```

## Error Handling

The package provides specific exception types for different scenarios:

- `ConcurrencyException`: Base exception for concurrency-related errors
- `MutexException`: Lock acquisition and release errors
- `RateLimitExceededException`: Rate limit exceeded
- `SchedulerException`: Invalid schedules or task execution errors
- `ThrottleException`: Throttling timeouts or cancellations

## Advanced Usage

### Custom Drivers

You can implement custom concurrency drivers by implementing the `Driver` interface:

```dart
class CustomDriver implements Driver {
  @override
  Future<List<T>> run<T>(FutureOr<T> Function() task, {int times = 1}) {
    // Custom implementation
  }

  @override
  Future<List<T>> runAll<T>(List<FutureOr<T> Function()> tasks) {
    // Custom implementation
  }

  @override
  Future<void> defer<T>(FutureOr<T> Function() task, {int times = 1}) {
    // Custom implementation
  }

  @override
  Future<void> deferAll<T>(List<FutureOr<T> Function()> tasks) {
    // Custom implementation
  }
}
```

### Configuration

The package is designed to be configurable and extensible:

```dart
// Configure rate limiter
final limiter = RateLimiter(
  tokensPerInterval: 100,
  interval: Duration(minutes: 1),
  maxBurst: 20,
);

// Configure throttle
final throttle = Throttle(
  minInterval: Duration(milliseconds: 100),
  combineRequests: true,
);

// Configure scheduler
final scheduler = Scheduler(
  IsolateDriver(maxConcurrent: 4),
);
```

## Testing

The package includes a `SyncDriver` that executes tasks sequentially, making it ideal for testing:

```dart
void main() {
  test('concurrent operations', () async {
    final manager = ConcurrencyManager()..setDefaultDriver('sync');
    final results = await manager.runAll([
      () => task1(),
      () => task2(),
    ]);
    expect(results, [...]);
  });
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is open-sourced software licensed under the MIT license.
