# Process Coordination

The Process package provides powerful features for coordinating multiple processes through pools and pipes.

## Process Pools

Process pools allow you to run multiple processes concurrently and manage their execution.

### Basic Pool Usage

```dart
final results = await factory.pool((pool) {
  pool.command('task1');
  pool.command('task2');
  pool.command('task3');
}).start();

if (results.successful()) {
  print('All processes completed successfully');
}
```

### Pool Configuration

```dart
// Configure individual processes
final results = await factory.pool((pool) {
  pool.command('task1').env({'TYPE': 'first'});
  pool.command('task2').timeout(Duration(seconds: 30));
  pool.command('task3').quietly();
}).start();

// Handle real-time output
await factory.pool((pool) {
  pool.command('task1');
  pool.command('task2');
}).start((output) {
  print('Output: $output');
});
```

### Pool Results

```dart
final results = await factory.pool((pool) {
  pool.command('succeed');
  pool.command('fail');
}).start();

print('Total processes: ${results.total}');
print('Successful: ${results.successCount}');
print('Failed: ${results.failureCount}');

// Get specific results
for (final result in results.successes) {
  print('Success: ${result.output()}');
}

for (final result in results.failures) {
  print('Failure: ${result.errorOutput()}');
}

// Throw if any process failed
results.throwIfAnyFailed();
```

## Process Pipes

Process pipes enable sequential execution with output piping between processes.

### Basic Pipe Usage

```dart
final result = await factory.pipeThrough((pipe) {
  pipe.command('echo "Hello, World!"');
  pipe.command('tr "a-z" "A-Z"');
  pipe.command('grep "HELLO"');
}).run();

print(result.output()); // Prints: HELLO, WORLD!
```

### Pipe Configuration

```dart
// Configure individual processes
final result = await factory.pipeThrough((pipe) {
  pipe.command('cat file.txt')
      .path('/data');
  pipe.command('grep "pattern"')
      .env({'LANG': 'C'});
  pipe.command('wc -l')
      .quietly();
}).run();

// Handle real-time output
await factory.pipeThrough((pipe) {
  pipe.command('generate-data');
  pipe.command('process-data');
}).run(output: (data) {
  print('Processing: $data');
});
```

### Error Handling in Pipes

```dart
try {
  final result = await factory.pipeThrough((pipe) {
    pipe.command('may-fail');
    pipe.command('never-reached-on-failure');
  }).run();
  
  result.throwIfFailed();
} catch (e) {
  print('Pipe failed: $e');
}
```

## Best Practices

### Process Pools

1. Use pools for independent concurrent tasks
2. Configure appropriate timeouts for each process
3. Handle output appropriately (quiet noisy processes)
4. Consider resource limits when running many processes
5. Implement proper error handling for pool results

### Process Pipes

1. Use pipes for sequential data processing
2. Ensure each process handles input/output properly
3. Consider buffering for large data streams
4. Handle errors appropriately at each stage
5. Use real-time output handling for long pipelines

## Advanced Usage

### Combining Pools and Pipes

```dart
// Run multiple pipelines concurrently
await factory.pool((pool) {
  pool.pipeThrough((pipe) {
    pipe.command('pipeline1-step1');
    pipe.command('pipeline1-step2');
  });
  
  pool.pipeThrough((pipe) {
    pipe.command('pipeline2-step1');
    pipe.command('pipeline2-step2');
  });
}).start();
```

### Resource Management

```dart
// Limit concurrent processes
final pool = factory.pool((pool) {
  for (var i = 0; i < 100; i++) {
    pool.command('task$i');
  }
}, maxProcesses: 10);

// Clean up resources
try {
  await pool.start();
} finally {
  pool.kill(); // Kill any remaining processes
}
```

For more information, see:
- [Process Execution](execution.md) for basic process management
- [Testing Utilities](testing.md) for testing process coordination
