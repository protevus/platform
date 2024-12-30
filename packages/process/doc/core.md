# Core Components

The Process package provides several core components for process management:

## Factory

The `Factory` class is the main entry point for creating and managing processes. It provides methods for:

- Creating new processes with `command()`
- Creating process pools with `pool()`
- Creating process pipes with `pipeThrough()`
- Setting up process faking for testing

Example:
```dart
final factory = Factory();

// Simple command execution
final result = await factory
    .command('echo "Hello, World!"')
    .run();

// With configuration
final result = await factory
    .command('npm install')
    .path('/path/to/project')
    .env({'NODE_ENV': 'production'})
    .run();
```

## PendingProcess

The `PendingProcess` class represents a process that has been configured but not yet started. It provides a fluent interface for:

- Setting working directory with `path()`
- Setting environment variables with `env()`
- Setting timeouts with `timeout()` and `idleTimeout()`
- Providing input with `input()`
- Controlling output with `quietly()`
- Enabling TTY mode with `tty()`

Example:
```dart
final process = factory
    .command('long-running-task')
    .path('/working/directory')
    .env({'DEBUG': 'true'})
    .timeout(60)
    .idleTimeout(10)
    .tty();
```

## ProcessResult

The `ProcessResult` class represents the result of a process execution, providing:

- Exit code access with `exitCode()`
- Output access with `output()` and `errorOutput()`
- Success/failure checking with `successful()` and `failed()`
- Error handling with `throwIfFailed()`
- Output searching with `seeInOutput()` and `seeInErrorOutput()`

Example:
```dart
final result = await process.run();

if (result.successful()) {
  print('Output: ${result.output()}');
} else {
  print('Error: ${result.errorOutput()}');
  result.throwIfFailed();
}
```

## Error Handling

The package includes robust error handling through:

- `ProcessFailedException` for process execution failures
- Timeout handling for both overall execution and idle time
- Detailed error messages with command, exit code, and output
- Optional error callbacks for custom error handling

Example:
```dart
try {
  await factory
      .command('risky-command')
      .run();
} catch (e) {
  if (e is ProcessFailedException) {
    print('Process failed with exit code: ${e.exitCode}');
    print('Error output: ${e.errorOutput}');
  }
}
```

## Best Practices

1. Always handle process failures appropriately
2. Use timeouts for long-running processes
3. Consider using `quietly()` for noisy processes
4. Clean up resources with proper error handling
5. Use environment variables for configuration
6. Set appropriate working directories
7. Consider TTY mode for interactive processes

For more details on specific components, see:
- [Process Execution](execution.md)
- [Process Coordination](coordination.md)
- [Testing Utilities](testing.md)
