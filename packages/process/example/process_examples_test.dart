import 'package:test/test.dart';
import 'package:platform_process/process.dart';
import 'process_examples.dart';

void main() {
  late Factory factory;

  setUp(() {
    factory = Factory();
    factory.fake(); // Enable process faking
    factory.preventStrayProcesses(); // Prevent real processes from running
  });

  group('Process Examples Tests', () {
    test('buildProject handles successful build', () async {
      // Fake successful build process
      factory.fake({
        'npm run build': '''
Creating production build...
Assets optimized
Build completed successfully
''',
      });

      await buildProject(factory);
      expect(factory.isRecording(), isTrue);
    });

    test('backupDatabase creates backup with correct filename pattern',
        () async {
      factory.fake({
        'pg_dump -U postgres mydatabase > backup-*':
            '', // Match any backup filename
      });

      await backupDatabase(factory);
      expect(factory.isRecording(), isTrue);
    });

    test('processLogs correctly pipes commands', () async {
      factory.fake({
        'cat /var/log/app.log': '''
2024-01-01 INFO: System started
2024-01-01 ERROR: Database connection failed
2024-01-01 ERROR: Retry attempt failed
2024-01-01 INFO: Backup completed
''',
        'grep ERROR': '''
2024-01-01 ERROR: Database connection failed
2024-01-01 ERROR: Retry attempt failed
''',
        'wc -l': '2\n',
      });

      await processLogs(factory);
      expect(factory.isRecording(), isTrue);
    });

    test('processConcurrently handles multiple files', () async {
      // Fake successful processing for all files
      factory.fake({
        'process_file.sh file1.txt': 'Processing file1.txt completed',
        'process_file.sh file2.txt': 'Processing file2.txt completed',
        'process_file.sh file3.txt': 'Processing file3.txt completed',
      });

      await processConcurrently(factory);
      expect(factory.isRecording(), isTrue);
    });

    test('runInteractiveProcess handles Python interaction', () async {
      factory.fake({
        'python': '''
Hello from Python!
What's your name? Nice to meet you, Test User!
''',
      });

      await runInteractiveProcess(factory);
      expect(factory.isRecording(), isTrue);
    });
  });
}
