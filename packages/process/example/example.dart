import 'dart:async';
import 'package:platform_process/platform_process.dart';

Future<void> runExamples() async {
  // Create a process factory
  final factory = Factory();

  // Basic command execution
  print('\n=== Basic Command Execution ===');
  try {
    final result = await factory.command(['echo', 'Hello, World!']).run();
    print('Output: ${result.output().trim()}');
    print('Exit Code: ${result.exitCode}');
    print('Success: ${result.successful()}');
  } catch (e) {
    print('Error: $e');
  }

  // Working directory
  print('\n=== Working Directory ===');
  try {
    final result =
        await factory.command(['pwd']).withWorkingDirectory('/tmp').run();
    print('Current Directory: ${result.output().trim()}');
  } catch (e) {
    print('Error: $e');
  }

  // Environment variables
  print('\n=== Environment Variables ===');
  try {
    final result = await factory
        .command(['sh', '-c', 'echo \$CUSTOM_VAR']).withEnvironment(
            {'CUSTOM_VAR': 'Hello from env!'}).run();
    print('Environment Value: ${result.output().trim()}');
  } catch (e) {
    print('Error: $e');
  }

  // Process timeout
  print('\n=== Process Timeout ===');
  try {
    await factory.command(['sleep', '5']).withTimeout(1).run();
    print('Process completed (unexpected)');
  } catch (e) {
    // Let the zone handler catch this
  }

  // Standard input
  print('\n=== Standard Input ===');
  try {
    final result =
        await factory.command(['cat']).withInput('Hello from stdin!').run();
    print('Input Echo: ${result.output()}');
  } catch (e) {
    print('Error: $e');
  }

  // Error handling
  print('\n=== Error Handling ===');
  try {
    await factory.command(['ls', 'nonexistent-file']).run();
    print('Command succeeded (unexpected)');
  } on ProcessFailedException catch (e) {
    print('Expected error:');
    print('  Exit code: ${e.exitCode}');
    print('  Error output: ${e.errorOutput.trim()}');
  } catch (e) {
    print('Unexpected error: $e');
  }

  // Shell commands with pipes
  print('\n=== Shell Commands with Pipes ===');
  try {
    final result = await factory.command(
        ['sh', '-c', 'echo "line1\nline2\nline3" | grep "line2"']).run();
    print('Grep Result: ${result.output().trim()}');
  } catch (e) {
    print('Error: $e');
  }

  // Async process with output callback
  print('\n=== Async Process with Output Callback ===');
  try {
    final process = await factory.command([
      'sh',
      '-c',
      'for n in 1 2 3; do echo \$n; sleep 1; done'
    ]).start((output) {
      print('Realtime Output: ${output.trim()}');
    });

    final result = await process.wait();
    print('Final Exit Code: ${result.exitCode}');
  } catch (e) {
    print('Error: $e');
  }

  // Process killing
  print('\n=== Process Killing ===');
  try {
    final process = await factory.command(['sleep', '10']).start();

    print('Process started with PID: ${process.pid}');
    print('Is running: ${process.running()}');

    // Kill after 1 second
    await Future.delayed(Duration(seconds: 1));
    final killed = process.kill();
    print('Kill signal sent: $killed');

    final result = await process.wait();
    print('Process completed with exit code: ${result.exitCode}');
  } catch (e) {
    print('Error: $e');
  }

  // Quiet mode (no output)
  print('\n=== Quiet Mode ===');
  try {
    final result = await factory
        .command(['echo', 'This output is suppressed'])
        .withoutOutput()
        .run();
    print('Output length: ${result.output().length}');
  } catch (e) {
    print('Error: $e');
  }

  // Color output (alternative to TTY mode)
  print('\n=== Color Output ===');
  try {
    final result = await factory.command(['ls', '--color=always']).run();
    print('Color Output: ${result.output().trim()}');
  } catch (e) {
    print('Error: $e');
  }
}

void main() {
  runZonedGuarded(() async {
    await runExamples();
  }, (error, stack) {
    if (error is ProcessTimedOutException) {
      print('Expected timeout error: ${error.message}');
    } else {
      print('Unexpected error: $error');
      print('Stack trace: $stack');
    }
  });
}
