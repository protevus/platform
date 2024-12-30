# Testing Utilities

The Process package provides comprehensive testing utilities for process-dependent code.

## Process Faking

### Basic Faking

```dart
final factory = Factory();

// Fake specific commands
factory.fake({
  'ls': 'file1.txt\nfile2.txt',
  'cat file1.txt': 'Hello, World!',
  'grep pattern': (process) => 'Matched line',
});

// Run fake processes
final result = await factory.command('ls').run();
expect(result.output().trim(), equals('file1.txt\nfile2.txt'));
```

### Preventing Real Processes

```dart
// Prevent any real process execution
factory.fake().preventStrayProcesses();

// This will throw an exception
await factory.command('real-command').run();
```

### Dynamic Results

```dart
factory.fake({
  'random': (process) => 
      DateTime.now().millisecondsSinceEpoch.toString(),
  'conditional': (process) => 
      process.env['SUCCESS'] == 'true' ? 'success' : 'failure',
});
```

## Process Descriptions

### Basic Description

```dart
final description = FakeProcessDescription()
  ..withExitCode(0)
  ..replaceOutput('Test output')
  ..replaceErrorOutput('Test error');

factory.fake({
  'test-command': description,
});
```

### Simulating Long-Running Processes

```dart
final description = FakeProcessDescription()
  ..withOutputSequence(['Step 1', 'Step 2', 'Step 3'])
  ..withDelay(Duration(milliseconds: 100))
  ..runsFor(duration: Duration(seconds: 1));

factory.fake({
  'long-task': description,
});
```

### Simulating Process Failures

```dart
final description = FakeProcessDescription()
  ..withExitCode(1)
  ..replaceOutput('Operation failed')
  ..replaceErrorOutput('Error: Invalid input');

factory.fake({
  'failing-task': description,
});
```

## Process Sequences

### Basic Sequences

```dart
final sequence = FakeProcessSequence()
  ..then(FakeProcessResult(output: 'First'))
  ..then(FakeProcessResult(output: 'Second'))
  ..then(FakeProcessResult(output: 'Third'));

factory.fake({
  'sequential-task': sequence,
});
```

### Alternating Success/Failure

```dart
final sequence = FakeProcessSequence.alternating(3);
while (sequence.hasMore) {
  final result = sequence.call() as FakeProcessResult;
  print('Success: ${result.successful()}');
}
```

### Custom Sequences

```dart
final sequence = FakeProcessSequence.fromOutputs([
  'Starting...',
  'Processing...',
  'Complete!',
]);

factory.fake({
  'progress-task': sequence,
});
```

## Testing Process Pools

```dart
test('executes processes concurrently', () async {
  factory.fake({
    'task1': FakeProcessDescription()
      ..withDelay(Duration(seconds: 1))
      ..replaceOutput('Result 1'),
    'task2': FakeProcessDescription()
      ..withDelay(Duration(seconds: 1))
      ..replaceOutput('Result 2'),
  });

  final results = await factory.pool((pool) {
    pool.command('task1');
    pool.command('task2');
  }).start();

  expect(results.successful(), isTrue);
  expect(results.total, equals(2));
});
```

## Testing Process Pipes

```dart
test('pipes output between processes', () async {
  factory.fake({
    'generate': 'initial data',
    'transform': (process) => process.input.toUpperCase(),
    'filter': (process) => process.input.contains('DATA') ? process.input : '',
  });

  final result = await factory.pipeThrough((pipe) {
    pipe.command('generate');
    pipe.command('transform');
    pipe.command('filter');
  }).run();

  expect(result.output(), equals('INITIAL DATA'));
});
```

## Best Practices

1. Use `preventStrayProcesses()` in tests to catch unintended process execution
2. Simulate realistic scenarios with delays and sequences
3. Test both success and failure cases
4. Test process configuration (environment, working directory, etc.)
5. Test process coordination (pools and pipes)
6. Use process descriptions for complex behaviors
7. Test timeout and error handling
8. Mock system-specific behaviors
9. Clean up resources in tests
10. Test real-time output handling

## Example Test Suite

```dart
void main() {
  group('Process Manager', () {
    late Factory factory;

    setUp(() {
      factory = Factory();
      factory.fake().preventStrayProcesses();
    });

    test('handles successful process', () async {
      factory.fake({
        'successful-task': FakeProcessDescription()
          ..withExitCode(0)
          ..replaceOutput('Success!'),
      });

      final result = await factory
          .command('successful-task')
          .run();

      expect(result.successful(), isTrue);
      expect(result.output(), equals('Success!'));
    });

    test('handles process failure', () async {
      factory.fake({
        'failing-task': FakeProcessDescription()
          ..withExitCode(1)
          ..replaceErrorOutput('Failed!'),
      });

      final result = await factory
          .command('failing-task')
          .run();

      expect(result.failed(), isTrue);
      expect(result.errorOutput(), equals('Failed!'));
    });
  });
}
```

For more information, see:
- [Process Execution](execution.md) for basic process management
- [Process Coordination](coordination.md) for pools and pipes
