import 'dart:io';

import 'package:platform_log/platform_log.dart';
import 'package:test/test.dart';

import '../utils/mocks.dart';

void main() {
  group('SingleLogger', () {
    late Directory tempDir;
    late MockApplication app;
    late String logPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('single_logger_test_');
      logPath = '${tempDir.path}/test.log';
      app = MockApplication();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('writes log messages to file', () {
      final config = {
        'path': logPath,
        'level': 'debug',
      };

      final logger = SingleLogger(app, config);
      logger.info('test message', {'context': 'value'});

      final logContent = File(logPath).readAsStringSync();
      expect(logContent, contains('[info] test message'));
      expect(logContent, contains('context'));
      expect(logContent, contains('value'));
    });

    test('appends to existing file', () {
      final config = {
        'path': logPath,
        'level': 'debug',
      };

      final logger = SingleLogger(app, config);
      logger.info('first message');
      logger.info('second message');

      final logContent = File(logPath).readAsStringSync();
      expect(logContent, contains('first message'));
      expect(logContent, contains('second message'));
    });

    test('creates directory if not exists', () {
      final nestedPath = '${tempDir.path}/nested/logs/test.log';
      final config = {
        'path': nestedPath,
        'level': 'debug',
      };

      final logger = SingleLogger(app, config);
      logger.info('test message');

      expect(File(nestedPath).existsSync(), isTrue);
      final logContent = File(nestedPath).readAsStringSync();
      expect(logContent, contains('test message'));
    });

    test('respects log level', () {
      final config = {
        'path': logPath,
        'level': 'error', // Only log error and above
      };

      final logger = SingleLogger(app, config);
      logger.debug('debug message'); // Should not be logged
      logger.info('info message'); // Should not be logged
      logger.error('error message'); // Should be logged
      logger.critical('critical message'); // Should be logged

      final logContent = File(logPath).readAsStringSync();
      expect(logContent, isNot(contains('debug message')));
      expect(logContent, isNot(contains('info message')));
      expect(logContent, contains('error message'));
      expect(logContent, contains('critical message'));
    });

    test('handles file locking', () {
      final config = {
        'path': logPath,
        'level': 'debug',
        'locking': true,
      };

      final logger = SingleLogger(app, config);
      logger.info('test message');

      final logContent = File(logPath).readAsStringSync();
      expect(logContent, contains('test message'));
    });

    test('closes file handle properly', () async {
      final config = {
        'path': logPath,
        'level': 'debug',
      };

      final logger = SingleLogger(app, config);
      logger.info('test message');
      await logger.close();

      // Should be able to delete file after closing
      expect(() => File(logPath).deleteSync(), returnsNormally);
    });
  });
}
