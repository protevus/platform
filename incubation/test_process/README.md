# Test Process

A Laravel-compatible process management implementation in pure Dart. This package provides a robust way to execute and manage system processes with features like timeouts, input/output handling, and asynchronous execution.

## Features

- 💫 Fluent API for process configuration
- ⏱️ Process timeout support
- 🔄 Asynchronous process execution
- 📥 Input/output handling
- 🌍 Environment variables support
- 📁 Working directory configuration
- 🚦 TTY mode support
- 🤫 Quiet mode for suppressing output
- ⚡ Process pooling capabilities

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  test_process: ^1.0.0
```

## Usage

### Basic Command Execution

```dart
import 'package:test_process/test_process.dart';

void main() async {
  final factory = Factory();
  
  // Simple command execution
  final result = await factory.run('echo "Hello World"');
  print(result.output());
}
```

### Configuring Process Execution

```dart
final result = await factory
    .command('ls -la')
    .withWorkingDirectory('/tmp')
    .withEnvironment({'CUSTOM_VAR': 'value'})
    .withTimeout(30)
    .run();

print('Exit code: ${result.exitCode}');
print('Output: ${result.output()}');
print('Error output: ${result.errorOutput()}');
```

### Asynchronous Process Execution

```dart
final process = await factory
    .command('long-running-command')
    .withTimeout(60)
    .start();

print('Process started with PID: ${process.pid}');

// Wait for completion
final result = await process.wait();
print('Process completed with exit code: ${result.exitCode}');
```

### Process Input/Output

```dart
// Provide input to process
final result = await factory
    .command('cat')
    .withInput('Hello from stdin!')
    .run();

// Disable output
await factory
    .command('noisy-command')
    .withoutOutput()
    .run();
```

### Error Handling

```dart
try {
  await factory.run('nonexistent-command');
} on ProcessFailedException catch (e) {
  print('Process failed with exit code: ${e.exitCode}');
  print('Error output: ${e.errorOutput}');
} on ProcessTimedOutException catch (e) {
  print('Process timed out: ${e.message}');
}
```

## API Reference

### Factory

The main entry point for creating and running processes.

- `run(command)` - Run a command synchronously
- `command(command)` - Begin configuring a command
- `path(directory)` - Begin configuring a command with a working directory

### PendingProcess

Configures how a process should be run.

- `withCommand(command)` - Set the command to run
- `withWorkingDirectory(directory)` - Set the working directory
- `withTimeout(seconds)` - Set the process timeout
- `withIdleTimeout(seconds)` - Set the idle timeout
- `withEnvironment(env)` - Set environment variables
- `withInput(input)` - Provide input to the process
- `withoutOutput()` - Disable process output
- `withTty()` - Enable TTY mode
- `forever()` - Disable timeout
- `run()` - Run the process
- `start()` - Start the process asynchronously

### ProcessResult

Represents the result of a completed process.

- `exitCode` - The process exit code
- `output()` - The process standard output
- `errorOutput()` - The process error output
- `successful()` - Whether the process was successful
- `failed()` - Whether the process failed

### InvokedProcess

Represents a running process.

- `pid` - The process ID
- `write(input)` - Write to the process stdin
- `kill([signal])` - Send a signal to the process
- `wait()` - Wait for the process to complete

## Error Handling

The package provides two main exception types:

- `ProcessFailedException` - Thrown when a process exits with a non-zero code
- `ProcessTimedOutException` - Thrown when a process exceeds its timeout

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is open-sourced software licensed under the MIT license.
