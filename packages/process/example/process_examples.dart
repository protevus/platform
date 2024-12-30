import 'package:platform_process/process.dart';

/// This file contains practical examples of using the Process package
/// for various common scenarios in real-world applications.

Future<void> main() async {
  final factory = Factory();

  // Example 1: Building a Project
  print('\n=== Building a Project ===');
  await buildProject(factory);

  // Example 2: Database Backup
  print('\n=== Database Backup ===');
  await backupDatabase(factory);

  // Example 3: Log Processing Pipeline
  print('\n=== Log Processing ===');
  await processLogs(factory);

  // Example 4: Concurrent File Processing
  print('\n=== Concurrent Processing ===');
  await processConcurrently(factory);

  // Example 5: Interactive Process
  print('\n=== Interactive Process ===');
  await runInteractiveProcess(factory);
}

/// Example 1: Building a project with environment configuration
Future<void> buildProject(Factory factory) async {
  try {
    final result = await factory
        .command('npm run build')
        .env({
          'NODE_ENV': 'production',
          'BUILD_NUMBER': '123',
        })
        .timeout(300) // 5 minutes timeout
        .run((output) {
          // Real-time build output handling
          print('Build output: $output');
        });

    if (result.successful()) {
      print('Build completed successfully');
    }
  } catch (e) {
    print('Build failed: $e');
  }
}

/// Example 2: Creating a database backup with error handling
Future<void> backupDatabase(Factory factory) async {
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final backupFile = 'backup-$timestamp.sql';

  try {
    final result = await factory
        .command('pg_dump -U postgres mydatabase > $backupFile')
        .env({'PGPASSWORD': 'secret'})
        .quietly() // Suppress normal output
        .timeout(120) // 2 minutes timeout
        .run();

    result.throwIfFailed((result, exception) {
      print('Backup failed with error: ${result.errorOutput()}');
    });

    print('Database backup created: $backupFile');
  } catch (e) {
    print('Backup process failed: $e');
  }
}

/// Example 3: Processing logs using pipes
Future<void> processLogs(Factory factory) async {
  try {
    final result = await factory.pipeThrough((pipe) {
      // Read logs
      pipe.command('cat /var/log/app.log');
      // Filter errors
      pipe.command('grep ERROR');
      // Count occurrences
      pipe.command('wc -l');
    }).run();

    print('Number of errors in log: ${result.output().trim()}');
  } catch (e) {
    print('Log processing failed: $e');
  }
}

/// Example 4: Processing multiple files concurrently
Future<void> processConcurrently(Factory factory) async {
  final files = ['file1.txt', 'file2.txt', 'file3.txt'];

  final results = ProcessPoolResults(await factory.pool((pool) {
    for (final file in files) {
      // Process each file concurrently
      pool.command('process_file.sh $file');
    }
  }).start());

  if (results.successful()) {
    print('All files processed successfully');
  } else {
    print('Some files failed to process');
    for (final result in results.results.where((r) => r.failed())) {
      print('Failed command: ${result.command()}');
      print('Error: ${result.errorOutput()}');
    }
  }
}

/// Example 5: Running an interactive process
Future<void> runInteractiveProcess(Factory factory) async {
  try {
    final result = await factory
        .command('python')
        .tty() // Enable TTY mode for interactive processes
        .input('''
print("Hello from Python!")
name = input("What's your name? ")
print(f"Nice to meet you, {name}!")
exit()
''').run();

    print('Interactive process output:');
    print(result.output());
  } catch (e) {
    print('Interactive process failed: $e');
  }
}
