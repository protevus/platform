# Process Execution

The Process package provides comprehensive features for process execution and management.

## Basic Process Execution

The simplest way to execute a process is using the `Factory` class:

```dart
final factory = Factory();
final result = await factory.command('echo "Hello"').run();
```

## Process Configuration

### Working Directory

Set the working directory for process execution:

```dart
await factory
    .command('npm install')
    .path('/path/to/project')
    .run();
```

### Environment Variables

Configure process environment:

```dart
await factory
    .command('node app.js')
    .env({
      'NODE_ENV': 'production',
      'PORT': '3000',
    })
    .run();
```

### Timeouts

Set execution and idle timeouts:

```dart
await factory
    .command('long-task')
    .timeout(Duration(minutes: 5))      // Total execution timeout
    .idleTimeout(Duration(seconds: 30)) // Idle timeout
    .run();
```

### Input/Output

Handle process input and output:

```dart
// Provide input
await factory
    .command('cat')
    .input('Hello, World!')
    .run();

// Capture output in real-time
await factory
    .command('long-task')
    .run((output) {
      print('Real-time output: $output');
    });

// Suppress output
await factory
    .command('noisy-task')
    .quietly()
    .run();
```

### TTY Mode

Enable TTY mode for interactive processes:

```dart
await factory
    .command('interactive-script')
    .tty()
    .run();
```

## Process Lifecycle

### Starting Processes

```dart
// Run and wait for completion
final result = await factory.command('task').run();

// Start without waiting
final process = await factory.command('server').start();
```

### Monitoring Processes

```dart
final process = await factory.command('server').start();

// Get process ID
print('PID: ${process.pid}');

// Check if running
if (await process.isRunning()) {
  print('Process is still running');
}

// Wait for completion
final result = await process.wait();
```

### Stopping Processes

```dart
// Kill process
process.kill();

// Kill with signal
process.kill(ProcessSignal.sigterm);

// Kill after timeout
await factory
    .command('task')
    .timeout(Duration(seconds: 30))
    .run();
```

## Error Handling

### Basic Error Handling

```dart
try {
  final result = await factory
      .command('risky-command')
      .run();
      
  result.throwIfFailed();
} catch (e) {
  print('Process failed: $e');
}
```

### Custom Error Handling

```dart
final result = await factory
    .command('task')
    .run();

result.throwIf(
  result.exitCode() != 0 || result.seeInOutput('error'),
  (result, exception) {
    // Custom error handling
    logError(result.errorOutput());
    notifyAdmin(exception);
  },
);
```

### Timeout Handling

```dart
try {
  await factory
      .command('slow-task')
      .timeout(Duration(seconds: 5))
      .run();
} catch (e) {
  if (e is ProcessTimeoutException) {
    print('Process timed out after ${e.duration.inSeconds} seconds');
  }
}
```

## Best Practices

1. Always set appropriate timeouts for long-running processes
2. Handle process failures and timeouts gracefully
3. Use real-time output handling for long-running processes
4. Clean up resources properly
5. Consider using `quietly()` for processes with noisy output
6. Set working directory and environment variables explicitly
7. Use TTY mode when interaction is needed
8. Implement proper error handling and logging
9. Consider using process pools for concurrent execution
10. Use process pipes for sequential operations

For more information on advanced features, see:
- [Process Coordination](coordination.md) for pools and pipes
- [Testing Utilities](testing.md) for process faking and testing
