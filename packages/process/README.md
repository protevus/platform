# Process

A fluent process execution package for Dart, inspired by Laravel's Process package. This package provides a powerful and intuitive API for running and managing system processes.

## Features

- 🔄 Fluent interface for process configuration and execution
- 🚀 Process pools for concurrent execution
- 📝 Process piping for sequential execution
- 📊 Process output capturing and streaming
- 🌍 Process environment and working directory configuration
- 📺 TTY mode support
- 🧪 Testing utilities with process faking and recording
- ⏱️ Timeout and idle timeout support

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  platform_process: ^1.0.0
```

## Usage

### Basic Process Execution

```dart
import 'package:platform_process/process.dart';

final factory = Factory();

// Simple command execution
final result = await factory
    .command('echo "Hello, World!"')
    .run();
print(result.output());

// With working directory and environment
final result = await factory
    .command('npm install')
    .path('/path/to/project')
    .env({'NODE_ENV': 'production'})
    .run();

// With timeout
final result = await factory
    .command('long-running-task')
    .timeout(60) // 60 seconds
    .run();

// Disable output
final result = await factory
    .command('background-task')
    .quietly()
    .run();
```

### Process Pools

Run multiple processes concurrently:

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

### Process Piping

Run processes in sequence, piping output between them:

```dart
final result = await factory.pipeThrough((pipe) {
  pipe.command('cat file.txt');
  pipe.command('grep pattern');
  pipe.command('wc -l');
}).run();

print('Lines matching pattern: ${result.output()}');
```

### Process Input

Provide input to processes:

```dart
final result = await factory
    .command('cat')
    .input('Hello, World!')
    .run();
```

### Error Handling

Handle process failures:

```dart
try {
  final result = await factory
      .command('risky-command')
      .run();
      
  result.throwIfFailed((result, exception) {
    print('Process failed with output: ${result.errorOutput()}');
  });
} catch (e) {
  print('Process failed: $e');
}
```

### Testing

The package includes comprehensive testing utilities:

```dart
// Fake specific commands
factory.fake({
  'ls': 'file1.txt\nfile2.txt',
  'cat file1.txt': 'Hello, World!',
});

// Prevent real processes from running
factory.preventStrayProcesses();

// Record process executions
factory.fake();
final result = await factory.command('ls').run();
// Process execution is now recorded

// Use process sequences
final sequence = FakeProcessSequence.alternating(3);
while (sequence.hasMore) {
  final result = sequence.call() as FakeProcessResult;
  print('Success: ${result.successful()}, Output: ${result.output()}');
}
```

### Advanced Configuration

Configure process behavior:

```dart
final result = await factory
    .command('complex-task')
    .path('/working/directory')
    .env({'VAR1': 'value1', 'VAR2': 'value2'})
    .timeout(120)
    .idleTimeout(30)
    .tty()
    .run((output) {
      print('Real-time output: $output');
    });
```

## API Reference

### Factory

The main entry point for creating and managing processes:

- `command()` - Create a new process with a command
- `pool()` - Create a process pool for concurrent execution
- `pipeThrough()` - Create a process pipe for sequential execution
- `fake()` - Enable process faking for testing
- `preventStrayProcesses()` - Prevent real processes during testing

### PendingProcess

Configure process execution:

- `path()` - Set working directory
- `env()` - Set environment variables
- `timeout()` - Set execution timeout
- `idleTimeout()` - Set idle timeout
- `input()` - Provide process input
- `quietly()` - Disable output
- `tty()` - Enable TTY mode
- `run()` - Execute the process
- `start()` - Start the process in background

### ProcessResult

Access process results:

- `command()` - Get executed command
- `successful()` - Check if process succeeded
- `failed()` - Check if process failed
- `exitCode()` - Get exit code
- `output()` - Get standard output
- `errorOutput()` - Get error output
- `throwIfFailed()` - Throw exception on failure

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This package is open-sourced software licensed under the [MIT license](LICENSE).
