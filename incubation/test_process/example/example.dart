import 'package:test_process/test_process.dart';

Future<void> main() async {
  // Create a process factory
  final factory = Factory();

  print('\n1. Basic command execution:');
  try {
    final result = await factory.command(['echo', 'Hello', 'World']).run();
    print('Output: ${result.output()}');
  } catch (e) {
    print('Error: $e');
  }

  print('\n2. Command with working directory and environment:');
  try {
    final result = await factory
        .command(['ls', '-la'])
        .withWorkingDirectory('/tmp')
        .withEnvironment({'CUSTOM_VAR': 'value'})
        .run();
    print('Directory contents: ${result.output()}');
  } catch (e) {
    print('Error: $e');
  }

  print('\n3. Asynchronous process with timeout:');
  try {
    final process =
        await factory.command(['sleep', '1']).withTimeout(5).start();

    print('Process started with PID: ${process.pid}');
    final result = await process.wait();
    print('Async process completed with exit code: ${result.exitCode}');
  } catch (e) {
    print('Error: $e');
  }

  print('\n4. Process with input:');
  try {
    final result =
        await factory.command(['cat']).withInput('Hello from stdin!').run();
    print('Output from cat: ${result.output()}');
  } catch (e) {
    print('Error: $e');
  }

  print('\n5. Error handling:');
  try {
    await factory.command(['nonexistent-command']).run();
  } on ProcessFailedException catch (e) {
    print('Expected error caught: ${e.toString()}');
  }

  print('\n6. Quiet process (no output):');
  try {
    await factory
        .command(['echo', 'This should not be visible'])
        .withoutOutput()
        .run();
    print('Process completed silently');
  } catch (e) {
    print('Error: $e');
  }

  print('\n7. Shell command with pipes:');
  try {
    final result = await factory
        .command(['/bin/sh', '-c', 'echo Hello | tr a-z A-Z']).run();
    print('Output: ${result.output()}');
  } catch (e) {
    print('Error: $e');
  }

  print('\n8. Multiple commands with shell:');
  try {
    final result = await factory
        .command(['/bin/sh', '-c', 'echo Start && sleep 1 && echo End']).run();
    print('Output: ${result.output()}');
  } catch (e) {
    print('Error: $e');
  }

  print('\n9. Complex shell command:');
  try {
    final result = await factory.command([
      '/bin/sh',
      '-c',
      r'for i in 1 2 3; do echo "Count: $i"; sleep 0.1; done'
    ]).run();
    print('Output: ${result.output()}');
  } catch (e) {
    print('Error: $e');
  }
}
