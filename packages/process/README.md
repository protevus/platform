# Dart Process Handler

A Laravel-inspired process handling library for Dart that provides an elegant and powerful API for executing shell commands and managing processes.

## Features

- Fluent API for process configuration
- Synchronous and asynchronous execution
- Process timeouts and idle timeouts
- Working directory and environment variables
- Input/output handling and streaming
- Shell command support with pipes and redirects
- TTY mode support
- Comprehensive error handling
- Real-time output callbacks
- Process status tracking and management

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  platform_process: ^1.0.0
```

## Basic Usage

### Simple Command Execution

```dart
import 'package:platform_process/platform_process.dart';

void main() async {
  final factory = Factory();
  
  // Basic command execution
  final result = await factory.command(['echo', 'Hello World']).run();
  print('Output: ${result.output()}');  // Output: Hello World
  print('Success: ${result.successful()}');  // Success: true
  
  // Using string command (executed through shell)
  final result2 = await factory.command('echo "Hello World"').run();
  print('Output: ${result2.output()}');  // Output: Hello World
}
```

### Working Directory

```dart
void main() async {
  final factory = Factory();
  
  // Execute command in specific directory
  final result = await factory
      .command(['ls', '-l'])
      .withWorkingDirectory('/tmp')
      .run();
      
  print('Files in /tmp:');
  print(result.output());
}
```

### Environment Variables

```dart
void main() async {
  final factory = Factory();
  
  final result = await factory
      .command(['printenv', 'MY_VAR'])
      .withEnvironment({'MY_VAR': 'Hello from env!'})
      .run();
      
  print('Environment Value: ${result.output()}');
}
```

### Process Timeouts

```dart
void main() async {
  final factory = Factory();
  
  try {
    // Process timeout
    await factory
        .command(['sleep', '10'])
        .withTimeout(5)  // 5 second timeout
        .run();
  } on ProcessTimedOutException catch (e) {
    print('Process timed out: ${e.message}');
  }
  
  try {
    // Idle timeout (no output for specified duration)
    await factory
        .command(['tail', '-f', '/dev/null'])
        .withIdleTimeout(5)  // 5 second idle timeout
        .run();
  } on ProcessTimedOutException catch (e) {
    print('Process idle timeout: ${e.message}');
  }
}
```

### Standard Input

```dart
void main() async {
  final factory = Factory();
  
  // String input
  final result1 = await factory
      .command(['cat'])
      .withInput('Hello from stdin!')
      .run();
  print('Input Echo: ${result1.output()}');
  
  // Byte input
  final result2 = await factory
      .command(['cat'])
      .withInput([72, 101, 108, 108, 111])  // "Hello" in bytes
      .run();
  print('Byte Input Echo: ${result2.output()}');
}
```

### Error Handling

```dart
void main() async {
  final factory = Factory();
  
  try {
    await factory.command(['ls', 'nonexistent-file']).run();
  } on ProcessFailedException catch (e) {
    print('Command failed:');
    print('  Exit code: ${e.result.exitCode}');
    print('  Error output: ${e.result.errorOutput()}');
  }
}
```

### Shell Commands with Pipes

```dart
void main() async {
  final factory = Factory();
  
  // Using pipes in shell command
  final result = await factory
      .command('echo "line1\nline2\nline3" | grep "line2"')
      .run();
  print('Grep Result: ${result.output()}');
  
  // Multiple commands
  final result2 = await factory
      .command('cd /tmp && ls -l | grep "log"')
      .run();
  print('Log files: ${result2.output()}');
}
```

### Asynchronous Execution with Output Callback

```dart
void main() async {
  final factory = Factory();
  
  // Start process asynchronously
  final process = await factory
      .command(['sh', '-c', 'for i in 1 2 3; do echo $i; sleep 1; done'])
      .start((output) {
        print('Realtime Output: $output');
      });
      
  // Wait for completion
  final result = await process.wait();
  print('Final Exit Code: ${result.exitCode}');
}
```

### Process Management

```dart
void main() async {
  final factory = Factory();
  
  // Start long-running process
  final process = await factory
      .command(['sleep', '10'])
      .start();
      
  print('Process started with PID: ${process.pid}');
  print('Is running: ${process.running()}');
  
  // Kill the process
  final killed = process.kill();  // Sends SIGTERM
  print('Kill signal sent: $killed');
  
  // Or with specific signal
  process.kill(ProcessSignal.sigint);  // Sends SIGINT
  
  final result = await process.wait();
  print('Process completed with exit code: ${result.exitCode}');
}
```

### Output Control

```dart
void main() async {
  final factory = Factory();
  
  // Disable output
  final result = await factory
      .command(['echo', 'test'])
      .withoutOutput()
      .run();
  print('Output length: ${result.output().length}');  // Output length: 0
}
```

### TTY Mode

```dart
void main() async {
  final factory = Factory();
  
  // Enable TTY mode for commands that require it
  final result = await factory
      .command(['ls', '--color=auto'])
      .withTty()
      .run();
  print('Color Output: ${result.output()}');
}
```

## Advanced Usage

### Custom Process Configuration

```dart
void main() async {
  final factory = Factory();
  
  final result = await factory
      .command(['my-script'])
      .withWorkingDirectory('/path/to/scripts')
      .withEnvironment({
        'NODE_ENV': 'production',
        'DEBUG': 'true'
      })
      .withTimeout(30)
      .withIdleTimeout(5)
      .withTty()
      .run();
      
  if (result.successful()) {
    print('Script completed successfully');
    print(result.output());
  }
}
```

### Process Pool Management

```dart
void main() async {
  final factory = Factory();
  final processes = <InvokedProcess>[];
  
  // Start multiple processes
  for (var i = 0; i < 3; i++) {
    final process = await factory
        .command(['worker.sh', i.toString()])
        .start();
    processes.add(process);
  }
  
  // Wait for all processes to complete
  for (var process in processes) {
    final result = await process.wait();
    print('Worker completed with exit code: ${result.exitCode}');
  }
}
```

### Error Output Handling

```dart
void main() async {
  final factory = Factory();
  
  try {
    final result = await factory
        .command(['some-command'])
        .run();
        
    print('Standard output:');
    print(result.output());
    
    print('Error output:');
    print(result.errorOutput());
    
  } on ProcessFailedException catch (e) {
    print('Command failed with exit code: ${e.result.exitCode}');
    print('Error details:');
    print(e.result.errorOutput());
  }
}
```

### Infinite Process Execution

```dart
void main() async {
  final factory = Factory();
  
  // Disable timeout for long-running processes
  final process = await factory
      .command(['tail', '-f', 'logfile.log'])
      .forever()  // Disables timeout
      .start((output) {
        print('New log entry: $output');
      });
      
  // Process will run until explicitly killed
  await Future.delayed(Duration(minutes: 1));
  process.kill();
}
```

## Error Handling

The library provides several exception types for different error scenarios:

### ProcessFailedException

Thrown when a process exits with a non-zero exit code:

```dart
try {
  await factory.command(['nonexistent-command']).run();
} on ProcessFailedException catch (e) {
  print('Command failed:');
  print('Exit code: ${e.result.exitCode}');
  print('Error output: ${e.result.errorOutput()}');
  print('Standard output: ${e.result.output()}');
}
```

### ProcessTimedOutException

Thrown when a process exceeds its timeout or idle timeout:

```dart
try {
  await factory
      .command(['sleep', '10'])
      .withTimeout(5)
      .run();
} on ProcessTimedOutException catch (e) {
  print('Process timed out:');
  print('Message: ${e.message}');
  if (e.result != null) {
    print('Partial output: ${e.result?.output()}');
  }
}
```

## Best Practices

1. **Always handle process failures:**
```dart
try {
  await factory.command(['risky-command']).run();
} on ProcessFailedException catch (e) {
  // Handle failure
} on ProcessTimedOutException catch (e) {
  // Handle timeout
}
```

2. **Set appropriate timeouts:**
```dart
factory
    .command(['long-running-task'])
    .withTimeout(300)        // Overall timeout
    .withIdleTimeout(60)     // Idle timeout
    .run();
```

3. **Use output callbacks for long-running processes:**
```dart
await factory
    .command(['lengthy-task'])
    .start((output) {
      // Process output in real-time
      print('Progress: $output');
    });
```

4. **Clean up resources:**
```dart
final process = await factory.command(['server']).start();
try {
  // Do work
} finally {
  process.kill();  // Ensure process is terminated
}
```

5. **Use shell mode appropriately:**
```dart
// For simple commands, use array form:
factory.command(['echo', 'hello']);

// For shell features (pipes, redirects), use string form:
factory.command('echo hello | grep "o"');
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
