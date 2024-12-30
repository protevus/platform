import 'package:platform_process/process.dart';

Future<void> main() async {
  // Create a process factory
  final factory = Factory();

  print('Basic Process Execution:');
  print('----------------------');

  // Simple process execution
  final result = await factory.command('echo "Hello, World!"').run();
  print('Output: ${result.output().trim()}\n');

  // Process with configuration
  final configuredResult = await factory
      .command('ls')
      .path('/tmp')
      .env({'LANG': 'en_US.UTF-8'})
      .quietly()
      .run();
  print('Files in /tmp: ${configuredResult.output().trim()}\n');

  print('Process Pool Example:');
  print('-------------------');

  // Process pool for concurrent execution
  final poolResults = await factory.pool((pool) {
    pool.command('sleep 1 && echo "First"');
    pool.command('sleep 2 && echo "Second"');
    pool.command('sleep 3 && echo "Third"');
  }).start();

  print('Pool results:');
  for (final result in poolResults) {
    print('- ${result.output().trim()}');
  }
  print('');

  print('Process Pipe Example:');
  print('-------------------');

  // Process pipe for sequential execution
  final pipeResult = await factory.pipeThrough((pipe) {
    pipe.command('echo "hello\nworld\nhello\ntest"'); // Create some sample text
    pipe.command('sort'); // Sort the lines
    pipe.command('uniq -c'); // Count unique lines
    pipe.command('sort -nr'); // Sort by count
  }).run();

  print('Pipe result:');
  print(pipeResult.output());
  print('');

  print('Process Testing Example:');
  print('----------------------');

  // Set up fake processes for testing
  factory.fake({
    'ls': 'file1.txt\nfile2.txt',
    'cat file1.txt': 'Hello from file1!',
    'grep pattern': (process) => 'Matched line',
  });

  // Run fake processes
  final fakeResult = await factory.command('ls').run();
  print('Fake ls output: ${fakeResult.output().trim()}');

  final catResult = await factory.command('cat file1.txt').run();
  print('Fake cat output: ${catResult.output().trim()}');

  // Process sequence example
  final sequence = FakeProcessSequence.alternating(3);
  print('\nProcess sequence results:');
  while (sequence.hasMore) {
    final result = sequence.call() as FakeProcessResult;
    print('- Success: ${result.successful()}, Output: ${result.output()}');
  }

  print('\nProcess Error Handling:');
  print('----------------------');

  try {
    await factory.command('nonexistent-command').run();
  } catch (e) {
    print('Error caught: $e');
  }

  // Clean up
  print('\nDone!');
}

/// Example of testing process execution
void testProcessExecution() {
  final factory = Factory();

  // Configure fake processes
  factory.fake({
    'test-command': FakeProcessDescription()
      ..withExitCode(0)
      ..replaceOutput('Test output')
      ..withOutputSequence(['Line 1', 'Line 2', 'Line 3'])
      ..runsFor(duration: Duration(seconds: 1)),
  });

  // Prevent real process execution during tests
  factory.preventStrayProcesses();

  // Now you can test your process-dependent code
  // without actually executing any real processes
}
