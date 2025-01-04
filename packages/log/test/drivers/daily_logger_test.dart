import 'dart:io';

import 'package:platform_log/platform_log.dart';
import 'package:test/test.dart';

import '../utils/mocks.dart';

void main() {
  group('DailyLogger', () {
    late Directory tempDir;
    late MockApplication app;
    late String logPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('daily_logger_test_');
      logPath = '${tempDir.path}/test.log';
      app = MockApplication();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('creates log file with current date', () {
      final config = {
        'path': logPath,
        'level': 'debug',
      };

      final logger = DailyLogger(app, config);
      logger.info('test message');

      final date = DateTime.now().toIso8601String().split('T')[0];
      final expectedPath = logPath.replaceAll('.log', '-$date.log');
      expect(File(expectedPath).existsSync(), isTrue);
    });

    test('rotates log file on date change', () {
      final config = {
        'path': logPath,
        'level': 'debug',
      };

      final logger = DailyLogger(app, config);

      // Write to today's log
      final today = DateTime.now();
      logger.info('today message');
      final todayPath = logPath.replaceAll(
          '.log', '-${today.toIso8601String().split('T')[0]}.log');

      // Write to tomorrow's log
      final tomorrow = today.add(Duration(days: 1));
      logger.info('tomorrow message');
      final tomorrowPath = logPath.replaceAll(
          '.log', '-${tomorrow.toIso8601String().split('T')[0]}.log');

      expect(File(todayPath).existsSync(), isTrue);
      expect(File(tomorrowPath).existsSync(), isTrue);
    });

    test('cleans old log files', () {
      final config = {
        'path': logPath,
        'level': 'debug',
        'days': 2, // Keep only 2 days of logs
      };

      final logger = DailyLogger(app, config);

      // Create some old log files
      final now = DateTime.now();
      for (var i = 0; i < 5; i++) {
        final date = now.subtract(Duration(days: i));
        final path = logPath.replaceAll(
            '.log', '-${date.toIso8601String().split('T')[0]}.log');
        File(path).writeAsStringSync('old log $i');
      }

      // Trigger cleanup by writing a new log
      logger.info('new message');

      // Count remaining files
      final files = tempDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      expect(files.length, equals(2)); // Only 2 most recent files should remain
    });

    test('handles file locking', () {
      final config = {
        'path': logPath,
        'level': 'debug',
        'locking': true,
      };

      final logger = DailyLogger(app, config);
      logger.info('test message');

      final date = DateTime.now().toIso8601String().split('T')[0];
      final expectedPath = logPath.replaceAll('.log', '-$date.log');
      final logContent = File(expectedPath).readAsStringSync();
      expect(logContent, contains('test message'));
    });

    test('closes file handle properly', () async {
      final config = {
        'path': logPath,
        'level': 'debug',
      };

      final logger = DailyLogger(app, config);
      logger.info('test message');
      await logger.close();

      final date = DateTime.now().toIso8601String().split('T')[0];
      final expectedPath = logPath.replaceAll('.log', '-$date.log');

      // Should be able to delete file after closing
      expect(() => File(expectedPath).deleteSync(), returnsNormally);
    });

    test('respects log level', () {
      final config = {
        'path': logPath,
        'level': 'error', // Only log error and above
      };

      final logger = DailyLogger(app, config);
      logger.debug('debug message'); // Should not be logged
      logger.info('info message'); // Should not be logged
      logger.error('error message'); // Should be logged
      logger.critical('critical message'); // Should be logged

      final date = DateTime.now().toIso8601String().split('T')[0];
      final expectedPath = logPath.replaceAll('.log', '-$date.log');
      final logContent = File(expectedPath).readAsStringSync();
      expect(logContent, isNot(contains('debug message')));
      expect(logContent, isNot(contains('info message')));
      expect(logContent, contains('error message'));
      expect(logContent, contains('critical message'));
    });
  });
}
