import 'package:platform_process/process.dart';

Future<void> main() async {
  // Create a process factory
  final factory = Factory();

  // Basic Process Execution
  print('\nBasic Process Execution:');
  print('----------------------');

  final result = await factory.command('echo "Hello, World!"').run();
  print('Output: ${result.output().trim()}');

  // Process with Configuration
  print('\nConfigured Process:');
  print('------------------');

  final configuredResult = await factory
      .command('ls')
      .path('/tmp')
      .env({'LANG': 'en_US.UTF-8'})
      .quietly()
      .run();
  print('Files: ${configuredResult.output().trim()}');

  // Process Pool Example
  print('\nProcess Pool:');
  print('-------------');

  final poolResults = await factory.pool((pool) {
    pool.command('sleep 1 && echo "First"');
    pool.command('sleep 2 && echo "Second"');
    pool.command('sleep 3 && echo "Third"');
  }).start();

  print('Pool results:');
  for (final result in poolResults) {
    print('- ${result.output().trim()}');
  }

  // Process Pipe Example
  print('\nProcess Pipe:');
  print('-------------');

  final pipeResult = await factory.pipeThrough((pipe) {
    pipe.command('echo "hello\nworld\nhello\ntest"');
    pipe.command('sort');
    pipe.command('uniq -c');
  }).run();

  print('Pipe result:');
  print(pipeResult.output().trim());

  // Error Handling Example
  print('\nError Handling:');
  print('---------------');

  try {
    await factory.command('nonexistent-command').run();
  } catch (e) {
    print('Error caught: $e');
  }

  // Testing Example
  print('\nTesting Example:');
  print('---------------');

  factory.fake({
    'test-command': FakeProcessDescription()
      ..withExitCode(0)
      ..replaceOutput('Fake output')
      ..withOutputSequence(['Step 1', 'Step 2', 'Step 3'])
      ..runsFor(duration: Duration(seconds: 1)),
  });

  final testResult = await factory
      .command('test-command')
      .run((output) => print('Real-time output: $output'));

  print('Test result: ${testResult.output().trim()}');
}
